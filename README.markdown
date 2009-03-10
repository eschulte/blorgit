<style>h1{color:e3e3e3;}a{text-decoration:none; color:a0a0a0;}a:hover{color:black;}</style>

[blog](http://wikipedia.org/wiki/Blog "web log")-[org](http://orgmode.org "emacs org-mode")-[git](http://git-scm.com/ "open source, distributed, version controll")
================================================================================

Install the required gems

<pre>
sudo gem install sinatra haml activerecord
</pre>

Install blorgit

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

Create a blogs directory with the default configuration, and the
default minimal theme

<pre>
rake new
rake themes:default
</pre>

Start sinatra with

<pre>
ruby blorgit.rb
</pre>

View at [localhost:4567](http://localhost:4567)

If you're wondering where git comes in, initialize your new blogs
directory as a git repo, and post all future blogs, moderate comments
and commentability of blogs, and manage configuration through git.

<pre>
cd ~/blogs
git init
git add .
git commit -a -m "initial commit"
</pre>

For an example of instillation behind a web server see the [deployable
branch](http://github.com/eschulte/blorgit/tree/deployable)

