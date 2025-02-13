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
    module AttachmentPatch
      def self.included(base)
        base.class_eval do
          #unloadable
          
          ################################################################################
          #
          # preview data functions
          #
          ################################################################################
          # class specific
          def more_preview(options={}, &block)
            RedmineMorePreviews::Converter.convert(
              diskfile, 
              preview_filepath(options),
              options.merge(
                :object => {:type => :attachment, :object => self},
                :preview_format => preview_format
              ), 
              &block
            )
          end #def
          
          # class specific
          def more_asset(options={}, &block)
            RedmineMorePreviews::Converter.convert(
              diskfile, 
              preview_assetpath(options),
              options.merge(
                :object => {:type => :attachment, :object => self},
                :preview_format => preview_format
              ), 
              &block
            )
          end #def
          
          def preview_convertible?
            RedmineMorePreviews::Converter.convertible?(filename)
          end #def
          
          def preview_available?(options={})
            File.exist?(preview_filepath(options))
          end #def
          
          def asset_available?(options={})
            File.exist?(preview_assetpath(options))
          end #def
          
          # class specific
          def preview_format
            extension = File.extname(filename).to_s[1..-1].downcase
            RedmineMorePreviews::Converter.conversion_extension(extension)
          end #def
          
          def preview_mtime(options={})
            preview_available?(options) ? File.mtime(preview_filepath(options)) : Time.now
          end #def
          
          def asset_mtime(options={})
            asset_available?(options) ? File.mtime(preview_assetpath(options)) : Time.now
          end #def
          
          ################################################################################
          #
          # path functions
          #
          ################################################################################
          def asset_link( asset )
          
            extname  = File.extname( asset )
            basename = File.basename( asset, extname )
            
            _link = Rails.application.routes.url_helpers.more_asset_path(
              self, basename, extname[1..-1]
            )
            
            if asset_available?(:asset => asset)
              ApplicationController.helpers.link_to( asset, _link,
               :class => "icon icon-file #{Marcel::MimeType.for(Pathname.new(preview_assetpath(:asset => asset)), name: File.basename(asset))&.tr('/', '-')}",
               :style => "padding-top:2px;padding-bottom:2px;"
              )
            else
              "" # asset does not exist
            end
          end #def
          
          ################################################################################
          #
          # preview file functions
          #
          ################################################################################
          
          #
          # directories
          #
          
          # directory of all previews
          def previews_storagepath
            File.join(RedmineMorePreviews::Constants::Defaults::MORE_PREVIEWS_STORAGE_PATH, self.class.name.underscore.pluralize)
          end #def
          
          # directory of this preview
          def preview_storagepath
            File.join(previews_storagepath, id.to_s)
          end #def
          
          # directory containing all preview files and assets
          def preview_dirname(options={})
            format = options[:format].presence || preview_format.presence
            File.join(preview_storagepath, ["preview", format ].compact.join("."))
          end #def
          
          #
          # files
          #
          
          # preview file name
          def preview_filename(options={})
            format = options[:format].presence || preview_format.presence
            ["index", format].compact.join(".")
          end #def
          
          # full path to preview file on disk
          def preview_filepath(options={})
            File.join(preview_dirname(options), preview_filename(options) )
          end #def
          
          # asset file name
          def preview_assetname(options={})
            assetformat = options[:assetformat].presence
            [options[:asset], assetformat].compact.join(".")
          end #def
          
          # full path to asset file on disk
          def preview_assetpath(options={})
#            File.join(preview_dirname(options.merge(:format => preview_format)), preview_filename(options) )
             File.join(preview_dirname(options.merge(:format => preview_format)), preview_assetname(options) )
         end #def
          
          ################################################################################
          #
          # overridden functions
          #
          ################################################################################
          # class specific
          def delete_from_disk!
            if disk_filename.present? && File.exist?(diskfile)
              File.delete(diskfile)
            end
            Dir[thumbnail_path("*")].each do |thumb|
              File.delete(thumb)
            end
            if File.exist?( preview_storagepath )
              FileUtils.rm_rf( preview_storagepath )
            end
          end #def
          
        end #base
      end #self
       
    end
  end  
end

unless Attachment.included_modules.include?(RedmineMorePreviews::Patches::AttachmentPatch)
  Attachment.send(:include, RedmineMorePreviews::Patches::AttachmentPatch)
end

