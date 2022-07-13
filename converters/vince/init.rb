# encoding: utf-8
#
# RedmineMorePreviews vcf (electronic business cards) previewer
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
# 1.1.0
#       - added internationalization for de, en, es, fr, pt, ru, ja, zh
#

require_relative 'lib/vince_lib/v_object'
require_relative 'lib/vince'

RedmineMorePreviews::Converter.register :vince do
  name           'Vince'
  author         'Stephan Wenzel'
  description    'Preview VCF in preview pane'
  version        '1.1.0'
  url            'https://github.com/HugoHasenbein/redmine_more_previews_vince'
  author_url     'https://github.com/HugoHasenbein/redmine_more_previews_vince'
                 
  settings       :logo    => "logo.png",
                 :partial => 'settings/redmine_more_previews/vince/settings'
                 
  mime_types     :vcf  =>    {:formats => [:txt, :html, :inline], :mime => "text/vcard", :synonyms => ["text/x-vcard"], :icon => "vcf.png" }
end

