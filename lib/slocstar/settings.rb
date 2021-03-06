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


module SlocStar
  module Settings
    extend self


    def redis
      @redis ||= {
        :url  => ENV['SLOCSTAR_REDIS_URL'] || ENV['REDIS_URL'],
        :path => ENV['SLOCSTAR_REDIS_SOCKET'] || ENV['REDIS_SOCKET']
      }
    end


    def repos
      unless @repos
        @repos = ENV['SLOCSTAR_REPOS'] || File.join(Dir.tmpdir, 'slocstar-repos')
        Dir.mkdir(@repos) unless Dir.exists?(@repos)
      end

      @repos
    end


    def github_public_ips
      @gihub_pub_ips ||= %w{ 207.97.227.253 50.57.128.197 }
    end
  end
end
