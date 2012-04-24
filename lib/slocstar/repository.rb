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


require 'digest/md5'
require 'tmpdir'
require 'httparty'

require 'slocstar/git'
require 'slocstar/settings'


module SlocStar
  class Repository
    include HTTParty
    base_uri "https://api.github.com"


    attr_reader :user, :proj

    def initialize(user, proj)
      @user, @proj = user, proj
    end

    # Returns array of arrays of sloc stats:
    #
    #   [0] slocs (integer)
    #   [1] name (string)
    #   [2] gravatar_id (string)
    #   [3] github_user (string, optional)
    #
    # Example:
    #
    #   [
    #     [ 123, "Alex Zapparov", "1ad2ce5d0b7e6e467ca7b7ba8c7840f6", "ixti" ],
    #     [ 12, "Anykey Foobar", "3858f62230ac3c915f300c664312c63f" ]
    #     ...
    #   ]
    def stats
      repo_path = "#{Settings.repos}/#{slug}"
      stats     = {}

      if File.directory?("#{repo_path}/.git")
        # update existing repo
        Git.pull(repo_path)
      else
        # clone new repo
        Git.clone(source_url, repo_path)
      end

      Git.stats(repo_path).each do |data|
        loc, name, mail = data

        if stats[mail].nil?
          stats[mail] = [loc.to_i, name, Digest::MD5.hexdigest(mail)]
        else
          stats[mail][0] += loc.to_i
          stats[mail][1] = name if stats[mail][1] < name
        end
      end

      stats.values.sort{ |a, b| b.first <=> a.first }.map do |data|
        if user = collaborators.find{ |u| u['gravatar_id'] == data.last }
          data << user['login']
        end
        data
      end
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

    def collaborators
      @collaborators ||= self.class.get("/repos/#{slug}/collaborators")
    end
  end
end
