// app/assets/javascripts/home_index.js
// Swiper initialization for donationSwiper

// Ensure Swiper-based carousels initialize reliably even when Swiper is loaded via a deferred CDN script.
function initDonationSwipers() {
  if (typeof Swiper === 'undefined') return false;

  document.querySelectorAll('.donationSwiper').forEach(function(swiperEl) {
    // avoid double-init
    if (swiperEl.__donation_swiper_inited) return;
    swiperEl.__donation_swiper_inited = true;

    var swiper = new Swiper(swiperEl, {
      slidesPerView: 1,
      spaceBetween: 24,
      breakpoints: {
        640: { slidesPerView: 1 },
        768: { slidesPerView: 2 },
        1024: { slidesPerView: 3 },
      },
      pagination: { el: swiperEl.querySelector('.swiper-pagination'), clickable: true },
      navigation: {
        nextEl: swiperEl.querySelector('.swiper-button-next'),
        prevEl: swiperEl.querySelector('.swiper-button-prev')
      },
      loop: false,
      on: {
        afterInit: function(swiper) {
          var pag = swiper.pagination && swiper.pagination.el;
          if (pag && swiper.slides.length <= swiper.params.slidesPerView) {
            pag.style.display = 'none';
          }
          var nextBtn = swiper.navigation && swiper.navigation.nextEl;
          var prevBtn = swiper.navigation && swiper.navigation.prevEl;
          if (swiper.slides.length <= swiper.params.slidesPerView) {
            if (nextBtn) nextBtn.style.display = 'none';
            if (prevBtn) prevBtn.style.display = 'none';
          }
        },
        slideChange: function(swiper) {
          var nextBtn = swiper.navigation && swiper.navigation.nextEl;
          var prevBtn = swiper.navigation && swiper.navigation.prevEl;
          if (nextBtn && prevBtn) {
            if (swiper.isBeginning) {
              prevBtn.classList.add('swiper-button-disabled');
            } else {
              prevBtn.classList.remove('swiper-button-disabled');
            }
            if (swiper.isEnd) {
              nextBtn.classList.add('swiper-button-disabled');
            } else {
              nextBtn.classList.remove('swiper-button-disabled');
            }
          }
        }
      }
    });
  });

  return true;
}

// Try to initialize on turbo:load and DOMContentLoaded. If Swiper isn't available yet (deferred CDN), retry a few times.
function ensureInitWithRetry(attemptsLeft) {
  attemptsLeft = typeof attemptsLeft === 'number' ? attemptsLeft : 10;
  // Diagnostic: report Swiper presence and target elements when retrying
  try {
    console.debug('[carousel] Swiper present?', typeof Swiper !== 'undefined', 'donationSwipers:', document.querySelectorAll('.donationSwiper').length);
    document.querySelectorAll('.donationSwiper').forEach(function(el, i){ console.debug('[carousel] donationSwiper['+i+'] inited?', !!el.__donation_swiper_inited); });
  } catch (e) { /* ignore in environments without DOM */ }

  if (initDonationSwipers()) return;
  if (attemptsLeft <= 0) return;
  setTimeout(function() { ensureInitWithRetry(attemptsLeft - 1); }, 200);
}

document.addEventListener('turbo:load', function() { ensureInitWithRetry(15); });
document.addEventListener('DOMContentLoaded', function() { ensureInitWithRetry(15); });

