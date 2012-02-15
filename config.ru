require File.expand_path("app", File.dirname(__FILE__))

map "/assets" do
  run SlocStar::Server.assets
end

map "/" do
  run SlocStar::Server.new
end
