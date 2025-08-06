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
    if (!this.validateUrl) {
      this.showResult('error', 'Validation URL not configured');
      return;
    }

    try {
      const response = await fetch(this.validateUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': this.getCSRFToken()
        },
        body: JSON.stringify({ qr_code: qrCode })
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      
      const result = await response.json();
      
      if (result.status === 'success') {
        this.showResult('success', result.message, result.ticket);
      } else {
        this.showResult('error', result.message);
      }
      
    } catch (error) {
      console.error('Error validating QR code:', error);
      this.showResult('error', 'Error validating QR code. Please try again.');
    }
  }

  showResult(type, message, ticketData = null) {
    const resultsDiv = this.safeQuerySelector('#scan-results');
    const contentDiv = this.safeQuerySelector('#result-content');
    
    if (!resultsDiv || !contentDiv) return;

    let bgColor, textColor, icon;
    
    if (type === 'success') {
      bgColor = 'bg-green-50';
      textColor = 'text-green-800';
      icon = '✓';
    } else {
      bgColor = 'bg-red-50';
      textColor = 'text-red-800';
      icon = '✗';
    }
    
    let content = `
      <div class="${bgColor} border border-${type === 'success' ? 'green' : 'red'}-200 rounded-md p-4">
        <div class="flex items-center">
          <span class="text-2xl mr-3">${icon}</span>
          <div class="flex-1">
            <h4 class="text-lg font-medium ${textColor}">${type === 'success' ? 'Success' : 'Error'}</h4>
            <p class="${textColor}">${message}</p>
            ${ticketData ? `
              <div class="mt-2 text-sm ${textColor}">
                <p><strong>User:</strong> ${ticketData.user_name || 'N/A'}</p>
                <p><strong>Event:</strong> ${ticketData.event_name || 'N/A'}</p>
                <p><strong>Type:</strong> ${ticketData.ticket_type || 'N/A'}</p>
                ${ticketData.seat_number ? `<p><strong>Seat:</strong> ${ticketData.seat_number}</p>` : ''}
              </div>
            ` : ''}
          </div>
        </div>
      </div>
    `;
    
    contentDiv.innerHTML = content;
    this.removeClass(resultsDiv, 'hidden');
    
    // Clear manual input
    const manualInput = this.safeQuerySelector('#manual-qr');
    if (manualInput) {
      manualInput.value = '';
    }
    
    // Auto-hide after 5 seconds for success, continue scanning
    if (type === 'success') {
      setTimeout(() => {
        this.addClass(resultsDiv, 'hidden');
        if (this.scanning) {
          requestAnimationFrame(() => this.scanQRCode());
        }
      }, 5000);
    } else {
      // For errors, continue scanning immediately
      if (this.scanning) {
        setTimeout(() => {
          requestAnimationFrame(() => this.scanQRCode());
        }, 2000);
      }
    }
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
