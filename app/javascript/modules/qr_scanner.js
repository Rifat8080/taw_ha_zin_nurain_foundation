// QR Code Scanner functionality
class QRScanner {
  constructor() {
    this.video = null;
    this.canvas = null;
    this.context = null;
    this.scanning = false;
    this.validateUrl = '';
    
    this.init();
  }

  init() {
    // Wait for DOM to be ready
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', () => this.setupElements());
    } else {
      this.setupElements();
    }
  }

  setupElements() {
    this.video = this.safeQuerySelector('#video');
    this.canvas = document.createElement('canvas');
    this.context = this.canvas?.getContext('2d');
    
    // Get validate URL from data attribute
    const scannerElement = this.safeQuerySelector('#qr-scanner');
    this.validateUrl = scannerElement?.dataset.validateUrl || '';

    this.bindEvents();
  }

  // Safe DOM query selector
  safeQuerySelector(selector) {
    try {
      return document.querySelector(selector);
    } catch (error) {
      console.warn(`Invalid selector: ${selector}`);
      return null;
    }
  }

  // Safe event listener addition
  addEventListenerSafe(element, event, handler, options = {}) {
    if (!element || typeof handler !== 'function') return;
    
    try {
      element.addEventListener(event, handler, options);
    } catch (error) {
      console.error('Error adding event listener:', error);
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

  bindEvents() {
    const startBtn = this.safeQuerySelector('#start-scan');
    const stopBtn = this.safeQuerySelector('#stop-scan');
    const manualInput = this.safeQuerySelector('#manual-qr');

    if (startBtn) {
      this.addEventListenerSafe(startBtn, 'click', () => this.startScanning());
    }

    if (stopBtn) {
      this.addEventListenerSafe(stopBtn, 'click', () => this.stopScanning());
    }

    if (manualInput) {
      // Allow Enter key to validate manual input
      this.addEventListenerSafe(manualInput, 'keypress', (e) => {
        if (e.key === 'Enter') {
          this.validateManualQR();
        }
      });
    }

    // Make function globally available for onclick handlers
    window.validateManualQR = () => this.validateManualQR();
  }

  async startScanning() {
    // Check if getUserMedia is supported
    if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
      this.showResult('error', 'Camera API not supported in this browser.');
      return;
    }
    
    try {
      console.log('Requesting camera permission...');
      const stream = await navigator.mediaDevices.getUserMedia({
        video: { facingMode: 'environment' } // Use back camera if available
      });
      
      if (this.video) {
        this.video.srcObject = stream;
        this.scanning = true;
        
        this.toggleScanButtons(true);
        
        // Start scanning loop
        requestAnimationFrame(() => this.scanQRCode());
      }
      
    } catch (error) {
      console.error('Error accessing camera:', error);
      
      let errorMessage = 'Unable to access camera. ';
      if (error.name === 'NotAllowedError') {
        errorMessage += 'Please allow camera permissions and try again.';
      } else if (error.name === 'NotFoundError') {
        errorMessage += 'No camera found on this device.';
      } else if (error.name === 'NotSupportedError') {
        errorMessage += 'Camera not supported on this device.';
      } else if (error.name === 'NotReadableError') {
        errorMessage += 'Camera is already in use.';
      } else {
        errorMessage += `Error: ${error.message}`;
      }
      
      this.showResult('error', errorMessage);
    }
  }

  stopScanning() {
    this.scanning = false;
    
    if (this.video && this.video.srcObject) {
      this.video.srcObject.getTracks().forEach(track => track.stop());
    }
    
    this.toggleScanButtons(false);
  }

  toggleScanButtons(scanning) {
    const startBtn = this.safeQuerySelector('#start-scan');
    const stopBtn = this.safeQuerySelector('#stop-scan');

    if (startBtn && stopBtn) {
      if (scanning) {
        this.addClass(startBtn, 'hidden');
        this.removeClass(stopBtn, 'hidden');
      } else {
        this.removeClass(startBtn, 'hidden');
        this.addClass(stopBtn, 'hidden');
      }
    }
  }

  scanQRCode() {
    if (!this.scanning || !this.video) return;
    
    if (this.video.readyState === this.video.HAVE_ENOUGH_DATA) {
      this.canvas.height = this.video.videoHeight;
      this.canvas.width = this.video.videoWidth;
      this.context.drawImage(this.video, 0, 0, this.canvas.width, this.canvas.height);
      
      const imageData = this.context.getImageData(0, 0, this.canvas.width, this.canvas.height);
      
      // Check if jsQR is available (loaded from CDN)
      if (typeof jsQR !== 'undefined') {
        const code = jsQR(imageData.data, imageData.width, imageData.height);
        
        if (code) {
          this.validateQRCode(code.data);
          return; // Stop scanning after successful read
        }
      }
    }
    
    requestAnimationFrame(() => this.scanQRCode());
  }

  validateManualQR() {
    const manualInput = this.safeQuerySelector('#manual-qr');
    const qrCode = manualInput?.value.trim();
    if (qrCode) {
      this.validateQRCode(qrCode);
    } else {
      this.showResult('error', 'Please enter a QR code');
    }
  }

  // Get CSRF token
  getCSRFToken() {
    const metaTag = document.querySelector('[name="csrf-token"]');
    return metaTag ? metaTag.content : '';
  }

  async validateQRCode(qrCode) {
    // Store for retry functionality
    this.storeLastScannedCode(qrCode);
    
    if (!this.validateUrl) {
      this.showResult('error', 'Validation URL not configured', null, 'system');
      return;
    }

    // Show loading state
    this.showResult('loading', 'Validating QR code...', null, 'loading');

    try {
      const response = await fetch(this.validateUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': this.getCSRFToken()
        },
        body: JSON.stringify({ qr_code: qrCode })
      });

      const result = await response.json();
      
      if (response.ok && result.status === 'success') {
        this.showResult('success', result.message, result.ticket, 'success');
      } else {
        // Handle specific error cases based on status codes and messages
        this.handleValidationError(response.status, result, qrCode);
      }
      
    } catch (error) {
      console.error('Error validating QR code:', error);
      
      if (error.name === 'TypeError' && error.message.includes('Failed to fetch')) {
        this.showResult('error', 'Network connection failed. Please check your internet connection and try again.', null, 'network');
      } else {
        this.showResult('error', 'An unexpected error occurred. Please try again.', null, 'system');
      }
    }
  }

  handleValidationError(statusCode, result, qrCode) {
    const errorType = this.getErrorType(statusCode, result.message);
    
    switch (statusCode) {
      case 404:
        this.showResult('error', 'QR code not found. This ticket may not exist in our system.', null, 'not-found');
        break;
        
      case 422:
        // Handle specific business logic errors
        if (result.message.includes('already been used')) {
          const usedAt = result.ticket?.used_at || 'Unknown time';
          this.showResult('error', `This ticket was already used on ${usedAt}.`, result.ticket, 'already-used');
        } else if (result.message.includes('cancelled')) {
          this.showResult('error', 'This ticket has been cancelled and cannot be used.', result.ticket, 'cancelled');
        } else if (result.message.includes('refunded')) {
          this.showResult('error', 'This ticket has been refunded and cannot be used.', result.ticket, 'refunded');
        } else if (result.message.includes('cannot be used yet')) {
          const eventDate = result.ticket?.event_start_date || 'the event date';
          this.showResult('error', `Check-in is not available yet. It opens 1 day before ${eventDate}.`, result.ticket, 'too-early');
        } else if (result.message.includes('expired') || result.message.includes('ended')) {
          const endDate = result.ticket?.event_end_date || 'recently';
          this.showResult('error', `This ticket has expired. The event ended on ${endDate}.`, result.ticket, 'expired');
        } else {
          this.showResult('error', result.message || 'This ticket cannot be used at this time.', result.ticket, 'invalid');
        }
        break;
        
      case 401:
        this.showResult('error', 'You are not authorized to validate tickets. Please log in.', null, 'unauthorized');
        break;
        
      case 403:
        this.showResult('error', 'You do not have permission to validate tickets.', null, 'forbidden');
        break;
        
      case 500:
        this.showResult('error', 'Server error occurred. Please contact support if this continues.', null, 'server-error');
        break;
        
      default:
        this.showResult('error', result.message || 'An error occurred while validating the ticket.', result.ticket, 'unknown');
    }
  }

  getErrorType(statusCode, message) {
    if (statusCode === 404) return 'not-found';
    if (statusCode === 422) {
      if (message.includes('already been used')) return 'already-used';
      if (message.includes('cancelled')) return 'cancelled';
      if (message.includes('refunded')) return 'refunded';
      if (message.includes('cannot be used yet')) return 'too-early';
      if (message.includes('expired')) return 'expired';
      return 'invalid';
    }
    if (statusCode === 401) return 'unauthorized';
    if (statusCode === 403) return 'forbidden';
    if (statusCode >= 500) return 'server-error';
    return 'unknown';
  }

  showResult(type, message, ticketData = null, errorType = null) {
    const resultsDiv = this.safeQuerySelector('#scan-results');
    const contentDiv = this.safeQuerySelector('#result-content');
    
    if (!resultsDiv || !contentDiv) return;

    let bgColor, textColor, borderColor, icon, iconColor;
    
    if (type === 'success') {
      bgColor = 'bg-green-50';
      textColor = 'text-green-800';
      borderColor = 'border-green-200';
      iconColor = 'text-green-600';
      icon = '✅';
    } else if (type === 'loading') {
      bgColor = 'bg-blue-50';
      textColor = 'text-blue-800';
      borderColor = 'border-blue-200';
      iconColor = 'text-blue-600';
      icon = '⏳';
    } else {
      bgColor = 'bg-red-50';
      textColor = 'text-red-800';
      borderColor = 'border-red-200';
      iconColor = 'text-red-600';
      
      // Choose specific icons based on error type
      switch (errorType) {
        case 'not-found':
          icon = '🔍';
          break;
        case 'already-used':
          icon = '🚫';
          break;
        case 'cancelled':
        case 'refunded':
          icon = '❌';
          break;
        case 'too-early':
          icon = '⏰';
          break;
        case 'expired':
          icon = '⌛';
          break;
        case 'unauthorized':
        case 'forbidden':
          icon = '🔒';
          break;
        case 'network':
          icon = '📡';
          break;
        case 'server-error':
          icon = '🔧';
          break;
        default:
          icon = '⚠️';
      }
    }

    // Create enhanced result HTML
    let html = `
      <div class="p-4 rounded-lg border-2 ${bgColor} ${borderColor}">
        <div class="flex items-start space-x-3">
          <div class="flex-shrink-0">
            <span class="text-2xl ${iconColor}">${icon}</span>
          </div>
          <div class="flex-1">
            <h3 class="text-lg font-semibold ${textColor} mb-2">
              ${this.getResultTitle(type, errorType)}
            </h3>
            <p class="${textColor} mb-3">${message}</p>
            
            ${this.generateTicketDetails(ticketData, type, errorType)}
            ${this.generateActionButtons(type, errorType)}
          </div>
        </div>
      </div>
    `;

    contentDiv.innerHTML = html;
    resultsDiv.classList.remove('hidden');
    
    // Auto-hide loading messages
    if (type === 'loading') {
      setTimeout(() => {
        // Don't hide if result has been updated to something else
        if (contentDiv.innerHTML.includes('⏳')) {
          resultsDiv.classList.add('hidden');
        }
      }, 10000); // Hide after 10 seconds if still loading
    }
    
    // Scroll to results
    resultsDiv.scrollIntoView({ behavior: 'smooth' });
  }

  getResultTitle(type, errorType) {
    if (type === 'success') return 'Ticket Validated Successfully!';
    if (type === 'loading') return 'Processing...';
    
    switch (errorType) {
      case 'not-found': return 'Ticket Not Found';
      case 'already-used': return 'Ticket Already Used';
      case 'cancelled': return 'Ticket Cancelled';
      case 'refunded': return 'Ticket Refunded';
      case 'too-early': return 'Check-in Not Available';
      case 'expired': return 'Ticket Expired';
      case 'unauthorized': return 'Authentication Required';
      case 'forbidden': return 'Access Denied';
      case 'network': return 'Connection Error';
      case 'server-error': return 'System Error';
      default: return 'Validation Failed';
    }
  }

  generateTicketDetails(ticketData, type, errorType) {
    if (!ticketData) return '';
    
    const statusColor = type === 'success' ? 'text-green-700' : 'text-red-700';
    
    return `
      <div class="mt-3 p-3 bg-white bg-opacity-50 rounded border">
        <h4 class="font-medium text-gray-900 mb-2">Ticket Details:</h4>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-2 text-sm">
          ${ticketData.user_name ? `<div><span class="font-medium">Attendee:</span> ${ticketData.user_name}</div>` : ''}
          ${ticketData.event_name ? `<div><span class="font-medium">Event:</span> ${ticketData.event_name}</div>` : ''}
          ${ticketData.ticket_type ? `<div><span class="font-medium">Type:</span> ${ticketData.ticket_type}</div>` : ''}
          ${ticketData.seat_number ? `<div><span class="font-medium">Seat:</span> ${ticketData.seat_number}</div>` : ''}
          ${ticketData.price ? `<div><span class="font-medium">Price:</span> ${ticketData.price}</div>` : ''}
          ${ticketData.status ? `<div><span class="font-medium">Status:</span> <span class="${statusColor}">${ticketData.status}</span></div>` : ''}
          ${ticketData.used_at ? `<div><span class="font-medium">Used At:</span> ${ticketData.used_at}</div>` : ''}
        </div>
      </div>
    `;
  }

  generateActionButtons(type, errorType) {
    if (type === 'loading') return '';
    
    let buttons = '';
    
    if (errorType === 'unauthorized') {
      buttons += `
        <div class="mt-4 flex flex-wrap gap-2">
          <button onclick="window.location.href='/users/sign_in'" 
                  class="px-4 py-2 text-sm font-medium text-white bg-blue-600 border border-transparent rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
            Sign In
          </button>
        </div>
      `;
    } else if (errorType === 'network') {
      buttons += `
        <div class="mt-4 flex flex-wrap gap-2">
          <button onclick="window.qrScanner.retryLastScan()" 
                  class="px-4 py-2 text-sm font-medium text-white bg-blue-600 border border-transparent rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
            Retry
          </button>
        </div>
      `;
    }
    
    return buttons;
  }

  retryLastScan() {
    if (this.lastScannedCode) {
      this.validateQRCode(this.lastScannedCode);
    }
  }

  // Store the last scanned code for retry functionality
  storeLastScannedCode(qrCode) {
    this.lastScannedCode = qrCode;
  }
}

// Export for use in other modules
window.QRScanner = QRScanner;

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
  if (document.querySelector('#qr-scanner')) {
    new QRScanner();
  }
});
