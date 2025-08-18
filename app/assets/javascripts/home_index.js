// app/assets/javascripts/home_index.js
// Swiper initialization for donationSwiper

document.addEventListener('turbo:load', function() {
  var swiperEl = document.querySelector('.donationSwiper');
  if (!swiperEl || typeof Swiper === 'undefined') return;
  var swiper = new Swiper('.donationSwiper', {
    slidesPerView: 1,
    spaceBetween: 24,
    breakpoints: {
      640: { slidesPerView: 1 },
      768: { slidesPerView: 2 },
      1024: { slidesPerView: 3 },
    },
    pagination: { el: '.swiper-pagination', clickable: true },
    navigation: { nextEl: '.swiper-button-next', prevEl: '.swiper-button-prev' },
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
