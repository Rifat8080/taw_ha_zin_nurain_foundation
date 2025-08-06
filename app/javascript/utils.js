// Common utilities and helper functions
class Utils {
  // Common CSRF token getter
  static getCSRFToken() {
    const metaTag = document.querySelector('[name="csrf-token"]');
    return metaTag ? metaTag.content : '';
  }

  // Common AJAX error handler
  static handleAjaxError(error, userMessage = 'An error occurred. Please try again.') {
    console.error('AJAX Error:', error);
    
    // You can add more sophisticated error handling here
    // For example, showing toast notifications, logging to external services, etc.
    
    return userMessage;
  }

  // Debounce function for performance optimization
  static debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
      const later = () => {
        clearTimeout(timeout);
        func(...args);
      };
      clearTimeout(timeout);
      timeout = setTimeout(later, wait);
    };
  }

  // Throttle function for performance optimization
  static throttle(func, limit) {
    let inThrottle;
    return function(...args) {
      if (!inThrottle) {
        func.apply(this, args);
        inThrottle = true;
        setTimeout(() => inThrottle = false, limit);
      }
    };
  }

  // Safe DOM manipulation
  static safeQuerySelector(selector) {
    try {
      return document.querySelector(selector);
    } catch (error) {
      console.warn(`Invalid selector: ${selector}`);
      return null;
    }
  }

  static safeQuerySelectorAll(selector) {
    try {
      return document.querySelectorAll(selector);
    } catch (error) {
      console.warn(`Invalid selector: ${selector}`);
      return [];
    }
  }

  // Check if element exists and is visible
  static isElementVisible(element) {
    if (!element) return false;
    return element.offsetWidth > 0 && element.offsetHeight > 0;
  }

  // Add/remove classes safely
  static toggleClass(element, className, force = null) {
    if (!element) return;
    
    if (force !== null) {
      element.classList.toggle(className, force);
    } else {
      element.classList.toggle(className);
    }
  }

  static addClass(element, ...classNames) {
    if (!element) return;
    element.classList.add(...classNames);
  }

  static removeClass(element, ...classNames) {
    if (!element) return;
    element.classList.remove(...classNames);
  }

  // Event listener helpers
  static addEventListenerSafe(element, event, handler, options = {}) {
    if (!element || typeof handler !== 'function') return;
    
    try {
      element.addEventListener(event, handler, options);
    } catch (error) {
      console.error('Error adding event listener:', error);
    }
  }

  // Create element with attributes
  static createElement(tag, attributes = {}, textContent = '') {
    const element = document.createElement(tag);
    
    Object.entries(attributes).forEach(([key, value]) => {
      if (key === 'className') {
        element.className = value;
      } else if (key === 'dataset') {
        Object.entries(value).forEach(([dataKey, dataValue]) => {
          element.dataset[dataKey] = dataValue;
        });
      } else {
        element.setAttribute(key, value);
      }
    });
    
    if (textContent) {
      element.textContent = textContent;
    }
    
    return element;
  }

  // Fetch wrapper with better error handling
  static async fetchWithErrorHandling(url, options = {}) {
    const defaultOptions = {
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': this.getCSRFToken(),
        ...options.headers
      },
      ...options
    };

    try {
      const response = await fetch(url, defaultOptions);
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      
      const contentType = response.headers.get('content-type');
      if (contentType && contentType.includes('application/json')) {
        return await response.json();
      } else {
        return await response.text();
      }
    } catch (error) {
      console.error('Fetch error:', error);
      throw error;
    }
  }

  // Show notification (you can enhance this with a proper notification system)
  static showNotification(message, type = 'info', duration = 5000) {
    // This is a basic implementation - you might want to use a proper toast library
    const notification = this.createElement('div', {
      className: `fixed top-4 right-4 p-4 rounded-md shadow-lg z-50 ${
        type === 'success' ? 'bg-green-500 text-white' :
        type === 'error' ? 'bg-red-500 text-white' :
        type === 'warning' ? 'bg-yellow-500 text-black' :
        'bg-blue-500 text-white'
      }`
    }, message);

    document.body.appendChild(notification);

    setTimeout(() => {
      if (notification.parentNode) {
        notification.parentNode.removeChild(notification);
      }
    }, duration);
  }

  // Local storage helpers with error handling
  static setLocalStorage(key, value) {
    try {
      localStorage.setItem(key, JSON.stringify(value));
      return true;
    } catch (error) {
      console.error('Error setting localStorage:', error);
      return false;
    }
  }

  static getLocalStorage(key, defaultValue = null) {
    try {
      const item = localStorage.getItem(key);
      return item ? JSON.parse(item) : defaultValue;
    } catch (error) {
      console.error('Error getting localStorage:', error);
      return defaultValue;
    }
  }

  static removeLocalStorage(key) {
    try {
      localStorage.removeItem(key);
      return true;
    } catch (error) {
      console.error('Error removing localStorage:', error);
      return false;
    }
  }
}

// Export for use in other modules
window.Utils = Utils;

// Initialize any global utilities if needed
document.addEventListener('DOMContentLoaded', () => {
  // Any global initialization can go here
});
