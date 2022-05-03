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

module VCard
  class AddressFormatter
    
    ######################################################################################
    # delegations
    ######################################################################################
    delegate :content_tag,        :to => "ApplicationController.helpers"
    
    ######################################################################################
    # constants
    ######################################################################################
    VERSION = "0.0.1"
    
    FIELDS = [
      :givenname            ,   # field from n-field
      :familyname           ,   # field from n-field
      :prefix               ,   # field from n-field
      :suffix               ,   # field from n-field
      :additionalname       ,   # field from n-field
      
      :gender               ,   # field from gender-field
      
      :postbox              ,   # field from adr-field
      :department           ,   # field from adr-field
      :street               ,   # field from adr-field
      :city                 ,   # field from adr-field
      :region               ,   # field from adr-field
      :postalcode           ,   # field from adr-field
      :country_name         ,   # field from adr-field
    ]
    
    INTERNALS = [
      :project              ,   # project
      :type                 ,   # type of desired address
      :format               ,   # format of desired address
      
      :cr                   ,   # separator 
      
      :recipient            ,   # used internally
      :iso_country          ,   # used internally
      :country              ,   # used internally
      :local_country_code   ,   # used internally
      :local_iso_country    ,   # used internally
      :local_country        ,   # used internally
      
      :version                  # version number
    ]
    
    DELIMITERS = {
      :text     => "\n"     ,
      :line     => ", "     ,
      :html     => "<br/>"  ,
      :htmlline => ", "     ,
      :table    => ""
    }
    
    # ------------------------------------------------------------------------------------
    # initialize instance
    #
    def initialize(attr={}, options={}, &block)
      
      attr.symbolize_keys.each do |k,v|
        send(k, v) if FIELDS.include?(k)
      end
      
      options.symbolize_keys.each do |k,v|
        send(k, v) if INTERNALS.include?(k)
      end
      
      # set defaults 
      self.format             ||= :text
      self.type               ||= :letter
      self.cr                 ||= DELIMITERS[format] || ", "
      
      self.locale             ||= "en"
      
      self.local_country_code ||= "US"
      self.local_iso_country    = ISO3166::Country.new(local_country_code)
      self.local_country        = local_iso_country.translation(local_country_code)
      
      self.country_code       ||= "US"
      self.iso_country          = ISO3166::Country.new(country_code)
      self.country              = (country_relative(country_code, local_country_code) && iso_country.translation(locale)) if iso_country
      
      self.version VERSION
      
      if block_given?
        if block.arity.zero?
          instance_eval(&block)
        else
          yield self
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
                if instance_variable_get("@#{name}")
                  instance_variable_get("@#{name}").concat(args)
                else
                  instance_variable_set("@#{name}", args.first.presence)
                end
              end
            end
            define_method("#{name}=") do |*args|
              instance_variable_set("@#{name}", *args)
            end
          end
        end
      end #def
    end #class
    def_field *FIELDS
    def_field *INTERNALS
    
    #-------------------------------------------------------------------------------------
    # reveal own attributes
    #
    def attributes
      FIELDS.map do |field|
        [field, send(field)]
      end.to_h
    end #def
    
    def attribute_names
      FIELDS.map(&:to_s)
    end #def
    
    #-------------------------------------------------------------------------------------
    #
    # format address: 
    #
    # options:
    #             :type                which type of address
    #                                  :letter    letter address with simple name
    #                                  :official  letter address with full name
    #                                  :all       letter address and media
    #                                  :address   address only
    #                                  
    #             :format              :text, :line, :html, :htmlline, :table
    #              
    #             :locale              locale for country name translation
    #             
    def format_address
      case format 
      when :text, :line
        build( filter(address_array) )
      when :html, :htmlline
        build( filter(address_array), rowglue: "<br/>" ).html_safe 
      when :table
        filter(address_array)
      end
    end #def
    
    
    
    #-------------------------------------------------------------------------------------
    # media array
    #
    def media_array
      arr = case format
      when :text, :line
        [ phone.presence &&  ["📞 #{phone}" ],
          mobile.presence && ["📱 #{mobile}"],
          fax.presence &&    ["📠 #{fax}"   ],
          email.presence &&  ["📧 #{email}" ],
          url.presence &&    ["🌍 #{url}"   ]
        ].compact.join(cr).html_safe
        
      when :html, :htmlline
        [ phone.presence &&  [phone_e164.present?  ? content_tag(:a, "📞 " + phone,  :href => "tel:#{phone_e164}")   : content_tag(:span, "📞 " + phone)  ],
          mobile.presence && [mobile_e164.present? ? content_tag(:a, "📱 " + mobile, :href => "tel:#{mobile_e164}")  : content_tag(:span, "📞 " + mobile) ],
          fax.presence &&    [fax_e164.present?    ? content_tag(:a, "📠 " + fax,    :href => "tel:#{fax_e164}")     : content_tag(:span, "📞 " + fax)    ],
          email.presence &&  [email.present?       ? content_tag(:a, "📧 " + email,  :href => "mailto:#{email}")     : nil ],
          url.presence &&    [url.present?         ? content_tag(:a, "🌍 " + url,    :href => url)                   : nil ]
        ].compact.join(cr).html_safe
        
      else #table
        [ phone.presence &&  ["#{::I18n.translate(:"business_address.phone" )}: #{phone}" ],
          mobile.presence && ["#{::I18n.translate(:"business_address.mobile")}: #{mobile}"],
          fax.presence &&    ["#{::I18n.translate(:"business_address.fax"   )}: #{fax}"   ],
          email.presence &&  ["#{::I18n.translate(:"business_address.email" )}: #{email}" ],
          url.presence &&    ["#{::I18n.translate(:"business_address.url"   )}: #{url}"   ]
        ].compact
      end
    end #def
    
    
   #######################################################################################
   # private
   #######################################################################################
   #private
    
    #-------------------------------------------------------------------------------------
    # returns two-dimensional address array, address arranged by country custom
    #
    def address_array
      address_format = case type
      when :all, :letter, :address, :official
        iso_country.address_format.presence if iso_country
      else
        nil
      end || "{{recipient}}\n{{street}}\n{{postalcode}} {{city}}\n{{region}}\n{{country}}"
      format_to_ruby(address_format)
    end #def
    
    #-------------------------------------------------------------------------------------
    # converts Country Gems address format string to evaluable array string
    # 
    # i.e. "{{recipient}}\n{{street}}\n{{postalcode}} {{city}}\n{{region}}\n{{country}}" 
    #      "[[{#recipient}], [#{street}], [#{postalcode}, #{city}], [{#region}, #{country}]]"
    #
    FORMAT_SUBSTITUTIONS = {
      '{{' => '#{',
      '}}' => '} ', # add extra space
    }
    def format_to_ruby(format_string)
      # work on string copy
      fmt = format_string.dup
      
      # replace curly brackets
      FORMAT_SUBSTITUTIONS.each{|pat, repl| fmt.gsub! pat, repl}
      
      # split lines to array
      fmt.split(/\n/).map{|line| line.split(/\s+/).map{|el| eval('"' + el + '"') }}
    end #def
    
    #-------------------------------------------------------------------------------------
    # filters empty strings from a one- or two-dimensional array 
    #
    def build( object, lineglue: " ", rowglue: cr )
      built = case object
      when Array
        if object.any?{|obj| obj.is_a?(Array)}
          object.map{|obj| build(obj) }.join(rowglue)
        else
          escape( object.join(lineglue) )
        end
      else
        escape( object )
      end
      built.to_s.html_safe
    end #def
    
    def filter( object )
      case object
      when Array
        object.select(&:present?).map{|o| filter( o ) }.compact.presence
      else
        object.presence
      end
    end #def
    
    #-------------------------------------------------------------------------------------
    # escapes string to make it html-safe
    #
    def escape( str )
      return str unless str.is_a?(String)
      str.html_safe ? str : CGI::escapeHTML(str.squish)
    end #def
    
    #-------------------------------------------------------------------------------------
    # returns recipient and department
    #
    def recipient
      case type
      when :letter
        # one liner: short name, department
        build( filter( [[first_name, name], [department]] ), rowglue: cr)
      when :all, :official
        # two liner: full name \n department
        filter( [[prefix, first_name, name, suffix], [department]] )
      else
        nil
      end #case
    end #def
    
    #-------------------------------------------------------------------------------------
    # returns country, unless two countries are the same
    #
    def country_relative( country_code, local_country_code)
      return country_code unless country_code == local_country_code
    end #def
    
    #-------------------------------------------------------------------------------------
    # checks if URL is valid
    #
    def valid_url?(url)
      uri = URI.parse(url.to_s)
      uri.host.present?
    rescue URI::InvalidURIError
      false
    end #def
    
    #-------------------------------------------------------------------------------------
    # normalizes phone number to international format
    #
    def normalize( number )
       dc = Phony[iso_country.country_code].clean(number) #iso_country.country_code is phone number code
       Phony[iso_country.country_code].plausible?(dc) ? Phony.format(Phony[iso_country.country_code].normalize(dc), type: :local) : number
    rescue Phony::NormalizationError => e
      Rails.logger.info ([e.message] + e.backtrace).join("\n")
      number
    end #def
    
  end #module
end #module
