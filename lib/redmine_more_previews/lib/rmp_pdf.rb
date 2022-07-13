# encoding: utf-8
# frozen_string_literal: true

# Redmine plugin to preview various file types in redmine's preview pane
#
# Copyright © 2018 -2022 Stephan Wenzel <stephan.wenzel@drwpatent.de>
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

module RedmineMorePreviews
  module Lib
    module RmpPdf
      class << self
        # Returns a PDF string for a converter
        def more_prewiew_to_pdf(locals={})
          pdf = Redmine::Export::PDF::ITCPDF.new(::I18n.locale)
          pdf.set_title("Hello World!")
          pdf.alias_nb_pages
          options = {}
          options[:format] = ::Setting.date_format unless ::Setting.date_format.blank?
          pdf.footer_date = ::I18n.l(User.current.today.to_date, options)
          pdf.add_page
          
          pdf.SetFontStyle('B',11)
          buf = "Hello World!"
          pdf.RDMMultiCell(190, 5, buf)
          
          pdf.SetFontStyle('',8)
          buf  = "You were trying to preview the following object: "
          buf += "#{locals.dig(:@object,'object').try(:class).try(:name)} - #{locals.dig(:@object,'object').try(:id)}"
          pdf.RDMMultiCell(190, 5, buf)
          
          buf  = "The following parameters were available for conversion of the object:"
          pdf.RDMMultiCell(190, 5, buf)
          
          imgfile = "emoji#{rand(1..5)}.png"
          imgpath = File.join(__dir__, "conversion", imgfile)
          atta = Attachment.create(
            :file           =>File.open(imgpath),
            :filename       =>imgfile, 
            :author         =>User.current
          )
          buf  = "<p>random image <img src='#{imgfile}'></p>"
          pdf.RDMwriteFormattedCell(190,5,'','', buf, [atta], 0)
          
          locals.each do |key, value|
            buf = "#{key}: #{value}"
            pdf.RDMMultiCell(190, 5, buf)
          end
          pdf.output
        ensure
          atta.destroy if atta
        end #def
      end #class
    end #module
  end #module
end #module
