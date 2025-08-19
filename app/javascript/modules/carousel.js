// app/assets/javascripts/home_index.js
// Swiper initialization for donationSwiper

document.addEventListener('turbo:load', function() {
  if (typeof Swiper === 'undefined') return;

  document.querySelectorAll('.donationSwiper').forEach(function(swiperEl) {
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
});
