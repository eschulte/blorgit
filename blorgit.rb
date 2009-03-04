# blorgit --- blog runing with org-mode git
require 'rubygems'
require 'sinatra'
require 'backend/init.rb'

# Routes
#--------------------------------------------------------------------------------
TITLE = "blorgit"
set(:public, Blog.base_directory)
enable(:static)
set(:app_file, __FILE__)
set(:haml, { :format => :html5, :attr_wrapper  => '"' })
use_in_file_templates!

get('/') { directory('./') }

get(/^\/(.*)?$/) do
  path, format = split_format(params[:captures].first)
  if @blog = Blog.find(path)
    if format == 'html'
      @title = @blog.title
      haml :blog
    else
      content_type(format)
      @blog.send("to_#{format}")
    end
  elsif @entries = Blog.entries(path)
    directory(path)
  else
    pass
  end
end

# Helpers
#--------------------------------------------------------------------------------

helpers do
  def directory(dir)
    @title = dir
    @dir = dir
    @entries = Blog.entries(dir).reject{|p| p.match(/^\./) }
    haml :list
  end
  
  def split_format(url) url.match(/(.+)\.(.+)/) ? [$1, $2] : [url, 'html'] end

  def path_for(blog, action = :show, options ={})
    File.join('/', (action == :edit) ? '.edit/' : '', extension(blog.path, (options[:format] or nil)))
  end
  
  def show(blog, options={}) haml("%a{ :href => '#{path_for(blog)}' } #{blog.title}", :layout => false) end

  def comment(blog, parent_comment) end
  
  def extension(path, format = nil) (path.match("^(.+)\\.(.+?)$") ? $1 : path) + (format or '') end

end

# HAML Templates (http://haml.hamptoncatlin.com/)
#--------------------------------------------------------------------------------
__END__
@@ layout
!!!
%html
  %head
    %meta{'http-equiv' => "content-type", :content => "text/html;charset=UTF-8"}
    %link{:rel => "stylesheet", :type => "text/css", :href => "/.stylesheet.css"}
    %title= "blorgit: #{@title}"
  %body
    #titlebar= render :haml, :titlebar, :layout => false
    %div{:style => 'clear:both;'}
    #sidebar= render :haml, :sidebar, :layout => false
    #contents= yield

@@ list
#list
%ul
- @entries.each do |entry|
  %li
    %a{ :href => File.join(@dir, entry) }= entry

@@ titlebar
#title
  %a{ :href => '/', :title => :blorgit } blorgit

@@ sidebar
%ul
- Blog.all.each do |blog|
  %li
    %a{ :href => path_for(blog)}= blog.title

@@ blog
#blog_body= @blog.to_html
#comments= render :haml, :comments, :locals => {:comments => @blog.comments}, :layout => false

@@ comments
%label= "Comments (#{comments.size})"
%ul
- comments.each do |comment|
  %li#comment
    %p
      %label title
      comment.title
    %p
      %label author
      comment.author
    %p
      %label date
      comment.date
    %p
      %label body
      comment.body

-#end-of-file
