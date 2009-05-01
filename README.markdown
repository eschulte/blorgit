[blog](http://wikipedia.org/wiki/Blog "web log")-[org](http://orgmode.org "emacs org-mode")-[git](http://git-scm.com/ "open source, distributed, version controll")
================================================================================

Blorgit is a blogging engine which uses [Emacs Org-Mode](http://orgmode.org) for markup, runs on the
[Sinatra](http://www.sinatrarb.com/) mini web framework, and is amenable to posting and maintenance
through [git](http://git-scm.com/).  Blorgit supports **searching**, **editing** through the web
interface, handles **comments** which are automatically added to a "COMMENTS" header in your
org-mode files, and has packaged **themes** available through
[blorgit_themes](http://github.com/eschulte/blorgit_themes/tree/master).

## 5 Step Install

### (1) Install the required gems

<pre>
sudo gem install rake sinatra haml activesupport
</pre>

### (2) Install blorgit

<pre>
git clone git://github.com/eschulte/blorgit.git
</pre>

Update the submodules of blorgit to provide file based persistence
([active\_file](http://github.com/eschulte/active_file/tree/master)),
org-mode interaction
([acts\_as\_org](http://github.com/eschulte/acts_as_org/tree/master)),
and themes
([blorgit\_themes](http://github.com/eschulte/blorgit_themes/tree/master))

<pre>
cd blorgit
git submodule init
git submodule update
</pre>

### (3) Create Blogs Directory

Create a blogs directory (in <tt>~/blogs/</tt>) with the default
configuration (To change the location of the blogs directory edit
<tt>blorgit.yml</tt> in this directory).  Apply the default minimal
theme (for a list of available themes run <tt>rake themes</tt>)

<pre>
rake new
rake themes:default
</pre>

### (4) Start Servers

#### Emacs Server

Starting your emacs server allows Emacs to act as a server which can
then export org-mode file to html.  To do this we simply need to load
the <tt>org-interaction.el</tt> file in <tt>acts_as_org</tt>.  You can
do this by executing the following in emacs

<pre>
M-x load-file /path/to/blorgit/backend/acts_as_org/elisp/org-interaction.el
</pre>

or with the following shell command

<pre>
emacs -l backend/acts_as_org/elisp/org-interaction.el
</pre>

#### Web Server

Start your sinatra web server with the following command

<pre>
ruby blorgit.rb
</pre>

### (5) View in Browser

View at [localhost:4567](http://localhost:4567)


## Additional Info

### Changing Configuration Options

The configuration is controlled through a [YAML](http://www.yaml.org)
file located at <tt>blorgit.yml</tt> in your blorgit instillation
directory.  Configuration variables can be used to control the
**title**, **index page**, **stylesheet**, the number of **recent
entries** shown in the sidebar, **commentability**, **editability**
and optional **password protection** for posting edits, .  The default
configuration is...

<pre>
--- 
title: Blorgit
index: index
style: stylesheet.css
recent: 5
commentable: true
editable: false
auth: 
- admin
- password
</pre>

### Git

If you're wondering where git comes in, initialize your new blogs
directory as a git repo, and post all future blogs, moderate comments
and commentability of blogs, and manage configuration through git.

<pre>
cd ./blogs
git init
git add .
git commit -a -m "initial commit"
</pre>

### Change blogs directory / Deploying to a Server / <tt>Rackup</tt> / <tt>Thin</tt>

To change the location of the blogs directory, or for pointers on
deploying behind a web-server, see the <tt>config.yml</tt> global
configuration file and the <tt>run.ru</tt> rackup file.  To run using
the run.ru rackup file use a command like the following (requires the
<tt>thin</tt> gem <tt>sudo gem install thin</tt>)

<pre>
./run.ru -sthin -p4567
</pre>
