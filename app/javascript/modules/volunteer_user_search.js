// JS module to provide a debounced live search for users in the volunteer form.
// Initializes on turbo:load and wires up elements with ids used in the volunteer form partial.

function debounce(fn, wait) {
  let t;
  return function(...args) {
    clearTimeout(t);
    t = setTimeout(() => fn.apply(this, args), wait);
  };
}

function renderResultItem(user) {
  const div = document.createElement('div');
  div.className = 'px-3 py-2 border rounded-md mb-2 flex items-center justify-between hover:bg-gray-50 cursor-pointer';
  div.dataset.userId = user.id;
  div.innerHTML = `<div><div class="font-medium">${escapeHtml(user.name)}</div><div class="text-sm text-gray-600">${escapeHtml(user.email || '')}${user.phone ? ' · ' + escapeHtml(user.phone) : ''}</div></div><div class="text-sm text-foundationprimarygreen">Select</div>`;
  return div;
}

function escapeHtml(unsafe) {
  return String(unsafe)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

function init() {
  const input = document.getElementById('live_user_search');
  const results = document.getElementById('live_user_results');
  const selectedDisplay = document.getElementById('selected_user_display');
  const hiddenInput = document.getElementById('volunteer_user_id');

  if (!input || !results || !hiddenInput || !selectedDisplay) return;

  const clearResults = () => { results.innerHTML = ''; };

  const showSelected = (user) => {
    hiddenInput.value = user.id;
    selectedDisplay.innerHTML = `<div class="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-foundationprimarygreen/10 border border-foundationprimarygreen/20 text-sm"><div class="font-medium">${escapeHtml(user.name)}</div><div class="text-xs text-gray-600">${escapeHtml(user.email)}</div><button type="button" id="clear_selected_user" class="ml-2 text-red-500">Remove</button></div>`;
    // hide results
    clearResults();
  };

  document.addEventListener('click', (e) => {
    if (e.target && e.target.id === 'clear_selected_user') {
      hiddenInput.value = '';
      selectedDisplay.innerHTML = '';
    }
  });

  results.addEventListener('click', (e) => {
    let el = e.target;
    while (el && el !== results) {
      if (el.dataset && el.dataset.userId) {
        const user = { id: el.dataset.userId, name: el.querySelector('.font-medium')?.textContent || '', email: el.querySelector('.text-sm')?.textContent || '' };
        showSelected(user);
        break;
      }
      el = el.parentElement;
    }
  });

  const doSearch = debounce(async () => {
    const q = input.value.trim();
    if (!q) { clearResults(); return; }

    try {
      const resp = await fetch(`/volunteers/user_search.json?q=${encodeURIComponent(q)}`);
      if (!resp.ok) { clearResults(); return; }
      const users = await resp.json();
      results.innerHTML = '';
      if (!users.length) {
        results.innerHTML = '<div class="text-sm text-gray-500">No users found</div>';
        return;
      }
      users.forEach(u => results.appendChild(renderResultItem(u)));
    } catch (err) {
      clearResults();
    }
  }, 250);

  input.addEventListener('input', doSearch);
}

document.addEventListener('turbo:load', init);

export default { init };
