# encoding: utf-8
#
# RedmineMorePreviews converter to preview zip files
#
# Copyright © 2020 Stephan Wenzel <stephan.wenzel@drwpatent.de>
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

require 'rubygems'
require 'zip'
require 'rubygems/package'
require 'zlib'

class Zippy < RedmineMorePreviews::Conversion
  
  ########################################################################################
  #
  # delegates
  #
  ########################################################################################
  delegate :number_to_human_size, :link_to, :to => "ApplicationController.helpers"
  
  ########################################################################################
  #
  # includes
  #
  ########################################################################################
  include RedmineMorePreviews::Lib
  
  ########################################################################################
  #
  # convert
  #
  ########################################################################################
  def convert
    case File.extname( source ).downcase
    when ".zip"
      asset ? zipasset : ziptable 
    when ".tgz"
      asset ? tgzasset : tgztable
    when ".tar"
      asset ? tarasset : tartable
    else
      # nothing
    end #def
  end #def
  
  ########################################################################################
  #
  # tar/tgz files
  #
  ########################################################################################
  def tartable
    File.open(source) do |tarfile|
      tartoc( Gem::Package::TarReader.new( tarfile ))
    end
  end #def
  
  def tarasset
    File.open(source) do |tarfile|
      tarcontent( Gem::Package::TarReader.new( tarfile ))
    end
  end #def
  
  def tgztable
    Zlib::GzipReader.open(source) do |tarfile|
      tartoc( Gem::Package::TarReader.new( tarfile ))
    end
  end #def
  
  def tgzasset
    Zlib::GzipReader.open(source) do |tarfile|
      tarcontent( Gem::Package::TarReader.new( tarfile ))
    end
  end #def
  
  #---------------------------------------------------------------------------------------
  # tartoc
  #---------------------------------------------------------------------------------------
  def tartoc( tarball )
    list = [[I18n.translate(:label_filepath)]]
    tarlist( tarball, "", list)
    html = list.to_html(
        :table_class => "list",
        :headings    => true,
        :cell        => {:class => "description"},
        :html_safe   => true
      )
    File.open(tmptarget, "wt"){|f| f.write html }
  end #def
  
  #---------------------------------------------------------------------------------------
  # tarlist
  #---------------------------------------------------------------------------------------
   def tarlist( tarball, path="", arr=[], level=0 )
    tarball.each do |entry|
      if entry.file?
        arr << [("&nbsp;" * 2 * level + tarlink(entry))]
      elsif entry.directory?
        arr << [("&nbsp;" * 2 * level + "<strong>" + CGI.escapeHTML(File.basename(RmpText.to_utf8(entry.full_name)))) + "</strong>"]
      end
    end
  end #def
  
  #---------------------------------------------------------------------------------------
  # tarlink
  #---------------------------------------------------------------------------------------
  def tarlink( entry, asset=nil )
    path   = URI.parse(request.fullpath).path
    params = request.query_parameters.to_h.symbolize_keys
    uri    = [path, params.
                      merge(:asset => URI::escape(entry.full_name)).
                      compact.
                      map{|k,v| "#{k}=#{v}"}.join("&")
             ].select(&:present?).join("?")
    link_to File.basename(RmpText.to_utf8(entry.full_name)), uri, :download => File.basename(RmpText.to_utf8(entry.full_name))
  end #def
  
  #---------------------------------------------------------------------------------------
  # tarcontent
  #---------------------------------------------------------------------------------------
  def tarcontent( tarball )
    tarball.seek( assetpath ) do |entry|
      FileUtils.mkdir_p(File.dirname(File.join(tmpdir, assetpath )))
      File.open(File.join(tmpdir, assetpath ), "wb") do |f| 
        while( chunk = entry.read(8192)) do
          f.write chunk
        end
      end
    end
  end #def
  
  ########################################################################################
  #
  # zip files
  #
  ########################################################################################
  def ziptable
    Zip::File.open(source)  do |zip_file|
      ziptoc( zip_file )
    end
  end #def
  
  def zipasset
    Zip::File.open(source)  do |zip_file|
      zipcontent( zip_file )
    end
  end #def
  
  #---------------------------------------------------------------------------------------
  # tartoc
  #---------------------------------------------------------------------------------------
  def ziptoc( zip_file )
    list = [[I18n.translate(:label_filename), 
             I18n.translate(:label_filesize), 
             I18n.translate(:label_compressed_filesize)
    ]];
    ziplist( zip_file, "", list )
    html = list.to_html(
      :table_class => "list",
      :headings    => true,
      :cell        => {:class => "description"},
      :html_safe   => true
    )
    File.open(tmptarget, "wt"){|f| f.write html }
  end #def
  
  #---------------------------------------------------------------------------------------
  # ziplist
  #---------------------------------------------------------------------------------------
  def ziplist( zip_file, path="", arr=[], level=0 )
    zip_file.glob(path + '*').each do |entry|
      case entry.ftype
      when :file 
        arr << ["&nbsp;" * 2 * level + ziplink( entry ), 
                number_to_human_size(entry.size), 
                number_to_human_size(entry.compressed_size)
               ]
      when :directory
        arr << ["&nbsp;" * 2 * level + "<strong>" + File.basename(RmpText.to_utf8(entry.name)) + "</strong>", "", ""]
        ziplist( zip_file, RmpText.to_utf8(entry.name), arr, level + 1 )
      end
    end
  end #def
  
  #---------------------------------------------------------------------------------------
  # ziplink
  #---------------------------------------------------------------------------------------
  def ziplink( entry, asset=nil )
    path   = URI.parse(request.fullpath).path
    params = request.query_parameters.to_h.symbolize_keys
    uri    = [path, params.
                      merge(:asset => URI::escape(entry.name)).
                      compact.
                      map{|k,v| "#{k}=#{v}"}.join("&")
             ].select(&:present?).join("?")
    link_to File.basename(RmpText.to_utf8(entry.name)), uri, :download => File.basename(RmpText.to_utf8(entry.name))
  end #def
  
  #---------------------------------------------------------------------------------------
  # zipasset
  #---------------------------------------------------------------------------------------
  def zipcontent( zip_file )
    if entry = zip_file.find_entry(assetpath)
      FileUtils.mkdir_p(File.dirname(File.join(tmpdir, assetpath ))) 
      zip_file.extract( entry, File.join(tmpdir, assetpath ))
    end #def
  end #def
  
end #class
