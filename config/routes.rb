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

RedmineApp::Application.routes.draw do
  
  #
  # attachments
  #
  get 'attachments/more_preview/:id/index(.:format)',
    :controller  => 'attachments',
    :action      => 'more_preview',
    :constraints => {:id => /\d+/, :format => /[^.]+/},
    :as          => "more_preview"
  
  get 'attachments/more_preview/:id/(*asset).:assetformat', 
    :controller  => 'attachments',
    :action      => 'more_asset',
    :constraints => {:id => /\d+/, :asset => /.*/, :format => /[^.]+/},
    :as          => "more_asset"
    
  #
  # repositories
  #
  get "projects/:id/repository/:repository_id/preview(/*path)@/index(.:format)",
    :controller  => 'repositories',
    :action      => "more_preview",
    :constraints => {:path => /.*?/, :format => /[A-Za-z0-9]+/}
    
  get "projects/:id/repository/:repository_id/:rev/preview(/*path)@/index(.:format)",
    :controller  => 'repositories',
    :action      => "more_preview",
    :constraints => {:rev => /[a-z0-9\.\-_]+/, :path => /.*?/, :format => /[A-Za-z0-9]+/}
    
  get "projects/:id/repository/:repository_id/preview(/*path).:baseformat@(*asset).:assetformat",
    :controller  => 'repositories',
    :action      => "more_asset",
    :constraints => {:path => /.*?/, :asset => /.*/, :baseformat => /[A-Za-z0-9]+/, :assetformat => /[A-Za-z0-9]+/}
    
  get "projects/:id/repository/:repository_id/:rev/preview(/*path).:baseformat@(*asset).:assetformat",
    :controller  => 'repositories',
    :action      => "more_asset",
    :constraints => {:rev => /[a-z0-9\.\-_]+/, :path => /.*?/, :baseformat => /[A-Za-z0-9]+/, :asset => /.*/, :assetformat => /[A-Za-z0-9]+/}
    
end
