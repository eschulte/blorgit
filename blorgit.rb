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

get(/^\/(.*)$/) do
  path, format = split_format(params[:captures].first)
  if FileUtils.directory?(path)
  pass unless @blog = Blog.find(path)
  case format
  when 'tex'
    send_data(@blog.to_latex,
              :filename => "#{@blog.name}.tex",
              :type => 'text/tex',
              :last_modified => @blog.updated_at.httpdate)
  when 'org'
    send_data(@blog.body,
              :filename => "#{@blog.name}.org",
              :type => 'text/org-mode',
              :last_modified => @blog.updated_at.httpdate)
  else
    haml :blog
  end
end

post(/^\/(.*)$/) do
  # post a comment to this blog
end

# Helpers
#--------------------------------------------------------------------------------

helpers do
  def split_format(url)
    url.match(/(.+)\.(.+)/) ? [$1, $2] : [url, nil]
  end
  
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
    %meta{'http-equiv' => "content-type", :content => "text/html;charset=UTF-8"}
    %link{:rel => "stylesheet", :type => "text/css", :href => "/stylesheet.css"}
    %title= "#{TITLE}: #{@blog.title}"
  %body
    #titlebar= render :haml, :titlebar
    %div{:style => 'clear:both;'}
    #sidebar= render :haml, :sidebar
    #blog_body= @blog.to_html
    #comments= render :haml, :comments, :locals => {:comments => @blog.comments}

@@ titlebar
#title
  %a{ :href => '/', :title => TITLE }
    %label= TITLE

#grep
  %form{:action => '.grep', :method => :post}
    %input{:name => :query, :id => :query, :type => :text}
    %input{:name => :grep, :type => :submit, :value => :grep}

@@ sidebar
%ul
- Blog.all.each do |blog|
  %li= show(blog)

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

@@ git
#git information on the git repository

-#end-of-file
