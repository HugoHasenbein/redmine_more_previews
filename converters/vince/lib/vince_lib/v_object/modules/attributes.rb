# encoding: utf-8
#
# RedmineMorePreviews vcf (electronic business cards) previewer
#
# Copyright © 2021 Stephan Wenzel <stephan.wenzel@drwpatent.de>
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
module VinceLib

module VObject 
  module Modules
    module Attributes
    
    # ------------------------------------------------------------------------------------
    # formats attributes
    #
    def formatted_attributes(**att)
      att.map do |key,val|
        vals = attribute_values(val); t,f,o = [vals & [true], vals & [false], vals - [true,false]]
        f.blank? &&
        ((o.presence && "#{key.to_s.upcase}=#{o.join(',')}") || 
         (t.presence && key.to_s.upcase))
      end.select(&:present?).join(";")
    end #def
    
    # ------------------------------------------------------------------------------------
    # unclutters attribute values, which can be Boolean, String and/or Array
    #
    def attribute_values(val)
      case val
      when String
        val.split(/,/)
      when Array
        val.map{|v| attribute_values(v) }.flatten
      when TrueClass, FalseClass
        [val]
      when NilClass
        []
      else
        [val.to_s]
      end.select{|v| v.present? || v == false}.uniq
    end #def
    
    end #module
  end #module
end #module
end