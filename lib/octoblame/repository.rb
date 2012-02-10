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


require 'digest/md5'
require 'tmpdir'

require 'octoblame/git'

module Octoblame
  class Repository
    attr_reader :user, :proj

    def initialize(user, proj)
      @user, @proj = user, proj
    end

    def stats
      tmp = Dir.mktmpdir('octoblame-')
      Git.clone(source_url, tmp)
      Git.stats(tmp).map do |data|
        loc, name, mail = data
        [loc.to_i, name, Digest::MD5.hexdigest(mail)]
      end.sort do |a, b|
        b.first <=> a.first
      end
    ensure
      # by some reasons, when Git.* raises error, tmpdir removed before we
      # get here, at least on my laptop
      FileUtils.remove_entry_secure(tmp) if File.directory? tmp
    end

    def slug
      self.class.slug(user, proj)
    end

    def self.slug(user, proj)
      "#{user}/#{proj}".gsub(/[^A-Za-z0-9._\-\/]/, '-')
    end

    def source_url
      "git://github.com/#{slug}.git"
    end
  end
end
