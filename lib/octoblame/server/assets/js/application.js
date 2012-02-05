//= require octoblame.js
//= require vendor/jquery.timeago

;(function ($) {
  $(function() {
    var $search, $contents, $btn;

    $slug = $('#slug');
    $contents = $('#contents');
    $btn = $slug.next('button');

    $btn.on('click', function (evt) {
      var slug = $.trim($slug.val());

      $btn.addClass('disabled').attr('disabled', 'disabled');

      if (0 < slug.length) {
        Octoblame.getStats(slug).always(function () {
          $btn.removeClass('disabled').removeAttr('disabled');
        }).done(function (data) {
          $contents.html(Octoblame.render('stats', data));

          // make timestamp human-readable
          $contents.find('#last-update > time').timeago();

          var total   = 0;
          var $chart  = $contents.find('#chart');
          var size    = $chart.width();

          $chart.add($contents.find('#stats')).css({
            height: size,
            overflow: 'hidden'
          });

          var $pie = Octoblame.initChart(size);

          // calculate total
          $.each(data.stats, function () {
            total += this.loc;
          });

          $contents.find('#stats li').each(function () {
            var $li = $(this);
            $pie.addSector($li.data('loc') / total, {
              mouseover: function () {
                $li.addClass('highlighted');
              },
              mouseout: function () {
                $li.removeClass('highlighted');
              }
            });
          });

          $chart.empty().append($pie);
        }).fail(function (err, fatal) {
          $contents.html(Octoblame.render('error', {slug: slug, error: err}));
        });
      }

      return false;
    });
  });
}(jQuery));
