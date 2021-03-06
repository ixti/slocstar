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


require 'posix-spawn'


# Some of the ideas were taken from Grit (https://github.com/mojombo/grit)


module SlocStar
  class Git
    include POSIX::Spawn


    # Timeouts of commands execution in seconds.
    TIMEOUTS = {
      :clone => 30*60,
      :pull  => 15*60,
      :stats => 8*60*60
    }


    # Sed script that leaves only author name and e-mail from procelain blame:
    #
    #   e124e0d02e8f9bc2f4834f614f62739b149bb0a6 1 1 8
    #   author Aleksey V Zapparov
    #   author-mail <ixti@member.fsf.org>
    #   author-time 1326057246
    #   author-tz +0100
    #   committer Aleksey V Zapparov
    #   ...
    #
    # will result in
    #
    #   Aleksey V Zapparov <ixti@member.fsf.org>
    STATS_SED_SCRIPT = '/^author\\(-mail\\)* /{s/^author //;$!N;s/\\nauthor-mail / /;p}'


    # Command that concat porcelain blames of all files in the repo, leaves only
    # authors of each line and generates stats summary with amounts of lines of
    # code per each author:
    #
    #   {lines of code} {author name} <{author-mail}>
    STATS_CMD = <<-CMD
      git ls-tree -r --name-only HEAD | while read file ; do
        git blame --line-porcelain HEAD "$file" | sed -n '#{STATS_SED_SCRIPT}'
      done | iconv -c -f UTF8 -t UTF8//IGNORE | sort | uniq -c
    CMD


    # RegExp used to parse lines generated by STATS_CMD. Capture groups are as
    # follows:
    #
    #   0 => lines of code
    #   1 => author
    #   2 => e-mail
    STATS_RE = /^\s*(\d+)\s+(.*) <(.*)>$/


    # Raised when git command timeout or max output reached.
    class GitTimeout < RuntimeError
      attr_reader :command
      def initialize(command)
        @command = command
      end
    end


    # Raised when git command exits with non-zero.
    class GitCommandFailed < StandardError
      # The full git command that failed as a String.
      attr_reader :command

      # The integer exit status.
      attr_reader :exitstatus

      # Everything output on the command's stderr as a String.
      attr_reader :err

      def initialize(command, exitstatus=nil, err='')
        if exitstatus
          @command = command
          @exitstatus = exitstatus
          @err = err
          message = "Command failed [#{exitstatus}]: #{command}"
          message << "\n\n" << err unless err.nil? || err.empty?
          super message
        else
          super command
        end
      end
    end


    # Clone `source` repository into `path`
    # BEWARE! We don't check neither source nor path.
    def self.clone(source, path)
      cmnd = "git clone --quiet '#{source}' '#{path}'"
      opts = {:timeout => TIMEOUTS[__method__]}

      exec({"GIT_ASKPASS" => "echo"}, cmnd, opts)
    end


    # Pull new changes from the repo
    # BEWARE! We don't check repo path.
    def self.pull(repo)
      cmnd = "git pull --force"
      opts = {:timeout => TIMEOUTS[__method__], :chdir => repo}

      exec({"GIT_ASKPASS" => "echo"}, cmnd, opts)
    end


    # Returns stats of git repo under given `path`.
    # Stats is an array of capture groups of STATS_RE, e.g.
    #
    #   [["10", "Aleksey V Zapparov", "ixti@member.fsf.org"], ...]
    def self.stats(repo)
      opts  = {:timeout => TIMEOUTS[__method__], :chdir => repo}
      stats = []

      exec({}, STATS_CMD, opts).each_line do |line|
        if m = STATS_RE.match(line)
          stats << m.captures
        end
      end

      stats
    end


    protected


    # Executes `command` and returns output.
    #
    # - Raises CommandFailed if exit status of command was failure.
    # - Raises GitTimeout on timeout or max output exceeded.
    def self.exec(env, command, options = {})
      process = Child.new(env, command, options)

      unless process.status.success?
        raise GitCommandFailed.new(command, process.status, process.err)
      end

      process.out
    rescue TimeoutExceeded, MaximumOutputExceeded
      raise GitTimeout, command
    end
  end
end
