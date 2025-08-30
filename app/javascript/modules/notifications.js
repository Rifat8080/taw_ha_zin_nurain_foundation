import consumer from "@rails/actioncable";

// Initialize notifications subscription and DOM handling
const initNotifications = () => {
  // Locate the notification button and container
  const button = document.querySelector('.btn-notif');
  if (!button) return;

  // Load dropdown content initially via AJAX to keep server-rendered markup
  const loadDropdown = async () => {
    try {
      const res = await fetch('/notifications', { headers: { Accept: 'text/html' } });
      if (res.ok) {
        const html = await res.text();
        // Insert into DOM; find existing dropdown wrapper in layout to replace
        const parser = new DOMParser();
        const doc = parser.parseFromString(html, 'text/html');
        // Flowbite expects the dropdown wrapper id to be 'notifications-dropdown'.
        // We will not replace the whole wrapper to avoid breaking Flowbite behavior.
        const serverList = doc.querySelector('#notifications-list');
        const localList = document.getElementById('notifications-list');
        if (serverList && localList) {
          localList.innerHTML = serverList.innerHTML;
        } else if (serverList && !localList) {
          // If there is no local wrapper yet, insert the server-provided dropdown after the button
          const root = doc.querySelector('#notifications-dropdown');
          if (root) button.insertAdjacentElement('afterend', root);
        }
      }
    } catch (err) {
      // silent
      console.error('Failed to load notifications', err);
    }
  };

  loadDropdown();

  // Toggle dropdown (Flowbite already handles data-dropdown-toggle but we need IDs consistent)

  // Helper to escape text before inserting into innerHTML
  const escapeHtml = (unsafe) => {
    if (!unsafe) return '';
    return unsafe
      .toString()
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#039;');
  };

  // Connect ActionCable consumer to subscribe
  let subscription;
  try {
    const cable = consumer.createConsumer();
    subscription = cable.subscriptions.create({ channel: 'NotificationsChannel' }, {
      received(data) {
        // data expected: { notification: {...}, unread_count: n }
        try {
          if (data && data.notification) {
            const notif = data.notification;
            const list = document.getElementById('notifications-list');
            if (list) {
              const li = document.createElement('li');
              li.setAttribute('data-notification-id', notif.id);
              li.className = 'px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 bg-gray-100';

              const createdAt = new Date(notif.created_at);
              const timeAgo = createdAt.toLocaleString();

              li.innerHTML = `
                <div class="flex items-start gap-3">
                  <span class="inline-flex items-center justify-center h-8 w-8 rounded-full bg-forange text-white"><i class="fa-solid fa-bell"></i></span>
                  <div class="flex-1">
                    <div class="text-sm font-medium text-gray-900 dark:text-white">${escapeHtml(notif.title || (notif.action || 'Notification').toString().replace(/_/g, ' '))}</div>
                    <div class="text-xs text-gray-500 dark:text-gray-400 truncate">${escapeHtml(notif.body || '')}</div>
                  </div>
                  <div class="text-xs text-gray-400 ms-2">${timeAgo}</div>
                </div>
              `;

              list.prepend(li);
            }
          }

          if (typeof data.unread_count !== 'undefined') {
            let badge = document.querySelector('.btn-notif .notif-badge');
            if (!badge) {
              badge = document.createElement('span');
              badge.className = 'notif-badge absolute -top-1 -right-1 inline-flex h-2 w-2 rounded-full bg-red-500 border-2 border-white';
              const btn = document.querySelector('.btn-notif');
              if (btn) btn.appendChild(badge);
            }
            badge.style.display = data.unread_count > 0 ? 'inline-flex' : 'none';
          }
        } catch (e) {
          console.error(e);
        }
      }
    });
  } catch (e) {
    console.warn('ActionCable not available', e);
  }

  // Mark notification read on click
  document.addEventListener('click', (ev) => {
    const li = ev.target.closest('[data-notification-id]');
    if (li) {
      const id = li.dataset.notificationId;
      fetch(`/notifications/${id}/mark_as_read`, { method: 'POST', headers: { 'X-CSRF-Token': document.querySelector('meta[name=csrf-token]').content } });
      li.classList.remove('bg-gray-100');
    }
  });
};

export default initNotifications;

// Auto-initialize when module is imported
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initNotifications);
} else {
  initNotifications();
}
