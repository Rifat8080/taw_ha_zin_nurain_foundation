// Event Guests Management
class EventGuests {
  constructor() {
    this.initialized = false;
    this.init();
  }

  init() {
    if (this.initialized) {
      return;
    }

    // initialization
    this.attachEventListeners();
    // Attach direct listeners to any existing rendered guest remove buttons
    const existingGuests = Array.from(document.querySelectorAll('.guest-form-item'));
    existingGuests.forEach((g) => {
      const removeBtn = g.querySelector('[data-remove-guest], .remove-guest-btn, .remove-guest');
      if (removeBtn) {
        removeBtn.addEventListener('click', (e) => {
          e.preventDefault();
          e.stopPropagation();
          this.removeGuest(g);
        });
      }
    });
    // ensure numbering is correct initially
    this.updateGuestNumbers();
    this.initialized = true;
  }

  attachEventListeners() {
    // Add guest button
    const addGuestButton = document.getElementById('add-guest-btn');
    if (addGuestButton && !addGuestButton.hasAttribute('data-listener-added')) {
      addGuestButton.setAttribute('data-listener-added', 'true');
      addGuestButton.addEventListener('click', (e) => {
        e.preventDefault();
        e.stopPropagation();
        this.addGuest();
      });
    }

    // Event delegation for remove guest buttons
    if (!document.documentElement.hasAttribute('data-guest-delegation-added')) {
      document.documentElement.setAttribute('data-guest-delegation-added', 'true');

      // Support both the data attribute and the partial's remove button class
      document.addEventListener('click', (e) => {
        const removeBtn = e.target.closest('[data-remove-guest], .remove-guest-btn, .remove-guest');
        if (removeBtn) {
          // delegated remove click detected
          e.preventDefault();
          e.stopPropagation();
          // The partial uses `guest-form-item` as the wrapper class; fallback to `.guest-fields` if present
          const guestField = removeBtn.closest('.guest-form-item') || removeBtn.closest('.guest-fields');
          // guestField resolved
          this.removeGuest(guestField);
        }
      });
    }
  }

  addGuest() {
  // adding guest
    const container = document.getElementById('guests-container');
    if (!container) {
      // Guest container not found
      return;
    }

  // Match the server-rendered partial wrapper class
  const currentGuests = Array.from(document.querySelectorAll('.guest-form-item'));
  const newIndex = currentGuests.length;

    const html = `
  <div class="guest-form-item bg-gray-50 rounded-lg p-4 border border-gray-200">
        <div class="flex justify-between items-center mb-4">
          <h4 class="text-md font-medium text-gray-900">Guest ${newIndex + 1}</h4>
          <button type="button" class="remove-guest text-red-600 hover:text-red-800 p-1" data-remove-guest>
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
            </svg>
          </button>
        </div>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Name</label>
            <input type="text" name="event[guests_attributes][${newIndex}][name]" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" placeholder="Guest name" required />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Title/Position</label>
            <input type="text" name="event[guests_attributes][${newIndex}][title]" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" placeholder="e.g., Keynote Speaker" />
          </div>
          <div class="md:col-span-2">
            <label class="block text-sm font-medium text-gray-700 mb-1">Bio/Description</label>
            <textarea name="event[guests_attributes][${newIndex}][description]" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" rows="2" placeholder="Brief description about the guest..."></textarea>
          </div>
        </div>
        <div class="mt-3">
          <label class="block text-sm font-medium text-gray-700 mb-1">Guest Image</label>
          <input type="file" name="event[guests_attributes][${newIndex}][image]" accept="image/*" class="guest-image-input mt-1 block w-full text-sm text-gray-500" />
        </div>
        <!-- hidden _destroy field for Rails nested attributes handling -->
        <input type="hidden" name="event[guests_attributes][${newIndex}][_destroy]" value="false" class="destroy-field" />
      </div>
    `;

    const div = document.createElement('div');
    div.innerHTML = html;
    const newGuest = div.firstElementChild;
    if (newGuest) {
      container.appendChild(newGuest);

      // Attach a direct remove listener to the newly added guest remove button
      const removeBtn = newGuest.querySelector('[data-remove-guest], .remove-guest, .remove-guest-btn');
      if (removeBtn) {
        removeBtn.addEventListener('click', (e) => {
          // direct remove click (new guest)
          e.preventDefault();
          e.stopPropagation();
          const guestField = removeBtn.closest('.guest-form-item') || removeBtn.closest('.guest-fields');
          this.removeGuest(guestField);
        });
      }
    }

  // guest added
  }

  removeGuest(guestField) {
    if (!guestField) {
      // removeGuest called but guestField not found
      return;
    }

    // If this guest was persisted (has an id hidden field), mark for destruction and hide
  const idField = guestField.querySelector('input[type="hidden"][name*="[id]"]');
  let destroyField = guestField.querySelector('.destroy-field');
  // fallback: try to find by name if class not present
  if (!destroyField) destroyField = guestField.querySelector('input[name*="[_destroy]"]');

  if (idField && destroyField) {
      // marking persisted guest for destroy
      destroyField.value = '1'; // Rails treats '1' as truthy for _destroy
      guestField.style.display = 'none';
      guestField.dataset.destroyed = 'true';
    } else {
      // New guest not persisted yet — remove from DOM entirely
      guestField.remove();
    }

  this.updateGuestNumbers();
  // guest removed
    
  }

  updateGuestNumbers() {
    const allGuests = Array.from(document.querySelectorAll('.guest-form-item'));
    // only count visible / non-marked-for-destroy guests
    const visibleGuests = allGuests.filter((g) => {
      const destroyField = g.querySelector('.destroy-field');
      if (g.style.display === 'none') return false;
      if (destroyField && (destroyField.value === '1' || destroyField.value === 'true')) return false;
      return true;
    });

    visibleGuests.forEach((field, index) => {
      const heading = field.querySelector('h4');
      if (heading) heading.textContent = 'Guest ' + (index + 1);
    });
  }

  reset() {
    this.initialized = false;
  document.documentElement.removeAttribute('data-guest-delegation-added');
    
    const addGuestButton = document.getElementById('add-guest-btn');
    if (addGuestButton) {
      addGuestButton.removeAttribute('data-listener-added');
    }
    
  // event guests reset for navigation
  }
}

// Initialize on DOM ready and Turbo events
function initializeEventGuests() {
  if (document.getElementById('guests-container')) {
    window.eventGuests = new EventGuests();
  }
}

// Reset on navigation
function resetEventGuests() {
  if (window.eventGuests) {
    window.eventGuests.reset();
    window.eventGuests = null;
  }
}

// Event listeners for initialization
document.addEventListener('DOMContentLoaded', initializeEventGuests);
document.addEventListener('turbo:load', initializeEventGuests);
document.addEventListener('turbo:render', initializeEventGuests);

// Reset on navigation
document.addEventListener('turbo:before-cache', resetEventGuests);
document.addEventListener('turbo:before-visit', resetEventGuests);

// Fallback initialization
setTimeout(() => {
  if (!window.eventGuests && document.getElementById('guests-container')) {
  // fallback guests initialization triggered
    initializeEventGuests();
  }
}, 100);
