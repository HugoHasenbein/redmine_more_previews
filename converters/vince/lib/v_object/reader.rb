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
  class Reader
  
    ######################################################################################
    # reads a vobject file
    ######################################################################################
    unloadable
    
    ######################################################################################
    # includes
    ######################################################################################
    include VObject::Modules::Constants
    include VObject::Modules::Escaping
    include VObject::Modules::Setters
    
    ######################################################################################
    # constants
    ######################################################################################
    
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
    # enumerates over vCard entries in a file
    #
    def fileeach(&block)
      return nil unless object.to_s.upcase.in?(SUPPORTEDOBJECTS.keys)
      obj   = SUPPORTEDOBJECTS[object.to_s.upcase]
      offset=0; vcfs = []
      while(vcf, offset = from_file( offset ); offset)
        if block_given?
          yield obj.new(vcf) if vcf
        elsif vcf
          vcfs << obj.new(vcf)
        end
      end
      vcfs.compact unless block_given?
    end #def
    alias :fileall :fileeach
    
    # ------------------------------------------------------------------------------------
    # enumerates over vCard entries in memory
    #
    def stringeach(&block)
      return nil unless object.to_s.upcase.in?(SUPPORTEDOBJECTS.keys)
      obj = SUPPORTEDOBJECTS[object.to_s.upcase].constantize
      offset=0; vcfs = []
      while(vcf, offset = from_str( string, offset ); offset)
        if block_given?
          yield obj.new(vcf) if vcf
        elsif vcf
          vcfs << obj.new(vcf)
        end
      end
      vcfs.compact unless block_given?
    end #def
    alias :stringall :stringeach
    
    private
    
    # ------------------------------------------------------------------------------------
    # read one vcf set from vCard file
    #
    # returns current position in file
    #
    def from_file( offset=0 )
      return nil unless object.to_s.upcase.in?(SUPPORTEDOBJECTS.keys)
      begun   = false
      pos     = nil
      arr     = []
      bvc     = /\ABEGIN:#{object.to_s.upcase}/in # i case insensitive, n us-ascii encoding
      evc     = /\AEND:#{object.to_s.upcase}/in   # i case insensitive, n us-ascii encoding
      
      # read binary to keep compatibility between platforms
      File.open(filepath, "rb") do |f|
        f.pos = offset
        f.each_line(LINE_LENGTH, :chomp => true) do |line|
          
          pos = f.tell
          case line;when bvc;begun = true; next; when evc;break;end;next unless begun
          
          line.to_utf8!
          case line
          when /\A\ / # beginning of line broken into chunks
            # arr.last[1] should be the 'value' part in the array
            if arr.last.is_a?(Array) && arr.last[1].is_a?(String)
              arr.last[1] << line[1..-1]
            end
          else
            arr << parse(line)
          end 
          
        end
      end
      [arr.presence, pos]
    end #def
    
    # ------------------------------------------------------------------------------------
    # read one vcf set from vCard string
    #
    # caller must provide an array in options as options[:vcf]
    # returns current position in String
    #
    def from_str( str, offset=0, **options )
      return nil unless object.to_s.upcase.in?(SUPPORTEDOBJECTS.keys)
      begun   = false
      pos     = nil
      arr     = []
      charset = options[:charset] || "UTF-8"
      bvc     = Regexp.new /\ABEGIN:#{object.to_s.upcase}/i.to_s.encode(charset)
      evc     = Regexp.new /\AEND:#{object.to_s.upcase}/i.to_s.encode(charset)
      
      StringIO.open(str) do |f|
        f.pos = offset
        f.each_line(LINE_LENGTH, :chomp => true) do |line|
          
          pos = f.tell
          case line;when bvc;begun = true; next; when evc;break;end;next unless begun
          
          line.to_utf8!
          case line
          when /\A\ / # beginning of line broken into chunks
            # options[:vcf].last[1] should be the 'value' part in the array
            if arr.last.is_a?(Array) && arr.last[1].is_a?(String)
              arr.last[1] << line[1..-1]
            end
          else
            arr << parse(line)
          end 
          
        end
      end
      [arr.presence, pos]
    end #def
    
    # ------------------------------------------------------------------------------------
    # splits line into name, value and attributes. values remain unescaped
    #
    def parse( line )
      str, value  = line.split(/\:/, 2)
      name, atts  = str.split(/\:|;/,2)
      attributes  = atts.to_s.split(";").map{|a| a.split("=",2).in_groups_of(2).flatten}.group_by_positions(0).apply(&:flatten)
      [name, value, attributes.symbolize_keys] # symbolize necessary to work with splat operator
    end #def
    
  end #class
end #module