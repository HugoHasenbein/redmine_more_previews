# encoding: utf-8
#
# RedmineMorePreviews eml converter
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
#       - added timezone support for mail dates in cliff
# 1.0.2
#       - simplified hooks views
# 1.0.3
#       - required files for non eager loading
# 1.1.0
#       - added internationalization for de, en, es, fr, pt, ru, jp, zh
# 1.1.1
#       - fixed japanese localization
#

require_relative 'lib/cliff'
require_relative 'lib/cliff_lib/hooks'

RedmineMorePreviews::Converter.register :cliff do
  name           'Cliff'
  author         'Stephan Wenzel'
  description    'Preview email files in preview pane'
  version        '1.1.1'
  url            'https://github.com/HugoHasenbein/redmine_more_previews_cliff'
  author_url     'https://github.com/HugoHasenbein/redmine_more_previews_cliff'
                 
  settings       :logo    => 'logo.png',
                 :partial => 'settings/redmine_more_previews/cliff/settings'
                 
  mime_types     :eml  =>    {:formats => [:html], :mime => 'message/rfc822', :icon => 'eml.png' },
                 :mime  =>   {:formats => [:html], :mime => 'message/rfc822', :icon => 'eml.png' }
end

