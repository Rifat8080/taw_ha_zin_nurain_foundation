// Event Guests Management
class EventGuests {
  constructor() {
    this.initialized = false;
    this.init();
  }

  init() {
    if (this.initialized) {
      console.log('Event guests already initialized, skipping...');
      return;
    }

    console.log('Initializing event guests...');
    this.attachEventListeners();
    this.initialized = true;
    console.log('Event guests initialized successfully');
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
      console.log('Add guest event listener attached');
    }

    // Event delegation for remove guest buttons
    if (!document.hasAttribute('data-guest-delegation-added')) {
      document.setAttribute('data-guest-delegation-added', 'true');
      
      document.addEventListener('click', (e) => {
        if (e.target.closest('[data-remove-guest]')) {
          e.preventDefault();
          e.stopPropagation();
          const guestField = e.target.closest('.guest-fields');
          this.removeGuest(guestField);
        }
      });
    }
  }

  addGuest() {
    console.log('Adding guest...');
    const container = document.getElementById('guests-container');
    if (!container) {
      console.error('Guest container not found');
      return;
    }

    const currentGuests = document.querySelectorAll('.guest-fields');
    const newIndex = currentGuests.length;

    const html = `
      <div class="guest-fields bg-gray-50 rounded-lg p-4 border border-gray-200">
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
            <textarea name="event[guests_attributes][${newIndex}][bio]" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" rows="2" placeholder="Brief description about the guest..."></textarea>
          </div>
        </div>
      </div>
    `;

    const div = document.createElement('div');
    div.innerHTML = html;
    container.appendChild(div.firstElementChild);

    console.log('Guest added successfully');
  }

  removeGuest(guestField) {
    if (guestField) {
      guestField.remove();
      this.updateGuestNumbers();
      console.log('Guest removed');
    }
  }

  updateGuestNumbers() {
    const guestFields = document.querySelectorAll('.guest-fields');
    guestFields.forEach((field, index) => {
      const heading = field.querySelector('h4');
      if (heading) {
        heading.textContent = 'Guest ' + (index + 1);
      }
    });
  }

  reset() {
    this.initialized = false;
    document.removeAttribute('data-guest-delegation-added');
    
    const addGuestButton = document.getElementById('add-guest-btn');
    if (addGuestButton) {
      addGuestButton.removeAttribute('data-listener-added');
    }
    
    console.log('Event guests reset for navigation');
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
    console.log('Fallback guests initialization triggered');
    initializeEventGuests();
  }
}, 100);
