# load up the backend
require 'active_record'
%w(active_file acts_as_org acts_as_git).each{ |sb| require(File.join(File.dirname(__FILE__), sb, 'init.rb')) }
%w(blog comment).each{ |model| require(File.join(File.dirname(__FILE__), model)) }
