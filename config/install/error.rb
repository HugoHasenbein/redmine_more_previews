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

#-----------------------------------------------------------------------------------------
# copy html file with message to  public directory
#-----------------------------------------------------------------------------------------
src = File.join(__dir__, "..", "..", "assets", "pages", "install_error.html")
pub = File.join(Redmine::Plugin.public_directory, "redmine_more_previews", "pages")
begin
Rails.logger.info "Trying to copy #{src} to #{pub}}"
  FileUtils.mkdir_p(pub); FileUtils.cp(src, pub)
rescue => e
  Rails.logger.info "Redmine More Previews: failed to create an error page after install failed"
end

#-----------------------------------------------------------------------------------------
# now add a hook, so that the error message is displayed on all pages of redmine
#-----------------------------------------------------------------------------------------
class RedmineMorePreviewsInstallError < Redmine::Hook::ViewListener
  def view_layouts_base_body_top(context)
    File.read(File.join(Redmine::Plugin.public_directory, "redmine_more_previews", "pages", "install_error.html"))
  end
end
