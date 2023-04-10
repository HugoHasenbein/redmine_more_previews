# encoding: utf-8
#
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

module RedmineMorePreviews
  module Patches
    module AdminControllerPatch
      def self.included(base)
        
        base.class_eval do
          #unloadable
          
          #
          # calling prepend within self.included is a bit awkward, as the same effect
          # could be achieved much easier with calling prepend in the below unless...
          # block. We keep this awkward way to be able to later concurrently include
          # and also prepend methods
          #
          prepend ClassMethods
         
        end #base
        
      end #self
       
      module ClassMethods
      
        def info
         super
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
