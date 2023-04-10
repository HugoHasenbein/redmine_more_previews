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
# 1.0.0
#       - initial version
# 1.0.1
#       - adapted to different tmpfile scheme of Conversion
# 1.0.2
#       - required files for non eager loading
# 1.1.0
#       - added internationalization for de, en, es, fr, pt, ru, jp, zh
# 1.1.1
#       - added fix to Gemfile
# 1.1.2
#       - fixed japanese localization
# 1.1.3  
#       - fixed long standing issue with links in inline zip file content tables

require_relative 'lib/array'
require_relative 'lib/zippy'

RedmineMorePreviews::Converter.register :zippy do
  name           'Zippy'
  author         'Stephan Wenzel'
  description    'Zip Converter'
  version        '1.1.3'
  url            'https://github.com/HugoHasenbein/redmine_more_previews_zippy'
  author_url     'https://github.com/HugoHasenbein/redmine_more_previews_zippy'
                   
  settings       :logo   => "logo.png",
                 :partial => 'settings/redmine_more_previews/zippy/settings'
                 
  mime_types     :zip    => {:formats => [:html, :inline], :mime => "application/zip" },
                 :tar    => {:formats => [:html, :inline], :mime => "application/tar",  :synonyms => ["application/x-tar" ], :icon => "tar.png" },
                 :tgz    => {:formats => [:html, :inline], :mime => "application/gtar", :synonyms => ["application/x-gtar"], :icon => "tgz.png" }
end

