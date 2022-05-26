# encoding: utf-8
# frozen_string_literal: true

# Redmine plugin to preview various file types in redmine's preview pane
#
# Copyright © 2018 -2020 Stephan Wenzel <stephan.wenzel@drwpatent.de>
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
#        - added supptort for development mode
#        - added support for per project activation
#        
#-----------------------------------------------------------------------------------------
# Check, if mimemagic gem is correctly installed
#-----------------------------------------------------------------------------------------
if Gem::Specification.all_names.any?{|gem| gem =~ /mimemagic/}
#-----------------------------------------------------------------------------------------
# Register plugin
#-----------------------------------------------------------------------------------------
redmine_more_previews = Redmine::Plugin.register :redmine_more_previews do
  name 'Redmine More Previews'
  author 'Stephan Wenzel'
  description 'Preview various file types in redmine\'s preview pane'
  version '4.1.3'
  url 'https://github.com/HugoHasenbein/redmine_more_previews'
  author_url 'https://github.com/HugoHasenbein/redmine_more_previews'
  
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
# Load stuff, which needs to be loaded on boot and on each request in development mode
#-----------------------------------------------------------------------------------------
Rails.application.config.to_prepare do

  #---------------------------------------------------------------------------------------
  # Constants
  #---------------------------------------------------------------------------------------
  unless defined?(MORE_PREVIEWS_STORAGE_PATH)
    MORE_PREVIEWS_STORAGE_PATH = File.join(Rails.root, "tmp", "more_previews")
  end
  
  #---------------------------------------------------------------------------------------
  # Load files
  #---------------------------------------------------------------------------------------
  require_relative "lib/redmine_more_previews"
  
  #---------------------------------------------------------------------------------------
  # Load Converters
  #---------------------------------------------------------------------------------------
  RedmineMorePreviews::Converter.load
end


#-----------------------------------------------------------------------------------------
# Add permissions
#-----------------------------------------------------------------------------------------
Rails.application.config.after_initialize do
  Redmine::AccessControl.permission(:view_changesets  ).actions.push("repositories/more_preview")
  Redmine::AccessControl.permission(:view_changesets  ).actions.push("repositories/more_asset")
  Redmine::AccessControl.permission(:browse_repository).actions.push("repositories/more_preview")
  Redmine::AccessControl.permission(:browse_repository).actions.push("repositories/more_asset")
end


#-----------------------------------------------------------------------------------------
# if gems are not correctly installed, then copy an error page
#-----------------------------------------------------------------------------------------
else
  require_relative "config/install/error.rb"
end
