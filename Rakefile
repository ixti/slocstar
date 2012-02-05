require File.expand_path("app", File.dirname(__FILE__))

require 'resque/tasks'
require 'resque_scheduler/tasks'
require 'rake/sprocketstask'

namespace :octoblame do
  Server = Octoblame::Server

  Rake::SprocketsTask.new do |t|
    t.environment = Server.assets
    t.output = "#{Server.public_folder}#{Server.assets_prefix}"
    t.assets = %w( application.js application.css )
  end
end
