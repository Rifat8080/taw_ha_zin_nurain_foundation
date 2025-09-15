// Ticket Show Module
// Binds QR copy behavior in a Turbo-friendly way

class TicketShow {
  constructor() {
    this.copyHandler = this.copyHandler.bind(this);
  }

  init() {
    // Delegate click events for copy buttons
    document.addEventListener('click', this.copyHandler);
  }

  destroy() {
    document.removeEventListener('click', this.copyHandler);
  }

  copyHandler(e) {
    const btn = e.target.closest('[data-action="copy-qr"]');
    if (!btn) return;

    e.preventDefault();
    const qr = btn.dataset.qrCode;
    if (!qr) return;

    const prev = btn.innerHTML;

    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(qr).then(() => {
        btn.innerHTML = '<i class="fa-solid fa-check text-green-500 w-4 h-4" aria-hidden="true"></i>';
        setTimeout(() => btn.innerHTML = prev, 1200);
      }).catch(() => {
        this.fallbackCopy(qr);
      });
    } else {
      this.fallbackCopy(qr);
    }
  }

  fallbackCopy(text) {
    const textarea = document.createElement('textarea');
    textarea.value = text;
    textarea.style.position = 'fixed';
    textarea.style.left = '-9999px';
    document.body.appendChild(textarea);
    textarea.select();
    try {
      document.execCommand('copy');
    } catch (e) {
      // ignore
    }
    document.body.removeChild(textarea);
  }
}

const ticketShow = new TicketShow();

document.addEventListener('turbo:load', () => ticketShow.init());
document.addEventListener('turbo:before-cache', () => ticketShow.destroy());

document.addEventListener('DOMContentLoaded', () => ticketShow.init());

export default ticketShow;
