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

module VObject
  class Writer
  
    ######################################################################################
    # writes a vobject file
    ######################################################################################
    unloadable
    
    ######################################################################################
    # constants
    ######################################################################################
    include VObject::Modules::Constants
    include VObject::Modules::Escaping
    include VObject::Modules::Attributes
    include VObject::Modules::Filters
    
    ######################################################################################
    # variables, field setters
    ######################################################################################
    FIELDS  = [
      :filepath          ,   # either filepath to be opened, or...
      :string            ,   # string to be interpreted
      :object            ,   # object name to be read, i.e. "VCARD" or "VCALENDAR"
    ]
    
    # ------------------------------------------------------------------------------------
    # define fields accessors
    #
    class << self
      def def_field(*names)
        class_eval do
          names.each do |name|
            define_method(name) do |*args|
              if args.empty?
                instance_variable_get("@#{name}")
              else
                instance_variable_set("@#{name}", *args)
              end
            end
            define_method("#{name}=") do |*args|
              instance_variable_set("@#{name}", *args)
            end
          end
        end
      end
    end
    def_field *FIELDS
    
    # ------------------------------------------------------------------------------------
    # initializes object
    #
    def initialize(*args, **options, &block)
      if block_given?
        if block.arity.zero?
          @args=args; @options=options
          instance_eval(&block)
        else
          yield self, args, options
        end
      else
        args.each do |arg|
          try(arg.first.to_s.downcase.to_sym, *(arg.from(1))) if arg.is_a?(Array)
        end
        options.each do |key, val|
          try(key.to_s.downcase.to_sym, *val)
        end
      end
    end #def
    
    # ------------------------------------------------------------------------------------
    # creates vobject file, aliased with to_s
    #
    def write
      
      v = object.class::FIELDS.map do |field|
        object.deep_try(field, :dump)
      end.flatten.select(&:present?)
      
      v.unshift( "BEGIN:#{object.class::NAME}" )
      v.push(      "END:#{object.class::NAME}" )
      
      v.map{|line| chunk(line)}.join("\n").encode("UTF-8", universal_newline: true)
      
    end #def
    
    # ------------------------------------------------------------------------------------
    # outputs humanized text
    #
    def humanize(fields: nil)
      
      (fields || object.class::FIELDS).map do |field|
        object.deep_try(field, :humanize)
      end.
      flatten.select(&:present?).
      join("\n").encode("UTF-8", universal_newline: true)
      
    end #def
    
    # ------------------------------------------------------------------------------------
    # outputs html
    #
    def webalize(fields: nil, iconize: false)
      
      (fields || object.class::FIELDS).map do |field|
        object.try(field).try(:webalize, iconize: iconize)
      end.
      flatten.select(&:present?).
      join("\n").encode("UTF-8", universal_newline: true)
      
    end #def
    
    # ------------------------------------------------------------------------------------
    # chunks long string into lines, with first char in following lines being <space>
    #
    def chunk(str, size=75)
      str.scan(/.{1,#{size}}/).join("\n ").encode("UTF-8", universal_newline: true)
    end
    
  end #class
end #module