// Modal functionality for donor information
class DonorInfoModal {
  constructor() {
    this.modal = this.safeQuerySelector('#donor-info-modal');
    if (this.modal) {
      this.init();
    }
  }

  // Safe DOM query selector
  safeQuerySelector(selector) {
    try {
      return document.querySelector(selector);
    } catch (error) {
  // Invalid selector encountered when querying DOM
      return null;
    }
  }

  // Safe class manipulation
  addClass(element, ...classNames) {
    if (!element) return;
    element.classList.add(...classNames);
  }

  removeClass(element, ...classNames) {
    if (!element) return;
    element.classList.remove(...classNames);
  }

  init() {
    // Auto-show modal for new donors with specific flash message
    this.checkForAutoShow();
  }

  show() {
    if (this.modal) {
      this.removeClass(this.modal, 'hidden');
    }
  }

  hide() {
    if (this.modal) {
      this.addClass(this.modal, 'hidden');
    }
  }

  checkForAutoShow() {
    // Check if there's a data attribute indicating we should show the modal
    const shouldAutoShow = document.body.dataset.showDonorModal;
    if (shouldAutoShow === 'true') {
      setTimeout(() => this.show(), 1000);
    }
  }
}

// Export for use in other modules
window.DonorInfoModal = DonorInfoModal;

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
  if (document.querySelector('#donor-info-modal')) {
    const modal = new DonorInfoModal();
    
    // Make functions globally available for onclick handlers
    window.showDonorInfoModal = () => modal.show();
    window.hideDonorInfoModal = () => modal.hide();
  }
});
