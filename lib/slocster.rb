# Slocster - Missing stupid statistics of GitHub repos
#
# Copyright (c) 2012 Aleksey V Zapparov <ixti@member.fsf.org>
#
# Slocster is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Slocster is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Slocster.  If not, see <http://www.gnu.org/licenses/>.


require 'redis'
require 'redis/namespace'
require 'resque'

require 'slocster/git'
require 'slocster/helpers'
require 'slocster/repository'
require 'slocster/server'
require 'slocster/stats'


module Slocster
  extend self

  ROOT = File.expand_path(File.dirname(__FILE__) + '/../')

  attr_reader :redis

  def configure!
    # TODO: Read configuration
    redis = Redis.connect
    Resque.redis = redis
    @redis = Redis::Namespace.new(:slocster, :redis => redis)
  end
end
