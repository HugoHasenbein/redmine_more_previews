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
    module Setters
    
      ####################################################################################
      # shared constants among VObject classes
      ####################################################################################
      unloadable
      
      ####################################################################################
      # includes
      ####################################################################################
      include Escaping
      
      ####################################################################################
      # constants
      ####################################################################################
      
      ####################################################################################
      # class extender
      ####################################################################################
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      # ----------------------------------------------------------------------------------
      # symbolizes keys in last attributes parameter.
      # apparently, rails (ruby) is dependent on symbolized keys for the double splat
      # operator to work reliably, therefore we make sure all keys are symbolized
      #
      def symbolize_attributes(*args)
        argd = args.dup; atts = argd.extract_options!
        atts = atts.map{|k,v| [k.to_sym,attributize(v)]}.to_h
        argd << atts
      end #def
      
      # ------------------------------------------------------------------------------------
      # unclutters attributes, which can be Boolean, String and/or Array
      #
      def attributize(val)
        case val
        when String
          val.split(/,/)
        when Array
          val.map{|v| attributize(v) }.flatten
        when NilClass
          []
        else
          [val.to_s]
        end.compact
      end #def
      
      # ------------------------------------------------------------------------------------
      # dumps all variables to hash
      #
      def to_h
        self.class::FIELDS.map do |field|
          [field, send(field)]
        end.to_h
      end #def
      
      # ------------------------------------------------------------------------------------
      # supplies variable value if arguments are empty and calls the calling method again
      #
      def arg_or_var(field, *val, **att, &block)
        if [val,att].all?(&:blank?)
          from = caller_locations(1,1)[0].label
          Array.wrap(send(field)).map{|v| v.presence && send(from, *v) } # *v will also contain **attributes
        else
          yield val + [att]
        end
      end #def
      
      ####################################################################################
      # class methods
      ####################################################################################
      module ClassMethods
      
        def def_field(*names)
          class_eval do
            names.each do |name|
              define_method(name) do |*args|
                if args.empty?
                  instance_variable_get("@#{name}")
                else
                  if instance_variable_get("@#{name}")
                    instance_variable_set("@#{name}", Array.wrap(instance_variable_get("@#{name}")))
                    instance_variable_get("@#{name}") << symbolize_attributes(*args)
                  else
                    instance_variable_set("@#{name}", [symbolize_attributes(*args)])
                  end
                end
              end
              define_method("#{name}=") do |*args|
                if args.first.nil?
                  remove_instance_variable("@#{name}")
                else
                 instance_variable_set("@#{name}", symbolize_attributes(*args))
                end
              end
            end
          end
        end
      end #def
      
    end #module
  end #module
end #module
end