// Event Ticket Types Management
class EventTicketTypes {
  constructor() {
    this.initialized = false;
    this.init();
  }

  init() {
  if (this.initialized) return;
    this.attachEventListeners();
    // Attach direct listeners to any existing rendered ticket remove buttons
    const existingTickets = Array.from(document.querySelectorAll('.ticket-type-fields'));
    existingTickets.forEach((t) => {
      const removeBtn = t.querySelector('[data-remove-ticket], .remove-ticket-type');
      if (removeBtn) {
        removeBtn.addEventListener('click', (e) => {
          e.preventDefault();
          e.stopPropagation();
          this.removeTicketType(t);
          this.updateRemoveButtons();
        });
      }
    });
    this.updateTotalSeats();
    this.updateRemoveButtons();
    this.initialized = true;
  }

  attachEventListeners() {
    // Add ticket type button
    const addButton = document.getElementById('add-ticket-type');
    if (addButton && !addButton.hasAttribute('data-listener-added')) {
      addButton.setAttribute('data-listener-added', 'true');
      addButton.addEventListener('click', (e) => {
        e.preventDefault();
        e.stopPropagation();
        this.addTicketType();
      });
    }

    // Event delegation for remove buttons and seats inputs
    if (!document.documentElement.hasAttribute('data-ticket-delegation-added')) {
      document.documentElement.setAttribute('data-ticket-delegation-added', 'true');
      
      // Listen for clicks on elements that either have the data attribute or the class
      document.addEventListener('click', (e) => {
        const removeBtn = e.target.closest('[data-remove-ticket], .remove-ticket-type');
        if (removeBtn) {
          e.preventDefault();
          e.stopPropagation();
          const ticketTypeField = removeBtn.closest('.ticket-type-fields');
          this.removeTicketType(ticketTypeField);
        }
      });
      
    document.addEventListener('input', (e) => {
        if (e.target.matches('[data-seats-input]')) {
          this.updateTotalSeats();
        }
      });
    }
  }

  addTicketType() {
  // adding ticket type
    const container = document.getElementById('ticket-types-container');
    if (!container) {
      console.error('Container not found');
      return;
    }

    const currentTicketFields = document.querySelectorAll('.ticket-type-fields');
    const newIndex = currentTicketFields.length + 1;

    const html = `
      <div class="ticket-type-fields bg-gray-50 rounded-lg p-4 mb-4">
        <div class="flex justify-between items-center mb-4">
          <h4 class="text-lg font-medium text-gray-900">Ticket Type ${newIndex}</h4>
          <button type="button" class="remove-ticket-type text-red-600 hover:text-red-800 p-2" data-remove-ticket>
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
            </svg>
          </button>
        </div>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Type Name</label>
            <input type="text" name="event[ticket_types][][name]" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent" placeholder="e.g., General Admission, VIP, Premium" required />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Category</label>
            <select name="event[ticket_types][][category]" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent" required>
              <option value="">Select category</option>
              <option value="general">General</option>
              <option value="vip">VIP</option>
              <option value="premium">Premium</option>
              <option value="standard">Standard</option>
            </select>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Price ($)</label>
            <input type="number" name="event[ticket_types][][price]" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent" step="0.01" min="0" placeholder="0.00" required />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Seats Available</label>
            <input type="number" name="event[ticket_types][][seats_available]" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent" min="1" placeholder="100" required data-seats-input />
          </div>
          <div class="md:col-span-2">
            <label class="block text-sm font-medium text-gray-700 mb-2">Description (Optional)</label>
            <textarea name="event[ticket_types][][description]" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent" rows="2" placeholder="Brief description of what this ticket type includes..."></textarea>
          </div>
        </div>
      </div>
    `;

  const div = document.createElement('div');
  div.innerHTML = html;
  // Insert the ticket block directly (first child of generated wrapper)
  const newBlock = div.firstElementChild;
    if (newBlock) {
      container.appendChild(newBlock);

      // Attach direct listener to the remove button on the new block
      const removeBtn = newBlock.querySelector('[data-remove-ticket], .remove-ticket-type');
      if (removeBtn) {
        removeBtn.addEventListener('click', (e) => {
          e.preventDefault();
          e.stopPropagation();
          const ticketTypeField = removeBtn.closest('.ticket-type-fields');
          this.removeTicketType(ticketTypeField);
          this.updateRemoveButtons();
        });
      }
    }

    this.updateTotalSeats();
    this.updateRemoveButtons();
  }

  removeTicketType(ticketTypeField) {
    const ticketFields = document.querySelectorAll('.ticket-type-fields');
    if (ticketFields.length <= 1) {
      alert('At least one ticket type is required');
      return;
    }

    if (!ticketTypeField) {
      console.warn('[EventTicketTypes] removeTicketType called but ticketTypeField is null');
      return;
    }

    console.debug('[EventTicketTypes] removing ticket block', ticketTypeField);
    ticketTypeField.remove();
    this.updateTotalSeats();
    this.updateTicketTypeNumbers();
    this.updateRemoveButtons();
  }

  updateTotalSeats() {
    const seatsInputs = document.querySelectorAll('input[data-seats-input]');
    let totalSeats = 0;

    seatsInputs.forEach((input) => {
      totalSeats += parseInt(input.value) || 0;
    });

    const totalDisplay = document.getElementById('total-seats-display');
    if (totalDisplay) {
      totalDisplay.textContent = totalSeats;
    }

    const legacySeatInput = document.getElementById('event_seat_number');
    if (legacySeatInput) {
      legacySeatInput.value = totalSeats;
    }

  }

  updateTicketTypeNumbers() {
    const ticketFields = document.querySelectorAll('.ticket-type-fields');
    ticketFields.forEach((field, index) => {
      const heading = field.querySelector('h4');
      if (heading) {
        heading.textContent = 'Ticket Type ' + (index + 1);
      }
    });
  }

  updateRemoveButtons() {
    const removeButtons = document.querySelectorAll('.remove-ticket-type');
    const ticketFields = document.querySelectorAll('.ticket-type-fields');

    removeButtons.forEach((button) => {
      button.disabled = ticketFields.length <= 1;
      if (ticketFields.length <= 1) {
        button.style.opacity = '0.5';
        button.style.cursor = 'not-allowed';
      } else {
        button.style.opacity = '1';
        button.style.cursor = 'pointer';
      }
    });
  }

  reset() {
    this.initialized = false;
  document.documentElement.removeAttribute('data-ticket-delegation-added');
    
    const addButton = document.getElementById('add-ticket-type');
    if (addButton) {
      addButton.removeAttribute('data-listener-added');
    }
    
  }
}

// Initialize on DOM ready and Turbo events
function initializeEventTicketTypes() {
  if (document.getElementById('ticket-types-container')) {
    window.eventTicketTypes = new EventTicketTypes();
  }
}

// Reset on navigation
function resetEventTicketTypes() {
  if (window.eventTicketTypes) {
    window.eventTicketTypes.reset();
    window.eventTicketTypes = null;
  }
}

// Event listeners for initialization
document.addEventListener('DOMContentLoaded', initializeEventTicketTypes);
document.addEventListener('turbo:load', initializeEventTicketTypes);
document.addEventListener('turbo:render', initializeEventTicketTypes);

// Reset on navigation
document.addEventListener('turbo:before-cache', resetEventTicketTypes);
document.addEventListener('turbo:before-visit', resetEventTicketTypes);

// Fallback initialization
setTimeout(() => {
  if (!window.eventTicketTypes && document.getElementById('ticket-types-container')) {
    initializeEventTicketTypes();
  }
}, 100);
