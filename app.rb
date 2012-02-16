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


$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/lib/')

require 'rubygems'
require 'bundler/setup'
require 'slocstar'


if ENV['SLOCSTAR_FAKE']
  require 'digest/md5'
  require 'faker'

  module SlocStar
    module Stats
      def self.get(user, proj)
        # simulate we have no data
        return nil if rand <= 0.35

        {
          :stats  => rand <= 0.25 ? fake_stats(1) : fake_stats(rand 1..42),
          :time   => Time.new.to_i
        }
      end

      protected

      def rand *args
        @prng = Random.new unless @prng
        @prng.rand *args
      end

      def fake_stats amount
        Array.new(amount).fill do
          [
            rand(1..12345),
            Faker::Name.name,
            Digest::MD5.hexdigest(Faker::Internet.email)
          ]
        end.sort{ |a,b| b.first <=> a.first }
      end
    end
  end
end


SlocStar.configure!
