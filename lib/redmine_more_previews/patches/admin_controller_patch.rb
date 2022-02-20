# encoding: utf-8
#
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

module RedmineMorePreviews
  module Patches
    module AdminControllerPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        
        base.class_eval do
          #unloadable
            
          alias_method :info_without_more_previews, :info
          alias_method :info, :info_with_more_previews
         
        end #base
        
      end #self
      
      module InstanceMethods
      
        def info_with_more_previews
         info_without_more_previews
         RedmineMorePreviews::Converter.all.each do |converter|
           check = converter.worker.check
           @checklist << check if check
         end
        end #def
        
      end #module
      
    end #module
  end #module
end #module

unless AdminController.included_modules.include?(RedmineMorePreviews::Patches::AdminControllerPatch)
  AdminController.send(:include, RedmineMorePreviews::Patches::AdminControllerPatch)
end

