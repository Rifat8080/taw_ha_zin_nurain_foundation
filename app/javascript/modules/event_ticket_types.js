/**
 * Event Ticket Types Module
 * Handles dynamic management of multiple ticket types for events
 * Rails-compatible version without ES6 modules
 */

(function() {
  'use strict';
  
  let ticketTypeIndex = 0;
  let initialized = false;

  function initializeEventTicketTypes() {
    if (initialized) return;
    
    console.log('Initializing Event Ticket Types...');
    
    const container = document.getElementById('ticket-types-container');
    const addButton = document.getElementById('add-ticket-type');
    
    console.log('Container found:', !!container);
    console.log('Add button found:', !!addButton);
    
    if (!container || !addButton) {
      console.log('Required elements not found, skipping initialization');
      return;
    }
    
    // Set initial index
    ticketTypeIndex = document.querySelectorAll('.ticket-type-fields').length;
    console.log('Initial ticket type count:', ticketTypeIndex);
    
    // Add event listener for the add button
    addButton.addEventListener('click', function(e) {
      e.preventDefault();
      console.log('Add button clicked!');
      addTicketType();
    });
    
    // Setup other listeners
    setupEventListeners();
    updateTotalSeats();
    
    initialized = true;
    console.log('Event Ticket Types initialized successfully');
  }

  function addTicketType() {
    console.log('Adding ticket type...');
    const container = document.getElementById('ticket-types-container');
    if (!container) {
      console.error('Container not found');
      return;
    }
    
    const html = getTicketTypeTemplate(ticketTypeIndex);
    const div = document.createElement('div');
    div.innerHTML = html;
    container.appendChild(div.firstElementChild);
    
    ticketTypeIndex++;
    updateTotalSeats();
    console.log('Ticket type added, new index:', ticketTypeIndex);
  }

  function setupEventListeners() {
    // Remove functionality (event delegation)
    document.addEventListener('click', function(e) {
      if (e.target.closest('.remove-ticket-type')) {
        e.preventDefault();
        const ticketTypeField = e.target.closest('.ticket-type-fields');
        if (ticketTypeField) {
          removeTicketType(ticketTypeField);
        }
      }
    });

    // Seats calculation (event delegation)
    document.addEventListener('input', function(e) {
      if (e.target.matches && e.target.matches('input[name*="[seats_available]"]')) {
        updateTotalSeats();
      }
    });
  }

  function removeTicketType(ticketTypeElement) {
    if (document.querySelectorAll('.ticket-type-fields').length <= 1) {
      alert('At least one ticket type is required');
      return;
    }
    
    ticketTypeElement.remove();
    updateTotalSeats();
  }

  function updateTotalSeats() {
    const seatsInputs = document.querySelectorAll('input[name*="[seats_available]"]');
    let totalSeats = 0;
    
    seatsInputs.forEach(function(input) {
      totalSeats += parseInt(input.value) || 0;
    });
    
    const totalDisplay = document.getElementById('total-seats-display');
    if (totalDisplay) {
      totalDisplay.textContent = totalSeats;
    }
    
    // Update the legacy seat_number field for backward compatibility
    const legacySeatInput = document.getElementById('event_seat_number');
    if (legacySeatInput) {
      legacySeatInput.value = totalSeats;
    }
  }

  function getTicketTypeTemplate(index) {
    return [
      '<div class="ticket-type-fields bg-gray-50 rounded-lg p-4 mb-4">',
        '<div class="flex justify-between items-center mb-4">',
          '<h4 class="text-lg font-medium text-gray-900">Ticket Type ' + (index + 1) + '</h4>',
          '<button type="button" class="remove-ticket-type text-red-600 hover:text-red-800 p-2">',
            '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">',
              '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>',
            '</svg>',
          '</button>',
        '</div>',
        '<div class="grid grid-cols-1 md:grid-cols-2 gap-4">',
          '<div>',
            '<label class="block text-sm font-medium text-gray-700 mb-2">Type Name</label>',
            '<input type="text" name="event[ticket_types][][name]" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent" placeholder="e.g., General Admission, VIP, Premium" required />',
          '</div>',
          '<div>',
            '<label class="block text-sm font-medium text-gray-700 mb-2">Category</label>',
            '<select name="event[ticket_types][][category]" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent" required>',
              '<option value="">Select category</option>',
              '<option value="general">General</option>',
              '<option value="vip">VIP</option>',
              '<option value="premium">Premium</option>',
              '<option value="standard">Standard</option>',
            '</select>',
          '</div>',
          '<div>',
            '<label class="block text-sm font-medium text-gray-700 mb-2">Price ($)</label>',
            '<input type="number" name="event[ticket_types][][price]" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent" step="0.01" min="0" placeholder="0.00" required />',
          '</div>',
          '<div>',
            '<label class="block text-sm font-medium text-gray-700 mb-2">Seats Available</label>',
            '<input type="number" name="event[ticket_types][][seats_available]" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent" min="1" placeholder="100" required />',
          '</div>',
          '<div class="md:col-span-2">',
            '<label class="block text-sm font-medium text-gray-700 mb-2">Description (Optional)</label>',
            '<textarea name="event[ticket_types][][description]" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent" rows="2" placeholder="Brief description of what this ticket type includes..."></textarea>',
          '</div>',
        '</div>',
      '</div>'
    ].join('');
  }

  // Initialize on various events
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initializeEventTicketTypes);
  } else {
    initializeEventTicketTypes();
  }
  
  // Turbo support
  document.addEventListener('turbo:load', initializeEventTicketTypes);
  
  // Reset on navigation
  document.addEventListener('turbo:before-cache', function() {
    initialized = false;
  });

  // Make functions globally available for debugging
  window.eventTicketTypesDebug = {
    init: initializeEventTicketTypes,
    addTicketType: addTicketType,
    getStatus: function() {
      return {
        initialized: initialized,
        ticketTypeIndex: ticketTypeIndex,
        containerExists: !!document.getElementById('ticket-types-container'),
        buttonExists: !!document.getElementById('add-ticket-type')
      };
    }
  };

})();
