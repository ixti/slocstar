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


require 'resque'
require 'resque_scheduler'

require 'slocstar/helpers'
require 'slocstar/repository'


module SlocStar
  module Stats
    extend Helpers
    extend self


    # Amount of attempts to get stats
    # before removing slug from the queue
    MAX_ATTEMPTS = 5

    # Amount of "latest" entries
    MAX_HISTORY = 16

    # Stats refresh on success delay in seconds
    UPDATE_DELAY = 7*24*60*60

    # Stats refresh on failure delay in seconds
    RETRY_DELAY = 60*60


    @queue = :stats_update


    # Used redis keys:
    #
    # stats   : HASH of {<slug> => <stats>}
    # fails   : HASH of {<slug> => <amount of failed attempts>}
    # queued  : SET of queued <slug>s
    # latest  : LIST of latest updated <slug>s


    # Returns last stats of the <user/proj> repo
    def get(user, proj)
      slug = Repository.slug(user, proj)

      # Stats task is "resurrectable", so avoid
      # adding more than one in the queue
      unless redis.sismember(:queued, slug)
        redis.sadd(:queued, slug)
        Resque.enqueue(Stats, *slug.split("/"))
      end

      decode(redis.hget(:stats, slug))
    end


    # Forced (by payload) update of the stats
    def update(user, proj)
      Resque.remove_delayed(Stats, user, proj)
      Resque.dequeue(Stats, user, proj)

      redis.sadd(:queued, Repository.slug(user, proj))
      Resque.enqueue(Stats, user, proj)
    end


    # Resque heavylifter
    def perform(user, proj)
      repo  = Repository.new(user, proj)
      stats = repo.stats

      redis.hset(:stats, repo.slug, encode({
        :stats => stats,
        :total => stats.inject(0){ |memo,arr| memo + arr.first },
        :time  => Time.new.to_i,
        :sha1  => Digest::SHA1.hexdigest(stats.flatten.join)
      }))

      redis.multi do
        redis.hdel(:fails, repo.slug)
        redis.lrem(:latest, 0, repo.slug)
        redis.lpush(:latest, repo.slug)
        redis.ltrim(:latest, 0, MAX_HISTORY)
      end

      Resque.enqueue_in(UPDATE_DELAY, Stats, user, proj)
    rescue Git::GitCommandFailed
      if MAX_ATTEMPTS > redis.hincrby(:fails, repo.slug, 1)
        Resque.enqueue_in(RETRY_DELAY, Stats, user, proj)
      else
        redis.multi do
          redis.hdel(:fails, repo.slug)
          redis.hdel(:stats, repo.slug)
          redis.srem(:queued, repo.slug)
          redis.lrem(:latest, repo.slug)
        end
      end

      raise
    end


    def latest
      slugs = redis.lrange(:latest, 0, -1)
      slugs.empty? ? [] : redis.hmget(:stats, *slugs).map do |stats|
        {:slug => slugs.shift, :time => decode(stats)[:time]}
      end
    end


    def known
      redis.hkeys(:stats)
    end
  end
end
