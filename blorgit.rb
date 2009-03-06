# blorgit --- blogging with org-mode
require 'rubygems'
require 'sinatra'
require 'yaml'
require 'backend/init.rb'

# Configuration (http://sinatra.rubyforge.org/book.html#configuration)
#--------------------------------------------------------------------------------
$config = YAML.load(File.read(File.join(Blog.base_directory, '.blorgit.yml')))
set(:public, Blog.base_directory)
set(:views, Blog.base_directory)
enable(:static)
set(:app_file, __FILE__)
set(:haml, { :format => :html5, :attr_wrapper  => '"' })
use_in_file_templates!

# Routes (http://sinatra.rubyforge.org/book.html#routes)
#--------------------------------------------------------------------------------
get('/') { redirect('/'+$config['index']) }

get(/^\/(.*)?$/) do
  path, format = split_format(params[:captures].first)
  if @blog = Blog.find(path)
    if format == 'html'
      @title = @blog.title
      haml :blog
    else
      content_type(format)
      attachment extension(@blog.path, format)
      @blog.send("to_#{format}")
    end
  elsif @entries = Blog.entries(path)
    directory(path)
  else
    pass
  end
end

post(/^\/(.*)?$/) do
  path, format = split_format(params[:captures].first)
  return "Sorry, review your math..." unless params[:checkout] == params[:captca]
  if @blog = Blog.find(path)
    @blog.add_comment(Comment.build(2, params[:name], params[:title], params[:comment]))
    @blog.save
    redirect(path_for(@blog))
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

  def path_for(blog, options ={}) File.join('/', extension(blog.path, (options[:format] or nil))) end
  
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
        if(el.style.visibility == "visible") { document.getElementById(item).style.visibility = "hidden" }
        else { document.getElementById(item).style.visibility = "visible" }
      }
  %link{:rel => "stylesheet", :type => "text/css", :href => "/"+$config['style']}
  %title= "#{$config['title']}: #{@title}"
  %body
    #container
      #titlebar= render(:haml, :titlebar, :layout => false)
      #title_separator
      #sidebar= render(:haml, :sidebar, :layout => false)
      #contents= yield

@@ list
#list
%ul
- @entries.each do |entry|
  %li
    %a{ :href => File.join(@dir, extension(entry)) }= entry

@@ titlebar
#title_container
  #logo_left
  #title
    %a{ :href => '/', :title => $config['title'] }= $config['title']
  #logo_right

@@ sidebar
%label= $config['sidebar_label']
- if($config['sidebar_text'] and $config['sidebar_text'].length > 0)
  %p= $config['sidebar_text']
%ul
  - Blog.all.sort_by(&:mtime)[(0..$config['recent'])].reverse.each do |blog|
    %li
      %a{ :href => path_for(blog)}= blog.title

@@ blog
#blog_body= @blog.to_html
- unless @blog.commentable == 'disabled'
  #comments= render(:haml, :comments, :locals => {:comments => @blog.comments, :commentable => @blog.commentable}, :layout => false)

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
    %form{ :action => path_for(@blog), :method => :post, :id => :comment_form, :style => 'visibility:hidden' }
      - equation = "#{rand(10)} #{['+', '*', '-'].sort_by{rand}.first} #{rand(10)}"
      %ul
        %li
          %label name
          %input{ :id => :name, :name => :name, :type => :text }
        %li
          %label title
          %input{ :id => :title, :name => :title, :type => :text, :size => 36 }
        %li
          %label comment
          %textarea{ :id => :comment, :name => :comment, :rows => 8, :cols => 68 }
        %li
          %input{ :id => :checkout, :name => :checkout, :type => :hidden, :value => eval(equation) }
          %span
          %p to protect against spam, please answer the following
          = equation + " = "
          %input{ :id => :captca, :name => :captca, :type => :text, :size => 4 }
        %li
          %input{ :id => :post, :name => :post, :value => :post, :type => :submit }

-#end-of-file # this is for Sinatra-Mode (http://github.com/eschulte/rinari/tree/sinatra)
