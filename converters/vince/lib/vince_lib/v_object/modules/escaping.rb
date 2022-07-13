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
    module Escaping
    
      ####################################################################################
      # escapes and unescapes objects
      ####################################################################################
      unloadable
      
      ####################################################################################
      # constants
      ####################################################################################
      
      # ----------------------------------------------------------------------------------
      # escapes an object e from ,;: and \n
      #
      def esc(obj)
        case obj
        when Array
          obj.map{|s| esc(s)}
        when Hash
          obj.map{|k,v| [k,esc(v)]}.to_h
        when String
          esc_str(obj)
        else
          esc(obj.to_s)
        end
      end #def
      
      # ----------------------------------------------------------------------------------
      # escapes a string value from ,;: and \n
      #
      def esc_str(str)
        str.to_s.to_utf8.
        gsub(/,/, '\,').
        gsub(/;/, '\;').
        gsub(/:/, '\:').
        gsub(/\n/, '\n')
      end #def
      
      # ----------------------------------------------------------------------------------
      # escapes an array from ,;: and \n and concatenates to a string with comma
      #
      def esc_arr_to_csv(arr)
        esc(arr).join(",")
      end #def
      
      # ----------------------------------------------------------------------------------
      # escapes an array from ,;: and \n and concatenates to a string with semicolon
      #
      def esc_arr_to_ssv(arr)
        esc(arr).join(";")
      end #def
      
      # ----------------------------------------------------------------------------------
      # unescapes an object e from ,;: and \n
      #
      def unesc(obj)
        case obj
        when Array
          obj.map{|s| unesc(s)}
        when Hash
          obj.map{|k,v| [k,unesc(v)]}.to_h
        when String
          unesc_str(obj)
        else
          unesc(obj.to_s)
        end
      end #def
      
      # ----------------------------------------------------------------------------------
      # unescapes a string value from \,\;\: and \n
      #
      def unesc_str(str)
        str.to_s.to_utf8.
        gsub(/\\,/, ',').
        gsub(/\\;/, ';').
        gsub(/\\:/, ':').
        gsub(/\\n/, "\n") # last double quote!
      end #def
      
      # ----------------------------------------------------------------------------------
      # unescapes a string value with comma separated values from ,;: and \n and returns array
      #
      def unesc_csv_to_arr(csv,n=nil)
        csv.split(*[/(?<!\\),/, n].compact).map{|s| unesc(s)}
      end #def
      
      # ----------------------------------------------------------------------------------
      # unescapes a string value with semicolon separated values from ,;: and \n and returns array
      #
      def unesc_ssv_to_arr(ssv,n=nil)
Rails.logger.info ssv
        ssv.split(*[/(?<!\\);/, n].compact).map{|s| unesc(s)}
      end #def
      
    end #module
  end #module
end #module
end