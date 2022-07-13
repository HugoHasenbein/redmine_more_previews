# encoding: utf-8
#
# RedmineMorePreviews converter to preview office files with LibreOffice
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
# 1.0.0
#        - initial version
# 1.0.1 
#        - removed UserInstallation param for Windows
# 1.0.2
#        - required files for non eager loading
# 1.1.0
#       - added internationalization for de, en, es, fr, pt, ru, jp, zh
# 1.1.1
#       - fixed japanese localization
##

require_relative 'lib/libre'

RedmineMorePreviews::Converter.register :libre do
  name           'Libre'
  author         'Stephan Wenzel'
  description    'Preview office files with LibreOffice'
  version        '1.1.1'
  url            'https://github.com/HugoHasenbein/redmine_more_previews_libre'
  author_url     'https://github.com/HugoHasenbein/redmine_more_previews_libre'
                 
  settings       :logo   => "logo.png",
                 :partial => 'settings/redmine_more_previews/libre/settings'
  
  mime_types(
    :csv  => {:formats => [:html,       :pdf, :png, :jpg], :mime => "text/csv"},
    :doc  => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/msword", :synonyms => ["application/vnd.ms-word"], :icon => "doc.png"},
    :docm => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/vnd.ms-word.document.macroenabled.12"},
    :docx => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/vnd.openxmlformats-officedocument.wordprocessingml.document", :icon => "docx.png"},
    :dotm => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/vnd.ms-word.template.macroenabled.12"},
    :dotx => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/vnd.openxmlformats-officedocument.wordprocessingml.template"},
    :fodg => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/vnd.oasis.opendocument.graphics-flat-xml"},
    :fodp => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/vnd.oasis.opendocument.presentation-flat-xml"},
    :fods => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/vnd.oasis.opendocument.spreadsheet-flat-xml"},
    :fodt => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/vnd.oasis.opendocument.text-flat-xml"},
    :odb  => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/vnd.sun.xml.base"},
    :odc  => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/vnd.oasis.opendocument.chart"},
    :odf  => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/vnd.oasis.opendocument.formula", :icon => "odf.png"},
    :odg  => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/vnd.oasis.opendocument.graphics", :icon => "odg.png"},
    :odi  => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/vnd.oasis.opendocument.image", :icon => "odi.png"},
    :odm  => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/vnd.oasis.opendocument.text-master"},
    :odp  => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/vnd.oasis.opendocument.presentation"},
    :ods  => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/vnd.oasis.opendocument.spreadsheet", :icon => "ods.png"},
    :odt  => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/vnd.oasis.opendocument.text"},
    :otg  => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/vnd.oasis.opendocument.graphics-template"},
    :oth  => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/vnd.oasis.opendocument.text-web"},
    :otp  => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/vnd.oasis.opendocument.presentation-template"},
    :ots  => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/vnd.oasis.opendocument.spreadsheet-template"},
    :ott  => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/vnd.oasis.opendocument.text-template"},
    :oxt  => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/vnd.openofficeorg.extension"},
    :potm => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/vnd.ms-powerpoint.template.macroenabled.12"},
    :potx => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/vnd.openxmlformats-officedocument.presentationml.template"},
    :ppt  => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/mspowerpoint"},
    :pptm => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/vnd.ms-powerpoint.presentation.macroenabled.12"},
    :pptx => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/vnd.openxmlformats-officedocument.presentationml.presentation"},
    :rtf  => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/rtf"},
    :sda  => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/vnd.stardivision.draw"},
    :sdc  => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/vnd.stardivision.calc"},
    :sdd  => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/vnd.stardivision.impress"},
    :sdp  => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/vnd.stardivision.impress"},
    :sds  => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/vnd.stardivision.chart"},
    :sdw  => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/vnd.stardivision.writer"},
    :sgl  => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/vnd.stardivision.writer-global"},
    :smf  => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/vnd.stardivision.math"},
    :stc  => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/vnd.sun.xml.calc.template"},
    :std  => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/vnd.sun.xml.draw.template"},
    :sti  => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/vnd.sun.xml.impress.template"},
    :stw  => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/vnd.sun.xml.writer.template"},
    :sxc  => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/vnd.sun.xml.calc"},
    :sxd  => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/vnd.sun.xml.draw"},
    :sxg  => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/vnd.sun.xml.writer.global"},
    :sxi  => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/vnd.sun.xml.impress"},
    :sxm  => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/vnd.sun.xml.math"},
    :sxw  => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/vnd.sun.xml.writer"},
    :vor  => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/vnd.stardivision.writer"},
    :xls  => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/msexcel", :synonyms => ["application/vnd.ms-excel"], :icon => "xls.png"},
    :xlsm => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/vnd.ms-excel.sheet.macroenabled.12"},
    :xlsx => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", :icon => "xlsx.png"},
    :xltm => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/vnd.ms-excel.template.macroenabled.12"},
    :xltx => {:formats => [:html, :txt, :pdf, :png, :jpg], :mime => "application/vnd.openxmlformats-officedocument.spreadsheetml.template"},
  )
  
  # 
  # see, which other conversions libreoffice can do:
  #
  # https://cgit.freedesktop.org/libreoffice/core/tree/filter/source/config/fragments/filters
  #
  
end

