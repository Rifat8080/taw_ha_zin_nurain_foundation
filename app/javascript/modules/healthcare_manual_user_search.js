// Module: healthcare_manual_user_search
// Initializes live user search and selected-user UI for manual donation form.
// This module registers a listener on `turbo:load` so it runs on Turbo visits.

function escapeHtml(unsafe) {
  return unsafe.replace(/[&<>"'`=\/]/g, function(s) {
    return {
      '&': '&amp;',
      '<': '&lt;',
      '>': '&gt;',
      '"': '&quot;',
      "'": '&#39;',
      '/': '&#x2F;',
      '=': '&#x3D;',
      '`': '&#x60;'
    }[s];
  });
}

function initHealthcareManualUserSearch() {
  var input = document.getElementById('live_user_search');
  if (!input) return; // nothing to do on pages without the form

  var resultsBox = document.getElementById('live_user_results');
  var serverResultsList = document.getElementById('server_search_results');
  var serverResultsContainer = document.getElementById('server_search_results_container');
  var donorSelect = document.querySelector('select#healthcare_donation_user_id');

  function showSelectedUser(user) {
    var container = document.getElementById('selected_user_display');
    if (!container) return;
    container.classList.remove('hidden');
    container.innerHTML = '';

    var badge = document.createElement('div');
    badge.className = 'flex items-center justify-between gap-3 bg-foundationprimarygreen/5 border border-foundationprimarygreen/10 rounded-md px-3 py-2';
    badge.innerHTML = '<div class="text-sm"><div class="font-medium text-foundationprimarygreen">' + escapeHtml(user.label) + '</div><div class="text-xs text-gray-500">Selected donor</div></div>';

    var changeBtn = document.createElement('button');
    changeBtn.type = 'button';
    changeBtn.className = 'inline-flex items-center px-3 py-1 bg-white border rounded-md text-sm text-foundationprimarygreen';
    changeBtn.textContent = 'Change';
    changeBtn.addEventListener('click', function() {
      clearSelectedUser();
      // reopen search box and focus
      input.focus();
    });

    badge.appendChild(changeBtn);
    container.appendChild(badge);
  }

  function clearSelectedUser() {
    var container = document.getElementById('selected_user_display');
    if (container) {
      container.classList.add('hidden');
      container.innerHTML = '';
    }
    var hidden = document.getElementById('healthcare_donation_user_id');
    if (hidden) hidden.value = '';
    if (donorSelect && donorSelect.tagName === 'SELECT') donorSelect.value = '';
  }

  function renderResults(users) {
    if (!resultsBox || !serverResultsList) return;
    resultsBox.innerHTML = '';
    serverResultsList.innerHTML = '';
    if (!users || users.length === 0) {
      resultsBox.classList.add('hidden');
      serverResultsContainer.classList.remove('hidden');
      serverResultsList.innerHTML = '<li class="text-sm text-gray-500 p-2">No users found. You can create a new user below.</li>';
      return;
    }

    serverResultsContainer.classList.remove('hidden');
    users.forEach(function(u) {
      var li = document.createElement('li');
      li.className = 'flex items-center justify-between p-2 border rounded-md bg-white';
      li.innerHTML = '<div class="text-sm text-gray-800"><div class="font-medium">' + (u.full_name || u.email) + '</div><div class="text-xs text-gray-500">' + u.email + (u.phone_number ? ' • ' + u.phone_number : '') + '</div></div>';
      var btn = document.createElement('button');
      btn.type = 'button';
      btn.className = 'inline-flex items-center px-3 py-1 btn-primary text-white rounded-md text-sm';
      btn.textContent = 'Select';
      btn.dataset.userId = u.id;
      btn.dataset.userLabel = (u.full_name || u.email) + ' — ' + u.email;
      btn.addEventListener('click', function() {
        var uid = this.dataset.userId;
        var ulabel = this.dataset.userLabel;
        if (donorSelect && donorSelect.tagName === 'SELECT') {
          if (!donorSelect.querySelector('option[value="' + uid + '"]')) {
            var opt = document.createElement('option');
            opt.value = uid;
            opt.text = ulabel;
            donorSelect.appendChild(opt);
          }
          donorSelect.value = uid;
        } else {
          var hidden = document.getElementById('healthcare_donation_user_id');
          if (hidden) hidden.value = uid;
        }

        showSelectedUser({ id: uid, label: ulabel });
        input.value = '';
        serverResultsContainer.classList.add('hidden');
        resultsBox.classList.add('hidden');
        var amountEl = document.getElementById('healthcare_donation_amount');
        if (amountEl) amountEl.focus();
        var notice = document.createElement('div');
        notice.className = 'fixed bottom-4 right-4 bg-foundationprimarygreen text-white px-4 py-2 rounded shadow';
        notice.textContent = 'Selected: ' + ulabel;
        document.body.appendChild(notice);
        setTimeout(function(){ notice.remove(); }, 2200);
      });
      li.appendChild(btn);
      serverResultsList.appendChild(li);
    });
    resultsBox.classList.remove('hidden');
  }

  var debounceTimer;
  input.addEventListener('input', function(e) {
    clearTimeout(debounceTimer);
    var q = e.target.value.trim();
    if (q.length < 2) {
      serverResultsContainer.classList.add('hidden');
      resultsBox.classList.add('hidden');
      return;
    }
    debounceTimer = setTimeout(function() {
      fetch('/healthcare_donations/user_search.json?q=' + encodeURIComponent(q), { headers: { 'Accept': 'application/json' } })
        .then(function(r) { return r.json(); })
        .then(function(data) { renderResults(data.users || []); })
        .catch(function() {
          serverResultsContainer.classList.remove('hidden');
          serverResultsList.innerHTML = '<li class="text-sm text-red-600 p-2">Search failed. Try again.</li>';
        });
    }, 250);
  });

  // click outside to close
  document.addEventListener('click', function(ev) {
    if (!input.contains(ev.target) && (!resultsBox || !resultsBox.contains(ev.target)) && (!serverResultsContainer || !serverResultsContainer.contains(ev.target))) {
      if (resultsBox) resultsBox.classList.add('hidden');
    }
  });
}

// Run on every Turbo visit
document.addEventListener('turbo:load', function() { initHealthcareManualUserSearch(); });

export default initHealthcareManualUserSearch;
