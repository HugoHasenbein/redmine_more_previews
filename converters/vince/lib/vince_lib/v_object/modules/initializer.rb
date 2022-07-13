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
    module Initializer
    
      ####################################################################################
      # shared constants among VObject classes: requires constants: FIELDS, VERSON, PRODID
      ####################################################################################
      unloadable
      
      ####################################################################################
      # constants
      ####################################################################################
      
      # ----------------------------------------------------------------------------------
      # initializes object
      # can be called with:
      #   - array of arguments [field, value, attributes]
      #   - hash {:field => [value, attributes]}
      #   - a pure block (no args) in which @args and @attributes are available
      #   - a block with self, args, attributes
      #
      def initialize(*args, **attributes, &block)
      
        if block_given?
        
          # pure block
          if block.arity.zero?
            @args=args; @attributes=attributes
            instance_eval(&block)
            
          # block  with self, args, attributes
          else
            yield self, args, attributes
            
          end
          
        else
        
          # array of arguments, each [field, value, attributes]
          if args.first.is_a?(Array)
            args.first.each do |arg|
              if arg.is_a?(Array)
                send(arg.first.to_s.downcase.to_sym, *(arg.from(1))) if self.class::FIELDS.include?(arg.first.to_s.downcase.to_sym)
                send(:x, *arg)                                       if                 arg.first.to_s.downcase =~ /\Ax-/
              end
            end
          end
          
          # hash {:field => [value, attributes]}
          attributes.each do |key, val|
            send(key.to_s.downcase.to_sym, *val) if FIELDS.include?(key.to_s.downcase.to_sym)
            send(:x, *val)                       if                 key.to_s.downcase =~ /\Ax-/
          end
        end
        
      end #def
      
      
      # ----------------------------------------------------------------------------------
      # yields itself
      #
      def with(*args, **attributes, &block)
      
        if block_given?
        
          # pure block
          if block.arity.zero?
            @args=args; @attributes=attributes
            instance_eval(&block)
            
          # block with self, args, attributes
          else
            yield self, args, attributes
            
          end
          
        end
        
      end #def
      
    end #module
  end #module
end #module
end