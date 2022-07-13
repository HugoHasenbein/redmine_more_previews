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
  class VCard
    
    ######################################################################################
    # vCard object
    ######################################################################################
    
    ######################################################################################
    # includes
    ######################################################################################
    include Modules::Initializer
    include Modules::Setters
    include Modules::Escaping
    include Modules::Extraction
    include Modules::Localization
    include Modules::Filters
    
    ######################################################################################
    # includes
    ######################################################################################
    class << self
      delegate :content_tag, :tag, :link_to, :to => "ApplicationController.helpers"
    end
    
    ######################################################################################
    # constants
    ######################################################################################
    NAME    = "VCARD"
    
    VERSION = "4.0"
    
    PRODID  = "-//HBLVOBJECT//DE"
    
    FIELDS  = [
      :version           ,   # MUST
      :prodid            ,   
      
      
      :kind              ,   # individual, organization or group
      :org               ,   
      :n                 ,   # MUST name; first, further, prefix, suffix
      :fn                ,   # MUST, commas must be escaped
      :nickname          ,   
      :gender            ,   
      :bday              ,   
      :anniversary       ,    
      
      :adr               ,   # pobox, ext addr, street, place, region, zip, country, type: dom, intl, postal, parcel, home, work, pref
      :tel               ,   
      :email             ,   
      :impp              ,   
      :url               ,   
      :geo               ,   
      :note              ,   
      
      :lang              ,   
      :role              ,   
      :title             ,   
      
      :logo              ,   
      :photo             ,   
      
      :categories        ,   
      :rev               ,   
      :x                 ,   
      
      # legacy version 3.0 only
      
      :label             ,   # formatted address 
    ]
    
    ######################################################################################
    # variable accessors
    ######################################################################################
    def_field *FIELDS
    
    ######################################################################################
    # aliases to mixed in modules
    ######################################################################################
    
    ######################################################################################
    # methods beyond fields
    ######################################################################################
    def write
      Writer.new(:object => self).write
    end #def
    
    def humanize(fields:nil)
      Writer.new(fields:fields,:object => self).humanize
    end #def
    
    def webalize(fields:nil,iconize: false)
      Writer.new(:object => self).webalize(fields:fields,iconize: iconize)
    end #def
    
    def present?
      FIELDS.any?{|field| send(field).present? }
    end #def
    
    ######################################################################################
    # field formatters
    ######################################################################################
    
    ######################################################################################
    # 6.1 GENERAL PROPERTIES
    ######################################################################################
    
    ######################################################################################
    # source: 
    # rfc6350:6.1.3 SOURCE-param = "VALUE=uri" / pid-param / pref-param / altid-param
    #                           / mediatype-param / any-param
    #               SOURCE-value = URI
    ######################################################################################
    def source(*val, **att)
      if[val,att].all?(&:blank?)
        @source ||= FieldTypes::VUri.new(:source, parent: self)
      else
        source.values(*val, **att)
      end
    end #def
    
    ######################################################################################
    # kind:
    # rfc6530:6.1.4 KIND-param = "VALUE=text" / any-param
    #               KIND-value = "individual" / "group" / "org" / "location"
    #                            / iana-token / x-name
    ######################################################################################
    def kind(*val, **att)
      if[val,att].all?(&:blank?)
        @kind ||= FieldTypes::VSymbol.new(:kind, parent: self)
      else
        kind.values(*val, **att)
      end
    end #def
    
    ######################################################################################
    # xml: 
    # rfc6350:6.1.5 XML-param = "VALUE=text" / altid-param
    #               XML-value = text
    ######################################################################################
    def xml(*val, **att)
      if[val,att].all?(&:blank?)
        @xml ||= FieldTypes::VText.new(:xml, parent: self)
      else
        xml.values(*val, **att)
      end
    end #def
    
    ######################################################################################
    # 6.2 IDENTIFICATION PROPERTIES
    ######################################################################################
    
    ######################################################################################
    # fn:
    # rfc6530:6.2.1 FN-param = "VALUE=text" / type-param / language-param / altid-param
    #                        / pid-param / pref-param / any-param
    #               FN-value = text
    ######################################################################################
    def fn(*val, **att)
      if[val,att].all?(&:blank?)
        @fn ||= FieldTypes::VText.new(:fn, parent: self)
      else
        fn.values(*val, **att)
      end
    end #def
    
    ######################################################################################
    # n:
    # rfc6530:6.2.2 N-param = "VALUE=text" / sort-as-param / language-param
    #                       / altid-param / any-param
    #               N-value = list-component 4(";" list-component)
    ######################################################################################
    N_FIELDS         = [:familyname, :givenname, :addtionalname, :prefix, :suffix]
    
    def n(*val, **att)
      if[val,att].all?(&:blank?)
        @n ||= FieldTypes::VArray.new(:n, parent: self,
          fields: N_FIELDS
        )
      else
        n.values(*val, **att)
      end
    end #def
    
    ######################################################################################
    # nickname:
    # rfc6530:6.2.3 NICKNAME-param = "VALUE=text" / type-param / language-param
    #                              / altid-param / pid-param / pref-param / any-param
    #               NICKNAME-value = text-list
    ######################################################################################
    def nickname(*val, **att)
      if[val,att].all?(&:blank?)
        @nickname ||= FieldTypes::VList.new(:nickname, parent: self)
      else
        nickname.values(*val, **att)
      end
    end #def
    
    ######################################################################################
    # photo:
    # rfc6530: 6.2.4 PHOTO-param = "VALUE=uri" / altid-param / type-param
    #                            / mediatype-param / pref-param / pid-param / any-param
    #                PHOTO-value = URI
    ######################################################################################
    PHOTO_WEBALIZE_PROC = Proc.new do |hash|
      url = case hash[:fields][:scheme]
      when /data/i, /http/i, /https/i
        # this is a reference to a remote image: reassemble uri
        hash[:fields][:full]
      when /file/i
        # this is a reference to a local file
        mime = Marcel::MimeType.for(Pathname.new(filepath), name: File.basename(filepath))
        "data:#{mime};base64,#{Base64.encode64(open(hash[:fields][:path]){|f|f.read})}"
      when nil
        # this is a vcard 3.0 notation
        mime = case hash[:attributes][:TYPE].to_a.first
        when /jpeg/i, /jpg/i, /png/i, /bmp/i, /gif/i, /svg+xml/i, /tiff/i
          "image/#{hash[:attributes][:TYPE].to_a.first}"
        else
          "application/octet-stream"
        end
        "data:#{mime};base64,#{hash[:fields][:path]}"
      end
      tag(:img, src: url, :class => "vcard photo box")
    end #def
    
    PHOTO_HUMANIZE_PROC = Proc.new{|hash| ":-)"}
    
    def photo(*val, **att)
      if[val,att].all?(&:blank?)
        @photo ||= FieldTypes::VUri.new(:photo, parent: self,
          webalize_proc: PHOTO_WEBALIZE_PROC,
          humanize_proc: PHOTO_HUMANIZE_PROC,
          readable_proc: PHOTO_WEBALIZE_PROC
        )
      else
        photo.values(*val, **att)
      end
    end #def
    
    ######################################################################################
    # bday:
    # rfc6530:6.2.4 BDAY-param = BDAY-param-date / BDAY-param-text
    #               BDAY-value = date-and-or-time / text
    #                 ; Value and parameter MUST match.
    #                 
    #               BDAY-param-date = "VALUE=date-and-or-time"
    #               BDAY-param-text = "VALUE=text" / language-param
    #               
    #               BDAY-param =/ altid-param / calscale-param / any-param
    #                 ; calscale-param can only be present when BDAY-value is
    #                 ; date-and-or-time and actually contains a date or date-time.
    ######################################################################################
    BDAY_WEBALIZE_PROC = Proc.new do |hash,iconize|
      icon = iconize.presence && "icon icon-bday"
      content_tag(:span, hash[:readable], :class => "vcard bday #{icon}")
    end
    
    def bday(*val, **att)
      if[val,att].all?(&:blank?)
        @bday ||= FieldTypes::VDateOrTime.new(:bday, parent: self,
          webalize_proc: BDAY_WEBALIZE_PROC
        )
      else
        bday.values(*val, **att)
      end
    end #def
    
    ######################################################################################
    # anniversary:
    # rfc6530:6.2.6 ANNIVERSARY-param = "VALUE=" ("date-and-or-time" / "text")
    #               ANNIVERSARY-value = date-and-or-time / text
    #                 ; Value and parameter MUST match.
    #                 
    #               ANNIVERSARY-param =/ altid-param / calscale-param / any-param
    #                 ; calscale-param can only be present when ANNIVERSARY-value is
    #                 ; date-and-or-time and actually contains a date or date-time.
    ######################################################################################
    ANNIVERSARY_WEBALIZE_PROC = Proc.new do |hash,iconize|
      icon = iconize.presence && "icon icon-anniversary"
      content_tag(:span, hash[:readable], :class => "vcard anniversary #{icon}")
    end
    
    def anniversary(*val, **att)
      if[val,att].all?(&:blank?)
        @anniversary ||= FieldTypes::VDateOrTime.new(:anniversary, parent: self,
          webalize_proc: ANNIVERSARY_WEBALIZE_PROC
        )
      else
        anniversary.values(*val, **att)
      end
    end #def
    
    ######################################################################################
    # gender:
    # rfc6530:6.2.7 GENDER-param = "VALUE=text" / any-param
    #               GENDER-value = sex [";" text]
    #                              sex = "" / "M" / "F" / "O" / "N" / "U"
    ######################################################################################
    GENDER_FIELDS = [:identity]
    
    def gender(*val, **att)
      if[val,att].all?(&:blank?)
        @gender ||= FieldTypes::VSymbolWithList.new(:gender, parent: self, 
          fields: GENDER_FIELDS
        )
      else
        gender.values(*val, **att)
      end
    end #def
    
    
    
    ######################################################################################
    # 6.3 DELIVERY ADDRESSING PROPERTIES
    ######################################################################################
    
    ######################################################################################
    # adr:
    # rfc6530:6.3.1 ADR-param = "VALUE=text" / label-param / language-param
    #                          / geo-parameter / tz-parameter / altid-param / pid-param
    #                          / pref-param / type-param / any-param
    #               ADR-value = ADR-component-pobox ";" ADR-component-ext ";"
    #                           ADR-component-street ";" ADR-component-locality ";"
    #                           ADR-component-region ";" ADR-component-code ";"
    #                           ADR-component-country
    #               ADR-component-pobox    = list-component
    #               ADR-component-ext      = list-component
    #               ADR-component-street   = list-component
    #               ADR-component-locality = list-component
    #               ADR-component-region   = list-component
    #               ADR-component-code     = list-component
    #               ADR-component-country  = list-component
    ######################################################################################
    ADR_FIELDS         = [:pobox, :ext, :street, :locality, :region, :code, :country]
    
    def adr(*val, **att)
      if[val,att].all?(&:blank?)
        @adr ||= FieldTypes::VArray.new(:adr, parent: self,
          fields:        ADR_FIELDS,
        )
      else
        adr.values(*val, **att)
      end
    end #def
    
    
    
    ######################################################################################
    # 6.4 COMMUNICATIONS PROPERTIES
    ######################################################################################
    
    ######################################################################################
    # tel:
    # rfc6530:6.4.1 TEL-param = TEL-text-param / TEL-uri-param
    #               TEL-value = TEL-text-value / TEL-uri-value
    #                 ; Value and parameter MUST match.
    #              
    #               TEL-text-param = "VALUE=text"
    #               TEL-text-value = text
    #              
    #               TEL-uri-param = "VALUE=uri" / mediatype-param
    #               TEL-uri-value = URI
    #              
    #               TEL-param =/ type-param / pid-param / pref-param / altid-param
    #                          / any-param
    #                          
    #               type-param-tel = "text" / "voice" / "fax" / "cell" / "video"
    #                              / "pager" / "textphone" / iana-token / x-name
    #                 ; type-param-tel MUST NOT be used with a property other than TEL.
    ######################################################################################
    def tel(*val, **att)
      if[val,att].all?(&:blank?)
        @tel ||= FieldTypes::VUri.new(:tel, parent: self)
      else
        tel.values(*val, **att)
      end
    end #def
    
    ######################################################################################
    # email:
    # rfc6530:6.4.2 EMAIL-param = "VALUE=text" / pid-param / pref-param / type-param
    #                           / altid-param / any-param
    #               EMAIL-value = text
    ######################################################################################
    EMAIL_WEBALIZE_PROC = Proc.new do |hash,iconize|
      icon = iconize.presence && "icon icon-email"
      link_to(
        hash[:value], 
        "mailto:#{hash[:value]}",
        :class => "vcard email #{icon}"
      )
    end
    
    def email(*val, **att)
      if[val,att].all?(&:blank?)
        @email ||= FieldTypes::VText.new(:email, parent: self,
          webalize_proc: EMAIL_WEBALIZE_PROC
        )
      else
        email.values(*val, **att)
      end
    end #def
    
    ######################################################################################
    # impp:
    # rfc6530:6.4.3 IMPP-param = "VALUE=uri" / pid-param / pref-param / type-param
    #                         / mediatype-param / altid-param / any-param
    #               IMPP-value = URI
    ######################################################################################
    def impp(*val, **att)
      if[val,att].all?(&:blank?)
        @impp ||= FieldTypes::VUri.new(:impp, parent: self)
      else
        impp.values(*val, **att)
      end
    end #def
    
    ######################################################################################
    # lang:
    # rfc6530:6.4.4 LANG-param = "VALUE=language-tag" / pid-param / pref-param
    #                         / altid-param / type-param / any-param
    #               LANG-value = Language-Tag
    ######################################################################################
    def lang(*val, **att)
      if[val,att].all?(&:blank?)
        @lang ||= FieldTypes::VSymbol.new(:lang, parent: self)
      else
        lang.values(*val, **att)
      end
    end #def
    
    
    
    ######################################################################################
    # 6.5 GEOGRAPHICAL PROPERTIES
    ######################################################################################
    
    ######################################################################################
    # tz:
    # rfc6530:6.5.1 TZ-param = "VALUE=" ("text" / "uri" / "utc-offset")
    #               TZ-value = text / URI / utc-offset
    #                 ; Value and parameter MUST match.
    #                 
    #               TZ-param =/ altid-param / pid-param / pref-param / type-param
    #                         / mediatype-param / any-param
    ######################################################################################
    
    ######################################################################################
    # geo:
    # rfc6530:6.5.2 GEO-param = "VALUE=uri" / pid-param / pref-param / type-param
    #                         / mediatype-param / altid-param / any-param
    #               GEO-value = URI
    ######################################################################################
    GEO_WEBALIZE_PROC = Proc.new do |hash,iconize|
      icon = iconize.presence && "icon icon-geo"
      link_to(
        hash[:fields][:opaque], 
        "https://www.google.com/maps/@#{hash[:fields][:opaque]},15z",
        :class => "vcard geo #{icon}"
      )
    end
    
    def geo(*val, **att)
      if[val,att].all?(&:blank?)
        @geo ||= FieldTypes::VUri.new(:geo, parent: self,
          webalize_proc: GEO_WEBALIZE_PROC
        )
      else
        geo.values(*val, **att)
      end
    end #def
    
    
    
    ######################################################################################
    # 6.6.  ORGANIZATIONAL PROPERTIES
    ######################################################################################
    
    ######################################################################################
    # title:
    # rfc6530:6.6.1 TITLE-param = "VALUE=text" / language-param / pid-param
    #                           / pref-param / altid-param / type-param / any-param
    #               TITLE-value = text
    ######################################################################################
    def title(*val, **att)
      if[val,att].all?(&:blank?)
        @title ||= FieldTypes::VText.new(:title, parent: self)
      else
        title.values(*val, **att)
      end
    end #def
    
    ######################################################################################
    # role:
    # rfc6530:6.6.2 ROLE-param = "VALUE=text" / language-param / pid-param / pref-param
    #                          / type-param / altid-param / any-param
    #               ROLE-value = text
    ######################################################################################
    def role(*val, **att)
      if[val,att].all?(&:blank?)
        @role ||= FieldTypes::VText.new(:role, parent: self)
      else
        role.values(*val, **att)
      end
    end #def
    
    ######################################################################################
    # logo:
    # rfc6530:6.6.3 LOGO-param = "VALUE=uri" / language-param / pid-param / pref-param
    #                          / type-param / mediatype-param / altid-param / any-param
    #               LOGO-value = URI
    ######################################################################################
    LOGO_WEBALIZE_PROC = Proc.new do |hash|
      url = case hash[:fields][:scheme]
      when /data/i, /http/i, /https/i
        # this is a reference to a remote image: reassemble uri
        hash[:fields][:full]
      when /file/i
        # this is a reference to a local file
        mime = Marcel::MimeType.for(Pathname.new(filepath), name: File.basename(filepath))
        "data:#{mime};base64,#{Base64.encode64(open(hash[:fields][:path]){|f|f.read})}"
      when nil
        # this is a vcard 3.0 notation
        mime = case hash[:attributes][:TYPE].to_a.first
        when /jpeg/i, /jpg/i, /png/i, /bmp/i, /gif/i, /svg+xml/i, /tiff/i
          "image/#{hash[:attributes][:TYPE].to_a.first}"
        else
          "application/octet-stream"
        end
        "data:#{mime};base64,#{hash[:fields][:path]}"
      end
      tag(:img, src: url, :class => "vcard logo box")
    end #def
    
    LOGO_HUMANIZE_PROC = Proc.new{|hash| "|/|"}
    
    def logo(*val, **att)
      if[val,att].all?(&:blank?)
        @logo ||= FieldTypes::VUri.new(:logo, parent: self,
          webalize_proc: LOGO_WEBALIZE_PROC,
          humanize_proc: LOGO_HUMANIZE_PROC,
          readable_proc: LOGO_WEBALIZE_PROC
        )
      else
        logo.values(*val, **att)
      end
    end #def
    
    ######################################################################################
    # org:
    # rfc6530:6.6.4 ORG-param = "VALUE=text" / sort-as-param / language-param
    #                           / pid-param / pref-param / altid-param / type-param
    #                           / any-param
    #               ORG-value = component *(";" component)
    ######################################################################################
    def org(*val, **att)
      if[val,att].all?(&:blank?)
        @org ||= FieldTypes::VList.new(:org, parent: self)
      else
        org.values(*val, **att)
      end
    end #def
    
    ######################################################################################
    # member:
    # rfc6530:6.6.5 MEMBER-param = "VALUE=uri" / pid-param / pref-param / altid-param
    #                            / mediatype-param / any-param
    #               MEMBER-value = URI
    ######################################################################################
    
    ######################################################################################
    # related:
    # rfc6530:6.6.6 RELATED-param = RELATED-param-uri / RELATED-param-text
    #               RELATED-value = URI / text
    #                 ; Parameter and value MUST match.
    #                 
    #               RELATED-param-uri = "VALUE=uri" / mediatype-param
    #               RELATED-param-text = "VALUE=text" / language-param
    #              
    #               RELATED-param =/ pid-param / pref-param / altid-param / type-param
    #                              / any-param
    #                              
    #               type-param-related = related-type-value *("," related-type-value)
    #                 ; type-param-related MUST NOT be used with a property other than
    #                 ; RELATED.
    #                 
    #               related-type-value = "contact" / "acquaintance" / "friend" / "met"
    #                                  / "co-worker" / "colleague" / "co-resident"
    #                                  / "neighbor" / "child" / "parent"
    #                                  / "sibling" / "spouse" / "kin" / "muse"
    #                                  / "crush" / "date" / "sweetheart" / "me"
    #                                  / "agent" / "emergency"
    ######################################################################################
    
    
    
    ######################################################################################
    # 6.7.  EXPLANATORY PROPERTIES
    ######################################################################################
    
    ######################################################################################
    # categories:
    # rfc6530:6.7.1 CATEGORIES-param = "VALUE=text" / pid-param / pref-param
    #                                / type-param / altid-param / any-param
    #               CATEGORIES-value = text-list
    ######################################################################################
    def categories(*val, **att)
      if[val,att].all?(&:blank?)
        @categories ||= FieldTypes::VList.new(:categories, parent: self)
      else
        categories.values(*val, **att)
      end
    end #def
    
    ######################################################################################
    # note:
    # rfc6530:6.7.2 NOTE-param = "VALUE=text" / language-param / pid-param / pref-param
    #                          / type-param / altid-param / any-param
    #               NOTE-value = text
    ######################################################################################
    def note(*val, **att)
      if[val,att].all?(&:blank?)
        @note ||= FieldTypes::VText.new(:note, parent: self)
      else
        note.values(*val, **att)
      end
    end #def
    
    ######################################################################################
    # prodid:
    # rfc6530:6.7.3 PRODID-param = "VALUE=text" / any-param
    #               PRODID-value = text
    ######################################################################################
    def prodid(*val, **att)
      if[val,att].all?(&:blank?)
        @prodid ||= FieldTypes::VText.new(:prodid, parent: self)
      else
        prodid.values(*val, **att)
      end
    end #def
    
    ######################################################################################
    # rev:
    # rfc6530:6.7.4 REV-param = "VALUE=timestamp" / any-param
    #               REV-value = timestamp
    ######################################################################################
    def rev(*val, **att)
      if[val,att].all?(&:blank?)
        @rev ||= FieldTypes::VTimestamp.new(:rev, parent: self)
      else
        rev.values(*val, **att)
      end
    end #def
    
    ######################################################################################
    # sound:
    # rfc6530:6.7.5 SOUND-param = "VALUE=uri" / language-param / pid-param / pref-param
    #                            / type-param / mediatype-param / altid-param
    #                            / any-param
    #                SOUND-value = URI
    ######################################################################################
    
    ######################################################################################
    # uid:
    # rfc6530:6.7.6 UID-param = UID-uri-param / UID-text-param
    #               UID-value = UID-uri-value / UID-text-value
    #                 ; Value and parameter MUST match.
    #                 
    #               UID-uri-param = "VALUE=uri"
    #               UID-uri-value = URI
    #              
    #               UID-text-param = "VALUE=text"
    #               UID-text-value = text
    #              
    #               UID-param =/ any-param
    ######################################################################################
    
    ######################################################################################
    # clientpidmap: 
    # rfc6350:6.7.7 CLIENTPIDMAP-param = any-param
    #               CLIENTPIDMAP-value = 1*DIGIT ";" URI
    #               
    ######################################################################################
    
    ######################################################################################
    # url:
    # rfc6530 6.7.8 URL-param = "VALUE=uri" / pid-param / pref-param / type-param
    #                        / mediatype-param / altid-param / any-param
    #               URL-value = URI
    ######################################################################################
    def url(*val, **att)
      if[val,att].all?(&:blank?)
        @url ||= FieldTypes::VUri.new(:url, parent: self)
      else
        url.values(*val, **att)
      end
    end #def
    
    ######################################################################################
    # version: 
    # rfc6350:6.7.9 VERSION-param = "VALUE=text" / any-param
    #               VERSION-value = "4.0"
    ######################################################################################
    def version(*val, **att)
      if[val,att].all?(&:blank?)
        @version ||= FieldTypes::VText.new(:version, parent: self)
      else
        version.values(*val, **att)
      end
    end #def
    
    ######################################################################################
    # 6.8.  SECURITY PROPERTIES
    ######################################################################################
    
    ######################################################################################
    # key:
    # rfc6530:6.8.1 KEY-param = KEY-uri-param / KEY-text-param
    #               KEY-value = KEY-uri-value / KEY-text-value
    #                 ; Value and parameter MUST match.
    #                 
    #               KEY-uri-param = "VALUE=uri" / mediatype-param
    #               KEY-uri-value = URI
    #              
    #               KEY-text-param = "VALUE=text"
    #               KEY-text-value = text
    #              
    #               KEY-param =/ altid-param / pid-param / pref-param / type-param
    #                          / any-param
    ######################################################################################
    
    
    
    ######################################################################################
    # 6.9.  CALENDAR PROPERTIES
    ######################################################################################
    
    ######################################################################################
    # fburl:
    # rfc6530:6.9.1 FBURL-param = "VALUE=uri" / pid-param / pref-param / type-param
    #                           / mediatype-param / altid-param / any-param
    #               FBURL-value = URI
    ######################################################################################
    
    ######################################################################################
    # caladruri:
    # rfc6530:6.9.2 CALADRURI-param = "VALUE=uri" / pid-param / pref-param / type-param
    #                               / mediatype-param / altid-param / any-param
    #               CALADRURI-value = URI
    ######################################################################################
    
    ######################################################################################
    # caluri:
    # rfc6530:6.9.3 CALURI-param = "VALUE=uri" / pid-param / pref-param / type-param
    #                            / mediatype-param / altid-param / any-param
    #               CALURI-value = URI
    ######################################################################################
    
    
    
    ######################################################################################
    # 6.10.  Extended Properties and Parameters
    ######################################################################################
    
    ######################################################################################
    #        Legacy Params
    ######################################################################################
    LABEL_WEBALIZE_PROC = Proc.new do |hash,iconize|
      icon = iconize.presence && "icon icon-label"
      content_tag(:span, :class => "vcard label") do
        hash[:value].split("\n").map do |line|
          content_tag(:span, line)
        end.join(tag(:br).html_safe).html_safe
      end
    end
    
    def label(*val, **att)
      if[val,att].all?(&:blank?)
        @label ||= FieldTypes::VText.new(:label, parent: self,
          webalize_proc: LABEL_WEBALIZE_PROC
        )
      else
        label.values(*val, **att)
      end
    end #def
    
  end #class
end #module
end
