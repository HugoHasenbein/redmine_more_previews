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
  class Printer
    
    ######################################################################################
    # prints a VObject
    ######################################################################################
    unloadable
    
    ######################################################################################
    # delegates
    ######################################################################################
    delegate :content_tag, :tag, :link_to, :to => "ApplicationController.helpers"
    
    ######################################################################################
    # variables
    ######################################################################################
    FIELDS = [
      :object              ,   # object to be printed
      :format              ,   # output format for pretty printing, currently html, text
    ]
    
    # ------------------------------------------------------------------------------------
    # initializes object
    # can be called with:
    #   - hash {:field => val}
    #   - a pure block (no args) in which @args and @attributes are available
    #   - a block with self, args, attributes
    #
    def initialize(*args, **attributes, &block)
    
      # with block
      if block_given?
      
        # pure block
        if block.arity.zero?
          @args=args; @attributes=attributes
          instance_eval(&block)
          
        # block  with self, args, attributes
        else
          yield self, args, attributes
          
        end
      
      # no block
      else
      
        # set object from first argument
        self.object = args.first
        
        # hash {:field => [value, attributes]}
        attributes.each do |key, val|
          try(key.to_s.downcase.to_sym, *val)
        end
        
      end
      
    end #def
    
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
                instance_variable_set("@#{name}", args)
              end
            end
            define_method("#{name}=") do |*args|
              if args.first.nil?
                remove_instance_variable("@#{name}")
              else
               instance_variable_set("@#{name}", args)
              end
            end
          end
        end
      end
    end
    def_field *FIELDS
    
    ######################################################################################
    # attributes handling
    ######################################################################################
    # ------------------------------------------------------------------------------------
    # symbolizes keys in last attributes parameter
    # apparently, rails (ruby) is dependent on symbolized keys for the double splat
    # operator to work reliably
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
    # creates vcf, aliased with to_s
    #
    def to_vcf
      
      vcf = *FIELDS.map do |k|
        instance_variable_get("@#{k}").to_a.map do |argv|
          send("fm_#{k}", *argv) if argv.present?
        end
      end.flatten.compact
      
      vcf.unshift( "BEGIN:VCARD" )
      vcf.push(    "END:VCARD"   )
      
      vcf.map!{|line| chunk(line)}.join("\n").encode("UTF-8", universal_newline: true)
      
    end #def
    alias :to_s :to_vcf
    
    # ------------------------------------------------------------------------------------
    # chunks long string into lines, with first char in following lines being <space>
    #
    def chunk(str, size=75)
      str.scan(/.{1,#{size}}/).join("\n ").encode("UTF-8", universal_newline: true)
    end
    
    # ------------------------------------------------------------------------------------
    # formats attributes
    #
    def attr(key, **att)
      [key.to_s.upcase, att.to_a.map{|k,val| attributize(val).map{|v|"#{k.to_s.upcase}=#{v.squish}"}}].flatten.join(";")
    end #def
    
    # ------------------------------------------------------------------------------------
    # escapes a value from ,;: and \n
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
    
    def esc_str(str)
      str.to_s.to_utf8.
      gsub(/,/, '\,').
      gsub(/;/, '\;').
      gsub(/:/, '\:').
      gsub(/\n/, '\n')
    end #def
    
    def esc_csv(csv,n=nil)
      csv.split(*[/,/, n].compact).map{|s| esc(s)}.join(",")
    end #def
    
    def esc_ssv(csv,n=nil)
      csv.split(*[/;/, n].compact).map{|s| esc(s)}.join(";")
    end #def
    
    # ------------------------------------------------------------------------------------
    # unescapes a string from \,\;\: and \n
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
    
    def unesc_str(str)
      str.to_s.to_utf8.
      gsub(/\\,/, ',').
      gsub(/\\;/, ';').
      gsub(/\\:/, ':').
      gsub(/\\n/, "\n") # last double quote!
    end #def
    
    def unesc_csv(csv,n=nil)
      csv.split(*[/(?<!\\),/, n].compact).map{|s| unesc(s)}.join(",")
    end #def
    
    def unesc_ssv(csv,n=nil)
      csv.split(*[/(?<!\\);/, n].compact).map{|s| unesc(s)}.join(";")
    end #def
    
    # ------------------------------------------------------------------------------------
    # formats field. If no value(s) are provided, then try to fetch values.
    # caveat: in case fields are fetched, then field values are not formatted.
    # some fields need special formatting, such as ADR or N
    #
    def fm(field, *val, **att)
      if val.present?
        chunk([attr(field, **att), val.join(";")].join(":"))
      else
        try(field.to_s.downcase.to_sym).to_a.sort{|a,b| pref( a, b )}.reverse.map do |arr|
          fm( field, *arr ) unless arr.blank? # else blank => endless loop
        end.compact.join("\n").encode("UTF-8", universal_newline: true)
      end
    end #def
    
    # ------------------------------------------------------------------------------------
    # formats value of given field
    #
    def vcf_value(field)
      symfield=field.to_s.downcase.to_sym
      try(symfield).to_a.sort{|a,b| pref( a, b )}.reverse.map do |arr|
        try(:"fm_#{symfield}", arr) || begin
          arrd = arr.dup; att = arrd.extract_options!
          arrd.map{|v| esc(v) }
        end
      end
    end #def
    
    ######################################################################################
    # pretty printer
    ######################################################################################
    def pp(field, *val, **att, &block)
      symfield=field.to_s.downcase.to_sym; upfield=field.to_s.upcase
      unless val.nil?
      
        # format label
        flabelled = print_label(field, **att)
        
        # format value
        formatted = print_field(field, val, **att, &block)
        
        if format.to_s =~ /html|inline/i
          # create tag
          content_tag(:p) do
            content_tag(:label, flabelled) +
            content_tag(:span, formatted.html_safe, :class =>["value", i(field, val, **atts)].compact.join(" "))
          end
        else
          # create tag
          sprintf("%-40s", flabelled) + formatted + "\n"
        end
        
      else
        try(symfield).to_a.sort{|a,b| pref( a, b )}.reverse.map do |arr| 
          pp( field, *arr ) unless arr.first.nil? # else nil => endless loop
        end.compact.join
      end
    end #def
    
    ######################################################################################
    # field printers
    ######################################################################################
    def print_field(field, *val, **atts, &block)
      symfield=field.to_s.downcase.to_sym; upval=val.to_s.upcase
      unless val.nil?
        if block_given?
          yield field, val, atts
        else
          if upval.in?(TRANSLATEVALUES[symfield].to_a)
            translate(:"vcard.#{field.to_s.upcase}_VALUE.#{upval}", default: unesc(val))
          else
            try(:"format_#{symfield}", val, **atts) || unesc(val)
          end
        end
      else
        # fetch and sort by pref parameter, if it exists 
        try(symfield).to_a.sort{|a,b| pref( a, b )}.reverse.map do |arr|
          print_field( field, *arr ) unless arr.first.nil? # else nil => endless loop
        end.compact.join(', ')
      end
    end #def
    
    ######################################################################################
    # label printer
    ######################################################################################
    def print_label(field, *val, **atts)
      upfield=field.to_s.upcase; symfield=field.to_s.downcase.to_sym
      translateparams=TRANSLATEPARAMS[symfield].to_h
        
      # translate field
      ([translate(:"vcard.#{upfield}", :default => field.to_s.humanize )] +
      
      # add type parameters, if applicable
      translateparams.map do |tk,tv|
        atts[tv].to_a.map do |av|
          translate(:"vcard.#{tk}", default: {})[av.to_s.upcase.to_sym]
        end
      end).flatten.compact.uniq.join(", ")
    end #def
    
    ######################################################################################
    # icon printer
    ######################################################################################
    def print_iconcss(field, *val, **atts)
      symfield=field.to_s.downcase.to_sym
      
      # either set css class for translatable values...
      if val.to_s.upcase.in?(TRANSLATEVALUES[symfield].to_a)
        "icon icon-#{symfield}-#{val.to_s.downcase}"
        
      # or set css class for translatable TYPE params...
      elsif symfield.in?(TRANSLATETYPEVALUES.keys)
        atts[:TYPE].to_a.each do |val|
          if val.upcase.in?(TRANSLATETYPEVALUES[symfield])
            return "icon icon-#{symfield}-#{val.downcase}"
          end
        end
        
      # or set css class for fields
      else
        "icon icon-field-#{symfield}"
      end
    end #def
    
    ######################################################################################
    # field filters
    ######################################################################################
    
    #-------------------------------------------------------------------------------------
    # filter fields with optional block providing field, value and attributes
    #
    def select(*fields, &block)
      fields = (fields.presence || FIELDS).map{|field| field.to_s.downcase.to_sym}
      fields.map do |field|
        instance_variable_get("@#{field}").to_a.map do |args|
          if block_given?
            [field.to_s.upcase] + args if yield( *args )
          else
            [field.to_s.upcase] + args
          end
        end.compact
      end.flatten(1).select(&:present?)
    end #def
    
    #-------------------------------------------------------------------------------------
    # select fields matching ALL attributes with optional block providing field, value and attributes
    #
    def select_by_all_attributes(*fields, **atts, &block)
      select(*fields){|*f,**a|  match_hashes(atts, a, &block)}
    end #def
    
    #-------------------------------------------------------------------------------------
    # select fields matching ANY attributes with optional block providing field, value and attributes
    #
    def select_by_any_attribute(*fields, **atts, &block)
      select(*fields){|*f,**a|  share_hashes(atts, a, &block)}
    end #def
    
    #-------------------------------------------------------------------------------------
    # unselect fields matching ALL attributes with optional block providing field, value and attributes
    #
    def unselect_by_all_attributes(*fields, **atts, &block)
      select(*fields){|*f,**a| !match_hashes(atts, a, &block)}
    end#def
    
    #-------------------------------------------------------------------------------------
    # unselect fields matching ANY attributes with optional block providing field, value and attributes
    #
    def unselect_by_any_attribute(*fields, **atts, &block)
      select(*fields){|*f,**a| !share_hashes(atts, a, &block)}
    end#def
    
    #-------------------------------------------------------------------------------------
    # matches if all values in hash1 correspond to hash2 with indifferent access
    # optionally manipulate values with block
    #
    def match_hashes(h1, h2, &block)
      (h1.transform_keys{|k| k.to_s.upcase }.expand.map{|k,v| [k, block_given? ? yield( v ) : v]} - 
       h2.transform_keys{|k| k.to_s.upcase }.expand.map{|k,v| [k, block_given? ? yield( v ) : v]}).blank?
    end #def
    
    #-------------------------------------------------------------------------------------
    # matches if any values in hash1 correspond to hash2 with indifferent access
    # optionally manipulate values with block
    #
    def share_hashes(h1, h2, &block)
      (h1.transform_keys{|k| k.to_s.upcase }.expand.map{|k,v| [k, block_given? ? yield( v ) : v]} & 
       h2.transform_keys{|k| k.to_s.upcase }.expand.map{|k,v| [k, block_given? ? yield( v ) : v]}).present?
    end #def
    
    #-------------------------------------------------------------------------------------
    # compare two fields by PREF attribute for sorting fields by preference
    #
    def pref( arr1, arr2 )
      (arr1.last.is_a?(Hash) ? arr1.last['PREF'].to_a.last.to_i : 0) <=>
      (arr2.last.is_a?(Hash) ? arr2.last['PREF'].to_a.last.to_i : 0)
    end #def
    
    ######################################################################################
    # misc
    ######################################################################################
    #-------------------------------------------------------------------------------------
    # provide language of redmine (not user language)
    #
    def global_lang
      Setting.default_language
    end #def
    
    #-------------------------------------------------------------------------------------
    # translate symbol
    #
    def translate(sym, **att)
      I18n.with_locale(global_lang){I18n.translate(sym, att)}
    end #def
    
  end #class
end #module
