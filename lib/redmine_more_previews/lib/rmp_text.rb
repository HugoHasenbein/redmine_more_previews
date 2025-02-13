# encoding: utf-8
# frozen_string_literal: true
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
  module Lib
    module RmpText
      class << self
      
        ##################################################################################
        #
        # text encodings converter
        #
        ###################################################################################
        def to_utf8(arg, from_charset=nil)
          if arg.is_a?(String)
            convert_encoding(arg, from_charset)
          elsif arg.is_a?(Array)
            arg.map do |a|
              convert_encoding(a, from_charset)
            end
          elsif arg.is_a?(Hash)
            arg = arg
            arg.each do |k,v|
              arg[k] = convert_encoding(v, from_charset)
            end
            arg
          else
            arg
          end
        end #def
        
        #---------------------------------------------------------------------------------
        # convert_encoding
        #---------------------------------------------------------------------------------
        def convert_encoding( str, from_charset=nil )
          
          encoding = from_charset || get_charset( str )
          
          if encoding.present?
            return str.encode( 'UTF-8', encoding,
              :invalid => :replace, 
              :undef   => :replace, 
              :replace => "?"
            )
          else 
            return str.encode( 'UTF-8',
              :invalid => :replace, 
              :undef   => :replace, 
              :replace => "?"
            )
          end #if
        end #def
        
        #---------------------------------------------------------------------------------
        # get_encoding
        #---------------------------------------------------------------------------------
        def get_charset( str )
        
          ###########################################################
          #  work on local copy                                     #
          ###########################################################
          str = str.dup
          
          ###########################################################
          #  if string is valid return immediately                  #
          ###########################################################
          if str.force_encoding("UTF-8").valid_encoding?
            return "UTF-8"
          end 
          
          ###########################################################
          #  now, try the most often string encodings               #
          ###########################################################
          encodings = %w(ISO-8859-1 Windows-1252 Windows-1251 Macintosh)
          encodings.each do |enc|
            return enc if str.force_encoding( enc ).valid_encoding?
          end
          
          ###########################################################
          #  if we are here, then some other encoding is used       #
          #  Encoding list: run through all available encodings     #
          ###########################################################
          Encoding.list.each do |enc|
            return enc if str.force_encoding( enc ).valid_encoding?
          end
          
          ###########################################################
          # this code is only reached if everything else failed     #
          ###########################################################
          # here we give up and set to no encoding 
          return ""
          
        end #def
      end #class
    end #module
  end #module
end #module
