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

    // Determine operation: prefer the operation selector, then the scanner's data-default-operation
    const opSelect = document.getElementById('qr-operation-select');
    let operation = 'entry';
    if (opSelect) {
      operation = opSelect.value || 'entry';
    } else {
      const scannerEl = document.querySelector('#qr-scanner');
      operation = (scannerEl && scannerEl.dataset && scannerEl.dataset.defaultOperation) ? scannerEl.dataset.defaultOperation : 'entry';
    }

    // Validate the QR code
    this.processQRCode(qrCode, operation);
  }

  async processQRCode(qrCode, operation = 'entry') {
    try {
      // Prefer a validate URL provided on the page (e.g., in qr_scan view)
      const scannerEl = document.getElementById('qr-scanner');
      const validateUrl = (scannerEl && scannerEl.dataset && scannerEl.dataset.validateUrl) ? scannerEl.dataset.validateUrl : '/tickets/validate_qr';

      const response = await fetch(validateUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify({ qr_code: qrCode, operation })
      });

      // Attempt to parse JSON body regardless of status so we can show server messages
      let data = null;
      try {
        data = await response.json();
      } catch (e) {
        // Non-JSON response
        data = null;
      }

      if (!response.ok) {
        const message = (data && (data.message || data.error)) ? (data.message || data.error) : `Server returned ${response.status}`;
        this.displayQRError(message);
        return;
      }

  this.displayQRResults(data || {});
    } catch (error) {
      // Network or unexpected error
      // Remove debug logging in production-like flows
      this.displayQRError('Error validating QR code. Please try again.');
    }
  }

  displayQRResults(data) {
    const scanResults = document.getElementById('scan-results');
    const resultContent = document.getElementById('result-content');
    
    if (!scanResults || !resultContent) return;

    // Show results section and ensure previous render is cleared
    scanResults.classList.remove('hidden');
    resultContent.innerHTML = '';
    resultContent.dataset.renderedBy = 'tickets';

    // Display the validation results (structure expected from server: {status, message, ticket})
    const ok = data && data.status === 'success';
    const message = data && (data.message || (data.error)) ? (data.message || data.error) : '';

    const ticket = data && data.ticket ? data.ticket : null;

    if (ok) {
      // success - prepare safe display values
      const t = ticket || {};
      const attendee = t.user_name || t.userName || '';
      const eventName = t.event_name || t.eventName || '';
      const entriesUsed = (typeof t.entries_used !== 'undefined' && t.entries_used !== null) ? t.entries_used : (typeof t.entriesUsed !== 'undefined' ? t.entriesUsed : null);
      const maxEntries = t.max_entries || t.maxEntries || '';
      const mealsClaimed = (typeof t.meals_claimed !== 'undefined') ? t.meals_claimed : (typeof t.mealsClaimed !== 'undefined' ? t.mealsClaimed : 0);
      const mealsAllowed = t.meals_allowed || t.mealsAllowed || 0;
      const onBreak = !!t.on_break || !!t.onBreak;
      const lastScanned = t.last_scanned_at || t.lastScannedAt || '';

      resultContent.innerHTML = `
        <div class="bg-green-50 border border-green-200 rounded-lg p-4">
          <div class="flex">
            <div class="flex-shrink-0">
              <span class="text-2xl text-green-600">✅</span>
            </div>
            <div class="ml-3">
              <h3 class="text-sm font-medium text-green-800">${message || 'Operation successful'}</h3>
              <div class="mt-2 text-sm text-green-700">
                ${attendee ? `<div><strong>Attendee:</strong> ${attendee}</div>` : ''}
                ${eventName ? `<div><strong>Event:</strong> ${eventName}</div>` : ''}
              </div>
              <div class="mt-3 text-xs text-gray-700">
                ${entriesUsed !== null ? `<div><strong>Entries:</strong> ${entriesUsed} / ${maxEntries}</div>` : ''}
                ${mealsAllowed ? `<div><strong>Meals:</strong> ${mealsClaimed} / ${mealsAllowed}</div>` : ''}
                <div><strong>On break:</strong> ${onBreak ? 'Yes' : 'No'}</div>
                ${lastScanned ? `<div><strong>Last scanned:</strong> ${lastScanned}</div>` : ''}
              </div>
            </div>
          </div>
        </div>
      `;
    } else {
      const t = ticket || {};
      const attendee = t.user_name || t.userName || '';
      const eventName = t.event_name || t.eventName || '';
      const statusStr = t.status || '';

      resultContent.innerHTML = `
        <div class="bg-red-50 border border-red-200 rounded-lg p-4">
          <div class="flex">
            <div class="flex-shrink-0">
              <svg class="h-5 w-5 text-red-400" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
              </svg>
            </div>
            <div class="ml-3">
              <h3 class="text-sm font-medium text-red-800">${message || 'This QR code is not valid or the ticket has been cancelled.'}</h3>
              <div class="mt-2 text-sm text-red-700">
                ${attendee ? `<div><strong>Attendee:</strong> ${attendee}</div>` : ''}
                ${eventName ? `<div><strong>Event:</strong> ${eventName}</div>` : ''}
                ${statusStr ? `<div><strong>Status:</strong> ${statusStr}</div>` : ''}
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
  resultContent.innerHTML = '';
  resultContent.dataset.renderedBy = 'tickets';
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
