require 'blorgit'
$base = File.dirname(__FILE__)
$themes = File.join($base, 'themes')
$blogs = Blog.base_directory

desc "Return configuration information about the current setup"
task :info do
  puts YAML.dump($config)
  puts "base: #{$base}"
  puts "blog_directory: #{$blogs}"
end

desc "list the available themes"
task :themes do
  themes.each{ |theme| puts theme }
end

namespace :deploy do
  
  desc "create a fresh blogs directory"
  task :new => :check do
  end

  desc "drop a new default config file into the blogs/.blorgit.yml"
  task :config do
  end

  desc "compile the sass css file and drop it into blogs/stylesheet.css"
  task :css do
  end

  desc "apply a given theme"
  task :theme do
    theme = (ENV['THEME'] or ENV['theme'])
    if theme
      %x{sass #{File.join($themes, theme, 'style.sass')} #{File.join($blogs, $config['style'])}}
    else
      puts "Must pass a theme, for example rake deploy:theme THEME=default"
      abort
    end
  end
end

def themes
  Dir.entries($themes).
    select{ |f| FileTest.directory?(File.join($themes, f)) }.
    reject{ |f| f.match(/^\./) }.each do |theme|
  end
end
