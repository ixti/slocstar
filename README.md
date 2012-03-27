SlocStar
========

SlocStar is a dummy stats generator that shows how much lines of code (SLOC)
belongs whom in the latest snapshot of git repo. It was written just to play
with [resque][1] and [posix-spawn][2] before starting [APICD][3].

To calculate amount of lines of code per-author I use piped bunch of commands
that are running in a spawned process by resque. You can get such stats by
yourself running following in the dir with your repo (no ruby needed at all):

``` bash
git ls-tree -r --name-only HEAD | while read file ; do
  git blame --line-porcelain HEAD "$file" | sed -n 's/^author //p'
done | sort | uniq -c | sort -rn
```


Deployment
----------

-   `$ bundle install`
-   Start resque worker: `$ bundle exec rake resque:work QUEUE=*`
    or multiple workers: `$ bundle exec rake resque:workers QUEUE=* COUNT=2`
    (see [resque][1] documentation for more details)
-   Start resque scheduler: `$ bundle exec rake resque:scheduler`
-   Start web interface: `$ bundle exec rackup -p 8080`
-   (Optional) Start resque monitor: `$ bundle exec rackup -p 8090 resque.ru`


Licence & Copyrights
--------------------

See COPYING.


[1]: https://github.com/defunkt/resque/
[2]: https://github.com/rtomayko/posix-spawn/
[3]: https://github.com/apicd
