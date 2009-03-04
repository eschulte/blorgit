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

get('/.git') { @git = Blog.git; haml :git }

# read a page
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

get(/^\/\.edit\/(.*)?$/) do
  path, format = split_format(params[:captures].first)
  if @blog = Blog.find(path)
    @title = @blog.title
    haml :edit
  else
    pass
  end
end

# update a page
put(/^\/(.*)?$/) do
  path, format = split_format(params[:captures].first)
  if @blog = Blog.find(path)
    @blog.body = params[:body]
    if @blog.save_and_commit(:message => params[:message], :author => git_author)
      @title = @blog.title
      haml :blog
    end
  else
    pass
  end
end

post(/^\/(.*)$/) do
  # post a comment to this blog
end

# Helpers
#--------------------------------------------------------------------------------

helpers do
  # user helpers
  def logged_in?() false end
  def current_user() nil end
  def ensure_role(role) current_user.role?(role) end
  def login(user, password) end
  def git_author() "Some One <someone@example.org>" end
  def show_git_author(author)
    haml("%a{ :href => 'mailto:#{author.email}', :title => 'email #{author.name}'} #{author.name}",
         :layout => false)
  end
  
  # blog helpers
  def directory(dir)
    @title = dir
    @dir = dir
    @entries = Blog.entries(dir).reject{|p| p.match(/^\./) }
    haml :list
  end
  
  def split_format(url) url.match(/(.+)\.(.+)/) ? [$1, $2] : [url, 'html'] end

  def path_for(blog, action = :show, options ={})
    File.join('/', (action == :edit) ? '.edit/' : '',
              force_extension(blog.path, (options[:format] or nil)))
  end
  
  def show(blog, options={}) haml("%a{ :href => '#{path_for(blog)}' } #{blog.title}", :layout => false) end

  def comment(blog, parent_comment) end
  
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
#user= render :haml, :user, :layout => false
%div{:style => 'clear:both;'}
#grep
  %form{:action => '.grep', :method => :post}
    %input{:name => :query, :id => :query, :type => :text, :size => 24}
    %input{:name => :grep, :type => :submit, :value => :grep}

@@ user
#login
  - unless logged_in?
    %form{:action => '.login', :method => :post}
      %input{:name => :username, :id => :username, :type => :text, :size => 12}
      %input{:name => :password, :id => :password, :type => :password, :size => 12}
      %input{:name => :login, :type => :submit, :value => :login}
  - else
    %span= username

@@ sidebar
%ul
- Blog.all.each do |blog|
  %li
    %a{ :href => path_for(blog)}= blog.title

@@ blog
#info
  %ul
    %li
      #commit_info
        %label last commit:
        - if commit = @blog.last_commit
          %span= "#{show_git_author(commit.author)} at #{commit.date}"
        - else
          %span Unknown
#actions
  %ul
    %li
      %a{ :href => path_for(@blog, :edit) } edit
#blog_body= @blog.to_html
#comments= render :haml, :comments, :locals => {:comments => @blog.comments}, :layout => false

@@ edit
#edit
  %form{:action => "/"+force_extension(@blog.path), :method => :post}
    %input{:type => :hidden, :name => :_method, :value => :put}
    %textarea{:name => :body, :id => :body, :cols => 100, :rows => 34}= @blog.body
    %textarea{:name => :message, :id => :message, :cols => 70}
    %br
    %input{:name => :edit, :type => :submit, :value => :commit}
    %a{ :href => '/'+force_extension(@blog.path) } cancel

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
