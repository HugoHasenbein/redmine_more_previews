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
  # NIL_PROGRAM = "whoami"
  
  #---------------------------------------------------------------------------------
  # status: is a possibly required external program (delegate) available?
  # 
  # If your plugin is not dependent on a delegate, then you may completely ignore 
  # the 'status' method. In this case the super method from 
  # RedmineMorePreviews::Conversion returns returns just nil.
  # Your plugin may also return nil if a status check is not applicable 
  # (f.i. runs without a delegate)
  #---------------------------------------------------------------------------------
  def status
  
    # do whatever to check, if your delegate program is functional
    # the command in the array may fail. In this case 'run' returns false 
    # s = run [NIL_PROGRAM, "--version"]
    
    # just for demonstration: here we always return true (available, working)
    [:text_nil_program_available, true ]
    
  end
  
  #---------------------------------------------------------------------------------
  # valid: for cached previews 'check' is called to check if current conversion is valid
  #
  # Your plugin may for instance check the current date and compare it with the date
  # of the File specified in @target
  #
  # If your plugin just converts a file from one format to another format without 
  # the necessity of being up-to-date, then you may completely ignore the 'valid'
  # method. In this case the super method from RedmineMorePreviews::Conversion 
  # queries if the file in @target exists. If it doesn't, then 'convert' is called.
  #---------------------------------------------------------------------------------
  def valid
    super
  end #def
  
  #---------------------------------------------------------------------------------
  # convert: the workhorse of your converter plugin
  #
  # The convert method should convert a file supplied by the method 'source', providing 
  # an absolute path, to a file having the file name provided by the method 'tmptarget', 
  # whereby the method 'tmptarget' returns an absolute path.
  #
  # == Conversion with a delegate program
  # 
  # The conversion should take place in the directory provided by the method 'tmpdir' 
  # also providing an absolute path. Call the method 'cd' to change the working directory
  # of a following system call to the 'tmpdir' directory.
  # 
  # The tmptarget and the tmpdir belong to this instance. This instance therefore
  # only works with file copies. The source, however, is the original file. So do not
  # tamper the file pointed to by source. Access to source is threadsafe.
  #
  # Concurrent conversions of the same plugin will all happen in their own tmpdir.
  #
  # If your plugin / delegate is threadsafe (define in init.rb), then each plugin
  # will convert concurrently as controlled by the operating system of the redmine host.
  # 
  # Thread safety is assumed to false. If your plugin / delegate is not threadsafe
  # then each call to your plugin is controlled by the super method. This may lead to
  # one user causing a conversion having to wait for the conversion of another user
  # also having caused a conversion. If a large program is started in the background
  # like LibreOffice, concurrent conversions may cause unpleasant user experience with
  # long duration latency.
  #
  # If the plugin is configured in the redmine plugin configuration to be cached,
  # then the cached version is shown to the user, whereby before each presentation
  # the method 'valid' is queried.
  #
  # In pseudo code your example delegate program 'myconverter' could convert like this:
  # 
  #     command( cd + join + command [myconverter, source, tmptarget].join(" ") )
  #     
  # whereby 'cd' translates to the corresponding command on linux or windows, 'join' joins
  # the commands corresponding to unix or windows syntax and 'command' runs 'myconverter',
  # your delegate program, in the operating system of your redmine host. The result should
  # be a converted file (html, inline html, xml, text, pdf, png, jpg, gif) in the tmpdir
  # directory.That would be all that is needed, if the example delegete program 
  # accepts two arguments, namely first argument to be the input file (path) and the 
  # second argument the name of the output file (path). Because 'cd' chose the working 
  # directory the outfile is written to the temp directory 'tmpdir'.
  # 
  # Please note, that the super class takes care to copy the tmptarget in the tmpdir to the 
  # final destination. This copy procedure is thread safe, regardless of the threadsafe 
  # parameter provided in init.rb of your plugin.
  #
  # == Conversion with rails
  # 
  # Your plugin may just read / interpret the contents of the file pointed to by the
  # 'source' method in the super class. Your plugin may then write to the file named
  # by the 'tmptarget' method in the superclass. The file should be saved in the tmpdir.
  # Therefore, regardless, if cached or non cached conversion is requested, your 
  # plugin should always write its result to the file 'tmptarget' in 'tmpdir'.
  #
  # == Assets
  # 
  # Let's assume your plugin interprets a file and converts the file to some html and
  # an image. The html will be written to 'tmptarget'. The filename part of the 'tmptarget'
  # path will be 'index' having the extension 'html' (or 'inline', 'txt').
  # The image file may have any name but the name 'index.<extension>'.
  # Eventually, the tmptarget will be copied over to the final destination and will have
  # the name 'index.html' ('index.txt', 'index.inline'). The filenames of the assets
  # (here: the image) will be untouched and copied with identical name.
  #
  #---------------------------------------------------------------------------------
  def convert
    super
  end #def
  
end #class
