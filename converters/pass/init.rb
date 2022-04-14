# encoding: utf-8
#
# RedmineMorePreviews html passthrough
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

RedmineMorePreviews::Converter.register :pass do
  name           'Pass'
  author         'Stephan Wenzel'
  description    'Passthrough HTML'
  version        '1.0.0'
  url            'https://github.com/HugoHasenbein/redmine_more_previews_pass'
  author_url     'https://github.com/HugoHasenbein/redmine_more_previews_pass'
                 
  settings       :logo   => "logo.png"
                 
  mime_types     :html  =>    {:formats => [:html], :mime => "text/html", :icon => "html.png" }
end

require 'pass'