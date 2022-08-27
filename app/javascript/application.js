// Entry point for the build script in your package.json

import $ from 'jquery';
require('jquery-mousewheel')($);

window.$ = window.jQuery = $;
import { Histropedia } from '../../lib/assets/javascript/histropedia-1.2.0';

$(() => {
  const container = document.getElementById('timeline-sample');
  if (container != null) {
    $.get('/timelines/data', (data) => {
      let min = null;
      let minVal = Infinity;
      data.forEach((item) => {
        const val = item.from.year * 10000 + item.from.month * 100 + item.from.day;
        if (val < minVal) {
          minVal = val;
          min = item;
        }
      });
      const timeline = new Histropedia.Timeline(container, { initialDate: min.from });
      timeline.load(data);
    });
  }
})
