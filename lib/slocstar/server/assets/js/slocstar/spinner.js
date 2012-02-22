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


//= require vendor/spin


;(function ($) {
  var $container, spinner;

  $container = $('<div></div>').hide().css({
    "position": "fixed",
    "z-index": 1040,
    "background": "#000",
    "top": "0px",
    "bottom": "0px",
    "left": "0px",
    "right": "0px",
    "opacity": 0.8
  });

  spinner = new Spinner({
    lines: 16, // The number of lines to draw
    length: 1, // The length of each line
    width: 16, // The line thickness
    radius: 42, // The radius of the inner circle
    color: '#fff', // #rgb or #rrggbb
    speed: 1, // Rounds per second
    trail: 42, // Afterglow percentage
    shadow: false, // Whether to render a shadow
    hwaccel: false // Whether to use hardware acceleration
  });

  SlocStar.showSpinner = function (callback) {
    $container.appendTo(document.body).fadeIn('fast', function () {
      spinner.spin($container.get(0));
      callback && callback();
    });
  };

  SlocStar.hideSpinner = function () {
    $container.fadeOut('fast', function () {
      spinner.stop();
      $container.detach();
    });
  };
}(jQuery));
