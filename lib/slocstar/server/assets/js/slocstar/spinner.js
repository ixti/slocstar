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


//= require vendor/sonic


;(function ($) {
  var $container, $canvas, spinner, size = 320, $w = $(window);

  // create container for the spinner
  $container = $('<div></div>').hide().css({
    "position":   "fixed",
    "z-index":    1040,
    "background": "rgba(0,0,0,0.8)",
    "top":        "0px",
    "bottom":     "0px",
    "left":       "0px",
    "right":      "0px"
  }).appendTo(document.body);

  // initialize new spinner
  spinner = new Sonic({
    width:          size,
    height:         size,

    stepsPerFrame:  1,
    trailLength:    1,
    pointDistance:  0.02,
    fps:            30,

    fillColor:      '#aaa',

    step: function(point, index) {
      this._.beginPath();
      this._.moveTo(point.x, point.y);
      this._.arc(point.x, point.y, index * 7, 0, Math.PI*2, false);
      this._.closePath();
      this._.fill();
    },

    path: [['arc', size / 2, size / 2, size * 0.35, 0, 360]]
  });


  $canvas = $(spinner.canvas).appendTo($container);


  SlocStar.showSpinner = function (callback) {
    $canvas.css({
      'margin-top':   ($w.height() - size) / 2,
      'margin-left':  ($w.width() - size) / 2
    });

    spinner.play();
    $container.fadeIn('fast', callback || $.noop, 5000);
  };

  SlocStar.hideSpinner = function (callback) {
    $container.fadeOut('fast', function () {
      spinner.stop();
      (callback || $.noop)();
    });
  };
}(jQuery));
