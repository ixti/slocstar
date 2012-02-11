require File.expand_path("app", File.dirname(__FILE__))

map "/assets" do
  run Slocster::Server.assets
end

map "/" do
  run Slocster::Server.new
end
