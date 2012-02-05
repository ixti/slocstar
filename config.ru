require File.expand_path("app", File.dirname(__FILE__))

map "/assets" do
  run Octoblame::Server.assets
end

map "/" do
  run Octoblame::Server.new
end
