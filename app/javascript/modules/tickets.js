/**
 * Tickets Module
 * Handles ticket printing and QR code validation functionality
 * Compatible with Turbo for SPA-like experience
 */

class Tickets {
  constructor() {
    this.initialized = false;
    
    // Bind methods to preserve context
    this.printTicket = this.printTicket.bind(this);
    this.validateManualQR = this.validateManualQR.bind(this);
    this.handlePrintButtonClick = this.handlePrintButtonClick.bind(this);
    this.handleQRValidateClick = this.handleQRValidateClick.bind(this);
  }

  init() {
    if (this.initialized) return;

    this.setupEventListeners();
    this.initialized = true;
  }

  // Clean up when navigating away (Turbo compatibility)
  destroy() {
    this.removeEventListeners();
    this.initialized = false;
  }

  setupEventListeners() {
    // Print and QR functionality (using event delegation)
    document.addEventListener('click', this.handlePrintButtonClick);
    document.addEventListener('click', this.handleQRValidateClick);
  }

  removeEventListeners() {
    document.removeEventListener('click', this.handlePrintButtonClick);
    document.removeEventListener('click', this.handleQRValidateClick);
  }

  handlePrintButtonClick(e) {
    // Check if clicked element is a print button
    if (e.target.getAttribute('data-action') === 'print-ticket') {
      e.preventDefault();
      this.printTicket();
    }
  }

  handleQRValidateClick(e) {
    // Check if clicked element is a QR validate button
    if (e.target.getAttribute('data-action') === 'validate-qr') {
      e.preventDefault();
      this.validateManualQR();
    }
  }

  printTicket() {
    // Implement print functionality
    window.print();
  }

  validateManualQR() {
    const manualQRInput = document.getElementById('manual-qr');
    if (!manualQRInput) return;

    const qrCode = manualQRInput.value.trim();
    if (!qrCode) {
      alert('Please enter a QR code');
      return;
    }

    // Validate the QR code
    this.processQRCode(qrCode);
  }

  async processQRCode(qrCode) {
    try {
      const response = await fetch('/tickets/validate_qr', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify({
          qr_code: qrCode
        })
      });

      if (!response.ok) {
        throw new Error('Network response was not ok');
      }

      const data = await response.json();
      this.displayQRResults(data);
    } catch (error) {
      console.error('Error validating QR code:', error);
      this.displayQRError('Error validating QR code. Please try again.');
    }
  }

  displayQRResults(data) {
    const scanResults = document.getElementById('scan-results');
    const resultContent = document.getElementById('result-content');
    
    if (!scanResults || !resultContent) return;

    // Show results section
    scanResults.classList.remove('hidden');
    
    // Display the validation results
    if (data.valid) {
      resultContent.innerHTML = `
        <div class="bg-green-50 border border-green-200 rounded-lg p-4">
          <div class="flex">
            <div class="flex-shrink-0">
              <svg class="h-5 w-5 text-green-400" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
              </svg>
            </div>
            <div class="ml-3">
              <h3 class="text-sm font-medium text-green-800">Valid Ticket</h3>
              <div class="mt-2 text-sm text-green-700">
                <p><strong>Event:</strong> ${data.event_title}</p>
                <p><strong>Attendee:</strong> ${data.attendee_name}</p>
                <p><strong>Status:</strong> ${data.status}</p>
              </div>
            </div>
          </div>
        </div>
      `;
    } else {
      resultContent.innerHTML = `
        <div class="bg-red-50 border border-red-200 rounded-lg p-4">
          <div class="flex">
            <div class="flex-shrink-0">
              <svg class="h-5 w-5 text-red-400" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
              </svg>
            </div>
            <div class="ml-3">
              <h3 class="text-sm font-medium text-red-800">Invalid Ticket</h3>
              <div class="mt-2 text-sm text-red-700">
                <p>${data.message || 'This QR code is not valid or the ticket has been cancelled.'}</p>
              </div>
            </div>
          </div>
        </div>
      `;
    }
  }

  displayQRError(message) {
    const scanResults = document.getElementById('scan-results');
    const resultContent = document.getElementById('result-content');
    
    if (!scanResults || !resultContent) return;

    scanResults.classList.remove('hidden');
    resultContent.innerHTML = `
      <div class="bg-red-50 border border-red-200 rounded-lg p-4">
        <div class="flex">
          <div class="flex-shrink-0">
            <svg class="h-5 w-5 text-red-400" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
            </svg>
          </div>
          <div class="ml-3">
            <h3 class="text-sm font-medium text-red-800">Error</h3>
            <div class="mt-2 text-sm text-red-700">
              <p>${message}</p>
            </div>
          </div>
        </div>
      </div>
    `;
  }
}

// Create a singleton instance
const tickets = new Tickets();

// Turbo event listeners for proper initialization and cleanup
document.addEventListener('turbo:load', () => {
  tickets.init();
});

document.addEventListener('turbo:before-cache', () => {
  tickets.destroy();
});

// Fallback for traditional page loads (when Turbo is disabled)
document.addEventListener('DOMContentLoaded', () => {
  tickets.init();
});

// Export for potential external use
export default tickets;
