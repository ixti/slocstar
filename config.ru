require File.expand_path("app", File.dirname(__FILE__))

map "/assets" do
  run SlocStar::Server.assets
end

if 'development' == SlocStar.env
  map "/resque" do
    require 'resque/server'
    require 'resque_scheduler'

    run Resque::Server.new
  end
end

map "/" do
  run SlocStar::Server.new
end
