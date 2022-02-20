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

require 'mimemagic'
require 'mimemagic/overlay'

module RedmineMorePreviews
  module Patches
    module RepositoryPatch
      def self.included(base)
        base.class_eval do
          #unloadable
          
          ################################################################################
          #
          # preview data functions
          #
          ################################################################################
          # class specific
          def more_preview(path, rev, options={}, &block)
            if entry(path, rev)
              Dir.mktmpdir do |tmpdir|
                filepath = File.join(tmpdir, entry(path, rev).name)
                File.open( filepath, "wb") {|f| f.write(cat(path, rev))}
                RedmineMorePreviews::Converter.convert(
                  filepath,
                  preview_filepath(path, rev, options),
                  options.merge(
                    :object => {:type => :repository, :object => self, :path => path, :rev => rev},
                    :preview_format => preview_format(path, rev)
                  ), 
                  &block
                )
              end #Dir
            elsif block_given?
              yield nil
            end #if
          end #def
          
          # class specific
          def more_asset(path, rev, options={}, &block)
            if entry(path, rev)
              Dir.mktmpdir do |tmpdir|
                filepath = File.join(tmpdir, entry(path, rev).name)
                File.open( filepath, "wb") {|f| f.write(cat(path, rev))}
                RedmineMorePreviews::Converter.convert(
                  filepath,
                  preview_filepath(path, rev, options),
                  options.merge(
                    :object => {:type => :repository, :object => self, :path => path, :rev => rev},
                    :preview_format => preview_format(path, rev)
                  ), 
                  &block
                )
              end #Dir
            elsif block_given?
              yield nil
            end #if
          end #def
          
          def preview_available?(path, rev, options={})
            File.exist?(preview_filepath(path, rev, options))
          end #def
          
          def asset_available?(path, rev, options={})
            File.exist?(preview_assetpath(path, rev, options))
          end #def
          
          # class specific
          def preview_format(path, rev)
            if e = entry(path, rev)
              extension = File.extname(e.name)[1..-1].downcase
              RedmineMorePreviews::Converter.conversion_extension(extension) if extension
            end
          end #def
          
          def preview_mtime(path, rev, options={})
            preview_available?(path, rev, options) ? File.mtime(preview_filepath(path, rev, options)) : Time.now
          end #def
          
          def asset_mtime(path, rev, options={})
            asset_available?(path, rev, options) ? File.mtime(preview_assetpath(path, rev, options)) : Time.now
          end #def
          
          ################################################################################
          #
          # path functions
          #
          ################################################################################
          def asset_link( path, rev, asset )
          
            extname     = File.extname( path)
            basename    = File.basename(path, extname)
            dirname     = File.dirname(path)
            
            assetformat = File.extname(asset)
            assetname   = File.basename(asset, assetformat)
            
            _link = Rails.application.routes.url_helpers.url_for(
              :controller    => "repositories",
              :action        => "more_asset",
              :id            => project.identifier,
              :repository_id => identifier_param,
              :rev           => rev,
              :path          => [dirname, basename].join("/"),
              :baseformat    => extname[1..-1],
              :asset         => assetname,
              :assetformat   => assetformat[1..-1], 
              :only_path     => true
            )
            
            ApplicationController.helpers.link_to( asset, _link,
              :class => "icon icon-file #{MimeMagic.by_path( asset ).type&.tr('/', '-')}",
              :style => "padding-top:2px;padding-bottom:2px;"
            )
          end #def
          
          ################################################################################
          #
          # preview file functions
          #
          ################################################################################
          # file
          def preview_filename(path, rev, options={})
            format = options[:format].presence || preview_format(path, rev).presence
            ["index", format].compact.join(".")
          end #def
          
          # filepath
          def preview_filepath(path, rev, options={})
            File.join(preview_dirname(path, rev, options), preview_filename(path, rev, options) )
          end #def
          
          # asset
          def preview_assetname(path, rev, options={})
            format = options[:format].presence || preview_format(path, rev).presence
            [options[:asset], format].compact.join(".")
          end #def
          
          # assetpath
          def preview_assetpath(path, rev, options={})
            File.join(preview_dirname(path, rev, options.merge(:format => preview_format(path, rev))), preview_filename(path, rev, options) )
          end #def
          
          # dir
          def preview_dirname(path, rev, options={})
            format = options[:format].presence || preview_format(path, rev).presence
            File.join(preview_storagepath, path, ["preview", format ].compact.join("."))
          end #def
          
          # upper dir
          def preview_storagepath
            File.join(previews_storagepath, identifier.to_s)
          end #def
          
          def previews_storagepath
            File.join(MORE_PREVIEWS_STORAGE_PATH, self.class.name.underscore.pluralize)
          end #def
          
        end #base
      end #self
      
    end #module
  end #module
end #module

unless Repository.included_modules.include?(RedmineMorePreviews::Patches::RepositoryPatch)
  Repository.send(:include, RedmineMorePreviews::Patches::RepositoryPatch)
end


