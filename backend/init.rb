# load up the backend
%w(active_file acts_as_org).each{ |sb| require(File.join(File.dirname(__FILE__), sb, 'init.rb')) }
%w(blog comment).each{ |model| require(File.join(File.dirname(__FILE__), model)) }
