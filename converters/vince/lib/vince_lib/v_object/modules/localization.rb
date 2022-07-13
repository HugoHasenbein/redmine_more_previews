# encoding: utf-8
#
# RedmineMorePreviews vcf (electronic business cards) previewer
#
# Copyright © 2021 Stephan Wenzel <stephan.wenzel@drwpatent.de>
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
module VinceLib

module VObject
  module Modules
    module Localization
    
      ####################################################################################
      # shared constants among VObject classes
      ####################################################################################
      unloadable
      
      ####################################################################################
      # constants
      ####################################################################################
      
      #-----------------------------------------------------------------------------------
      # provide language of redmine (not user language)
      #
      def global_lang
        Setting.default_language
      end #def
      
      #-----------------------------------------------------------------------------------
      # translate symbol
      #
      def translate(sym, **att)
        I18n.with_locale(global_lang){I18n.translate(sym, **att)}
      end #def
      
      #-----------------------------------------------------------------------------------
      # localize object
      #
      def localize(obj, **att)
        I18n.with_locale(global_lang){I18n.localize(obj, **att)}
      end #def
      
    end #module
  end #module
end #module
end