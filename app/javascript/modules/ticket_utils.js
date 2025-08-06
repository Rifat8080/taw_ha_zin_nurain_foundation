// Ticket functionality
class TicketUtils {
  constructor() {
    this.init();
  }

  init() {
    // Make print function globally available for onclick handlers
    window.printTicket = () => this.printTicket();
  }

  printTicket() {
    window.print();
  }

  // Additional utility methods can be added here
  // For example, QR code generation, ticket validation, etc.
}

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
  new TicketUtils();
});
