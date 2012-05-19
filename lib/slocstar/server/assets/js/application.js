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
//= require vendor/bootstrap-modal
//= require vendor/bootstrap-typeahead
//= require vendor/director


;(function ($) {
  var SLUG_RE = new RegExp('^[^/]+/[^/]+$');
  var known_repos = [];


  $(function() {
    var $win = $(window), $search, $contents, $btn, skip_director = false;

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

    function load_stats(slug) {
      if (0 < slug.length) {

        if (!SLUG_RE.test(slug)) {
          $(SlocStar.render('fatal', {
            slug: slug,
            error: "Invalid project name."
          })).modal();

          return false;
        }

        $btn.add($search).addClass('disabled').attr('disabled', 'disabled');

        // running real update only AFTER spinner was shown
        // to avoid annoying blinking
        SlocStar.showSpinner(function () {
          SlocStar.getStats(slug).always(function () {
            $btn.add($search).removeClass('disabled').removeAttr('disabled');
          }).done(function (data) {
            $contents.html(SlocStar.render('stats', data));

            // make timestamp human-readable
            $contents.find('#last-update > time').timeago();

            SlocStar.hideSpinner();
          }).fail(function (err) {
            var tpl, context;

            tpl = err.fatal ? 'fatal' : 'error';
            context = {slug: slug, error: err.msg};

            SlocStar.hideSpinner();
            $(SlocStar.render(tpl, context)).modal();
          });
        });
      }
    }

    $search = $('#search-slug');
    $contents = $('#contents');
    $btn = $search.next('button');

    $btn.on('click', function (evt) {
      var slug = $.trim($search.val());
      load_stats(slug);

      skip_director = true;
      location.assign('#/' + slug);

      evt.stopPropagation();
      return false;
    });

    Router({
      '/*/*': function (user, repo) {
        if (skip_director) {
          skip_director = false;
          return;
        }

        load_stats([user, repo].join('/'));
      }
    }).init();

    $('#last-updates .timestamp > time').each(function () {
      var $this = $(this), date = SlocStar.to_iso8601(+($this.text().substr(1)));
      $this.text(date).attr('datetime', date).timeago();
    });

    $.ajax({url: '/known', dataType: 'json'}).done(function (data) {
      var $typeahead;

      known_repos = data.concat(known_repos);
      $search.attr('autocomplete', 'off').typeahead({
        source: known_repos,
        menu: '<ul id="search-autocomplete" class="typeahead dropdown-menu"></ul>'
      });

      $typeahead = $search.data('typeahead');

      $typeahead._select = $typeahead.select;
      $typeahead.select = function () {
        var slug;

        this._select();

        slug = $.trim($search.val());
        load_stats(slug);

        skip_director = true;
        location.assign('#/' + slug);
      };
    });
  });
}(jQuery));
