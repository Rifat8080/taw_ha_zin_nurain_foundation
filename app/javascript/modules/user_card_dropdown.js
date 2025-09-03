// app/javascript/modules/user_card_dropdown.js
// Simple per-card dropdown toggles initialized on turbo:load.
function initUserCardDropdowns() {
  document.querySelectorAll('[data-user-card]').forEach(card => {
    const btn = card.querySelector('[data-user-card-menu-button]');
    const menu = card.querySelector('[data-user-card-menu]');
    if (!btn || !menu) return;

    // Toggle on click
    btn.addEventListener('click', (e) => {
      e.preventDefault();
      const isOpen = menu.classList.contains('hidden') === false;
      // Close all other menus
      document.querySelectorAll('[data-user-card-menu]').forEach(m => m.classList.add('hidden'));
      if (!isOpen) menu.classList.remove('hidden');
    });
  });

  // Close menus when clicking outside
  document.addEventListener('click', (e) => {
    if (e.target.closest('[data-user-card]')) return;
    document.querySelectorAll('[data-user-card-menu]').forEach(m => m.classList.add('hidden'));
  });
}

document.addEventListener('turbo:load', initUserCardDropdowns);

export { initUserCardDropdowns };
