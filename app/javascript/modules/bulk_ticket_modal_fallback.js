// Fallback JavaScript for bulk ticket modal
// This provides backup functionality if the main ES6 module fails to load

// Wait a bit to see if the main module has loaded
setTimeout(() => {
  // Only initialize fallback if main module hasn't already defined the functions
  if (typeof window.openTicketModal === 'undefined') {
    
    window.openTicketModal = function() {
      const modal = document.getElementById('ticket-booking-modal');
      if (!modal) return;
      
      modal.style.display = 'block';
      document.body.style.overflow = 'hidden';
      
      // Initialize the functionality if not already done
      initModalFunctionality();
    };

    window.closeTicketModal = function() {
      const modal = document.getElementById('ticket-booking-modal');
      if (modal) {
        modal.style.display = 'none';
        document.body.style.overflow = '';
      }
    };
    
    let modalInitialized = false;
    
    function initModalFunctionality() {
      if (modalInitialized) return;
      
      const modal = document.getElementById('ticket-booking-modal');
      if (!modal) return;
      
      const quantityInputs = modal.querySelectorAll('.quantity-input');
      const quantityButtons = modal.querySelectorAll('.quantity-btn-minus, .quantity-btn-plus');
      const totalAmountSpan = modal.querySelector('#total-amount');
      const totalQuantitySpan = modal.querySelector('#total-quantity');
      const purchaseBtn = modal.querySelector('#purchase-btn');

      // Handle quantity button clicks
      quantityButtons.forEach(button => {
        button.addEventListener('click', function(e) {
          e.preventDefault();
          e.stopPropagation();
          
          const ticketType = this.dataset.ticketType;
          const action = this.dataset.action;
          const input = modal.querySelector(`#quantity_${ticketType}`);
          
          if (!input) return;

          const currentValue = parseInt(input.value) || 0;
          const max = parseInt(input.max) || 0;
          const min = parseInt(input.min) || 0;

          if (action === 'increase' && currentValue < max) {
            input.value = currentValue + 1;
          } else if (action === 'decrease' && currentValue > min) {
            input.value = currentValue - 1;
          }

          updateCalculations();
        });
      });

      // Handle direct input changes
      quantityInputs.forEach(input => {
        input.addEventListener('input', function() {
          const max = parseInt(this.max) || 0;
          const min = parseInt(this.min) || 0;
          let value = parseInt(this.value) || 0;
          
          if (value > max) {
            this.value = max;
          } else if (value < min) {
            this.value = min;
          }
          
          updateCalculations();
        });
      });

      function updateCalculations() {
        let totalAmount = 0;
        let totalQuantity = 0;

        quantityInputs.forEach(input => {
          const quantity = parseInt(input.value) || 0;
          const price = parseFloat(input.dataset.price) || 0;
          const subtotal = quantity * price;
          const ticketType = input.dataset.ticketType;

          // Update subtotal display
          const subtotalSpan = modal.querySelector(`.subtotal[data-ticket-type="${ticketType}"]`);
          if (subtotalSpan) {
            subtotalSpan.textContent = `$${subtotal.toFixed(2)}`;
          }

          totalAmount += subtotal;
          totalQuantity += quantity;
        });

        // Update totals
        if (totalAmountSpan) {
          totalAmountSpan.textContent = `$${totalAmount.toFixed(2)}`;
        }
        
        if (totalQuantitySpan) {
          totalQuantitySpan.textContent = totalQuantity;
        }

        // Enable/disable purchase button
        if (purchaseBtn) {
          purchaseBtn.disabled = totalQuantity === 0;
        }
      }

      // Reset quantities and update calculations
      quantityInputs.forEach(input => {
        input.value = 0;
      });
      updateCalculations();
      
      modalInitialized = true;
    }
  }
}, 100); // Wait 100ms to allow main module to load first
