/**
 * Mobile Navigation Module
 * Handles mobile menu toggle functionality
 * Compatible with Turbo for SPA-like experience
 */

class MobileNavigation {
  constructor() {
    this.initialized = false;
    
    // Bind methods to preserve context
    this.toggleMobileMenu = this.toggleMobileMenu.bind(this);
    this.handleMenuButtonClick = this.handleMenuButtonClick.bind(this);
  }

  init() {
    if (this.initialized) return;
    
    // Check if mobile menu elements exist
    const mobileMenuButton = document.getElementById('mobile-menu-button');
    const mobileMenu = document.getElementById('mobile-menu');
    
    if (!mobileMenuButton || !mobileMenu) return;

    this.setupEventListeners();
    this.initialized = true;
  }

  // Clean up when navigating away (Turbo compatibility)
  destroy() {
    this.removeEventListeners();
    this.initialized = false;
  }

  setupEventListeners() {
    const mobileMenuButton = document.getElementById('mobile-menu-button');
    if (mobileMenuButton) {
      mobileMenuButton.addEventListener('click', this.handleMenuButtonClick);
    }
  }

  removeEventListeners() {
    const mobileMenuButton = document.getElementById('mobile-menu-button');
    if (mobileMenuButton) {
      mobileMenuButton.removeEventListener('click', this.handleMenuButtonClick);
    }
  }

  handleMenuButtonClick(e) {
    e.preventDefault();
    this.toggleMobileMenu();
  }

  toggleMobileMenu() {
    const mobileMenu = document.getElementById('mobile-menu');
    if (mobileMenu) {
      mobileMenu.classList.toggle('hidden');
    }
  }
}

// Create a singleton instance
const mobileNavigation = new MobileNavigation();

// Turbo event listeners for proper initialization and cleanup
document.addEventListener('turbo:load', () => {
  mobileNavigation.init();
});

document.addEventListener('turbo:before-cache', () => {
  mobileNavigation.destroy();
});

// Fallback for traditional page loads (when Turbo is disabled)
document.addEventListener('DOMContentLoaded', () => {
  mobileNavigation.init();
});

// Export for potential external use
export default mobileNavigation;
