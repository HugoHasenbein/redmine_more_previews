# encoding: utf-8
#
# RedmineMorePreviews preview / convert images
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
# 1.0.0
#       - initial version

class Maggie < RedmineMorePreviews::Conversion

  DENSITIES   = [["72", "72"], ["96", "96"], ["144", "144"], ["300", "300"]]
  CONVERT_BIN = (Redmine::Configuration['imagemagick_convert_command'] || 'convert').freeze
    
  def status
    [:text_convert_available, Redmine::Thumbnail.convert_available?]
  end
  
  def convert
    mime_type = Marcel::MimeType.for(Pathname.new(source), name: File.basename(source))
    
    cmd = case mime_type
    when "image/jpeg", "image/png"
      "#{shell_quote CONVERT_BIN} -resample #{get_density}x#{get_density} #{shell_quote source} #{shell_quote "#{preview_format}:#{outfile}"}"
      
    when "image/gif", "image/bmp"
      "#{shell_quote CONVERT_BIN} -density 72x72 #{shell_quote source} -resample #{get_density}x#{get_density} #{shell_quote "#{preview_format}:#{outfile}"}"
    
    when "application/pdf"
      if Redmine::Thumbnail.gs_available?
        "#{shell_quote CONVERT_BIN} -density #{get_density} #{shell_quote "#{source}[0]"} #{shell_quote outfile}"
      else
        copy( source, thisdir(outfile) )
      end
    end
    command( cd + join + cmd + join + move(thisdir(outfile))) if cmd
  end #def
  
  def get_density
    DENSITIES.map{|a| a[1]}.include?(converter_settings['density'] ) ? converter_settings['density'] : "72"
  end #def
  
end #class