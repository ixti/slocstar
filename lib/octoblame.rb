require 'redis'
require 'redis/namespace'
require 'resque'

require 'octoblame/git'
require 'octoblame/helpers'
require 'octoblame/repository'
require 'octoblame/server'
require 'octoblame/stats'


module Octoblame
  extend self

  ROOT = File.expand_path(File.dirname(__FILE__) + '/../')

  attr_reader :redis

  def configure!
    # TODO: Read configuration
    redis = Redis.connect
    Resque.redis = redis
    @redis = Redis::Namespace.new(:octoblame, :redis => redis)
  end
end
