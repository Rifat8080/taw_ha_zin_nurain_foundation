// Handles dynamic ticket type loading and UI for the spot registration page
let currentTicketFetchController = null;

function escapeHtml(unsafe) {
  return String(unsafe)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

async function loadTicketTypesForEvent(eventId) {
  const ticketSelect = document.getElementById('spot_registration_ticket_type');
  if (!ticketSelect) return;

  if (currentTicketFetchController) {
    try { currentTicketFetchController.abort(); } catch (e) {}
    currentTicketFetchController = null;
  }

  const controller = new AbortController();
  currentTicketFetchController = controller;

  // loading state
  ticketSelect.innerHTML = '';
  ticketSelect.disabled = true;
  ticketSelect.setAttribute('aria-busy', 'true');
  const loadingOpt = document.createElement('option');
  loadingOpt.value = '';
  loadingOpt.textContent = 'Loading ticket types...';
  ticketSelect.appendChild(loadingOpt);

  try {
    const res = await fetch(`/events/${eventId}/ticket_types.json`, { headers: { 'Accept': 'application/json' }, credentials: 'same-origin', signal: controller.signal });
    if (!res.ok) throw new Error(`Failed to load (${res.status})`);
    const data = await res.json();

    // populate select
    ticketSelect.innerHTML = '';
    ticketSelect.disabled = false;
    ticketSelect.removeAttribute('aria-busy');
    const prompt = document.createElement('option');
    prompt.value = '';
    prompt.textContent = 'Select ticket type...';
    ticketSelect.appendChild(prompt);

    const cardsContainer = document.getElementById('ticket_type_cards');
    if (cardsContainer) { cardsContainer.innerHTML = ''; }
    if (data.ticket_types && data.ticket_types.length) {
      data.ticket_types.forEach(function(tt) {
        const opt = document.createElement('option');
        opt.value = tt.category;
        opt.textContent = `${tt.name}${tt.price ? ` - $${tt.price}` : ''}`;
        if (tt.sold_out) { opt.disabled = true; opt.textContent += ' (Sold out)'; }
        ticketSelect.appendChild(opt);

        if (cardsContainer) {
          const card = document.createElement('div');
          card.className = 'border border-gray-200 rounded-lg p-3 bg-white hover:shadow-md transition-shadow cursor-pointer flex flex-col';
          if (tt.sold_out) card.classList.add('opacity-60', 'cursor-not-allowed');

          card.innerHTML = `
            <div class="flex justify-between items-start">
              <div>
                <h5 class="text-sm font-medium text-gray-900">${escapeHtml(tt.name)}</h5>
                <p class="text-xs text-gray-500 uppercase tracking-wide">${escapeHtml(tt.category)}</p>
              </div>
              <div class="text-lg font-bold text-gray-900">${tt.price ? '$' + tt.price : ''}</div>
            </div>
            <p class="text-xs text-gray-600 mt-2">${escapeHtml(tt.description || '')}</p>
            <div class="mt-3 text-xs ${tt.sold_out ? 'text-red-600' : 'text-green-600'}">${tt.sold_out ? 'Sold out' : tt.seats_remaining + ' / ' + tt.seats_available + ' available'}</div>
          `;

          if (!tt.sold_out) {
            card.addEventListener('click', function() {
              ticketSelect.value = tt.category;
              cardsContainer.querySelectorAll('div').forEach(c => c.classList.remove('ring-2','ring-forange','ring-opacity-30'));
              card.classList.add('ring-2','ring-forange','ring-opacity-30');
            });
          }

          cardsContainer.appendChild(card);
        }
      });
    } else {
      const opt = document.createElement('option');
      opt.value = '';
      opt.textContent = 'No ticket types available for this event';
      ticketSelect.appendChild(opt);
      ticketSelect.disabled = true;
      if (cardsContainer) { cardsContainer.innerHTML = '<div class="text-xs text-gray-500">No ticket types to display</div>'; }
    }
  } catch (err) {
    if (err.name === 'AbortError') {
      return;
    }
    ticketSelect.innerHTML = '';
    const opt = document.createElement('option');
    opt.value = '';
    opt.textContent = 'Failed to load ticket types';
    ticketSelect.appendChild(opt);
    ticketSelect.disabled = true;
    ticketSelect.removeAttribute('aria-busy');
    console.error('Error loading ticket types for event', eventId, err);
  } finally {
    currentTicketFetchController = null;
  }
}

function initSpotRegistration() {
  const phone = document.getElementById('spot_registration_phone_number');
  const firstName = document.getElementById('spot_registration_first_name');
  const lastName = document.getElementById('spot_registration_last_name');
  const eventSelect = document.getElementById('spot_registration_event_id');

  if (phone) {
    phone.addEventListener('input', function(e) {
      let value = e.target.value.replace(/\D/g, '');
      if (value.length >= 6) {
        value = value.replace(/(\d{3})(\d{3})(\d{4})/, '($1) $2-$3');
      } else if (value.length >= 3) {
        value = value.replace(/(\d{3})(\d{0,3})/, '($1) $2');
      }
      e.target.value = value;
    });
  }

  if (firstName) {
    firstName.addEventListener('input', function(e) { e.target.value = e.target.value.replace(/\b\w/g, l => l.toUpperCase()); });
  }
  if (lastName) {
    lastName.addEventListener('input', function(e) { e.target.value = e.target.value.replace(/\b\w/g, l => l.toUpperCase()); });
  }

  if (eventSelect) {
    // Wire up quick-select chips
    document.querySelectorAll('.event-chip').forEach(function(btn) {
      btn.addEventListener('click', function() {
        const id = this.getAttribute('data-event-id');
        if (!id) return;
        eventSelect.value = id;
        eventSelect.dispatchEvent(new Event('change', { bubbles: true }));
        document.querySelectorAll('.event-chip').forEach(c => c.classList.remove('bg-forange/10','text-forange','border-forange'));
        this.classList.add('bg-forange/10','text-forange');
      });
    });

    eventSelect.addEventListener('change', function() {
      if (this.value) loadTicketTypesForEvent(this.value);
      else {
        const ticketSelect = document.getElementById('spot_registration_ticket_type');
        if (!ticketSelect) return;
        ticketSelect.innerHTML = '';
        const prompt = document.createElement('option');
        prompt.value = '';
        prompt.textContent = 'Select ticket type...';
        ticketSelect.appendChild(prompt);
        [['General Admission','general'],['VIP','vip'],['Premium','premium'],['Standard','standard']].forEach(function(pair){
          const o = document.createElement('option'); o.value = pair[1]; o.textContent = pair[0]; ticketSelect.appendChild(o);
        });
      }
    });

    if (eventSelect.value) loadTicketTypesForEvent(eventSelect.value);
  }
}

function teardownSpotRegistration() {
  // Abort any pending fetch before Turbo caches the page
  if (currentTicketFetchController) {
    try { currentTicketFetchController.abort(); } catch (e) {}
    currentTicketFetchController = null;
  }
}

document.addEventListener('turbo:load', initSpotRegistration);
document.addEventListener('DOMContentLoaded', initSpotRegistration);
document.addEventListener('turbo:before-cache', teardownSpotRegistration);

export { initSpotRegistration, teardownSpotRegistration };
