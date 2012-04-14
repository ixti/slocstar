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


require 'yajl'


module SlocStar
  module Helpers
    class DecodeException < StandardError; end

    def redis
      SlocStar.redis
    end

    # Given a Ruby object, returns a string suitable for storage in a queue.
    def encode(object)
      ::Yajl::Encoder.encode(object)
    end

    # Given a string, returns a Ruby object.
    def decode(string)
      return unless string

      begin
        ::Yajl::Parser.parse(string, :symbolize_keys => true)
      rescue ::Yajl::ParseError => e
        raise DecodeException, e.message, e.backtrace
      end
    end
  end
end
