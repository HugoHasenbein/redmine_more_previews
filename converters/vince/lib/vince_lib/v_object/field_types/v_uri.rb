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
  module FieldTypes
    class VUri < Default
    
      # dumps values as vobject formatted line(s)
      #
      def dump
        sorted.map do |val, att|
          [ name_and_attributes(**att),
            get_uri(*val, **att).to_s
          ].join(':')
        end
      end #def
      
      # returns values as hash
      #
      def to_h
        {name => sorted.map do |val, att|
                   {:fields     => get_uri_hash(*val, **att),
                    :attributes => att
                   }
                 end
        }
      end #def
      
      # returns array useful values without label
      #
      def readable
        to_h[name].map do |hash|
          if readable_proc.is_a?(Proc)
            readable_proc.call(hash)
          else
            hash[:fields][:full]
          end
        end
      end #def
      
      # formats values as human readable text line(s)
      #
      def humanize
        humanize_uri
      end #def
      
      # formats values as html
      #
      def webalize(iconize: false)
        webalize_uri(iconize: iconize)
      end #def
      
    end #module
  end #module
end #module
end