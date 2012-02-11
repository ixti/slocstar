//  Slocster - Missing stupid statistics of GitHub repos
//
//  Copyright (c) 2012 Aleksey V Zapparov <ixti@member.fsf.org>
//
//  Slocster is free software: you can redistribute it and/or modify
//  it under the terms of the GNU Affero General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Slocster is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU Affero General Public License for more details.
//
//  You should have received a copy of the GNU Affero General Public License
//  along with Slocster.  If not, see <http://www.gnu.org/licenses/>.


//= require slocster.js
//= require vendor/jquery.timeago


;(function ($) {
  $(function() {
    var $search, $contents, $btn;

    $slug = $('#slug');
    $contents = $('#contents');
    $btn = $slug.next('button');

    $btn.on('click', function (evt) {
      var slug = $.trim($slug.val());

      if (0 < slug.length) {
        $btn.addClass('disabled').attr('disabled', 'disabled');

        Slocster.getStats(slug).always(function () {
          $btn.removeClass('disabled').removeAttr('disabled');
        }).done(function (data) {
          var $pie, $chart;

          $contents.html(Slocster.render('stats', data));

          // make timestamp human-readable
          $contents.find('#last-update > time').timeago();

          // init piechart
          $chart  = $contents.find('#chart');
          $pie    = Slocster.initPieChart($chart.width());

          $contents.find('#stats li').each(function () {
            var $this = $(this), rate, sector, activate, deactivate;

            rate = $this.data('loc') / data.total;
            sector = $pie.sector(rate);

            activate = function () {
              $this.addClass('active');
              sector.activate();
            };

            deactivate = function () {
              $this.removeClass('active');
              sector.deactivate();
            };


            $this.on('mouseover', activate);
            $this.on('mouseout', deactivate);

            sector.mouseover(activate);
            sector.mouseout(deactivate);
          });

          $('#stats').css({
            minHeight: $chart.width()
          }).addClass('offset6');

          $chart.empty().append($pie.css({position: 'fixed'}));
        }).fail(function (err, fatal) {
          $contents.html(Slocster.render('error', {slug: slug, error: err}));
        });
      }

      return false;
    });
  });
}(jQuery));
