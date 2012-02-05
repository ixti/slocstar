require 'resque_scheduler'

require 'octoblame/helpers'
require 'octoblame/repository'

# TODO: Improve resurrection

module Octoblame
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
        :time => Time.new.to_i
      }))

      # Re-enqueue stats update
      Resque.enqueue_in(UPDATE_FREQ, Stats, user, proj)
    rescue Git::GitCommandFailed
      redis.del("queued:#{repo.slug}")
      raise
    end
  end
end
