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
#require 'routes'

class Mark < RedmineMorePreviews::Conversion

  #---------------------------------------------------------------------------------
  # delegates
  #---------------------------------------------------------------------------------
  delegate :url_for, :to => "Rails.application.routes.url_helpers"
           
  #---------------------------------------------------------------------------------
  # constants
  #---------------------------------------------------------------------------------
  PANDOC_BIN = 'pandoc'.freeze
  PANDOC_FRM = {"text/markdown" => "markdown", "text/html" => "html"}
  
  #---------------------------------------------------------------------------------
  # check: is Pandoc available?
  #---------------------------------------------------------------------------------
  def status
    s = run [PANDOC_BIN, "--version"]
    [:text_pandoc_available, s[2] == 0 ]
  end
  
  ########################################################################################
  #
  # convert
  #
  ########################################################################################
  def convert
    command(cd + join + pandoc + join + move(outfile))
  end #def
  
  #---------------------------------------------------------------------------------
  # pandoc
  #---------------------------------------------------------------------------------
  def pandoc
  
    mime    = RedmineMorePreviews::Converter.mime( source )
    frompts = PANDOC_FRM[mime["mime"]]
    
    case format
    when "html"
      base_url = case object["object"]
      when Repository
        url_for( :controller    => "repositories",
                 :action        => "raw",
                 :id            => object["object"].project.identifier,
                 :repository_id => object["object"].identifier_param,
                 :rev           => object["rev"],
                 :path          => object["path"],
                 :only_path     => true
        )
      when Attachment
        url_for( :controller    => "attachments",
                 :action        => "download",
                 :id            => object["object"].id,
                 :filename      => object["object"].filename,
                 :only_path     => true
        )
      else
        nil
      end
      
      if base_url
        base = "<base href='#{base_url}'>"
        "#{PANDOC_BIN} #{shell_quote source} -f #{frompts} -t html -s -V header-includes=#{shell_quote base} -o #{shell_quote outfile}"
      else
        "#{PANDOC_BIN} #{shell_quote source} -f #{frompts} -t html -s -o #{shell_quote outfile}"
      end
      
    when "inline"
      "#{PANDOC_BIN} #{shell_quote source} -f #{frompts} -t html -o #{shell_quote outfile}"
    when "txt"
      "#{PANDOC_BIN} #{shell_quote source} -f #{frompts} -t plain -o #{shell_quote outfile}"
    end.to_s
    
  end #def
  
end #class
