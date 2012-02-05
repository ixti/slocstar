//= require ./templates

(function ($, undef) {
  // Converts simple array of arrays stucture into arrat of hashes, so it can be
  // used in templating.
  //
  // in:  [ [ 10, 'ixti', '258e88dcbd3cd44d8e7ab43f6ecb6af0' ], ... ]
  // out: [ { loc: 10,
  //          name: 'ixti',
  //          hash: '258e88dcbd3cd44d8e7ab43f6ecb6af0' }, ... ]
  function unpack_stats(raw) {
    return $.map(raw, function (arr) {
      return {
        loc:  arr[0],
        name: arr[1],
        hash: arr[2]
      };
    });
  }


  function pad(n) {
    return 10 < n ? ('0' + n) : n;
  }


  function to_iso8601(ts) {
    var d = new Date(ts * 1000);
    return  d.getUTCFullYear() + '-' +
            pad(d.getUTCMonth() + 1) + '-' +
            pad(d.getUTCDate()) + 'T' +
            pad(d.getUTCHours()) + ':' +
            pad(d.getUTCMinutes()) + ':' +
            pad(d.getUTCSeconds()) + 'Z';
  }


  /**
   *  Octoblame.getStats(slug) -> jQuery.Deferred
   *  - slug (String): GitHub repo slug, e.g. `ixti/octoblame`
   *
   *  ##### Success
   *
   *  Success handler receives `stats` object argument:
   *
   *      {
   *        stats: [
   *          { loc: 10,
   *            name: 'ixti',
   *            hash: '258e88dcbd3cd44d8e7ab43f6ecb6af0'
   *          },
   *          // ...
   *        ],
   *        time: 1328228586
   *      }
   *
   *  ##### Failure
   *
   *  Failure handler receives error message as a string:
   *
   *      "500 Internal Server Error"
   **/
  Octoblame.getStats = function (slug) {
    var $stats = new $.Deferred();

    $.ajax({
      url: '/stats/' + slug,
      dataType: 'json'
    }).fail(function (err) {
      // fatal error (HTTP 500/400)
      $stats.rejectWith(this, [err.status + ' ' + err.statusText]);
    }).done(function (data) {
      if (!!data.err) {
        // expected error - no stats yet
        $stats.rejectWith(this, [data.err]);
        return;
      }

      // success. got stats.
      $stats.resolveWith(this, [{
        slug:   slug,
        stats:  unpack_stats(data.stats),
        time:   to_iso8601(data.time)
      }]);
    });

    return $stats;
  };
}(jQuery));
