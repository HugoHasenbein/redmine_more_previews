# encoding: utf-8
# frozen_string_literal: true

# Redmine plugin to preview various file types in redmine's preview pane
#
# Copyright © 2018 -2022 Stephan Wenzel <stephan.wenzel@drwpatent.de>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#


require 'fileutils'

module RedmineMorePreviews 
  class Conversion
  
    
    #-------------------------------------------------------------------------------------
    # include libraries
    #-------------------------------------------------------------------------------------
    include Redmine::Utils::Shell
    include RedmineMorePreviews::Lib
    include RedmineMorePreviews::Modules::Shell
    include RedmineMorePreviews::Exceptions
    
    #-------------------------------------------------------------------------------------
    # delegations
    #-------------------------------------------------------------------------------------
    delegate :url_helpers, :to => "Rails.application.routes"
    
    #-------------------------------------------------------------------------------------
    # instance variables
    #-------------------------------------------------------------------------------------
    attr_accessor :id, :name, :threadsafe, :semaphore, :mime_types, :project, :object, 
                  :source, :format, :preview_format, :request, :timeout, :shell_api,
                  :target,    :dir,         :file,        :ext,        :targetpath,
                  :asset,     :assetdir,    :assetfile,   :assetext,   :assetpath,
                  :assets,                                             :assetspaths,
                  :tmptarget, :tmpdir,      :tmpfile,     :tmpext, 
                  :tmpasset,  :tmpassetdir, :tmpassetfile,:tmpassetext,
                  :tmpassetspaths,
                  :settings, :unique_id,
                  :transient, :reload, :unsafe,
                  :version, :plugin_version,
                  :converter, :views, :pub_dir
    
    #-------------------------------------------------------------------------------------
    # initialize
    #-------------------------------------------------------------------------------------
    def initialize(id, options={})
    
      options.symbolize_keys!
      
      self.id             = id.to_s
      self.name           = options[:name].to_s
      self.version        = options[:version].to_s
      self.plugin_version = Redmine::Plugin.registered_plugins[:redmine_more_previews].version
      
      self.converter      = RedmineMorePreviews::Converter.find(id)
      self.views          = converter.path.views
      self.pub_dir        = converter.path.public_directory
      
      self.settings       = options[:settings].presence || {}
      raise ConverterWrongArgument unless settings.is_a?(Hash)
      
      self.threadsafe     = options[:threadsafe].presence || false
      raise ConverterWrongArgument unless [true,false].include?(threadsafe)
      
      self.semaphore      = options[:semaphore].presence
      raise ConverterWrongArgument unless semaphore.is_a?(Mutex) || semaphore.nil?
      
      self.timeout        = options[:timeout].presence
      raise ConverterWrongArgument unless timeout.is_a?(Numeric)
      
      self.shell_api      = options[:shell_api].presence
      raise ConverterWrongArgument unless shell_api.present?
      
      self.mime_types     = options[:mime_types].presence || {}
      raise ConverterWrongArgument unless mime_types.is_a?(Hash)
      
      self.object         = (options[:object].presence || {}).stringify_keys
      self.project        = object['object'].try(:project)
      
      self.unique_id      = case object['type']
      when :attachment
        object['object'].id
      when :repository
        entry = object['object'].try(:entry, object['path'], object['rev'])
        entry.try(:info)
      else
        object['object'].try(:object_id)
      end
      
      self.format         = options[:format].to_s.downcase
      self.preview_format = options[:preview_format].to_s.downcase
      self.request        = options[:request]
      
      # preview 
      self.target         = options[:target]
      
      # should preview asset be served instead of preview
      self.assets         = options[:assets].presence
      self.asset          = options[:asset].presence
      
      # should cache be renewed
       self.reload        = options[:reload].presence || false
      
      # should an unsafe reload be one
       self.unsafe        = options[:unsafe].presence || false
      
      # create path_sets for cache storage
      self.targetpath, self.dir,        self.file,       self.ext      = path_set( target,                :nocreate => true )
      self.assetpath,  self.assetdir,   self.assetfile,  self.assetext = path_set( File.join(dir, asset), :nocreate => true ) if asset
      self.assetspaths = assets.to_a.map{ |ass| path_set( File.join(dir, ass), nil, :nocreate => true )}
    end #def
    
    #-------------------------------------------------------------------------------------
    # lock and unlock, if converter is not thread safe
    #-------------------------------------------------------------------------------------
    def lock;     threadsafe ||               (semaphore && semaphore.lock);      end #def
    def unlock;   threadsafe ||               (semaphore && semaphore.unlock);    end #def
    def try_lock; threadsafe ||               (semaphore && semaphore.try_lock);  end #def
    def locked?;  return false if threadsafe; (semaphore && semaphore.locked?);   end #def
    def owned?;   return true  if threadsafe; (semaphore && semaphore.owned?);    end #def
    def sync(&b); threadsafe ? call.b : (semaphore && semaphore.synchronize(&b)); end #def
    
    #-------------------------------------------------------------------------------------
    # convertible?
    #-------------------------------------------------------------------------------------
    def convertible?(filename)
      @mime_types.keys.include?( File.extname(filename).downcase.to_sym )
    end #def
    
    #-------------------------------------------------------------------------------------
    # source_mime
    #-------------------------------------------------------------------------------------
    def source_mime_ext(options={})
      mime_data = RedmineMorePreviews::Converter.mime( source, options )
      mime_data && mime_data["format"]
    end #ddef
    
    #-------------------------------------------------------------------------------------
    # preview
    #-------------------------------------------------------------------------------------
    def preview(file, options={}, &block)
      
      # transient?
      self.transient = block_given?
      
      # sourcefile, either direct or copied in a tmp dir from elsewhere 
      begin; self.source = file.path; rescue; raise ConverterBadArgument; end
      
      # do conversion
      begin
        if unsafe || transient
          # transient (non-cached) conversion, yielded in block
          sync { transient_preview( &block ) }
        else
          # cached conversion, just read from file
          sync { cached_preview }
        end
      rescue Exception => e
        Rails.logger.error "An error occured while generating preview for #{file.path}"
        Rails.logger.error "Exception was: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        return nil
      end
    end #def
    
    #-------------------------------------------------------------------------------------
    # transient_preview
    #-------------------------------------------------------------------------------------
    def transient_preview( &block )
      Dir.mktmpdir do |tdir|
        files = []
        self.tmptarget, self.tmpdir,     self.tmpfile,     self.tmpext      = path_set(tdir, ["index", preview_format].join("."))
        self.tmpasset,  self.tmpassetdir,self.tmpassetfile,self.tmpassetext = path_set(tmpdir, asset )
        self.tmpassetspaths = assets.to_a.map do |ass|
          path_set( File.join(tmpdir, ass), nil, :nocreate => true )
        end 
        convert
        debug if RedmineMorePreviews::Converter.debug? # debug will overwrite the result of convert
        if block_given?
          result = [tmptarget, tmpasset, tmpassetspaths.map(&:first)].flatten.compact.map do |f|
            File.open(f, "rb") {|io| io.read} if File.exist?( f ) && File.file?( f )
          end
          yield *result
        end
      end
    end #def
    
    #-------------------------------------------------------------------------------------
    # cached_preview
    #-------------------------------------------------------------------------------------
    def cached_preview
      begin; transient_preview{|*files| copy_over}; end if !valid || reload
      read_safe
    end #def
    
    #-------------------------------------------------------------------------------------
    # copy over
    #-------------------------------------------------------------------------------------
    def copy_over
      if File.exist?(tmpdir)
        FileUtils.mkdir_p( dir )
        if semaphore.owned?
          # copy all files.
          # Dir.glob() also produces "." ".."
          # therefore get files and directories with 
          # Dir.children() and reassemble paths
            Dir.children(tmpdir).each do |f|
              FileUtils.copy_entry(File.join(tmpdir,f), File.join(dir,f), true, false, true)
            end
        else 
          semaphore.synchronize do
            Dir.children(tmpdir).each do |f|
              FileUtils.copy_entry(File.join(tmpdir,f), File.join(dir,f), true, false, true)
            end
          end
        end
      end
    end #def
    
    #-------------------------------------------------------------------------------------
    # read safe
    #-------------------------------------------------------------------------------------
    def read_safe
      if asset && File.exist?(assetpath)
        semaphore.owned? ? File.open(assetpath,  "rb") {|io| io.read} : semaphore.synchronize { File.open(assetpath,  "rb") {|io| io.read} }
      elsif target && File.exist?(targetpath)
        semaphore.owned? ? File.open(targetpath, "rb") {|io| io.read} : semaphore.synchronize { File.open(targetpath, "rb") {|io| io.read} }
      else
        nil
      end
    end #def
    
    #-------------------------------------------------------------------------------------
    # check
    #-------------------------------------------------------------------------------------
    def check
      sync{ @status = status }; @status
    end #def
    
    #-------------------------------------------------------------------------------------
    # pathset create path, director
    #-------------------------------------------------------------------------------------
    def path_set( path, filename=nil, **options)
      return [nil, nil, nil, nil] if path.nil?
      raise ConverterBadArgument unless path.present?
      fullpath = filename ? File.join(path, filename) : path
      directory = File.dirname( fullpath )
      raise ConverterBadArgument if directory == File.dirname("")
      FileUtils.mkdir_p( directory ) unless (File.directory?( directory ) || options[:nocreate])
      filename, extension = File.basename( fullpath ), File.extname( fullpath )
      [fullpath, directory, filename, extension]
    end #def
    
    #-------------------------------------------------------------------------------------
    # urls for assets
    #-------------------------------------------------------------------------------------
    def asset_path(asset)
      asset_format = File.extname(asset)
      asset_base   = File.basename(asset, asset_format)
      asset_format.gsub!(/\A\./, "") # remove preceeding dot
      case object['type']
      when :attachment
        url_helpers.more_asset_path(object['object'].id, :asset => asset_base, :assetformat => asset_format)
      when :repository
        ext  = File.extname(object['path'])
        path = File.join(File.dirname(object['path']),File.basename(object['path'], ext))
        ext.gsub!(/\A\./, "") # remove preceeding dot
        url_helpers.url_for(
          :controller    => "repositories", 
          :action        => "more_asset",
          :id            => object['object'].project.identifier,
          :repository_id => object['object'].identifier,
          :rev           => object['rev'],
          :path          => path,
          :baseformat    => ext.gsub(/\A\./, ""), 
          :asset         => asset_base,
          :assetformat   => asset_format,
          :only_path     => true
        )
      end
    end #def
    
    ######################################################################################
    #
    # unix and windows command line helpers
    #
    ######################################################################################
    # move src to tmparget
    def move( src, tgt= tmptarget)
      mv  = Redmine::Platform.mswin? ? "move" : "mv"
      "#{mv} #{shell_quote src} #{shell_quote tgt} "
    end #def
    
    # copy src to tmparget
    def copy( src, tgt= tmptarget)
      cp  = Redmine::Platform.mswin? ? "copy" : "cp"
      "#{cp} #{shell_quote src} #{shell_quote tgt} "
    end #def
    
    # cd to tmpdir
    def cd
      "cd #{shell_quote tmpdir}"
    end #def
    
    # prepend thisdir to filename
    def thisdir( name )
      File.join(".", name)
    end #def
    
    # join two commands in command line
    def join
      Redmine::Platform.mswin? ? " & " : "; "
    end #def
    
    # list files in dir
    def ls( dir )
      Dir.glob(File.join(dir, "*"))
    end #def
    
    # execute command
    def command( cmd, options={})
      unless system(cmd)
        Rails.logger.error("Creating preview with #{name} failed (#{$?}):\nCommand: #{cmd}")
        raise ConverterShellError unless options[:dontfail]
        return false
      end
      true
    end #def
    
    # create outfile name for programs that create conversions having the same basename
    # of the converted file as the input file, f.i. LibreOffice creates a my.html file
    # from a conversion of a my.odt file
    def outfile
      File.basename(source, File.extname(source)) + ".#{preview_format}"
    end #def
    
    def converter_settings
      Setting["plugin_redmine_more_previews"].to_h.dig("converter", id).to_h
    end #def
    
    ######################################################################################
    #
    # helper functios
    #
    ######################################################################################
    def public_web_directory
      converter.public_web_directory
    end #def
    
    def assets_directory
      File.join(public_web_directory, 'assets')
    end #def
    
    def images_directory
      File.join(public_web_directory, 'images')
    end #def
    
    def javascripts_directory
      File.join(public_web_directory, 'javascripts')
    end #def
    
    def stylesheets_directory
      File.join(public_web_directory, 'stylesheets')
    end #def
    
    def javascript_include_tag(rel_path, **options, &block)
      if block_given?
        ApplicationController.helpers.content_tag(:script, :src => [javascripts_directory, rel_path].join('/'), &block)
      else
        ApplicationController.helpers.content_tag(:script, "", :src => [javascripts_directory, rel_path].join('/'))
      end
    end #def
    
    def stylesheet_link_tag(rel_path, **options)
      ApplicationController.helpers.tag(:link, :rel => "stylesheet", :media => 'all', :href => [stylesheets_directory, rel_path].join('/'))
    end #def
    
    ######################################################################################
    #
    # override these methods
    #
    ######################################################################################
    def status
      #
      # child classes should override this method
      #
      # returns :symbol for translation or string and boolean: true: ok, false: not ok
      # ["External Program Name is available (needed for #{@name})", true ]
      # ["External Program Name is not available (needed for #{@name})", false ]
      # if nil is returned, no status is given (f.i. if no external program is needed)
      
      nil
    end #def
    
    def valid
      #
      # child classes should override this method
      #
      # converter is given a chance to invalidate the cached conversion
      # 
      # returns true, if data in cache is valid, else false
      #
      #
      @target && File.exist?(@target)
    end #def
    
    def convert
      #
      # child classes should override this method
      #
      # and convert the source file to a target file with format extension
      #   
      #   @mime_types     (Hash)
      #   @object         (Hash) {:type => :attachment, :object => @attachment}, or 
      #                          {:type => :repository, :object => @repository, :path => @path, :rev => @rev}
      #                          
      #   @project        (Project)  project 
      #   @name           (String)   beautiful name of converter
      #   
      #   @preview_format (String)   "html", "inline", "text" or "pdf"
      #   @source         (String)   path of source file
      #   
      #   --- the following data are just for informational purposes 
      #       do not write to the paths below to stay thread safe
      #       
      #   @target         (String)   full target path
      #   @dir            (String)   target directory of full target path
      #   @file           (String)   target filename of full target path
      #   @ext            (String)   target filename extension of full target path
      #   @asset          (String)   name of preview asset, f.i. an inline image
      #   
      #   --- the following paths belong to your converter -------
      #
      #   @tmptarget      (String)   full tmp target path
      #   @tmpdir         (String)   target directory of full tmp target path
      #   @tmpfile        (String)   target filename of full tmp target path
      #   @tmpext         (String)   target directory of full tmp target path
      #   
      # asset, asset=, assetdir, assetdir=, assetext, assetext=, assetfile, assetfile=, 
      # assets, assets=, cached_preview, cd, check, command, convert, convertible?, 
      # copy_over, dir, dir=, execute, ext, ext=, file, file=, format, format=, id, id=, 
      # join, lock, locked?, mime_types, mime_types=, move, name, name=, object, object=, 
      # outfile, owned?, path_set, preview, preview_format, preview_format=, project, 
      # project=, read_safe, reload, reload=, request, request=, run, semaphore, 
      # semaphore=, settings, settings=, shell_api, shell_api=, source, source=, status, 
      # sync, target, target=, threadsafe, threadsafe=, timeout, timeout=, tmpdir, 
      # tmpdir=, tmpext, tmpext=, tmpfile, tmpfile=, tmptarget, tmptarget=, transient, 
      # transient_preview, transient=, try_lock, unlock, valid
      
      #
      # when here, then do conversion
      #
      debug # we just do debug
      
    end #def
    
    def debug
    
      # create some more data
      @emoji          = asset_path("emoji#{rand(1..5)}.png")
      @tmpdir_content = Dir.glob(File.join(@tmpdir, "*")).to_s
      @dir_content    = Dir.glob(File.join(@dir,    "*")).to_s
      @url            = @request.url
      @rails_root     = Rails.root
      @controller     = request.parameters['controller']
      @action         = request.parameters['action']
      
      case preview_format
      when "html", "inline"
        Dir.glob( File.join(__dir__, 'conversion', "*.png")).each{|f| FileUtils.cp(f,tmpdir)}
        erb  = ERB.new(File.read(File.join(__dir__, 'conversion', 'convert.html.erb')))
        obj  = erb.result(binding).html_safe
        
      when "txt"
        erb  = ERB.new(File.read(File.join(__dir__, 'conversion', 'convert.txt.erb')))
        obj  = erb.result(binding).html_safe
        
      when "pdf" 
        erb  = ERB.new(File.read(File.join(__dir__, 'conversion', 'convert.pdf.erb')))
        obj  = erb.result(binding).html_safe
        
      when "jpg", "jpeg", "gif", "png"
        erb  = ERB.new(File.read(File.join(__dir__, 'conversion', 'convert.pango.erb')))
        erb  = erb.result(binding).html_safe
        obj  = RmpImg.to_img( erb, format)
        
      else
        raise ConverterWrongArgument
      end
      File.open(tmptarget, "wb") {|f| f.write( obj ) }
      
    end #def
    
  end #class
end #module
