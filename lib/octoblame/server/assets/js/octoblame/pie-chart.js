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


  Octoblame.initChart = function (size) {
    var $el, paper, x, y, r, a, idx;

    $el   = $('<div>');
    idx   = 0;
    paper = Raphael($el.get(0), size, size);

    // center of the paper
    x = y = size / 2;

    // radius
    r = size / 2 * 0.85;

    // angle of the last sector
    a = 0;

    $el.addSector = function (rate, options) {
      var turn = 360 * rate, s;

      s = add_sector(paper, x, y, r, a, a + turn).attr({
        "fill": "90-" + Raphael.hsb(idx, 1, 1) + "-" + Raphael.hsb(idx, 0.75, 1),
        "stroke": "black",
        "stroke-width": 1,
        "stroke-opacity": 0.3
      }).mouseover(function () {
        s.stop().animate({transform: "s1.1 1.1 " + x + " " + y}, 500, "elastic");
        options.mouseover();
      }).mouseout(function () {
        s.stop().animate({transform: ""}, 500, "elastic");
        options.mouseout();
      });

      a += turn;
      idx += 0.03;
    };

    return $el;
  };
}(jQuery));
