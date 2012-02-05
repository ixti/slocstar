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
