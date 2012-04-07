require File.expand_path("app", File.dirname(__FILE__))
require 'resque/server'
run Resque::Server.new
