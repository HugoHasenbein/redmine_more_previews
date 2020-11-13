# encoding: utf-8
#
# RedmineMorePreviews converter to text files
#
# Copyright © 2020 Stephan Wenzel <stephan.wenzel@drwpatent.de>
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

class NilText < RedmineMorePreviews::Conversion

  #---------------------------------------------------------------------------------
  # constants
  #---------------------------------------------------------------------------------
  #NIL_PROGRAM = "whoami"
  
  #---------------------------------------------------------------------------------
  # check: is a possibly required external program available?
  #---------------------------------------------------------------------------------
  def status
    # s = # run [NIL_PROGRAM, "--version"]
    # [:text_nil_program_available, s ]
    nil # uncomment and return array before
  end
  
  def convert
    #
    # child classes should override this method
    #
    # and convert the source file to a target file with format extension
    #   
    #   @mime_types   (Hash)
    #   @object       (Hash) {:type => :attachment, :object => @attachment}, or 
    #                        {:type => :repository, :object => @repository, :path => @path, :rev => @rev}
    #                        
    #   @project      (Project)  project 
    #   @name         (String)   beautiful name of converter
    #   
    #   @transient    (Boolean)  if true, then raw data must be returned, else data must be stored in @tmpdir/@tmpfile
    #   
    #   @format       (String)   "html", "inline", "text" or "pdf"
    #   @source       (String)   path of source file
    #   
    #   --- the following data are just for informational purposes 
    #       do not write to the paths below to stay thread safe
    #       
    #   @target       (String)   full target path
    #   @dir          (String)   target directory of full target path
    #   @file         (String)   target filename of full target path
    #   @ext          (String)   target filename extension of full target path
    #
    #   @asset        (String)   name of preview asset, f.i. an inline image
    #   @assetdir     (String)   target directory of full asset path
    #   @assetfile    (String)   target filename of full asset path
    #   @assetext     (String)   target filename extension of full asset path
    #   
    #   --- the following paths belong to your converter -------
    #   @tmptarget    (String)   full tmp target path
    #   @tmpdir       (String)   target directory of full tmp target path
    #   @tmpfile      (String)   target filename of full tmp target path
    #   @tmpext       (String)   target directory of full tmp target path
    #
    super
    
  end #def
  
end #class
