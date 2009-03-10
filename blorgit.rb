# blorgit --- blogging with org-mode
$blogs_dir  ||= File.join(File.dirname(__FILE__), 'blogs')
$url_prefix ||= '/'
require 'rubygems'
require 'sinatra'
require 'yaml'
require 'backend/init.rb'

# Configuration (http://sinatra.rubyforge.org/book.html#configuration)
#--------------------------------------------------------------------------------
puts "blogs_dir=#{$blogs_dir}"
puts "url_prefix=#{$url_prefix}"
config_file = File.join($blogs_dir, '.blorgit.yml')
$config = File.exists?(config_file) ? YAML.load(File.read(config_file)) : {}
set(:public, $blogs_dir)
enable(:static)
set(:app_file, __FILE__)
set(:haml, { :format => :html5, :attr_wrapper  => '"' })
set(:url_prefix, $url_prefix)
use_in_file_templates!

# Routes (http://sinatra.rubyforge.org/book.html#routes)
#--------------------------------------------------------------------------------
get('/') { redirect(path_for($config['index'])) }

get(/^\/\.edit\/(.*)?$/) do
  pass unless $config['editable']
  path, format = split_format(params[:captures].first)
  if @blog = Blog.find(path)
    @title = @blog.title
    @files = (Blog.files(path) or [])
    haml :edit
  else
    "Nothing here to edit."
  end
end

get(/^\/(.*)?$/) do
  path, format = split_format(params[:captures].first)
  @files = (Blog.files(path) or [])
  @blog = Blog.find(path)
  pass unless (@blog or File.directory?(Blog.expand(path)))
  if format == 'html'
    @title = @blog ? @blog.title : path
    haml :blog
  elsif @blog
    content_type(format)
    attachment extension(@blog.path, format)
    @blog.send("to_#{format}")
  else
    pass
  end
end

post(/^\/(.*)?$/) do
  path, format = split_format(params[:captures].first)
  if @blog = Blog.find(path)
    if params[:comment]
      return "Sorry, review your math..." unless params[:checkout] == params[:captca]
      @blog.add_comment(Comment.build(2, params[:title], params[:author], params[:body]))
      @blog.save
      redirect(path_for(@blog))
    elsif params[:edit] and $config['editable']
      protected!
      @blog.body = params[:body]
      @blog.save
      redirect(path_for(@blog))
    end
  else
    pass
  end
end

post(/^\/.search/) do
  @query = params[:query]
  @results = Blog.search(params[:query])
  haml :results
end

# Helpers (http://sinatra.rubyforge.org/book.html#helpers)
#--------------------------------------------------------------------------------
helpers do
  def split_format(url) url.match(/(.+)\.(.+)/) ? [$1, $2] : [url, 'html'] end

  def path_for(path, opts ={})
    path = (path.class == Blog ? path.path : path)
    File.join(options.url_prefix, extension(path, (opts[:format] or nil)))
  end
  
  def show(blog, options={}) haml("%a{ :href => '#{path_for(blog)}' } #{blog.title}", :layout => false) end

  def comment(blog, parent_comment) end
  
  def extension(path, format = nil) (path.match(/^(.+)\..+$/) ? $1 : path)+(format ? "."+format : '') end

  def time_ago(from_time)
    distance_in_minutes = (((Time.now - from_time.to_time).abs)/60).round
    case distance_in_minutes
    when 0..1            then 'about a minute'
    when 2..44           then "#{distance_in_minutes} minutes"
    when 45..89          then 'about 1 hour'
    when 90..1439        then "about #{(distance_in_minutes.to_f / 60.0).round} hours"
    when 1440..2879      then '1 day'
    when 2880..43199     then "#{(distance_in_minutes / 1440).round} days"
    when 43200..86399    then 'about 1 month'
    when 86400..525599   then "#{(distance_in_minutes / 43200).round} months"
    when 525600..1051199 then 'about 1 year'
    else                      "over #{(distance_in_minutes / 525600).round} years"
    end
  end

  # from http://www.sinatrarb.com/faq.html#auth
  def protected!
    response['WWW-Authenticate'] = %(Basic realm="username and password required") and \
    throw(:halt, [401, "Not authorized\n"]) and \
    return unless ((not $config['auth']) or authorized?)
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == $config['auth']
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
    :javascript
      function toggle(item) {
        el = document.getElementById(item);
        if(el.style.display == "none") { document.getElementById(item).style.display = "block" }
        else { document.getElementById(item).style.display = "none" }
      }
  %link{:rel => "stylesheet", :type => "text/css", :href => path_for($config['style'], :format => 'css')}
  %title= "#{$config['title']}: #{@title}"
  %body
    #container
      #titlebar= render(:haml, :titlebar, :layout => false)
      #insides
        #sidebar= render(:haml, :sidebar, :locals => { :files => @files }, :layout => false)
        #contents= yield

@@ titlebar
#title_pre
#title
  %a{ :href => path_for(''), :title => 'home' }= $config['title']
#title_post
#search= haml :search, :layout => false
- if @blog
  #actions
    %ul
      - if $config['editable']
        %li
          %a{ :href => path_for(File.join(".edit", @blog.path)), :title => "edit #{@title}" } edit
      %li
        %a{ :href => path_for(@blog, :format => 'org'), :title => 'download as org-mode' } .org
      %li
        %a{ :href => path_for(@blog, :format => 'tex'), :title => 'download as LaTeX' } .tex
#title_separator

@@ sidebar
#recent= haml :recent, :layout => false
- if @files
  #dir= haml :dir, :locals => { :files => files }, :layout => false

@@ search
%form{ :action => path_for('.search'), :method => :post, :id => :search }
  %ul
    %li
      %input{ :id => :query, :name => :query, :type => :text, :size => 12 }
    %li
      %input{ :id => :search, :name => :search, :value => :search, :type => :submit }

@@ recent
%label Recent
%ul
  - Blog.all.sort_by(&:ctime).reverse[(0..($config['recent'] - 1))].each do |blog|
    %li
      %a{ :href => path_for(blog)}= blog.title

@@ dir
%label Directory
%ul
  - files.each do |file|
    %li
      %a{ :href => path_for(file) + (File.directory?(Blog.expand(file)) ? "/" : "") }= File.basename(file)

@@ results
#results_list
  %h1
    Search Results for
    %em= "/" + @query + "/"
  %ul
    - @results.sort_by{ |b,h| -h }.each do |blog, hits|
      %li
        %a{ :href => path_for(blog) }= blog.name
        = "(#{hits})"

@@ edit
%h1= "Edit #{@title}"
%form{ :action => path_for(@blog), :method => :post, :id => :comment_form }
  %textarea{ :id => :body, :name => :body, :rows => 28, :cols => 82 }= @blog.body
  %br
  %input{ :id => :submit, :name => :edit, :value => :update, :type => :submit }
  %a{ :href => path_for(@blog) } Cancel

@@ blog
- if @blog
  #blog_body= @blog.to_html
  - unless @blog.commentable == 'disabled'
    #comments= render(:haml, :comments, :locals => {:comments => @blog.comments, :commentable => @blog.commentable}, :layout => false)
- else
  #dir= haml :dir, :locals => { :files => @files }, :layout => false

@@ comments
#existing_commment
  %label= "Comments (#{comments.size})"
  %ul
  - comments.each do |comment|
    %li
      %ul
        %li
          %label title
          = comment.title
        %li
          %label author
          = comment.author
        %li
          %label date
          = time_ago(comment.date) + " ago"
        %li
          %label comment
          %div= Blog.string_to_html(comment.body)
- unless commentable == 'closed'
  #new_comment
    %label{ :onclick => "toggle('comment_form');"} Post a new Comment
    %form{ :action => path_for(@blog), :method => :post, :id => :comment_form, :style => 'display:none' }
      - equation = "#{rand(10)} #{['+', '*', '-'].sort_by{rand}.first} #{rand(10)}"
      %ul
        %li
          %label name
          %input{ :id => :author, :name => :author, :type => :text }
        %li
          %label title
          %input{ :id => :title, :name => :title, :type => :text, :size => 36 }
        %li
          %label comment
          %textarea{ :id => :body, :name => :body, :rows => 8, :cols => 68 }
        %li
          %input{ :id => :checkout, :name => :checkout, :type => :hidden, :value => eval(equation) }
          %span
          %p to protect against spam, please answer the following
          = equation + " = "
          %input{ :id => :captca, :name => :captca, :type => :text, :size => 4 }
        %li
          %input{ :id => :submit, :name => :comment, :value => :comment, :type => :submit }

-#end-of-file # this is for Sinatra-Mode (http://github.com/eschulte/rinari/tree/sinatra)
