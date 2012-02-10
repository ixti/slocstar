//  Octoblame - Missing stupid statistics of GitHub repos
//
//  Copyright (c) 2012 Aleksey V Zapparov <ixti@member.fsf.org>
//
//  Octoblame is free software: you can redistribute it and/or modify
//  it under the terms of the GNU Affero General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Octoblame is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU Affero General Public License for more details.
//
//  You should have received a copy of the GNU Affero General Public License
//  along with Octoblame.  If not, see <http://www.gnu.org/licenses/>.


//= require ./templates


;(function ($, undef) {
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
      var stats, total;

      if (!!data.err) {
        // expected error - no stats yet
        $stats.rejectWith(this, [data.err]);
        return;
      }

      // unpack stats and initialize total counter
      stats = unpack_stats(data.stats);
      total = 0;

      // calculate total amount of SLOCs
      $.each(stats, function () { total += this.loc; });

      // success. got stats.
      $stats.resolveWith(this, [{
        slug:   slug,
        stats:  stats,
        total:  total,
        time:   to_iso8601(data.time)
      }]);
    });

    return $stats;
  };
}(jQuery));
