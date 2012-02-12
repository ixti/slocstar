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
  function init_pie_sector($pie, $el, rate) {
    var sector, activate, deactivate;

    sector = $pie.sector(rate);

    activate = function () {
      $el.addClass('active');
      sector.activate();
    };

    deactivate = function () {
      $el.removeClass('active');
      sector.deactivate();
    };


    $el.on('mouseover', activate);
    $el.on('mouseout', deactivate);

    sector.mouseover(activate);
    sector.mouseout(deactivate);
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

        Slocster.getStats(slug).always(function () {
          $btn.removeClass('disabled').removeAttr('disabled');
        }).done(function (data) {
          var $pie, $chart, $minor = $('<ul>'), minor_rate = 0;

          $contents.html(Slocster.render('stats', data));

          // make timestamp human-readable
          $contents.find('#last-update > time').timeago();

          // init piechart
          $chart  = $contents.find('#chart');
          $pie    = Slocster.initPieChart($chart.width()).hide();

          $contents.find('#stats li').each(function () {
            var $this = $(this), rate = $this.data('loc') / data.total;

            if (0.01 <= rate) {
              init_pie_sector($pie, $this, rate);
            } else {
              $minor.append($this.detach());
              minor_rate += rate;
            }
          });

          if (0 < minor_rate) {
            $contents.find('#stats').append($minor);
            init_pie_sector($pie, $minor, minor_rate);
          }

          $contents.find('#stats').css({
            minHeight: $chart.width()
          }).addClass('offset6');

          $chart.empty().append($pie.css({position: 'fixed'}));
          $pie.fadeIn();

          init_page_title($contents.find('#repo-title'));
        }).fail(function (err, fatal) {
          $contents.html(Slocster.render('error', {slug: slug, error: err}));
        });
      }

      return false;
    });
  });
}(jQuery));
