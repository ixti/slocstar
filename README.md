SLOCster
========

Formerly named _Octoblame_.

Deployment
----------

-   `$ bundle install`
-   Start resque worker: `$ bundle exec rake resque:work`
    or multiple workers: `$ bundle exec rake resque:workers`
    (see resque documentation)
-   Start resque scheduler: `$ bundle exec rake resque:scheduler`
-   Start web interface: `$ bundle exec rackup -p 8080`
-   (Optional) start resque monitor: `$ bundle exec rackup -p 8090 resque.ru`
