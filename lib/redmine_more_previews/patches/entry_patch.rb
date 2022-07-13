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

require File.join(Rails.root, "lib", "redmine", "scm", "adapters", "abstract_adapter.rb")

module RedmineMorePreviews
  module Patches
    module EntryPatch
      def self.included(base)
        base.class_eval do
          #unloadable
          
          def convertible?
            RedmineMorePreviews::Converter.convertible?(name)
          end #def
          
          def conversion_extension
            RedmineMorePreviews::Converter.conversion_extension( File.extname( name ))
          end #def
          
          def info
            [name, path, kind, size, lastrev].join(" ").
            gsub(/[^a-z^A-Z^0-9^_]/, " ").squish.gsub(/\ /, "-")
          end #def
          
        end #base
      end #self
      
    end #module
  end #module
end #module

unless Redmine::Scm::Adapters::Entry.included_modules.include?(RedmineMorePreviews::Patches::EntryPatch)
  Redmine::Scm::Adapters::Entry.send(:include, RedmineMorePreviews::Patches::EntryPatch)
end

