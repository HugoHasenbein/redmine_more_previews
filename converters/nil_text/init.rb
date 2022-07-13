# encoding: utf-8
#
# RedmineMorePreviews empty converter
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
#       - initial version
# 1.0.1
#       - required files for non eager loading
# 1.0.2
#       - fixed japanese localization
#

require_relative 'lib/nil_text'

RedmineMorePreviews::Converter.register :nil_text do
  name           'Nil Text'
  author         'Stephan Wenzel'
  description    'Empty Converter'
  version        '1.0.2'
  url            'https://github.com/HugoHasenbein/redmine_more_previews_nil_text'
  author_url     'https://github.com/HugoHasenbein/redmine_more_previews_nil_text'
                 
  settings       :default => {:example => "12345678"},
                 :partial => 'settings/redmine_more_previews/nil_text/settings',
                 :logo   => "logo.png"
                 
  mime_types     :txt  =>    {:formats => [:html, :inline, :pdf, :jpg, :png, :gif], :mime => "text/plain", :synonyms => [] }
  
end

