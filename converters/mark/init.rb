# encoding: utf-8
#
# RedmineMorePreviews converter to preview markup text files with pandoc
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
#        - fixed 'File' bug
# 1.0.3
#        - fixed handling filenames with whitespace

RedmineMorePreviews::Converter.register :mark do
  name           'Mark'
  author         'Stephan Wenzel'
  description    'Preview markup text files'
  version        '1.0.3'
  url            'https://github.com/HugoHasenbein/redmine_more_previews_mark'
  author_url     'https://github.com/HugoHasenbein/redmine_more_previews_mark'
                 
  settings       :logo   => "logo.png"
                 
  mime_types     :md      => {:formats => [:html, :inline      ], :mime => "text/markdown",      :icon => "markdown.png" },
                 :textile => {:formats => [:html, :inline      ], :mime => "text/x-web-textile", :icon => "textile.png"  },
                 :html    => {:formats => [:html, :inline, :txt], :mime => "text/html"                                   }
end

require 'mark'