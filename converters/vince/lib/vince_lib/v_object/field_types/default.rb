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
    class Default
    
      ####################################################################################
      # shared constants among VObject classes
      ####################################################################################
      unloadable
      
      ####################################################################################
      # includes
      ####################################################################################
      include Modules::Setters
      include Modules::Attributes
      include Modules::Extraction
      include Modules::Filters
      include Modules::Localization
      
      ####################################################################################
      # constants
      ####################################################################################
      FIELDS = [
        :values
      ]
      attr_accessor :name, :parent, :fields, :humanize_proc, :webalize_proc, :readable_proc
      
      LABEL_WIDTH=24
      
      ####################################################################################
      # dynamic method definitions
      ####################################################################################
      def_field(*FIELDS)
      
      ####################################################################################
      # delegations
      ####################################################################################
      delegate :content_tag, :tag, :link_to, :to => "ApplicationController.helpers"
      
      # creates a new Default field instance
      #   - name:   name of field
      #   - parent: name of parent object, i.e. 'vcard', 'vcalendar', etc.
      #   - fields: array of sub fields
      #   - humanize_proc: optional proc to format to humanized format
      #   - webalize_proc: optional proc to format to webalized format
      #
      def initialize(name, parent: nil, fields: nil, humanize_proc: nil, webalize_proc: nil, readable_proc: nil)
        self.name          = name.to_s.downcase.to_sym
        self.parent        = parent
        self.fields        = fields && fields.map{|f| f.to_s.downcase.to_sym}
        self.humanize_proc = humanize_proc
        self.webalize_proc = webalize_proc
        self.readable_proc = readable_proc
      end #def
      
      # returns name and attributes
      #
      def name_and_attributes(**att)
        [name.to_s.upcase, formatted_attributes(**att).presence].compact.join(';')
      end #def
      
      # returns name and fields
      #
      def name_and_fields
        [name] + Array.wrap(fields)
      end #def
      
      # returns values sorted by pref parameter
      #
      def sorted
        values.to_a.sort{|a,b| pref(a,b)}
      end #def
      
      # returns true if any values are present
      #
      #
      def present?
        values.present?
      end #def
      
      # returns value if any values are present, else nil
      #
      #
      def presence
        values.presence
      end #def
      
      #private
      
      # returns the parents class name
      #
      def parent_class_symbol
        parent.class.name.demodulize.downcase.to_sym
      end #def
      
      # ----------------------------------------------------------------------------------
      # arrays with field names
      # ----------------------------------------------------------------------------------
      
      # formats field values as human readable text line(s)
      #
      def humanize_fields
        to_h[name].map do |hash| 
          [ "#{translate(:"#{parent_class_symbol}.#{name.to_s.upcase}")}:",
            if humanize_proc.is_a?(Proc)
              humanize_proc.call(hash,iconize)
            else
              hash[:fields].map{|field, value| "  #{translate(:"#{parent_class_symbol}.#{name.to_s.upcase}_FIELD.#{field}")}:".ljust(LABEL_WIDTH) + "#{value}"}
            end
          ].join("\n")
        end.flatten.compact.join("\n")
      end #def
      
      # formats field values as html
      #
      def webalize_fields(iconize:false)
        to_h[name].map do |hash| 
          content_tag(:p) do
            [ content_tag(:label, translate(:"#{parent_class_symbol}.#{name.to_s.upcase}"), :class => "#{parent_class_symbol} #{name} fields"),
              if webalize_proc.is_a?(Proc)
                webalize_proc.call(hash,iconize)
              else
                hash[:fields].map do |field, value|
                  icon = iconize.presence && "icon icon-#{name}-#{field}"
                  content_tag(:label, "  #{translate(:"#{parent_class_symbol}.#{name.to_s.upcase}_FIELD.#{field}")}:", :class => "#{parent_class_symbol} #{name} field") +
                  content_tag(:span, value, :class => "#{parent_class_symbol} #{name} #{field} #{icon}")
                end.join(tag(:br).html_safe).html_safe
              end
            ].flatten.compact.join(tag(:br).html_safe).html_safe
          end
        end.flatten.compact.join.html_safe
      end #def
      
      # ----------------------------------------------------------------------------------
      # arrays with field names
      # ----------------------------------------------------------------------------------
      
      # formats field values as human readable text line(s)
      #
      def humanize_list
        to_h[name].map do |hash| 
          [ "#{translate(:"#{parent_class_symbol}.#{name.to_s.upcase}")}:",
            if humanize_proc.is_a?(Proc)
              humanize_proc.call(hash,iconize)
            else
              hash[:fields].map{|field, value| "".ljust(LABEL_WIDTH) + "#{value}"}
            end
          ].join("\n")
        end.flatten.compact.join("\n")
      end #def
      
      # formats field values as html
      #
      def webalize_list(iconize:false)
        to_h[name].map do |hash| 
          content_tag(:p) do
            [ content_tag(:label, translate(:"#{parent_class_symbol}.#{name.to_s.upcase}"), :class => "#{parent_class_symbol} #{name} list"),
              if webalize_proc.is_a?(Proc)
                webalize_proc.call(hash,iconize)
              else
                hash[:fields].map do |field, value|
                  icon = iconize.presence && "icon icon-#{name}-#{field}"
                  content_tag(:label, field, :class => "#{parent_class_symbol} #{name} field") +
                  content_tag(:span, value, :class => "#{parent_class_symbol} #{name} #{field} #{icon}")
                end.join(tag(:br).html_safe).html_safe
              end
            ].flatten.compact.join(tag(:br).html_safe).html_safe
          end
        end.flatten.compact.join.html_safe
      end #def
      
      # ----------------------------------------------------------------------------------
      # values
      # ----------------------------------------------------------------------------------
      
      # formats values as human readable text line(s)
      #
      def humanize_value
        to_h[name].map do |hash|
          [  "#{translate(:"#{parent_class_symbol}.#{name.to_s.upcase}")}:".ljust(LABEL_WIDTH),
            if humanize_proc.is_a?(Proc)
              humanize_proc.call(hash,iconize)
            else
              "#{hash[:value]}"
            end
          ].join
        end.join("\n")
      end #def
      
      # formats values as html
      #
      def webalize_value(iconize:false)
        to_h[name].map do |hash|
          content_tag(:p) do
            content_tag(:label, translate(:"#{parent_class_symbol}.#{name.to_s.upcase}"), :class => "#{parent_class_symbol} #{name} value" ) +
            if webalize_proc.is_a?(Proc)
              webalize_proc.call(hash,iconize)
            else
              icon = iconize.presence && "icon icon-#{name}"
              content_tag(:span, hash[:value], :class => "#{parent_class_symbol} #{name} #{icon}")
            end
          end
        end.flatten.compact.join.html_safe
      end #def
      
      # ----------------------------------------------------------------------------------
      # translatable symbols
      # ----------------------------------------------------------------------------------
      
      # formats symbols as human readable text line(s)
      #
      def humanize_symbol
        to_h[name].map do |hash| 
           [ "#{translate(:"#{parent_class_symbol}.#{name.to_s.upcase}")}:".ljust(LABEL_WIDTH),
             if humanize_proc.is_a?(Proc)
               humanize_proc.call(hash,iconize)
             else
               "#{translate(:"#{parent_class_symbol}.#{name.to_s.upcase}_VALUE.#{hash[:symbol]}", :default => hash[:symbol])}"
             end
           ].join
        end.join("\n")
      end #def
      
      # formats symbols as html
      #
      def webalize_symbol(iconize:false)
        to_h[name].map do |hash|
          content_tag(:p) do
            content_tag(:label, translate(:"#{parent_class_symbol}.#{name.to_s.upcase}"), :class => "#{parent_class_symbol} #{name} symbol" ) +
            if webalize_proc.is_a?(Proc)
              webalize_proc.call(hash,iconize)
            else
              icon = iconize.presence && "icon icon-#{name}-#{hash[:symbol].to_s.downcase}"
              content_tag(:span, translate(:"#{parent_class_symbol}.#{name.to_s.upcase}_VALUE.#{hash[:symbol]}", :default => hash[:symbol]), :class => "#{parent_class_symbol} #{name} #{icon}") 
            end
          end
        end.flatten.compact.join.html_safe
      end #def
      
      # ----------------------------------------------------------------------------------
      # translatable symbols and following text fields
      # ----------------------------------------------------------------------------------
      
      # formats field values as human readable text line(s)
      #
      def humanize_symbol_with_list
        to_h[name].map do |hash| 
          [ "#{translate(:"#{parent_class_symbol}.#{name.to_s.upcase}")}:".ljust(LABEL_WIDTH) + 
            translate(:"#{parent_class_symbol}.#{name.to_s.upcase}_VALUE.#{hash[:fields][name]}" ),
            if humanize_proc.is_a?(Proc)
              humanize_proc.call(hash[:fields].except(name))
            else
              hash[:fields].except(name).map do |field, value| 
                "  #{translate(:"#{parent_class_symbol}.#{name.to_s.upcase}_FIELD.#{field}")}:".ljust(LABEL_WIDTH) + value.to_s
              end.join("\n")
            end
          ].join("\n")
        end.flatten.compact.join("\n")
      end #def
      
      # formats field values as html
      #
      def webalize_symbol_with_list(iconize:false)
        to_h[name].map do |hash|
          content_tag(:p) do
            icon = iconize.presence && "icon icon-#{name}-#{hash[:fields][name].to_s.downcase}"
            [ content_tag(:label, translate(:"#{parent_class_symbol}.#{name.to_s.upcase}"), :class => "#{parent_class_symbol} #{name} symbol-with-list") + tag(:br) +
              content_tag(:label, "#{translate(:"#{parent_class_symbol}.#{name.to_s.upcase}_FIELD.#{name}")}: ", :class => "#{parent_class_symbol} #{name} field") +
              content_tag(:span,  translate(:"#{parent_class_symbol}.#{name.to_s.upcase}_VALUE.#{hash[:fields][name]}"), :class => "#{parent_class_symbol} #{name} #{icon}"),
              if webalize_proc.is_a?(Proc)
                webalize_proc.call(hash[:fields].except(name))
              else
                hash[:fields].except(name).map do |field, value|
                  icon = iconize.presence && "icon icon-#{name}-#{field}"
                  content_tag(:label, "#{translate(:"#{parent_class_symbol}.#{name.to_s.upcase}_FIELD.#{field}")}: ", :class => "#{parent_class_symbol} #{name} field") +
                  content_tag(:span, value, :class => "#{parent_class_symbol} #{name} #{icon}")
                end.join(tag(:br).html_safe).html_safe
              end
            ].flatten.compact.join(tag(:br).html_safe).html_safe
          end
        end.flatten.compact.join.html_safe
      end #def
      
      # ----------------------------------------------------------------------------------
      # uris
      # ----------------------------------------------------------------------------------
      
      # formats uris as human readable text line(s)
      #
      def humanize_uri
        to_h[name].map do |hash|
          [ "#{translate(:"#{parent_class_symbol}.#{name.to_s.upcase}")}:".ljust(LABEL_WIDTH),
            if humanize_proc.is_a?(Proc)
              humanize_proc.call(hash,iconize)
            else
              hash[:fields][:full]
            end
          ].join
        end.join("\n")
      end #def
      
      # formats values as html
      #
      def webalize_uri(iconize:false)
        to_h[name].map do |hash| 
          icon = iconize.presence && "icon icon-#{name}"
          
          content_tag(:p) do
            content_tag(:label, translate(:"#{parent_class_symbol}.#{name.to_s.upcase}"), :class => "#{parent_class_symbol} #{name} uri") +
            if webalize_proc.is_a?(Proc)
              webalize_proc.call(hash,iconize)
            else
              if hash[:fields][:scheme].present?
                text = case hash[:fields][:scheme]
                when /http/i, /https/i, /ftp/i
                  hash[:fields][:host].presence || hash[:fields][:path]
                when /tel/i
                  teltype = (hash.dig(:attributes, :TYPE).to_a.map(&:to_s).map(&:downcase) & %w(voice fax text cell video pager textphone)).first
                  icon << "-#{teltype}" if iconize.present? && teltype.present?
                  hash[:fields][:opaque][0..32] 
                when /mailto/i
                  hash[:fields][:opaque][0..32] 
                when /geo/i
                  hash[:fields][:opaque][0..32] 
                else
                  hash[:fields][:scheme]
                end
                content_tag(:span, link_to( text, hash[:fields][:full]), :class => "#{parent_class_symbol} #{name} #{icon}")
                
              elsif hash[:fields][:opaque].present?
                content_tag(:span, hash[:fields][:opaque][0..32], :class => "#{parent_class_symbol} #{name} #{icon}")
                
              else
                content_tag(:span, hash[:fields][:full][0..32], :class => "#{parent_class_symbol} #{name} #{icon}")
              end
            end
          end
        end.flatten.compact.join.html_safe
      end #def
      
    end #module
  end #module
end #module
end