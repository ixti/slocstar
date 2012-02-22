require File.expand_path("app", File.dirname(__FILE__))

require 'resque/tasks'
require 'resque_scheduler/tasks'
require 'rake/sprocketstask'

namespace :slocstar do
  Server = SlocStar::Server

  Rake::SprocketsTask.new do |t|
    require 'yui/compressor'

    t.environment = Server.assets
    t.environment.js_compressor = YUI::JavaScriptCompressor.new
    t.environment.css_compressor = YUI::CssCompressor.new

    t.output = "#{Server.public_folder}#{Server.assets_prefix}"
    t.assets = %w( application.js application.css )
  end
end
