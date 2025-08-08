/**
 * Healthcare Donations Module
 * Handles donation amount selection and form interactions
 * Compatible with Turbo for SPA-like experience
 */

class HealthcareDonations {
  constructor() {
    this.initialized = false;
    
    // Bind methods to preserve context
    this.setAmount = this.setAmount.bind(this);
    this.handleCustomAmountInput = this.handleCustomAmountInput.bind(this);
    this.handleAmountButtonClick = this.handleAmountButtonClick.bind(this);
  }

  init() {
    if (this.initialized) return;
    
    // Check if we're on the healthcare donation page
    const donationForm = document.querySelector('form[action*="healthcare_donations"]');
    if (!donationForm) return;

    this.setupEventListeners();
    this.initialized = true;
  }

  // Clean up when navigating away (Turbo compatibility)
  destroy() {
    this.removeEventListeners();
    this.initialized = false;
  }

  setupEventListeners() {
    // Amount buttons (using event delegation)
    document.addEventListener('click', this.handleAmountButtonClick);

    // Custom amount input
    const amountInput = document.getElementById('donation_amount');
    if (amountInput) {
      amountInput.addEventListener('input', this.handleCustomAmountInput);
    }
  }

  removeEventListeners() {
    document.removeEventListener('click', this.handleAmountButtonClick);
    
    const amountInput = document.getElementById('donation_amount');
    if (amountInput) {
      amountInput.removeEventListener('input', this.handleCustomAmountInput);
    }
  }

  handleAmountButtonClick(e) {
    if (!e.target.classList.contains('amount-btn')) return;
    
    e.preventDefault();
    const amount = e.target.getAttribute('data-amount');
    if (amount) {
      this.setAmount(parseInt(amount), e.target);
    }
  }

  setAmount(amount, clickedButton = null) {
    const amountInput = document.getElementById('donation_amount');
    if (!amountInput) return;

    amountInput.value = amount;
    
    // Remove active class from all buttons
    this.clearActiveButtons();
    
    // Add active class to clicked button (if provided)
    if (clickedButton) {
      this.setActiveButton(clickedButton);
    }
  }

  clearActiveButtons() {
    document.querySelectorAll('.amount-btn').forEach(btn => {
      btn.classList.remove('bg-blue-100', 'border-blue-500', 'text-blue-700');
      btn.classList.add('border-gray-300', 'text-gray-700', 'bg-white');
    });
  }

  setActiveButton(button) {
    button.classList.remove('border-gray-300', 'text-gray-700', 'bg-white');
    button.classList.add('bg-blue-100', 'border-blue-500', 'text-blue-700');
  }

  handleCustomAmountInput() {
    // Remove active state when custom amount is typed
    this.clearActiveButtons();
  }
}

// Create a singleton instance
const healthcareDonations = new HealthcareDonations();

// Turbo event listeners for proper initialization and cleanup
document.addEventListener('turbo:load', () => {
  healthcareDonations.init();
});

document.addEventListener('turbo:before-cache', () => {
  healthcareDonations.destroy();
});

// Fallback for traditional page loads (when Turbo is disabled)
document.addEventListener('DOMContentLoaded', () => {
  healthcareDonations.init();
});

// Export for potential external use
export default healthcareDonations;
