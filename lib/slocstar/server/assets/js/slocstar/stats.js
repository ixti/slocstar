//  SlocStar - Missing stupid statistics of GitHub repos
//
//  Copyright (c) 2012 Aleksey V Zapparov <ixti@member.fsf.org>
//
//  SlocStar is free software: you can redistribute it and/or modify
//  it under the terms of the GNU Affero General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  SlocStar is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU Affero General Public License for more details.
//
//  You should have received a copy of the GNU Affero General Public License
//  along with SlocStar.  If not, see <http://www.gnu.org/licenses/>.


;(function ($) {
  // Converts simple array of arrays stucture into arrat of hashes, so it can be
  // used in templating.
  //
  // in:  [ [ 10, 'Aleksey', '258e88dcbd3cd44d8e7ab43f6ecb6af0', 'ixti' ], ... ]
  // out: [ { loc: 10,
  //          rate: 0.99,
  //          name: 'Aleksey',
  //          hash: '258e88dcbd3cd44d8e7ab43f6ecb6af0',
  //          user: 'ixti' }, ... ]
  function unpack_stats(raw, total) {
    return $.map(raw, function (arr) {
      return {
        loc:  arr[0],
        rate: arr[0] / total,
        name: arr[1],
        hash: arr[2],
        user: arr[3]
      };
    });
  }


  /**
   *  SlocStar.getStats(slug) -> jQuery.Deferred
   *  - slug (String): GitHub repo slug, e.g. `ixti/slocstar`
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
  SlocStar.getStats = function (slug) {
    var $stats = new $.Deferred();

    $.ajax({
      url: '/stats/' + slug,
      dataType: 'json'
    }).fail(function (err) {
      // fatal error (HTTP 500/400)
      var message;

      if (!!err.status) {
        message = err.status + ' ' + err.statusText;
      } else {
        message = "Can't connect to SlocStar";
      }

      $stats.rejectWith(this, [{fatal: true, msg: message}]);
    }).done(function (data) {
      var stats;

      if (!!data.err) {
        // expected error - no stats yet
        $stats.rejectWith(this, [{fatal: false, msg: data.err}]);
        return;
      }

      // success. got stats.
      $stats.resolveWith(this, [{
        slug:   slug,
        stats:  unpack_stats(data.stats, data.total),
        total:  data.total,
        time:   SlocStar.to_iso8601(data.time)
      }]);
    });

    return $stats;
  };
}(jQuery));
