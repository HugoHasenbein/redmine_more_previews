# encoding: utf-8
#
# RedmineMorePreviews vcf (electronic business cards) previewer
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

class Vince < RedmineMorePreviews::Conversion
  
  def convert
  
    @vcfs    = VinceLib::VObject::Reader.new(:object => :vcard, :filepath => source).fileall
    @iconize = converter_settings["iconize"].to_i > 0
    
    # create preview
    case preview_format
    
    when "html", "inline"
      erb  = ERB.new(File.read(File.join(views, 'vince', 'vince.html.erb')))
      obj  = I18n.with_locale(Setting.default_language){erb.result(binding).html_safe}.squish
      
    when "txt"
      erb  = ERB.new(File.read(File.join(views, 'vince', 'vince.txt.erb')))
      obj  = I18n.with_locale(Setting.default_language){erb.result(binding).html_safe}.gsub(/\n{3,}/, "\n")
    end
    
    File.open(tmptarget, "wb"){|f| f.write obj}
    
  end #def
  
end #class
