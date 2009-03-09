#!/usr/bin/env rackup
require File.join(File.dirname(__FILE__), "blorgit")
 
# disable sinatra's auto-application starting
disable :run
 
# we're in dev mode
set :environment, :development
 
# mount food with a base url of /food
map "/food" do
  run Sinatra::Application
end
