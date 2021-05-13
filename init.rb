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

require 'redmine'

#-----------------------------------------------------------------------------------------
# Register plugin
#-----------------------------------------------------------------------------------------
redmine_more_previews = Redmine::Plugin.register :redmine_more_previews do
  name 'Redmine More Previews'
  author 'Stephan Wenzel'
  description 'Preview various file types in redmine\'s preview pane'
  version '2.0.2d.2'
  url 'https://github.com/HugoHasenbein/redmine_more_previews'
  author_url 'https://github.com/HugoHasenbein/redmine_more_previews'
  
  settings :default => {'embedding'      => '0',  # use <object><embed>-tag or <iframe>-tag
                        'cache_previews' => '1'   # yes, cache previews
                       },
           :partial => 'settings/redmine_more_previews/settings'
end

#-----------------------------------------------------------------------------------------
# Constants
#-----------------------------------------------------------------------------------------
MORE_PREVIEWS_STORAGE_PATH = File.join(Rails.root, "tmp", "more_previews")

#-----------------------------------------------------------------------------------------
# Plugin Library
#-----------------------------------------------------------------------------------------
require "redmine_more_previews"

#-----------------------------------------------------------------------------------------
# Load Converters
#-----------------------------------------------------------------------------------------
RedmineMorePreviews::Converter.load

#-----------------------------------------------------------------------------------------
# Add permissions
#-----------------------------------------------------------------------------------------
Rails.application.config.after_initialize do
  Redmine::AccessControl.permission(:view_changesets  ).actions.push("repositories/more_preview")
  Redmine::AccessControl.permission(:view_changesets  ).actions.push("repositories/more_asset")
  Redmine::AccessControl.permission(:browse_repository).actions.push("repositories/more_preview")
  Redmine::AccessControl.permission(:browse_repository).actions.push("repositories/more_asset")
end

