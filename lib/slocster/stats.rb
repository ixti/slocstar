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


require 'resque_scheduler'

require 'slocster/helpers'
require 'slocster/repository'

# TODO: Improve resurrection

module Slocster
  module Stats
    extend Helpers
    extend self

    @queue = :stats_update

    # Update frequency in seconds
    UPDATE_FREQ = 24*60*60

    def get(user, proj)
      slug = Repository.slug(user, proj)
      data = decode(redis.get("stats:#{slug}"))

      unless redis.exists("queued:#{slug}")
        redis.set("queued:#{slug}", Time.new.to_i)
        Resque.enqueue(Stats, user, proj)
      end

      data
    end

    def perform(user, proj)
      repo  = Repository.new(user, proj)
      stats = repo.stats

      redis.set("stats:#{repo.slug}", encode({
        :stats => stats,
        :time => Time.new.to_i,
        :sha1 => Digest::SHA1.hexdigest(stats.flatten.unshift(Time.new).join)
      }))

      # Re-enqueue stats update
      Resque.enqueue_in(UPDATE_FREQ, Stats, user, proj)
    rescue Git::GitCommandFailed
      redis.del("queued:#{repo.slug}")
      raise
    end
  end
end
