# encoding: utf-8
# frozen_string_literal: true

# Redmine plugin to preview various file types in redmine's preview pane
#
# Copyright © 2018 -2020 Stephan Wenzel <stephan.wenzel@drwpatent.de>
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

require 'nokogiri'
require 'active_support/core_ext/hash/conversions'

module RedmineMorePreviews
  module Lib
    module RmpMeta
      class << self
      
        # ------------------------------------------------------------------------------ #
        # create a token as a safe subdirectory for temporary file storage
        #
        def token
          File.join( "temp", SecureRandom.uuid.to_s )
        end #def
        
        
        # ------------------------------------------------------------------------------ #
        # save( obj(obj), token(string), filename(string), obj_meta(hash) )
        # saves a file to temporary storage
        # token should be world unique
        #
        # obj        object to save
        # token      unique, directory safe identifier, which is used for storage
        # filename   filename (will be sanitized)
        # obj_meta:  optional additional meta data, such as :type (mime)
        #
        def save( obj, token, filename, obj_meta={} )
        
          filepath = safe_file_save( obj, token, filename )
          
          meta     = obj_meta.merge(
            #"filename"          => filename,
            "content_file"      => filepath,
            "local_cache_time"  => DateTime.now.to_s,
            "local_cache_tag"   => SecureRandom.uuid.to_s.gsub(/-/, "_")
          )
          save_file_meta( meta, token, filename )
          
          meta # return enriched meta data
          
        end #def
        
        
        # ------------------------------------------------------------------------------ #
        # read( token(string), filename(string) )
        # returns obj after it reads file from temporary storage
        #
        # token:     unique, directory safe identifier
        # filename   filename (will be sanitized)
        #
        def read( token, filename )
        
          filepath = upload_path( token, filename ) 
          if File.exist?(filepath)
            obj = File.read( filepath )
          end
          
          obj
        end #def
        
        
        # ------------------------------------------------------------------------------ #
        # save_meta( meta(hash), root(string), token(string), filename(string) )
        # saves meta information to temporary storage
        # token should be world unique
        #
        # meta       hash to save
        # root       name of xml root for hash storage
        # token      unique, directory safe identifier, which is used for storage
        # filename   filename (will be sanitized)
        #
        def save_meta( meta, root, token, filename )
        
          xml = obj_to_xml(root, meta).to_xml
          safe_file_save( xml, token, "#{filename}.xml" )
        
        end #def
        
        
        # ------------------------------------------------------------------------------ #
        # read_meta( root(string), token(string), filename(string) )
        # returns file_meta(hash)
        #
        # root       name of xml root
        # token:     unique, directory safe identifier
        # filename   filename (will be sanitized)
        #
        def read_meta( root, token, filename )
          
          if xml = read( token, "#{filename}.xml")
            meta = Hash.from_xml(xml).dig("root", root)
          end
          
          meta
        end #def
        
        
        # ------------------------------------------------------------------------------ #
        # safe_file_save( obj(raw), token )
        # saves file in multi-user environment, where many users may touch/create
        # files at the same time
        #
        # token:   unique, directory safe identifier
        #
        def safe_file_save( obj, token, filename )
          
          filepath = upload_path( token, filename, :createdir => true ) 
          filedir  = File.dirname( filepath )
          tmppath  = filepath + SecureRandom.hex( 10 )
          
          if File.exist?( filedir ) # && !File.exist?( filepath )
            File.open( tmppath, "wb+" ) do |f| 
              f.write( obj ) 
            end #File
            FileUtils.mv( tmppath, filepath, :force => true )
          end #if
          filepath
        end #def
        
        
        # ------------------------------------------------------------------------------ #
        # save_file_meta( file_meta(hash), token(string) )
        # saves file_meta(hash)
        #
        # token:   unique, directory safe identifier
        #
        def save_file_meta( file_meta, token, filename )
        
          save_meta( file_meta, "file_meta", token, filename )
          
        end #def
        
        
        
        # ------------------------------------------------------------------------------ #
        # read_file_meta( token(string) )
        # returns file_meta(hash)
        #
        # token:   unique, directory safe identifier
        #
        def read_file_meta( token, filename )
        
          read_meta( "file_meta", token, filename )
          
        end #def
        
        
        # ------------------------------------------------------------------------------ #
        # purge( token(string) )
        # purge file
        #
        # token:   unique, directory safe identifier
        #
        def purge( token )
          purge_dir = upload_dir(token)
          if File.exist?( purge_dir ) || File.symlink?( purge_dir )
            Rails.logger.info "purging  #{purge_dir}"
            FileUtils.rm_r( purge_dir, :secure => true )
          end
        end #def
        
        # ------------------------------------------------------------------------------ #
        # upload_path 
        # returns path, where file is stored
        #
        # subdir unique, safe subdirectory
        #
        # filename   optional filename
        #
        def upload_path( subdir, filename, options={} )
          ###########################################################
          # sanitize token and join with upload dir                 #
          ###########################################################
          disk_filename = RmpFile.sanitize( filename )
          File.join( upload_dir( subdir, options), disk_filename )
        end #def
        
        # ------------------------------------------------------------------------------ #
        # upload_dir SINGULAR!!!!!!!!
        # returns directory, where files are stored
        #
        # subdir unique, safe subdirectory
        # 
        # options   :create create directory, if it does not exist
        #
        def upload_dir( subdir, options={} )
          sandir = RmpFile.sanitize_subdir( subdir, uploads_dir( options ) )
          upload_dir = File.join( uploads_dir( options ), sandir )
          ###########################################################
          # create directory if it does not exist                   #
          # directory maybe purged from time to time                #
          ###########################################################
          if !!options[:createdir] && !File.exist?( upload_dir )
            FileUtils.mkdir_p upload_dir
          end
          upload_dir
        end #def
        
        # ------------------------------------------------------------------------------ #
        # uploads_dir PLURAL!!!!!!!!
        # returns parent directory, where directories are stored
        #
        # options   :create create directory, if it does not exist
        #
        def uploads_dir( options={} )
          uploads_dir = MORE_PREVIEWS_STORAGE_PATH
          ###########################################################
          # create directory if it does not exist                   #
          # directory maybe purged from time to time                #
          ###########################################################
          if !!options[:createdir] && !File.exist?( uploads_dir )
            FileUtils.mkdir_p uploads_dir
          end
          uploads_dir
        end #def
        
        
        # ------------------------------------------------------------------------------ #
        # obj_to_xml( label, obj, xml=nil )
        # creates xml from an arbitrary nested mixture of arrays and hashes
        #
        def obj_to_xml( label, obj, xml=nil )
        
          if xml
            if obj.is_a?(Array)
              obj.each do |value|
                obj_to_xml(label,value,xml)     # Recurse
              end
            elsif obj.is_a?(Hash)
              if obj.any?
                xml.send(label) do
                  obj.each do |key, value|
                    obj_to_xml(key,value,xml)   # Recurse
                  end
                end
              end
            else
              xml.send(label,obj)               # Create <label>obj(value)</label>
            end #if 
            
          else
            _xml = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
              xml.root do                       # Wrap everything in one element.
               obj_to_xml(label, obj ,xml)      # Start the recursion with a custom name.
              end #_xml
            end #Nokogiri
            
          end #if
          _xml
        end #def 
        
      end #class
    end #module
  end #module
end #module