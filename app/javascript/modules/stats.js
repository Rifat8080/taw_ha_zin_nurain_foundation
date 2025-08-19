// app/javascript/modules/stats.js
// Handles count-up and progress bar animation for Quick Stats section

document.addEventListener('DOMContentLoaded', function() {
  document.querySelectorAll('.count-up').forEach(function(el) {
    var end = parseInt(el.dataset.count);
    if (isNaN(end)) return;
    var start = 0;
    var duration = 1200;
    var stepTime = Math.max(20, Math.abs(Math.floor(duration / (end || 1))));
    var current = start;
    var timer = setInterval(function() {
      current += 1;
      el.textContent = current;
      if (current >= end) {
        el.textContent = end;
        clearInterval(timer);
      }
    }, stepTime);
  });
  // Animate progress bars
  document.querySelectorAll('.animate-progress').forEach(function(bar) {
    var width = bar.style.width || '100%';
    bar.style.setProperty('--progress-width', width);
  });
});
