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

get('/') { redirect '/index' }

get('/.git') { @git = Blog.git; haml :git }

get(/^\/(.*)$/) { pass unless @blog = Blog.find(params[:captures].first); haml :blog }

post(/^\/(.*)$/) do
  # post a comment to this blog
end

# Helpers
#--------------------------------------------------------------------------------

helpers do
  def show(blog, options = {})
    haml "%a{ :href => '/#{force_extension(blog.path, (options[:format] or nil))}' } #{blog.title}"
  end
  
  def comment(blog, parent_comment)
  end
  
  # if new_extension is not true, then any existing extension will be stripped
  def force_extension(path, new_extension = nil)
    path = $1 if path.match("^(.+)\\.(.+?)$")
    if new_extension
      "#{path}.#{new_extension}"
    else
      path
    end
  end

end

# HAML Templates (http://haml.hamptoncatlin.com/)
#--------------------------------------------------------------------------------
__END__
@@ blog
!!!
%html
  %head
    %title= "#{TITLE}: #{@blog.title}"
  %body
    #sidebar= render :haml, :sidebar
    #blog_body= @blog.to_html
    #comments= render :haml, :comments, :locals => {:comments => @blog.comments}

@@ sidebar
#sidebar
  %ul
  - Blog.all.each do |blog|
    %li= show(blog)

@@ comments
#comments
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

@@ git
#git information on the git repository
