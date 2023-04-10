# redmine_more_previews

Redmine plugin to preview various file types in redmine's preview pane. Works for issue attachments, documents module, files module and repositories. This plugin is designed to work with own plugins. That is plugins for plugins.
To preview files this plugin converts the previewed file content to either
 - pdf
 - png, jpg or gif
 - html or inline html
 - text, or
 - xml
 
The appropriate conversion type(s) is/are up to the plugin developer. The available conversion option can be chosen on the plugin configuration page. 
The plugin was developed with thread safety in mind. With caching enabled, it should stand even higher loads.

Currently, there exist the following plugins:

---

![Libre](doc/libre/logo.png "Libre")

This plugin requires LibreOffice to be installed on your system. LibreOffice must be reachable with "soffice" to the user, the redmine service is executed by.

Libre uses LibreOffice to do the conversion. Libre converts almost everything LibreOffice can convert:

.csv , .doc , .docm , .docx , .dotm , .dotx , .fodg , .fodp , .fods , .fodt , .odb , .odc , .odf , .odg , .odi , .odm , .odp , .ods , .odt , .otg , .oth , .otp , .ots , .ott , .oxt , .potm , .potx , .ppt , .pptm , .pptx , .rtf , .sda , .sdc , .sdd , .sdp , .sds , .sdw , .sgl , .smf , .stc , .std , .sti , .stw , .sxc , .sxd , .sxg , .sxi , .sxm , .sxw , .vor , .xls , .xlsm , .xlsx , .xltm , .xltx 

to either pdf, html, inline, png, jpg or gif.

Please note, that not all conversions have been thoroughly tested yet. Please send files for a conversion test to me, if you are uncertain if your files get converted an can be viewed in a browser. Further, please note that the conversion accuracy strongly depends on the availability of installed fonts. Please consult the LibreOffice portals to see how to install fonts.

Currently, thoroughly tested are: .csv, .doc, .docx, .ppt, .pptx, .xls, .xlsx, .oddt, .rtf

---

![Cliff](doc/cliff/logo.png "Cliff")

This plugin requires no additional software to be installed on your system. 

Cliff converts

.mime, .eml 

to html.

You can view the .eml file almost like in a professional email viewer, see mail headers and download attachments. Cliff will sweep the .eml files from scripts, event attributes beginning with "on…", url() in css styles and external images. To do an unsafe preview, you can press a button do so and if you trust the .eml or .mime file

---

![Mark](doc/mark/logo.png "##mark##")

Mark uses Pandoc to do the conversion. Currently supported is:

.md, .textile, .html

---

![Peek](doc/peek/logo.png "Peek")

Peek lets you preview pdf-Files in the browser. Peek uses imagemagick to do the conversion. Imagemagick uses Ghostscript as a delegate to handle pdf files. Pdf previews can be the full pdf or a png, jpg or gif of the first page. Please note, that the conversion resolution strongly depends on your ImageMagick's configuration in the delegates file. Please consult ImageMagick's configuration help to edit the delegates file.

---

![Zippy](doc/zippy/logo.png "Zippy")

Zippy lets you preview zip, tgz or tar-Files in the browser. Click on an entry to download one individual file from within the compressed file.

---

![Maggie](doc/maggie/logo.png "Maggie")

Maggie converts images from one format to another and downscales images.

---

![Pass](doc/pass/logo.png "Pass")

Pass lets you pass through html.

---

![Vince](doc/vince/logo.png "Vince")

Vince lets you preview .vcf (vCard) files.

---

![NilText](doc/nil_text/logo.png "NilText") *DO NOT USE IN PRODUCTION* 

NilText lets you see, which data are available for a file conversion. NilText not suited for production use. You can peruse this plugin to learn about the plugin functionality. Please note, that this plugin may reveal a password of a repository. Like all other plugins, **this plugin is deactivated by default**.

---

### Install

1. download plugin and copy plugin folder redmine_more_previews go to Redmine's plugins folder

2. go to redmine root folder

`bundle install`

to install necessary gems. Install LibreOfiice (for Libre) and/or Pandoc for (for Mark)

3. restart server f.i.  

`sudo /etc/init.d/apache2 restart`

### Uninstall

1. go to plugins folder, delete plugin folder redmine_attachment_categories

`rm -r redmine_more_previews`

3. restart server f.i.  

`sudo /etc/init.d/apache2 restart`

### Use

* Go to Administration -> Plugins -> Redmine More Previews Configuration 

Choose the following options

 - use embed-tag or iframe-tag
 - cache previews (speeds views, may bloat your rails root's tmp folder a bit)
 - activate sub plugins above
 - for each sub plugin activate the file extension for files you want to preview (if you choose two sub plugins converting the same file type, then a warning will be issued and the last activated sub plugin will do the conversion).

**Have fun!**

### Localisations

* English
* German
* Spanish
* French
* Japanese
* Portugese (Brazil)
* Portugese
* Russian
* Chinese

Native speakers: please help to improve localizations

### Change-Log* 

**5.0.8**  
  - fixed File.exists? to File.exist?
  - fixed URI.esacape to URI.encode\_www\_form\_component for zippy
  - fixed long standing issue with links in zippy's inline zip file content tables
        
**5.0.7**  
  - yet another patch to please Zeitwerk
        
**5.0.6**  
  - yet another patch to please Zeitwerk
        
**5.0.5**  
  - yet another patch to please Zeitwerk
        
**5.0.4**  
  - added more include statements to please Zeitwerk
        
**5.0.3**
  - removed legacy code to please Zeitwerk
        
**5.0.2**
  - altered sequence of file loading to please Zeitwerk
        
**5.0.1**
  - fixed some new locale files
        
**5.0.0**
  - running under Redmine 5
        
**4.1.3**
  - fixed repositories controller patch not finding project
  - added support for development mode
        
**4.1.2**
  - added conditional loading of mimemgaic/overlay
  - added capability of activating on a per project base
         
**4.1.1**
  - added pagination links to attachments preview page and 
    entry (repository) preview page
  - fixed japanese localization
         
**4.0.1a**
  - added method to prevent plugin from registering, if mimemagic is not installed.
    In this case. a permanent error message is displayed.
         
**4.0.0a**
  - switched to patching existing redmine classes with 'prepend' instead of an 
    alias chain, therefore loosing compatibility with redmine versions less 
    than 4.0. Due to many redmine plugins now using the prepend method, introduced 
    with Rails 5, the coexistence of 'prepend' and an alias chain methodology,
    whereby 'prepend' and the alias chain methodology is incompatible with 
    each other, the coexistence cannot be further maintained.
         
---
         
**3.2.0**
  - added new previewer "vince" to preview vcf virtual business cards
         
**3.1.2**
  - minor code additions
         
**3.1.1**
  - added fix to zippy's Gemfile
         
**3.1.0**
  - improved rendering of conversions to images
  - added new converter Maggie, which converts images to one another
  - updated nil text comments
         
**3.0.3**
  - fixed handling filenames with whitespace for converter 'mark'
         
**3.0.2**
  - added converter named 'pass'
         
**3.0.1**
  - fixed 'File' bug for converter 'mark'
         
**3.0.0b**
  - rearranged code and files to better match zeitwerk
  - made compatible with development mode
  - beta quality
         
**2.0.11**
  - amended autoload paths
         
**2.0.10 
  - fixed broken api calls for attachment
         
**2.0.9**
  - simplified hooks views for cliff
         
**2.0.8**
  - fixed tmpfile scheme (internals)
         
**2.0.7**
  - added support for non-ascii email headers in cliff
         
**2.0.6**
  - added timezone support for mail dates in cliff
         
**2.0.5**
  - fixed dependency on mimemagick after license change
**2.0.4**
         
  - fixed mimemagick dependency after license change
         
**2.0.3**
  - fixed windows glitch for File.read
         
**2.0.2**
  - fixed virgin startup bug. On some events plugin crashes on first time use
  - removed UserInstallation parameter in libre for windows platforms
  - fixed missing assets bug
         
**2.0.1** 
  - fixed last minute issues
         
**2.0.0** 
  - Recoded and published, supports redmine 3+, redmine 4+
         
**1.0.0** 
  - Running on Redmine 3.4.6, never published

# replaces
This plugin replaces 
 - redmine_preview_office, 
 - redmine_preview_docx and 
 - redmine_preview_pdf

# best with
This plugin ideally works together with
 - redmine_preview_inline
 - redmine_all_thumbnails
 
# a note on caching
This plugin caches conversions in the Rail tmp-directory. For large repositories (f.i. firm file servers) each conversion will store a copy of the conversion file in the Rails tmp directory and thus the tmp directory may become as large or even larger as the original repository. There are two ways to handle such a situation: 1. swipe Rails tmp/more_previews directory frequently, 2. change the storage path in the plugin's init.rb file to choose a mass storage, which can handle the amount of data.

If two users choose to reload (do a new conversion) concurrently, then thread safety is honored.
 
