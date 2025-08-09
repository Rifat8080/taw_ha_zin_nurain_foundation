// Bulk Ticket Modal Management
class BulkTicketModal {
  constructor() {
    this.modal = null;
    this.quantityInputs = [];
    this.quantityButtons = [];
    this.totalAmountSpan = null;
    this.totalQuantitySpan = null;
    this.purchaseBtn = null;
    this.initialized = false;
    this.eventListenersAttached = false;
  }

  init() {
    this.modal = document.getElementById('ticket-booking-modal');
    if (!this.modal) return;

    this.quantityInputs = this.modal.querySelectorAll('.quantity-input');
    this.quantityButtons = this.modal.querySelectorAll('.quantity-btn-minus, .quantity-btn-plus');
    this.totalAmountSpan = this.modal.querySelector('#total-amount');
    this.totalQuantitySpan = this.modal.querySelector('#total-quantity');
    this.purchaseBtn = this.modal.querySelector('#purchase-btn');

    // Only attach event listeners if not already attached
    if (!this.eventListenersAttached) {
      this.attachEventListeners();
      this.eventListenersAttached = true;
    }
    
    this.updateCalculations();
    this.initialized = true;
  }

  attachEventListeners() {
    // Handle quantity button clicks with once option to prevent duplicates
    this.quantityButtons.forEach(button => {
      button.addEventListener('click', (e) => {
        e.preventDefault();
        e.stopPropagation();
        
        const ticketType = button.dataset.ticketType;
        const action = button.dataset.action;
        const input = this.modal.querySelector(`#quantity_${ticketType}`);
        
        if (!input) return;

        const currentValue = parseInt(input.value) || 0;
        const max = parseInt(input.max) || 0;
        const min = parseInt(input.min) || 0;

        if (action === 'increase' && currentValue < max) {
          input.value = currentValue + 1;
        } else if (action === 'decrease' && currentValue > min) {
          input.value = currentValue - 1;
        }

        this.updateCalculations();
      }, { once: false, passive: false });
    });

    // Handle direct input changes
    this.quantityInputs.forEach(input => {
      input.addEventListener('input', () => {
        const max = parseInt(input.max) || 0;
        const min = parseInt(input.min) || 0;
        let value = parseInt(input.value) || 0;
        
        // Ensure value is within bounds
        if (value > max) {
          value = max;
          input.value = max;
        } else if (value < min) {
          value = min;
          input.value = min;
        }
        
        this.updateCalculations();
      });

      // Also handle blur event to ensure validation
      input.addEventListener('blur', () => {
        const max = parseInt(input.max) || 0;
        const min = parseInt(input.min) || 0;
        let value = parseInt(input.value) || 0;
        
        if (value > max) {
          input.value = max;
        } else if (value < min) {
          input.value = min;
        }
        
        this.updateCalculations();
      });
    });
  }

  updateCalculations() {
    if (!this.initialized) return;

    let totalAmount = 0;
    let totalQuantity = 0;

    this.quantityInputs.forEach(input => {
      const quantity = parseInt(input.value) || 0;
      const price = parseFloat(input.dataset.price) || 0;
      const subtotal = quantity * price;
      const ticketType = input.dataset.ticketType;

      // Update subtotal display
      const subtotalSpan = this.modal.querySelector(`.subtotal[data-ticket-type="${ticketType}"]`);
      if (subtotalSpan) {
        subtotalSpan.textContent = `$${subtotal.toFixed(2)}`;
      }

      totalAmount += subtotal;
      totalQuantity += quantity;
    });

    // Update totals
    if (this.totalAmountSpan) {
      this.totalAmountSpan.textContent = `$${totalAmount.toFixed(2)}`;
    }
    
    if (this.totalQuantitySpan) {
      this.totalQuantitySpan.textContent = totalQuantity;
    }

    // Enable/disable purchase button
    if (this.purchaseBtn) {
      this.purchaseBtn.disabled = totalQuantity === 0;
      if (totalQuantity === 0) {
        this.purchaseBtn.classList.add('disabled:bg-gray-300', 'disabled:cursor-not-allowed');
      } else {
        this.purchaseBtn.classList.remove('disabled:bg-gray-300', 'disabled:cursor-not-allowed');
      }
    }
  }

  open() {
    // Always try to find the modal fresh from the DOM
    const modalElement = document.getElementById('ticket-booking-modal');
    if (!modalElement) return;
    
    // Update our reference
    this.modal = modalElement;

    // Initialize if not already done
    if (!this.initialized) {
      this.init();
    }

    this.modal.style.display = 'block';
    document.body.style.overflow = 'hidden'; // Prevent background scrolling
    
    // Reset all quantities to 0
    if (this.quantityInputs && this.quantityInputs.length > 0) {
      this.quantityInputs.forEach(input => {
        input.value = 0;
      });
    }
    
    this.updateCalculations();
  }

  close() {
    if (!this.modal) return;

    this.modal.style.display = 'none';
    document.body.style.overflow = ''; // Restore scrolling
  }

  reset() {
    this.initialized = false;
    this.eventListenersAttached = false;
  }
}

// Global instance
let bulkTicketModal = null;

// Initialize and expose global functions immediately
function initializeBulkTicketModal() {
  if (!bulkTicketModal) {
    bulkTicketModal = new BulkTicketModal();
  }
  
  // Try to initialize if the modal exists in the DOM
  const modalElement = document.getElementById('ticket-booking-modal');
  if (modalElement && !bulkTicketModal.initialized) {
    bulkTicketModal.init();
  }
  
  // Define global functions
  window.openTicketModal = function() {
    if (!bulkTicketModal) {
      bulkTicketModal = new BulkTicketModal();
    }
    
    // Ensure modal is initialized before opening
    if (!bulkTicketModal.initialized) {
      const modalElement = document.getElementById('ticket-booking-modal');
      if (modalElement) {
        bulkTicketModal.init();
      }
    }
    
    bulkTicketModal.open();
  };

  window.closeTicketModal = function() {
    if (bulkTicketModal) {
      bulkTicketModal.close();
    }
  };
}

// Initialize immediately when the script loads
initializeBulkTicketModal();

// Also initialize on DOM ready
document.addEventListener('DOMContentLoaded', function() {
  initializeBulkTicketModal();
});

// Also initialize on turbo:load for Rails with Turbo
document.addEventListener('turbo:load', function() {
  // Reset any existing instance
  if (bulkTicketModal) {
    bulkTicketModal.reset();
    bulkTicketModal = null;
  }
  
  initializeBulkTicketModal();
});
