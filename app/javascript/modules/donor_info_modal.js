/**
 * Donor Info Modal Module
 * Handles donor information modal functionality
 * Compatible with Turbo for SPA-like experience
 */

class DonorInfoModal {
  constructor() {
    this.initialized = false;
    
    // Bind methods to preserve context
    this.showDonorInfoModal = this.showDonorInfoModal.bind(this);
    this.hideDonorInfoModal = this.hideDonorInfoModal.bind(this);
    this.handleModalButtonClick = this.handleModalButtonClick.bind(this);
    this.checkForAutoShow = this.checkForAutoShow.bind(this);
  }

  init() {
    if (this.initialized) return;
    
    // Check if modal elements exist
    const modal = document.getElementById('donor-info-modal');
    if (!modal) return;

    this.setupEventListeners();
    this.checkForAutoShow();
    this.initialized = true;
  }

  // Clean up when navigating away (Turbo compatibility)
  destroy() {
    this.removeEventListeners();
    this.initialized = false;
  }

  setupEventListeners() {
    // Close button functionality (using event delegation)
    document.addEventListener('click', this.handleModalButtonClick);
  }

  removeEventListeners() {
    document.removeEventListener('click', this.handleModalButtonClick);
  }

  handleModalButtonClick(e) {
    // Check if clicked element is a modal close button
    if (e.target.getAttribute('data-action') === 'close-donor-modal') {
      e.preventDefault();
      this.hideDonorInfoModal();
    }
  }

  checkForAutoShow() {
    // Check if modal should be shown automatically based on flash message
    if (document.body.dataset.showDonorModal === 'true') {
      this.showDonorInfoModal();
    }
  }

  showDonorInfoModal() {
    const modal = document.getElementById('donor-info-modal');
    if (modal) {
      modal.classList.remove('hidden');
      modal.style.display = 'flex';
    }
  }

  hideDonorInfoModal() {
    const modal = document.getElementById('donor-info-modal');
    if (modal) {
      modal.classList.add('hidden');
      modal.style.display = 'none';
    }
    
    // Clear the dataset flag
    delete document.body.dataset.showDonorModal;
  }
}

// Create a singleton instance
const donorInfoModal = new DonorInfoModal();

// Turbo event listeners for proper initialization and cleanup
document.addEventListener('turbo:load', () => {
  donorInfoModal.init();
});

document.addEventListener('turbo:before-cache', () => {
  donorInfoModal.destroy();
});

// Fallback for traditional page loads (when Turbo is disabled)
document.addEventListener('DOMContentLoaded', () => {
  donorInfoModal.init();
});

// Export for potential external use
export default donorInfoModal;
