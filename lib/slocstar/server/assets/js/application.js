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


//= require slocstar.js
//= require vendor/jquery.timeago


;(function ($) {
  function init_pie_sector($pie, $el, rate, title) {
    var sector, activate, deactivate;

    sector = $pie.sector(rate, title);

    activate = function () {
      $el.addClass('active');
      sector.activate();
    };

    deactivate = function () {
      $el.removeClass('active');
      sector.deactivate();
    };

    $el.hover(activate, deactivate);
    sector.hover(activate, deactivate);
  }


  $(function() {
    var $win = $(window);

    function init_page_title($title) {
      var titleTop = $title.offset().top - 40, isFixed = false;

      $win.on('scroll', function () {
        var scrollTop = $win.scrollTop();

        if (!isFixed && scrollTop >= titleTop) {
          isFixed = true;
          $title.addClass('page-title-fixed');
        } else if (isFixed && scrollTop <= titleTop) {
          isFixed = false;
          $title.removeClass('page-title-fixed');
        }
      });
    }

    var $search, $contents, $btn;

    $slug = $('#slug');
    $contents = $('#contents');
    $btn = $slug.next('button');

    $btn.on('click', function (evt) {
      var slug = $.trim($slug.val());

      if (0 < slug.length) {
        $btn.addClass('disabled').attr('disabled', 'disabled');

        SlocStar.getStats(slug).always(function () {
          $btn.removeClass('disabled').removeAttr('disabled');
        }).done(function (data) {
          var $pie, $chart, $minor = $('<ul>'), minor_loc = 0;

          $contents.html(SlocStar.render('stats', data));

          // make timestamp human-readable
          $contents.find('#last-update > time').timeago();

          // init pie-chart
          $chart  = $contents.find('#chart');
          $pie    = SlocStar.initPieChart($chart.width());

          // truncate charts pane
          $chart.empty();

          // add "hidden" placeholder:
          // - guarantee chart height when pie will become in a fixed position.
          // - helps to workaround Raphael problem with calculation of text
          //   coordinates when paper is inside dom element that is detached or
          //   have `display: none` css property.
          $('<div>...</div>').css({
            visibility: 'hidden',
            height: $chart.width()
          }).append($pie).appendTo($chart);

          // init major contributors
          $contents.find('#stats li').each(function () {
            var $this = $(this), loc = $this.data('loc'), rate = loc / data.total;

            if (0.01 <= rate) {
              init_pie_sector($pie, $this, rate, Math.floor(rate * 100) + '%');
            } else {
              $minor.append($this.detach());
              minor_loc += loc;
            }
          });

          // init minor contributors
          if (0 < minor_loc) {
            $contents.find('#stats').append($minor);
            init_pie_sector($pie, $minor, minor_loc / data.total, '< 1%');
          }

          // fade in pie chart
          $pie.detach().hide().appendTo($chart).css({
            position: 'fixed',
            top: $chart.offset().top,
            left: $chart.offset().left
          }).fadeIn();

          init_page_title($contents.find('#repo-title'));
        }).fail(function (err, fatal) {
          $contents.html(SlocStar.render('error', {slug: slug, error: err}));
        });
      }

      return false;
    });
  });
}(jQuery));
