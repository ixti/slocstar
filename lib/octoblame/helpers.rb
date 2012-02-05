require 'multi_json'

# Some of the ideas were shamelessly taken from Resque
# https://github.com/defunkt/resque

# yajl-ruby 100% works with utf-8, while I'm not sure about others and
# :json-common had problems for sure...
begin 
  require 'yajl'
  MultiJson.engine = :yajl
rescue
  raise "Please install the yajl-ruby gem"
end

module Octoblame
  module Helpers
    class DecodeException < StandardError; end

    def redis
      Octoblame.redis
    end

    # Given a Ruby object, returns a string suitable for storage in a
    # queue.
    def encode(object)
      ::MultiJson.encode(object)
    end

    # Given a string, returns a Ruby object.
    def decode(object)
      return unless object

      begin
        ::MultiJson.decode(object)
      rescue ::MultiJson::DecodeError => e
        raise DecodeException, e.message, e.backtrace
      end
    end
  end
end
