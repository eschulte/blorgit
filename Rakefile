require 'blorgit'
$base = File.dirname(__FILE__)
$blogs = Blog.base_directory
$themes = File.join($base, 'themes')
def themes
  Dir.entries($themes).
    select{ |f| FileTest.directory?(File.join($themes, f)) }.
    reject{ |f| f.match(/^\./) }.each do |theme|
  end
end

# Load theme rake files
Dir[File.join(File.dirname(__FILE__), "themes", "*", "*.rake")].each { |ext| load ext }

# handle exported files
def all_exported(dir) Dir.chdir($blogs){ Dir['**/.exported_*'].each{ |path| yield(path) } } end
namespace :exported do
  desc "list all temporary exported files"
  task :list do
    all_exported($blogs){ |path| puts path }
  end

  desc "delete all temporary exported files"
  task :delete do
    all_exported($blogs){ |path| FileUtils.rm(path) }
  end
end

desc "return configuration information about the current setup"
task :info do
  puts YAML.dump($global_config[:config])
  puts "base: #{$base}"
  puts "blog_directory: #{$blogs}"
end

desc "list the available themes"
task :themes do
  themes.each{ |theme| puts theme }
end

desc "create a new blorgit instance"
task :new => [:index]

desc "drop a minimal index page into #{File.join($blogs, 'index.org')}"
task :index do
  config = File.join($blogs, 'index.org')
  if FileTest.exists?(config)
    puts "A file already exists at #{config}"
    abort
  else
    File.open(config, 'w') do |f|
      f << <<ORG
#+TITLE:    blorgit
#+OPTIONS: toc:nil ^:nil

Welcome to *blorgit*, the blog backed by [[http://orgmode.org][org-mode]].

Edit the =index.org= text file in your base directory to change the
contents of this page.

To remove the [edit] button (and the ability for users to edit page on
this site) remove the

: editable: true

 line from the =.blorgit.yml= configuration file inside your =blogs=
directory (Note it will still be possible for users to make comments
on the site.).  To add password protection to edits add lines like the
following to your configuration.

: auth: 
: - username
: - password

All configuration is handled through the =blogs/.blorgit.yml= file to
allow easy maintenance of the application through git (or your version
control system of choice).

ORG
    end
  end
end
