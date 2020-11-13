# encoding: utf-8
#
# RedmineMorePreviews converter to preview zip files
#
# Copyright © 2020 Stephan Wenzel <stephan.wenzel@drwpatent.de>
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

class Array

  ########################################################################################
  #
  # to_html: creates a html table from a rectangular array
  #
  ########################################################################################
  delegate :content_tag, :to => "ApplicationController.helpers"
  
  def to_html(options={}, &block)
  
    options[:table] = options[:table].to_h.merge({:class => options[:table_class]}.compact) # support legacy
    
    t = dup
          body = t
    head, body = [t.shift, t] if options[:headings]
    foot, body = [t.pop  , t] if options[:footer]
    
    content_tag(:table, options[:table].to_h.compact) do
      [head].compact.table_row_group(options.deep_merge(:row_group => {:type => :thead}, :cell => {:type => :th})) +
        body.compact.table_row_group(options.deep_merge(:row_group => {:type => :tbody}, :cell => {:type => :td})) +
      [foot].compact.table_row_group(options.deep_merge(:row_group => {:type => :tfoot}, :cell => {:type => :td})) 
    end
  end #def
    
  def table_row_group(options={}, &block)
    rows =  collect.with_index do |row, i|
      row.table_row(options, &block)
    end.join("").html_safe
    rows.present? ? content_tag(options.dig(:row_group, :type) || :tbody, rows) : "".html_safe
  end #def
  
  def table_row(options={}, &block)
    content_tag(:tr, options[:row].to_h.compact) do
      row = collect.with_index do |column, i| 
        content_tag(options.dig(:cell, :type) || :td, options[:cell].to_h.except(:type).compact) do
          cell_value = if block_given?
            yield(column, i)
          else
            style_value(column, options)
          end
        end #content_tag #cell_type
      end.join("").html_safe #collect columns
      row
    end #content_tag #tr
  end #def
  
  def style_value(value, options={}, &block)
    case value.class
    when Integer
      value.to_s
    when Numeric
      p = options[:precision] || 2
      sprintf("%.#{p}f",value)
    else
      options[:html_safe] ? value.to_s.html_safe : CGI::escapeHTML(value.to_s)
    end 
  end #def
  
end unless Array.method_defined?(:to_html)
