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
  task :fresh do
    if FileTest.exists?($blogs)
      puts "A blogs directory already exists at #{$blogs}"
      abort
    else
      FileUtils.mkdir_p($blogs)
    end
  end

  desc "drop a new default config file into the blogs/.blorgit.yml"
  task :config do
    config = File.join($blogs, '.blorgit.yml')
    if FileTest.exists?(config)
      puts "A config file already exists at #{config}"
      abort
    else
      File.open(config, 'w') {|f| f < YAML.dump({
                                                  :title => 'Blorgit',
                                                  :index => 'index',
                                                  :recent => -1,
                                                  :style => 'stylesheet.css',
                                                  :sidebar_label => 'All Blogs'
                                                }) }
      end
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
