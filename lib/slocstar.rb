# SlocStar - Missing stupid statistics of GitHub repos
#
# Copyright (c) 2012 Aleksey V Zapparov <ixti@member.fsf.org>
#
# SlocStar is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# SlocStar is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with SlocStar.  If not, see <http://www.gnu.org/licenses/>.


require 'redis'
require 'redis/namespace'
require 'resque'


module SlocStar
  autoload :Git,            'slocstar/git'
  autoload :Helpers,        'slocstar/helpers'
  autoload :Repository,     'slocstar/repository'
  autoload :Server,         'slocstar/server'
  autoload :Settings,       'slocstar/settings'
  autoload :Stats,          'slocstar/stats'
  autoload :Version,        'slocstar/version'


  extend self


  def redis
    unless @redis
      conn = Resque.redis = Redis.connect(Settings.redis)
      @redis = Redis::Namespace.new(:slocstar, :redis => conn)
    end

    @redis
  end


  def env
    @env ||= ENV['SLOCSTAR_ENV'] || 'development'
  end
end
