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
    module ApplicationHelperPatch
      def self.included(base)
        base.class_eval do
        
          #unloadable 
          
          def more_previews_tag(path, filename, options={})
          
            if RedmineMorePreviews::Converter.embed?
              content_tag(:div, 
                content_tag(
                  :object,
                  tag(:embed, :href => path, :type => options[:type]),
                  { :style   => "position:absolute;top:0;left:0;width:95%;height:100%;",
                    :title   => filename,
                    :type    => options[:type],
                    :data    => path,
                    :id      => 'preview_object',
                   }.merge(options)
                ),
                :id     => "preview_pane",
                :style  => "position:relative;padding-top:141%;",
              )
            else
              content_tag(:div, 
                content_tag(:script, "$(document).ready(function() { $('#ajax-indicator').show()});".html_safe) +
                content_tag(
                  :iframe,
                  "",
                  { :style                => "position:absolute;top:0;left:0;width:95%;height:16px;",
                    :seamless             => "seamless",
                    :scrolling            => "no",
                    :frameborder          => "0",
                    :allowtransparency    => "true",
                    :title                => filename,
                    :src                  => path,
                    :id                   => 'preview_frame',
                    :onload               => "$(document).ready(function() {$('#preview_frame').css('height', $(window).height())});".html_safe 
                                             
                   }.merge(options)
                ),
                :id    => "preview_pane",
                :style => "position:relative;padding-top:141%;"
              )
            end #if
          end #def
          
        end #base
      end #self
    end #module
  end #module
end #module

unless ApplicationHelper.included_modules.include?(RedmineMorePreviews::Patches::ApplicationHelperPatch)
  ApplicationHelper.send(:include, RedmineMorePreviews::Patches::ApplicationHelperPatch)
end


