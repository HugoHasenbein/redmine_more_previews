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
# 1.0.4
#        -support redmine 4
#        
# 2.0.0  
#        - recoded Redmine Preview Office and renamed; now supports own plugins 
#        
# 2.0.1  
#        - fixed last minute issues
#        
# 2.0.2  
#        - fixed virgin startup bug. On some events plugin crashes on first time use
#        - removed UserInstallation parameter in libre for windows platforms
#        - fixed missing assets bug
# 2.0.3  
#        - fixed windows glitch for File.read
# 2.0.4  
#        - fixed dependency on mimemagick after license change
# 2.0.5  
#        - fixed dependency on mimemagick after license change
# 2.0.6  
#        - added timezone support for mail dates in cliff
# 2.0.7  
#        - added support for non-ascii email headers in cliff
# 2.0.8  
#        - fixed tmpfile scheme (internals)
# 2.0.9  
#        - simplified hooks views for cliff
# 2.0.10 
#        - fixed broken api calls for attachment
# 2.0.11 
#        - amended autoload paths
# 3.0.0b 
#        - rearranged code and files to better match zeitwerk
#        - made compatible with development mode
#        - beta quality
# 3.0.1  
#        - fixed 'File' bug for converter 'mark'
# 3.0.2  
#        - added converter named 'pass'
# 3.0.3  
#        - fixed handling filenames with whitespace for converter 'mark'
# 3.1.0  
#        - improved rendering of conversions to images
#        - added new converter Maggie, which converts images to one another
#        - updated nil text comments
# 3.1.1  
#        - added fix to zippy's Gemfile
# 3.1.2  
#        - minor code additions
# 3.2.0  
#        - added new previewer "vince" to preview vcf virtual business cards
# 4.0.0a 
#        - switched to patching existing redmine classes with 'prepend' instead of an 
#          alias chain, therefore loosing compatibility with redmine versions less 
#          than 4.0. Due to many redmine plugins now using the prepend method, introduced 
#          with Rails 5, the coexistence of 'prepend' and an alias chain methodology,
#          whereby 'prepend' and the alias chain methodology is incompatible with 
#          each other, the coexistence cannot be further maintained.
# 4.0.1a 
#        - added method to prevent plugin from registering, if mimemagic is not installed.
#          In this case. a permanent error message is displayed.
#          
# 4.1.1  
#        - added pagination links to attachments preview page and 
#          entry (repository) preview page
#        - fixed japanese localization
# 4.1.2  
#        - added conditional loading of mimemgaic/overlay
#        - added capability of activating on a per project base
# 4.1.3  
#        - fixed repositories controller patch not finding project
#        - added support for development mode
# 5.0.0  
#        - running under Redmine 5
#        
# 5.0.1  
#        - fixed some new locale files
#        
# 5.0.2  
#        - altered sequence of file loading to please Zeitwerk
#        
# 5.0.3  
#       - removed legacy code to please Zeitwerk
#        
# 5.0.4  
#       - added more include statements to please Zeitwerk
#        
# 5.0.5  
#       - yet another patch to please Zeitwerk
# 5.0.6  
#       - yet another patch to please Zeitwerk
# 5.0.7  
#       - yet another patch to please Zeitwerk
# 5.0.8  
#       - fixed File.exists? to File.exist? in zippy
#       - fixed URI.esacape to URI.encode_www_form_component for zippy
#       - fixed long standing issue with links in zippy's inline zip file content tables
# 5.0.9 
#       - runs on Redmine 6.x
#-----------------------------------------------------------------------------------------
# Register plugin
#-----------------------------------------------------------------------------------------
Redmine::Plugin.register :redmine_more_previews do
  name         'Redmine More Previews'
  author       'Stephan Wenzel'
  description  'Preview various file types in redmine\'s preview pane'
  version      '5.0.9'
  url          'https://github.com/HugoHasenbein/redmine_more_previews'
  author_url   'https://github.com/HugoHasenbein/redmine_more_previews'
  
  requires_redmine(:version_or_higher => '4')
  
  settings :default => {'embedding'      => '0',  # use <object><embed>-tag or <iframe>-tag
                        'cache_previews' => '1',  # yes, cache previews
                        'debug'          => '0',  # no, do not debug
                        'absolute'       => '0',  # no, use relative paths for iFrame- and embed-tags
                       },
           :partial => 'settings/redmine_more_previews/settings'
           
  project_module :redmine_more_previews do
    permission :use_redmine_more_previews, {}, :public => true, :read => true
  end #project_module
end

#-----------------------------------------------------------------------------------------
# Load files
#-----------------------------------------------------------------------------------------
require_relative "lib/redmine_more_previews"

#-----------------------------------------------------------------------------------------
# Load Converters
#-----------------------------------------------------------------------------------------
RedmineMorePreviews::Converter.load

#-----------------------------------------------------------------------------------------
# File reloader for development environment. In Redmine 5 init.rb is called in to_prepare
#-----------------------------------------------------------------------------------------
# if Redmine::VERSION.to_s < "5"
#   Rails.configuration.to_prepare do
#     Rails.logger.info "-------------reloading"
#     require_relative "lib/redmine_more_previews"
#     RedmineMorePreviews::Converter.load
#   end
# end

#-----------------------------------------------------------------------------------------
# File reloader for development environment. In Redmine 5 init.rb is called in to_prepare
# fix proposed in
# https://zenn-dev.translate.goog/tohosaku/articles/3ccdeb2f38bb07?_x_tr_sl=auto&_x_tr_tl\
# =en&_x_tr_hl=ja&_x_tr_pto=wapp
#-----------------------------------------------------------------------------------------
if Rails.version > '6.0' && Rails.autoloaders.zeitwerk_enabled?
    # リロード時の処理 
else
  Rails.configuration.to_prepare do
    Rails.logger.info "-------------reloading"
    require_relative "lib/redmine_more_previews"
    RedmineMorePreviews::Converter.load
  end
end


#-----------------------------------------------------------------------------------------
# Add permissions
#-----------------------------------------------------------------------------------------
Rails.application.config.after_initialize do
  [ [:view_changesets,   "repositories/more_preview"],
    [:view_changesets,   "repositories/more_asset"],
    [:browse_repository, "repositories/more_preview"],
    [:browse_repository, "repositories/more_asset"]
  ].each do |permission, action|
    RedmineMorePreviews::Lib::RmpPerm.push_permission(permission, action)
  end
end
