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


require 'digest/md5'
require 'tmpdir'

require 'slocster/git'

module Slocster
  class Repository
    attr_reader :user, :proj

    def initialize(user, proj)
      @user, @proj = user, proj
    end

    def stats
      tmp = Dir.mktmpdir('slocster-')
      stats = {}

      Git.clone(source_url, tmp)
      Git.stats(tmp).each do |data|
        loc, name, mail = data

        if stats[mail].nil?
          stats[mail] = [loc.to_i, name, Digest::MD5.hexdigest(mail)]
        else
          stats[mail][0] += loc.to_i
          stats[mail][1] = name if stats[mail][1] < name
        end
      end

      stats.values.sort{ |a, b| b.first <=> a.first }
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
