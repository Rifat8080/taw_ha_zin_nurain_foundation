// Turbo-aware module to handle tab switching and donors auto-scrolling
document.addEventListener('turbo:load', () => {
  try {
    initTabsAndDonors();
  } catch (e) {
    // defensive: log to console in dev
    console.error('tabs_and_donors init error', e);
  }
});

function initTabsAndDonors() {
  // Tabs
  const tabButtons = Array.from(document.querySelectorAll('.tab-button'));
  if (tabButtons.length) {
    tabButtons.forEach(btn => {
      btn.addEventListener('click', (ev) => {
        const targetSelector = btn.dataset.tabTarget;
        if (!targetSelector) return;
        const panel = document.querySelector(targetSelector);
        if (!panel) return;

        // Deselect all
        tabButtons.forEach(b => {
          b.setAttribute('aria-selected', 'false');
          b.classList.remove('active');
        });

        // Hide all panels
        document.querySelectorAll('.tab-panel').forEach(p => p.classList.add('hidden'));

        // Activate clicked
        btn.setAttribute('aria-selected', 'true');
        btn.classList.add('active');
        panel.classList.remove('hidden');

        // Ensure focus lands sensibly for keyboard users
        panel.setAttribute('tabindex', '-1');
        panel.focus({ preventScroll: true });
      });
    });
  }

  // Donors auto-scrolling (infinite right->left marquee)
  const donorsRow = document.querySelector('.donors-row');
  if (donorsRow) {
    setupInfiniteScroll(donorsRow);
  }
}

function setupInfiniteScroll(container) {
  // Capture original classes, we'll preserve non-layout utilities but strip conflicting layout utilities
  const originalClasses = Array.from(container.classList || []);

  // Create a wrapping track we can animate; keep original children
  const track = document.createElement('div');
  track.className = 'donors-track';
  // Move children into track and force single-row behavior for each card
  while (container.firstChild) {
    const child = container.firstChild;
    // ensure donor cards don't wrap and keep their intrinsic size
    if (child.classList && child.classList.contains('donor-card')) {
      child.style.flex = '0 0 auto';
      child.style.display = 'inline-flex';
    }
    track.appendChild(child);
  }

  // Create a wrapper that will be animated; put original track and its clone inside
  const wrapper = document.createElement('div');
  wrapper.className = 'donors-track-wrapper';
  const clone = track.cloneNode(true);
  clone.classList.add('donors-track');
  wrapper.appendChild(track);
  wrapper.appendChild(clone);

  // Clear container and append the wrapper
  container.innerHTML = '';
  container.appendChild(wrapper);
  // Rebuild container's class list: preserve non-layout utilities but remove Tailwind layout classes that interfere
  // Replace classes with a minimal safe set to avoid Tailwind layout utilities interfering with marquee
  // Preserve any non-class attributes (data-*) but reset classes to the ones needed
  container.className = 'donors-row donors-marquee';

  // Pause on hover/focus for accessibility
  container.addEventListener('mouseenter', () => container.classList.add('paused'));
  container.addEventListener('mouseleave', () => container.classList.remove('paused'));
  container.addEventListener('focusin', () => container.classList.add('paused'));
  container.addEventListener('focusout', () => container.classList.remove('paused'));

  // Responsive speed calculation
  const setMarqueeSpeed = () => {
    // Compute duration based on the width of a single track so scrolling speed feels constant
    const singleTrack = wrapper.querySelector('.donors-track');
    if (!singleTrack) return;
    const trackWidth = singleTrack.getBoundingClientRect().width || 600;
    // px per second speed (tweakable) - larger value = faster
    const pxPerSecond = 80;
    // duration for one full track to move by its width
    let duration = Math.max(6, Math.round(trackWidth / pxPerSecond));
    // if there are very few cards and trackWidth is small, keep minimum duration
    container.style.setProperty('--marquee-duration', duration + 's');
  };

  // Recalculate on resize and after images load
  // Recalculate on resize and after images load
  window.addEventListener('resize', setMarqueeSpeed);
  setTimeout(setMarqueeSpeed, 100);
  // If images load inside donor cards, recompute when they finish
  const imgs = wrapper.querySelectorAll('img');
  imgs.forEach(img => img.addEventListener('load', setMarqueeSpeed));

  // Also observe mutations to recompute if donor cards change
  const mo = new MutationObserver(() => setMarqueeSpeed());
  mo.observe(container, { childList: true, subtree: true });
}

export { initTabsAndDonors };
