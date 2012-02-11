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


require 'slim'
require 'sass'
require 'multi_json'
require 'sprockets'
require 'sinatra/base'
require 'slocster/helpers'
require 'slocster/stats'

module Slocster
  class Server < Sinatra::Base
    include Helpers

    set :root, File.expand_path(File.dirname(__FILE__) + '/server/')
    set :assets_prefix, "/assets"

    def self.assets
      unless @assets
        @assets = Sprockets::Environment.new(root)

        # add assets paths
        @assets.append_path 'assets/js'
        @assets.append_path 'assets/css'

        # add helpers
        @assets.context_class.class_eval do
          def template path, options = {}
            pathname  = resolve(path, options)
            result    = Tilt.new(pathname.to_s).render

            # Shamelessly taken from EJS:
            # https://github.com/sstephenson/ruby-ejs/blob/master/lib/ejs.rb

            result.gsub!(/\\/) { '\\\\' }
            result.gsub!(/'/) { "\\'" }

            result
          end
        end
      end

      @assets
    end

    helpers do
      def asset_path(source, options = {})
        "#{Server.assets_prefix}/#{Server.assets[source].digest_path}"
      end
    end

    get "/stats/:user/:proj" do
      content_type :json
      stats = Stats.get(params[:user], params[:proj])
      encode(stats || {:err => "No stats for this repo yet."})
    end

    get "/" do
      slim :application
    end

    not_found do
      status 404
      slim :not_found
    end

    error do
      status 500
      slim :error
    end
  end
end
