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


require 'slim'
require 'sass'
require 'multi_json'
require 'sprockets'
require 'sinatra/base'

require 'slocstar/helpers'
require 'slocstar/stats'

module SlocStar
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
      end

      @assets
    end

    configure :production do
      begin
        require 'closure-compiler'
        Server.assets.js_compressor = Closure::Compiler.new
      rescue LoadError
        # no js compression enbled
      end

      begin
        require 'yui/compressor'
        Server.assets.css_compressor = YUI::CssCompressor.new
      rescue LoadError
        # no css compression enbled
      end
    end

    helpers do
      def asset_path(source, options = {})
        "#{Server.assets_prefix}/#{Server.assets[source].digest_path}"
      end
    end

    get "/stats/:user/:proj.json" do
      content_type :json
      stats = Stats.get(params[:user], params[:proj])

      return encode({:err => "No stats for this repo yet."}) unless stats

      cache_control :public
      last_modified stats[:time]
      etag stats[:sha1]

      encode(stats)
    end

    get "/version" do
      content_type :json
      encode SlocStar::VERSION
    end

    get "/" do
      slim :application, :locals => {:latest => Stats.latest}
    end

    not_found do
      status 404
      slim :"404"
    end

    error do
      status 500
      slim :"500"
    end
  end
end
