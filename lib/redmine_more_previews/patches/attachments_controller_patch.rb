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
    module AttachmentsControllerPatch
      def self.included(base)
        
        base.class_eval do
          #unloadable
          
          prepend ClassMethods
          
          alias_method  :find_attachment_for_more_preview, :find_attachment
          alias_method  :read_authorize_for_more_preview,  :read_authorize
          before_action :find_attachment_for_more_preview, :only => [:more_preview, :more_asset]
          before_action :read_authorize_for_more_preview,  :only => [:more_preview, :more_asset]
          before_action :find_asset_param,                 :only => [:more_preview, :more_asset]
          
          ################################################################################
          #
          # include helpers
          #
          ################################################################################
          include RedmineMorePreviews::ControllerHelper
          
          ################################################################################
          #
          # controller actions
          #
          ################################################################################
          def more_preview
            if @attachment.preview_convertible?
              if params[:asset]
                @disposition = "attachment"
                respond_to do |format|
                  format.any { send_more_asset }
                end #respond
              else
                respond_to do |format|
                  format.html  { send_more_preview }
                  format.xml   { send_more_preview }
                  format.text  { send_more_preview }
                  format.pdf   { send_more_preview }
                  format.png   { send_more_preview }
                  format.jpeg  { send_more_preview }
                  format.gif   { send_more_preview }
                end
              end
            else #no convertible document
              render_404
            end
          end #def
          
          def more_asset
            if @attachment.preview_convertible?
              respond_to do |format|
                format.any { send_more_asset }
              end #respond
            else #no convertible document
              render_404
            end #if
          end #def
          
          ################################################################################
          #
          # private
          #
          ################################################################################
          def send_more_preview
            if !params[:unsafe] && RedmineMorePreviews::Converter.cache_previews?
              if params[:reload] || stale?(:etag => @attachment.preview_mtime(preview_params))
                send_data @attachment.more_preview(preview_params),
                  :filename    => filename_for_content_disposition( @attachment.preview_filename(preview_params) ),
                  :type        => Rack::Mime.mime_type(".#{params[:format]}"),
                  :disposition => 'inline'
              end
            else #no cache
              @attachment.more_preview(preview_params) do |preview_data|
                 send_data preview_data,
                   :filename    => filename_for_content_disposition( @attachment.preview_filename(preview_params) ),
                   :type        => Rack::Mime.mime_type(".#{params[:format]}"),
                   :disposition => 'inline'
              end
            end
          end #def
          private :send_more_preview
          
          def send_more_asset
            if !params[:unsafe] && RedmineMorePreviews::Converter.cache_previews?
              if params[:reload] || stale?(:etag => @attachment.asset_mtime(preview_params))
                send_data @attachment.more_asset(preview_params),
                  :filename    => filename_for_content_disposition( File.basename(@asset) ),
                  :type        => Rack::Mime.mime_type( File.extname(@asset) ),
                  :disposition => @disposition || 'inline'
              end
            else #no cache
              @attachment.more_asset(preview_params) do |preview_data, asset_data|
                 send_data asset_data,
                  :filename    => filename_for_content_disposition( File.basename(@asset) ),
                  :type        => Rack::Mime.mime_type( File.extname(@asset) ),
                  :disposition => @disposition || 'inline'
              end
            end
          end #def
          private :send_more_asset
          
          def find_asset_param
            @asset = params[:asset].is_a?(Array) ? params[:asset].join('/') : params[:asset]
            @asset = [@asset, params[:assetformat]].compact.join(".").presence
          end #def
          private :find_asset_param
        end #base
        
      end #self
      
      module ClassMethods
      
        def show
          if @attachment.project&.module_enabled?('redmine_more_previews') &&
             request.format.html? &&
             @attachment.preview_convertible?
            if @attachment.container.respond_to?(:attachments)
              @attachments = @attachment.container.attachments.to_a
              if index = @attachments.index(@attachment)
                @paginator = Redmine::Pagination::Paginator.new(
                  @attachments.size, 1, index+1
                )
              end
            end
            render :action => 'more_preview', :formats => :html
          else
            super
          end
        end #def 
        
      end #module  
    end #module
  end #module
end #module

unless AttachmentsController.included_modules.include?(RedmineMorePreviews::Patches::AttachmentsControllerPatch)
  AttachmentsController.send(:include, RedmineMorePreviews::Patches::AttachmentsControllerPatch)
end

