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

module RedmineMorePreviews
  module Patches
    module MimeTypePatch
      def self.included(base)
        base.class_eval do
          #unloadable
          
          # Returns the css class associated to
          # the mime type of name
          def self.css_class_of(name)
            mimetype = of(name)
            mimetype&.gsub(/[^a-z^A-Z^0-9]/, "-")
          end #def
          
        end #base
      end #self
      
    end #module
  end #module
end #module

unless Redmine::MimeType.included_modules.include?(RedmineMorePreviews::Patches::MimeTypePatch)
  Redmine::MimeType.send(:include, RedmineMorePreviews::Patches::MimeTypePatch)
end

