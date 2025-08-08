/**
 * Guests Module
 * Handles dynamic form functionality for adding/removing guests in events
 * Compatible with Turbo for SPA-like experience
 */

class GuestsManager {
  constructor() {
    this.guestIndex = 0;
    this.initialized = false;
    
    // Bind methods to preserve context
    this.addGuest = this.addGuest.bind(this);
    this.removeGuest = this.removeGuest.bind(this);
  }

  // Guest template for dynamic adding
  get guestTemplate() {
    return `
      <div class="guest-form-item bg-gray-50 rounded-lg p-4 mb-4">
        <div class="flex justify-between items-center mb-3">
          <h4 class="text-lg font-semibold text-gray-800">Guest INDEX_DISPLAY</h4>
          <button type="button" class="remove-guest-btn text-red-600 hover:text-red-800 transition-colors duration-200">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
            </svg>
          </button>
        </div>
        
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <!-- Guest Name -->
          <div class="form-group">
            <label class="block text-sm font-medium text-gray-700 mb-1">
              Guest Name <span class="text-red-500">*</span>
            </label>
            <input type="text" 
                   name="event[guests_attributes][INDEX][name]" 
                   class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                   required>
          </div>

          <!-- Guest Title -->
          <div class="form-group">
            <label class="block text-sm font-medium text-gray-700 mb-1">
              Title/Position
            </label>
            <input type="text" 
                   name="event[guests_attributes][INDEX][title]" 
                   class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                   placeholder="e.g., CEO, Speaker, Guest of Honor">
          </div>

          <!-- Guest Description -->
          <div class="form-group md:col-span-2">
            <label class="block text-sm font-medium text-gray-700 mb-1">
              Description
            </label>
            <textarea name="event[guests_attributes][INDEX][description]" 
                      rows="3"
                      class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                      placeholder="Brief description about the guest..."></textarea>
          </div>

          <!-- Guest Image -->
          <div class="form-group md:col-span-2">
            <label class="block text-sm font-medium text-gray-700 mb-1">
              Guest Image
            </label>
            <input type="file" 
                   name="event[guests_attributes][INDEX][image]" 
                   accept="image/*"
                   class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent">
            <p class="text-sm text-gray-500 mt-1">Upload an image for the guest (optional)</p>
          </div>
        </div>
        
        <!-- Hidden field for Rails to handle destruction -->
        <input type="hidden" name="event[guests_attributes][INDEX][_destroy]" value="false" class="destroy-field">
      </div>
    `;
  }

  // Initialize the guests manager
  init() {
    if (this.initialized) return;
    
    // Check if we're on an events form page
    const form = document.querySelector('form[action*="events"]');
    if (!form) return;

    // Get initial count from existing guests
    this.guestIndex = document.querySelectorAll('.guest-form-item').length;

    this.setupEventListeners();
    this.initialized = true;
    
    console.log('Guests manager initialized with', this.guestIndex, 'existing guests');
  }

  // Clean up when navigating away (Turbo compatibility)
  destroy() {
    this.removeEventListeners();
    this.initialized = false;
  }

  setupEventListeners() {
    // Add guest button
    const addGuestBtn = document.getElementById('add-guest-btn');
    if (addGuestBtn) {
      addGuestBtn.addEventListener('click', this.addGuest);
    }

    // Remove guest functionality (using event delegation)
    document.addEventListener('click', this.removeGuest);
  }

  removeEventListeners() {
    const addGuestBtn = document.getElementById('add-guest-btn');
    if (addGuestBtn) {
      addGuestBtn.removeEventListener('click', this.addGuest);
    }
    
    document.removeEventListener('click', this.removeGuest);
  }

  addGuest(e) {
    e.preventDefault();
    
    const guestsContainer = document.getElementById('guests-container');
    if (!guestsContainer) {
      console.error('Guests container not found');
      return;
    }

    // Replace INDEX with actual index and INDEX_DISPLAY with human-readable number
    const newGuestHTML = this.guestTemplate
      .replace(/INDEX/g, this.guestIndex)
      .replace(/INDEX_DISPLAY/g, this.guestIndex + 1);
    
    const tempDiv = document.createElement('div');
    tempDiv.innerHTML = newGuestHTML;
    guestsContainer.appendChild(tempDiv.firstElementChild);
    
    this.guestIndex++;
    
    // Focus on the name field of the newly added guest
    const newGuestForm = guestsContainer.lastElementChild;
    const nameInput = newGuestForm.querySelector('input[name*="[name]"]');
    if (nameInput) {
      nameInput.focus();
    }
    
    console.log('Added guest with index:', this.guestIndex - 1);
  }

  removeGuest(e) {
    if (!e.target.closest('.remove-guest-btn')) return;

    e.preventDefault();
    
    const guestDiv = e.target.closest('.guest-form-item');
    if (!guestDiv) {
      console.error('Could not find guest form item');
      return;
    }

    // Check if this is a persisted guest by looking for an ID field
    const idField = guestDiv.querySelector('input[name*="[id]"]');
    const destroyField = guestDiv.querySelector('.destroy-field');
    
    if (idField && idField.value) {
      // This is a persisted guest, mark it for destruction
      if (destroyField) {
        destroyField.value = 'true';
        guestDiv.style.display = 'none';
        console.log('Marked existing guest for destruction');
      }
    } else {
      // This is a new guest, just remove it from the DOM
      guestDiv.remove();
      console.log('Removed new guest from DOM');
    }
    
    // Update guest numbers
    this.updateGuestNumbers();
  }

  updateGuestNumbers() {
    const guestForms = document.querySelectorAll('.guest-form-item:not([style*="display: none"])');
    guestForms.forEach((form, index) => {
      const header = form.querySelector('h4');
      if (header) {
        header.textContent = `Guest ${index + 1}`;
      }
    });
  }
}

// Create a singleton instance
const guestsManager = new GuestsManager();

// Turbo event listeners for proper initialization and cleanup
document.addEventListener('turbo:load', () => {
  guestsManager.init();
});

document.addEventListener('turbo:before-cache', () => {
  guestsManager.destroy();
});

// Fallback for traditional page loads (when Turbo is disabled)
document.addEventListener('DOMContentLoaded', () => {
  guestsManager.init();
});

// Export for potential external use
export default guestsManager;
