# Octoblame - Missing stupid statistics of GitHub repos
#
# Copyright (c) 2012 Aleksey V Zapparov <ixti@member.fsf.org>
#
# Octoblame is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Octoblame is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Octoblame.  If not, see <http://www.gnu.org/licenses/>.


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
