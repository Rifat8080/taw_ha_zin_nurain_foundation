/**
 * Guests Module
 * Handles dynamic form functionality for add        <!-- Guest Image -->
        <div class="form-group">
          <label class="block text-sm font-medium text-gray-700">
            Guest Image
          </label>
          <input type="file" 
                 name="event[guests_attributes][INDEX][image]" 
                 accept="image/*"
                 data-max-size="5242880"
                 class="guest-image-input mt-1 block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100 transition-colors duration-200">
          <div class="image-error-message hidden mt-1">
            <p class="text-sm text-red-600">
              <svg class="inline w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd"></path>
              </svg>
              <span class="error-text">Image upload error</span>
            </p>
          </div>
          <p class="text-xs text-gray-500 mt-1">
            Upload an image for this guest (optional)<br>
            <span class="text-gray-400">Supported formats: JPEG, PNG, GIF, WebP (max 5MB)</span>
          </p>
        </div>g guests in events
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
      <div class="guest-form-item bg-gray-50 rounded-lg p-4 mb-4 border border-gray-200">
        <div class="flex justify-between items-center mb-4">
          <h4 class="text-sm font-medium text-gray-900">New Guest</h4>
          <button type="button" class="remove-guest-btn inline-flex items-center px-2 py-1 border border-red-300 text-xs font-medium rounded text-red-700 bg-white hover:bg-red-50 transition-colors duration-200">
            <svg class="w-3 h-3 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
            </svg>
            Remove
          </button>
        </div>
        
        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <!-- Guest Name -->
          <div class="form-group">
            <label class="block text-sm font-medium text-gray-700">
              Guest Name <span class="text-red-500">*</span>
            </label>
            <input type="text" 
                   name="event[guests_attributes][INDEX][name]" 
                   placeholder="Enter guest name"
                   required
                   class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500">
          </div>

          <!-- Guest Title -->
          <div class="form-group">
            <label class="block text-sm font-medium text-gray-700">
              Title/Position
            </label>
            <input type="text" 
                   name="event[guests_attributes][INDEX][title]" 
                   placeholder="e.g., Speaker, Performer, VIP"
                   class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500">
          </div>
        </div>

        <!-- Guest Description -->
        <div class="mt-4 form-group">
          <label class="block text-sm font-medium text-gray-700">
            Description
          </label>
          <textarea name="event[guests_attributes][INDEX][description]" 
                    rows="3"
                    placeholder="Brief description about the guest..."
                    class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"></textarea>
        </div>

        <!-- Guest Image -->
        <div class="mt-4 form-group">
          <label class="block text-sm font-medium text-gray-700">
            Guest Image
          </label>
          <input type="file" 
                 name="event[guests_attributes][INDEX][image]" 
                 accept="image/*"
                 class="mt-1 block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100 transition-colors duration-200">
          <p class="text-xs text-gray-500 mt-1">Upload an image for this guest (optional)</p>
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
    this.setupImageValidation();
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

    // Replace INDEX with actual index
    const newGuestHTML = this.guestTemplate.replace(/INDEX/g, this.guestIndex);
    
    const tempDiv = document.createElement('div');
    tempDiv.innerHTML = newGuestHTML;
    const newGuestElement = tempDiv.firstElementChild;
    
    guestsContainer.appendChild(newGuestElement);
    
    // Increment index for next guest
    this.guestIndex++;
    
    // Focus on the name field of the newly added guest
    const nameInput = newGuestElement.querySelector('input[name*="[name]"]');
    if (nameInput) {
      nameInput.focus();
    }
    
    // Update guest numbering
    this.updateGuestNumbers();
    
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
        const isNewGuest = header.textContent.includes('New Guest');
        const isPersisted = form.querySelector('input[name*="[id]"]')?.value;
        
        if (isNewGuest && !isPersisted) {
          header.textContent = `New Guest ${index + 1}`;
        } else if (!isPersisted) {
          header.textContent = `Guest ${index + 1}`;
        }
        // For persisted guests, we keep the original "Guest Details" text
      }
    });
  }

  // File validation methods
  validateImageFile(file, errorContainer) {
    const maxSize = 5 * 1024 * 1024; // 5MB
    const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp'];
    
    // Clear previous errors
    this.hideImageError(errorContainer);
    
    if (!file) return true;
    
    // Check file size
    if (file.size > maxSize) {
      this.showImageError(errorContainer, 'File is too large. Maximum size is 5MB.');
      return false;
    }
    
    // Check file type
    if (!allowedTypes.includes(file.type.toLowerCase())) {
      this.showImageError(errorContainer, 'Invalid file type. Please upload JPEG, PNG, GIF, or WebP files only.');
      return false;
    }
    
    // Check if file is empty
    if (file.size === 0) {
      this.showImageError(errorContainer, 'File appears to be empty or corrupted.');
      return false;
    }
    
    return true;
  }
  
  showImageError(errorContainer, message) {
    if (!errorContainer) return;
    
    const errorText = errorContainer.querySelector('.error-text');
    if (errorText) {
      errorText.textContent = message;
    }
    
    errorContainer.classList.remove('hidden');
  }
  
  hideImageError(errorContainer) {
    if (!errorContainer) return;
    errorContainer.classList.add('hidden');
  }
  
  setupImageValidation() {
    // Set up validation for existing and new image inputs
    document.addEventListener('change', (e) => {
      if (e.target.classList.contains('guest-image-input')) {
        const file = e.target.files[0];
        const errorContainer = e.target.closest('.form-group').querySelector('.image-error-message');
        
        if (!this.validateImageFile(file, errorContainer)) {
          // Clear the input if validation fails
          e.target.value = '';
        }
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
