[blog](http://wikipedia.org/wiki/Blog "web log")-[org](http://orgmode.org "emacs org-mode")-[git](http://git-scm.com/ "open source, distributed, version controll")
================================================================================

Blorgit is a blogging engine which uses [Emacs Org-Mode](http://orgmode.org) for markup, runs on the
[Sinatra](http://www.sinatrarb.com/) mini web framework, and is amenable to posting and maintenance
through [git](http://git-scm.com/).  Blorgit supports **searching**, **editing** through the web
interface, handles **comments** which are automatically added to a "COMMENTS" header in your
org-mode files, and has packaged **themes** available through
[blorgit_themes](http://github.com/eschulte/blorgit_themes/tree/master).

[5 Step Install](#install)

1. [Install the Required gems](#1)
2. [Install blorgit](#2)
3. [Create Blogs Directory](#3)
4. [Start Server](#4)
5. [View in Browser](#5)

[Additional Info](#additional-info)

* [Changing Configuration Options](#a1)
* [Git](#a2)
* [Change blogs directory / Deploying to a Server / <tt>Rackup</tt> / <tt>Thin</tt>](#a3)

<div id="install">
<h2>5 Step Install</h2>
</div>

<div id="1">
<h3>(1) Install the required gems</h3>
</div>

<pre>
sudo gem install rake sinatra haml activesupport
</pre>

<div id="2">
<h3>(2) Install blorgit</h3>
</div>

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

<div id="3">
<h3>(3) Create Blogs Directory</h3>
</div>

Create a blogs directory (in <tt>~/blogs/</tt>) with the default
configuration (To change the location of the blogs directory edit
<tt>blorgit.yml</tt> in this directory).  Apply the default minimal
theme (for a list of available themes run <tt>rake themes</tt>)

<pre>
rake new
rake themes:default
</pre>

<div id="4">
<h3>(4) Start Server</h3>
</div>

Start your sinatra web server with the following command

<pre>
ruby blorgit.rb
</pre>

<div id="5">
<h3>(5) View in Browser</h3>
</div>

View at [localhost:4567](http://localhost:4567)


<div id="additional-info">
<h2>Additional Info</h2>
</div>

<div id="a1">
<h3>Changing Configuration Options</h3>
</div>

The configuration is controlled through a [YAML](http://www.yaml.org)
file located at <tt>.blorgit.yml</tt> in the base of your blogs
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

<div id="a2">
<h3>Git</h3>
</div>

If you're wondering where git comes in, initialize your new blogs
directory as a git repo, and post all future blogs, moderate comments
and commentability of blogs, and manage configuration through git.

<pre>
cd ./blogs
git init
git add .
git commit -a -m "initial commit"
</pre>

<div id="a3">
<h3>Change blogs directory / Deploying to a Server / <tt>Rackup</tt> / <tt>Thin</tt></h3>
</div>

To change the location of the blogs directory, or for pointers on
deploying behind a web-server, see the <tt>config.yml</tt> global
configuration file and the <tt>run.ru</tt> rackup file.  To run using
the run.ru rackup file use a command like the following (requires the
<tt>thin</tt> gem <tt>sudo gem install thin</tt>)

<pre>
./run.ru -sthin -p4567
</pre>
