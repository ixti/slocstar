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


//= require vendor/raphael.js


// Inspired by original pie-chart sample of Raphael:
// http://raphaeljs.com/pie.html
;(function ($) {
  var RAD = Math.PI / 180;

  // add_sector(paper, x, y, r, a1, a2) -> Path
  function add_sector(paper, x, y, r, a1, a2) {
    var x1, x2, y1, y2;

    if (0 === a1 && 360 === a2) {
      return paper.circle(x, y, r);
    }

    x1 = x + r * Math.cos(-a1 * RAD);
    y1 = y + r * Math.sin(-a1 * RAD);

    x2 = x + r * Math.cos(-a2 * RAD);
    y2 = y + r * Math.sin(-a2 * RAD);

    return paper.path([
      "M", x, y,
      "L", x1, y1,
      "A", r, r, 0, +(a2 - a1 > 180), 0, x2, y2,
      "Z"
    ]);
  }


  Slocster.initPieChart = function (size) {
    var $el, paper, x, y, r, a, i;

    $el   = $('<div></div>'); // chart container
    paper = Raphael($el.get(0), size, size); // Raphael paper object
    x     =
    y     = size / 2; // X and Y coordinates of the center
    r     = size / 2 * 0.85; // radius
    a     = 0; // angle of the last sector
    i     = 0; // counter used to generate "smooth" rainbow colors

    // add new sector with given rate (percentage in decimals)
    $el.sector = function (rate) {
      var turn = 360 * rate, s;

      s = add_sector(paper, x, y, r, a, a + turn).attr({
        "fill": "90-" + Raphael.hsb(i, 1, 1) + "-" + Raphael.hsb(i, 0.75, 1),
        "stroke": "black",
        "stroke-width": 1,
        "stroke-opacity": 0.3
      });

      s.activate = function () {
        s.stop().animate({transform: "s1.1 1.1 " + x + " " + y}, 500, "elastic");
      };

      s.deactivate = function () {
        s.stop().animate({transform: ""}, 500, "elastic");
      };

      a += turn;
      i += 0.03;

      return s;
    };

    return $el;
  };
}(jQuery));
