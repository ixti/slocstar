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


//= require vendor/hogan.js


;(function ($) {
  var templates = {};


  /**
  *  SlocStar.render(tpl, data) -> String
  *  - tpl (String): template name
  *  - data (Object): context object
  **/
  SlocStar.render = function (tpl, data) {
    if (!templates[tpl]) {
      templates[tpl] = Hogan.compile($('#' + tpl + '-tpl').html());
    }

    return templates[tpl].render(data);
  };
}(jQuery));
