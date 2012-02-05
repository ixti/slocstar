require 'slim'
require 'sass'
require 'multi_json'
require 'sprockets'
require 'sinatra/base'
require 'octoblame/helpers'
require 'octoblame/stats'

module Octoblame
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
