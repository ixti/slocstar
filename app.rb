$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/lib/')

require 'rubygems'
require 'bundler/setup'
require 'octoblame'


if ENV['OCTOBLAME_FAKE']
  require 'faker'

  module Octoblame
    module Stats
      def self.get(user, proj)
        # simulate we have no data
        return nil if rand <= 0.25

        stats = Array.new(rand 1..42).fill do
          [
            rand(1..12345),
            Faker::Name.name,
            Digest::MD5.hexdigest(Faker::Internet.email)
          ]
        end.sort{ |a,b| b.first <=> a.first }
        
        # return fake data
        {:stats => stats, :time => Time.new.to_i}
      end

      protected

      def rand *args
        @prng = Random.new unless @prng
        @prng.rand *args
      end
    end
  end
end


Octoblame.configure!
