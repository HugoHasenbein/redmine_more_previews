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

require "nokogiri"
require 'active_support/core_ext/hash/conversions'

class Cliff < RedmineMorePreviews::Conversion

  #---------------------------------------------------------------------------------------
  # libraries
  #---------------------------------------------------------------------------------------
  include RedmineMorePreviews::Lib
  
  #---------------------------------------------------------------------------------------
  # delegates
  #---------------------------------------------------------------------------------------
  delegate :number_to_human_size, :link_to, :to => "ApplicationController.helpers"
  delegate :url_for, :to => "Rails.application.routes.url_helpers"
  
  ########################################################################################
  #
  # convert
  #
  ########################################################################################
  def convert
    case preview_format
    when 'html'
      eml
    end
  end #def
  
  ########################################################################################
  #
  # helpers
  #
  ########################################################################################
  
  #---------------------------------------------------------------------------------------
  # eml
  #---------------------------------------------------------------------------------------
  def eml
  
    # read eml file
    mail  = Mail.new(RmpText.to_utf8(File.read(source)))
    
    # get html
    html, charset = html( mail )
    
    # sweep bad stuff from html
    unless unsafe
    html = sweep( html )
    end
    
    # save headers, users usually want to see
    save_headers( mail ) 
    
    # save headers, users may want to see
    save_fields( mail )
    
    if mail.attachments.any?
    
      # create an empty index.html file, which causes, that no extracted attachment is named likewise
      File.open(tmptarget, "w") {}
      
      # create an empty attachments.html file, which causes, that no extracted attachment is named likewise
      File.open(File.join(tmpdir, "attachments.html"), "wb") {}
    
      # save attachments( which will not collide with index.html and attachments.html)
      attachments = save_attachments( mail ) 
      
      # modify cid:links in html and save 
      html = link( Nokogiri::HTML( html ), Array(attachments) ).to_html
      
      # create list of attachments and save
      att_html = list( attachments )
      attachments_path = File.join( File.dirname(tmptarget), "attachments.html")
      File.open(attachments_path, "wb") {|f| f.write att_html }
      
    end
    
    
    File.open(tmptarget, "wb") {|f| f.write html }
    
  rescue Exception => e
    File.open(tmptarget, "wb") {|f| f.write (([e.message] + e.backtrace).join("<br>\n")) }
  end #def
  
  #---------------------------------------------------------------------------------------
  # html
  #---------------------------------------------------------------------------------------
  def html( mail )
  
    if mail.content_type && mail.content_type.downcase =~ /multipart/
    
        ###########################################################
        #  multipart:                                             #
        ###########################################################
        
      if mail.html_part
        ###########################################################
        #  multipart: try to fetch html                           #
        ###########################################################
        encoding      = mail.html_part.content_transfer_encoding
        charset       = mail.html_part.charset
        
        if encoding =~ /quoted-printable/ # there is a bug in .decoded
          html        = mail.html_part.body.to_s.unpack('M')[0].html_safe
        else
          html        = mail.html_part.body.decoded
        end
        
        ###########################################################
        #  get eventual charset: UTF-8, Windows-1252, etc.        #
        #  careful: 'charset' in mail is 'encoding' for strings   #
        ###########################################################
        charset     ||= RmpText.get_charset( html )
      
      elsif mail.text_part 
        ###########################################################
        #  multipart: no html -> try to fetch text                #
        ###########################################################
        encoding      = mail.text_part.content_transfer_encoding
        charset       = mail.text_part.charset
        
        if encoding =~ /quoted-printable/ # there is a bug in .decoded
          text        = mail.text_part.body.to_s.unpack('M')[0].html_safe
          text        = RmpText.to_utf8(text, charset)
        else
          text        = mail.text_part.body.decoded
        end
        
        @text         = text
        erb           = ERB.new(File.read(File.join(views, 'cliff', 'pre.html.erb')))
        html          = erb.result(binding).html_safe
        charset       = "UTF-8"
        
      else
        ###########################################################
        #  multipart: no html, no text -> empty message part      #
        ###########################################################
        @text         = ""
        erb           = ERB.new(File.read(File.join(views, 'cliff', 'pre.html.erb')))
        html          = erb.result(binding).html_safe
        charset       = 'UTF-8'
      end
    else
    
        ###########################################################
        #  single part:                                           #
        ###########################################################
      
      if mail.content_type && mail.content_type.downcase =~ /text\/html/
        ###########################################################
        #  single part: try to identify html by content_type      #
        ###########################################################
        encoding      = mail.body.encoding
        charset       = mail.body.charset
        
        if encoding =~ /quoted-printable/ # there is a bug in .decoded
          html        = mail.body.to_s.unpack('M')[0].html_safe
        else
          html        = mail.body.decoded
        end
        
        ###########################################################
        #  get eventual encoding: UTF-8, Windows-1252, etc.       #
        #  careful: 'charset' in mail is 'encoding' for strings   #
        ###########################################################
        charset     ||= RmpText.get_charset( html )
        
      elsif mail.content_type && mail.content_type.downcase =~ /text\/plain/
        ###########################################################
        #  single part: text                                      #
        ###########################################################
        encoding      = mail.body.encoding
        charset       = mail.body.charset
        
        if encoding =~ /quoted-printable/ # there is a bug in .decoded
          text        = mail.body.to_s.unpack('M')[0].html_safe
          text        = RmpText.to_utf8(text, charset)
        else
          text        = mail.body.decoded
        end
        
        @text         = text
        erb           = ERB.new(File.read(File.join(views, 'cliff', 'pre.html.erb')))
        html          = erb.result(binding).html_safe
        charset       = "UTF-8"
        
      else
        ###########################################################
        #  single part: no html no text                           #
        ###########################################################
        @text         = ""
        erb           = ERB.new(File.read(File.join(views, 'cliff', 'pre.html.erb')))
        html          = erb.result(binding).html_safe
        charset       = 'UTF-8'
      end
    end 
    [html, charset]
  end #def
  
  #---------------------------------------------------------------------------------------
  # save_attachments
  #---------------------------------------------------------------------------------------
  def save_attachments( message )
    attachments      = {}
    message.attachments.each_with_index do | attachment, i |
      filename       = RmpFile.sanitize(attachment.filename)
      filename       = RmpFile.unique_filename( Dir.children(tmpdir), filename)
      content_id     = attachment.content_id.to_s.match(/^\<(.*?)\>$/)
      content_id   ||= [0, attachment.content_id.to_s]
      content_id     = content_id && content_id[1]
      attachments[i] = {:filename     => filename,
                        :content_id   => content_id,
                        :content_type => attachment.content_type
                        }
      File.open(File.join(tmpdir, filename), "w+b", 0644) {|f| f.write attachment.decoded}
    end 
    attachments 
  end #def
  
  #---------------------------------------------------------------------------------------
  # save_headers
  #---------------------------------------------------------------------------------------
  def save_headers( message )
    @mail      = message
    erb        = ERB.new(File.read(File.join(views, 'cliff', 'headers.html.erb')))
    headers    = erb.result(binding).html_safe
    File.open(File.join(tmpdir, "headers.html"), "w+b", 0644) {|f| f.write headers }
  end #def
  
  #---------------------------------------------------------------------------------------
  # save_headers
  #---------------------------------------------------------------------------------------
  def save_fields( message )
    @mail      = message
    erb        = ERB.new(File.read(File.join(views, 'cliff', 'fields.html.erb')))
    fields     = erb.result(binding).html_safe
    File.open(File.join(tmpdir, "fields.html"), "w+b", 0644) {|f| f.write fields }
  end #def
  
  #---------------------------------------------------------------------------------------
  # sweep
  #---------------------------------------------------------------------------------------
  UNSAFETAGS   = %w(script)
  
  def sweep( html )
  
    doc = Nokogiri::HTML(html)
    
    #
    # remove unsafe tags
    #
    UNSAFETAGS.each do |ust|
      doc.xpath("//*[self::#{ust}]").each do |node|
        node.remove
      end
    end
    
    #
    # remove link= attribute of style tags
    #
    doc.xpath("//style").each do |node|
      node.keys.each do |attribute|
        if attribute =~ /link/i
          node.delete attribute
        end
      end
    end
    
    #
    # remove url(.*) attribute within css style tags
    #
    doc.xpath("//style/text()").each do |node|
      node.replace(node.content.gsub(/url\(.*?\)/, ""))
    end
    
    #
    # remove url(.*) attribute within css style attributes
    #
    doc.xpath("//*").each do |node|
      node.keys.each do |attribute|
        if attribute =~ /style/i
          node[attribute] = node[attribute].to_s.gsub(/url\(.*?\)/, "")
        end
      end
    end
    
    #
    # remove src= attribute of external images
    #
    doc.xpath("//img").each do |node|
      node.keys.each do |attribute|
        if attribute =~ /src/i && node[attribute] !~ /\Acid:/i
          node.delete attribute
        end
      end
    end
    
    #
    # remove href= attribute of external links
    #
    doc.xpath("//a").each do |node|
      node.keys.each do |attribute|
        if attribute =~ /href/i
          node.delete attribute
        end
      end
    end
    
    #
    # remove unsafe event attributes beginning with "on…"
    #
    patterns = [
                 "//*[@*[starts-with(name(), 'on')]]",
                "//@*[@*[starts-with(name(), 'on')]]",
      "//namespace::*[@*[starts-with(name(), 'on')]]"
    ].join(" | ")
    doc.xpath(patterns).each do |node|
      node.keys.each do |attribute|
        node.delete attribute if attribute =~ /\Aon/i
      end
    end
    
    # to_html will automatically correct 
    # <meta http-equiv="Content-Type" content="text/html; charset=<CHARSET>"
    # took me a day to find that out
    doc.to_html
  end #def
  
  #---------------------------------------------------------------------------------------
  # link
  #---------------------------------------------------------------------------------------
  def link( xml, attachments )
    #
    # link src= attribute of images
    #
    xml.xpath("//img").each do |node|
      node.keys.each do |attribute|
        if attribute =~ /src/i && node[attribute] =~ /\Acid:/i
          cidmatch = node[attribute].match(/^cid:(.*)/i); cid = cidmatch && cidmatch[1]
          if att = attachments.find{|key,value| value && value[:content_id] == cid}
            node[attribute] = att[1][:filename]
          end
        end
      end
    end
    xml
  end #def
  
  #---------------------------------------------------------------------------------------
  # list 
  #---------------------------------------------------------------------------------------
  def list( attachments )
    b = binding
    b.local_variable_set(:attachments, attachments)
    b.local_variable_set(:object, object)
    erb = ERB.new(File.read(File.join(views, 'cliff', 'attachments.html.erb')))
    erb.result(b).squish.html_safe
  end #def
  
  #---------------------------------------------------------------------------------------
  # obj_to_xml( label, obj, xml=nil )
  # creates xml from an arbitrary nested mixture of arrays and hashes
  #
  def obj_to_xml( label, obj, xml=nil )
  
    if xml
      if obj.is_a?(Array)
        obj.each do |value|
          obj_to_xml(label,value,xml)     # Recurse
        end
      elsif obj.is_a?(Hash)
        if obj.any?
          xml.send(label) do
            obj.each do |key, value|
              obj_to_xml(key,value,xml)   # Recurse
            end
          end
        end
      else
        xml.send(label,obj)               # Create <label>obj(value)</label>
      end #if 
    else
      _xml = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        xml.root do                       # Wrap everything in one element.
         obj_to_xml(label, obj ,xml)      # Start the recursion with a custom name.
        end #_xml
      end #Nokogiri
    end #if
    _xml
  end #def 
  
end #class
