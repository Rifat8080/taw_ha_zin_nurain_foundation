// app/assets/javascripts/gallery_tabs.js

document.addEventListener('turbo:load', function() {
  const tabs = document.querySelectorAll('.gallery-tab');
  const categories = document.querySelectorAll('.gallery-category');
  if (!tabs.length || !categories.length) return;
  tabs.forEach(tab => {
    tab.addEventListener('click', function() {
      const catId = this.getAttribute('data-category');
      categories.forEach(cat => cat.style.display = 'none');
      document.getElementById(catId).style.display = 'block';
      tabs.forEach(t => t.classList.remove('bg-forange', 'text-white'));
      this.classList.add('bg-forange', 'text-white');
    });
  });
});
