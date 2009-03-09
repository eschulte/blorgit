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
