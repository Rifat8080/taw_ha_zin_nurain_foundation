// Handles donation card behaviour (preset amounts, amount input, payment toggles, submit feedback)
// This module uses turbo:load so it runs after Turbo page loads and on navigations.

function initDonationCard() {
  try {
    var presets = Array.prototype.slice.call(document.querySelectorAll('.preset-amount'));
    var amountField = document.getElementById('donation_amount');
    var form = amountField ? amountField.closest('form') : document.getElementById('donation_form');

    function clearActive() {
      presets.forEach(function(b){ b.classList.remove('active'); b.setAttribute('aria-pressed', 'false'); });
    }

    function setActiveButtonForValue(val) {
      var matched = null;
      presets.forEach(function(b){
        var a = parseFloat(b.getAttribute('data-amount'));
        if(!isNaN(a) && parseFloat(val) === a) matched = b;
      });
      clearActive();
      if(matched) { matched.classList.add('active'); matched.setAttribute('aria-pressed', 'true'); }
    }

    presets.forEach(function(btn){
      btn.addEventListener('click', function(e){
        var a = this.getAttribute('data-amount');
        if(amountField) amountField.value = a;
        clearActive();
        this.classList.add('active');
        this.setAttribute('aria-pressed', 'true');
        if(amountField) amountField.focus();
      });

      btn.addEventListener('keydown', function(e){
        if(e.key === 'Enter' || e.key === ' ') {
          e.preventDefault();
          this.click();
        }
      });
    });

    if(amountField) {
      amountField.addEventListener('input', function(e){
        var v = this.value ? this.value.toString().trim() : '';
        if(v === '') { clearActive(); return; }
        setActiveButtonForValue(v);
      });
      if(amountField.value) setActiveButtonForValue(amountField.value);
    }

    if(form) {
      form.addEventListener('reset', function(){ clearActive(); });
    }

    // Payment method toggle logic
    var paymentRadios = Array.prototype.slice.call(document.querySelectorAll('input[name="donation[payment_method]"]'));
    var transactionWrap = document.getElementById('transaction_wrap');
    var manualFlagInput = document.getElementById('donation_manual_flag');

    function updateTransactionVisibility() {
      var selected = paymentRadios.find(function(r){ return r.checked; });
      var val = selected ? selected.value : 'online';
      if(val === 'manual_transaction') {
        if(transactionWrap) transactionWrap.classList.remove('hidden');
      } else {
        if(transactionWrap) transactionWrap.classList.add('hidden');
      }
      if(manualFlagInput) manualFlagInput.value = (val && val.toString().startsWith('manual')).toString();
    }

    paymentRadios.forEach(function(r){ r.addEventListener('change', updateTransactionVisibility); });
    updateTransactionVisibility();

    // Submit feedback
    var donationForm = document.getElementById('donation_form');
    if(donationForm) {
      donationForm.addEventListener('submit', function(e){
        try {
          console.info('[donation_form] submit fired');
          var submitBtn = donationForm.querySelector('input[type="submit"], button[type="submit"]');
          if(submitBtn) {
            submitBtn.disabled = true;
            submitBtn.setAttribute('aria-disabled', 'true');
            submitBtn.classList.add('opacity-50');
          }
        } catch(err) {
          console.error('donation_form submit handler error', err);
        }
      });
    }

    // Add-to-giving logic: track primary amount (for this show page's project) and extras for other projects
    var addButtons = Array.prototype.slice.call(document.querySelectorAll('.add-to-giving'));
    // initial hidden fields
    var primaryHidden = document.getElementById('donation_primary_amount');
    var extrasHidden = document.getElementById('donation_extras_json');
    var totalDisplay = document.getElementById('donation_total_value');

    function parseNumber(v){ return parseFloat((v||'').toString().replace(/[^0-9.-]+/g,'')) || 0; }

    // read primary project id from existing hidden field (form renders project_id by default)
    var formEl = document.getElementById('donation_form');
    var primaryProjectInput = formEl ? formEl.querySelector('input[name="donation[project_id]"]') : null;
    var primaryProjectId = primaryProjectInput ? primaryProjectInput.value : null;

    // helpers to update totals and hidden payloads
    function readPrimaryAmountFromUI(){
      // the amount input represents the primary donation amount by default
      return parseNumber(amountField ? amountField.value : (primaryHidden ? primaryHidden.value : 0));
    }

    function getExtras(){
      try { return extrasHidden && extrasHidden.value ? JSON.parse(extrasHidden.value) : []; } catch(e){ return []; }
    }

    function setExtras(arr){ if(extrasHidden) extrasHidden.value = JSON.stringify(arr); }

    function updatePrimaryHidden(){ if(primaryHidden) primaryHidden.value = readPrimaryAmountFromUI(); }

    function updateTotalDisplay(){
      var primary = readPrimaryAmountFromUI();
      var extras = getExtras().reduce(function(sum, it){ return sum + (parseNumber(it.amount) || 0); }, 0);
      var total = Math.round((primary + extras) * 100) / 100;
      if(totalDisplay) totalDisplay.textContent = total.toString();
    }

    // keep hidden fields in sync when user types/selects amount
    if(amountField) {
      amountField.addEventListener('input', function(){ updatePrimaryHidden(); updateTotalDisplay(); });
      // initialize
      updatePrimaryHidden();
    }

    addButtons.forEach(function(btn){
      btn.addEventListener('click', function(e){
        var amt = parseNumber(this.getAttribute('data-amount')) || 0;
        var btnPid = this.getAttribute('data-project-id') || '';

        // If this add-to-giving targets the same project as the primary project, add it to the primary amount
        if(primaryProjectId && btnPid && btnPid === primaryProjectId.toString()){
          // treat as primary: increment amountField
          if(!amountField) amountField = document.getElementById('donation_amount');
          if(amountField){
            var current = parseNumber(amountField.value);
            amountField.value = (current + amt).toString();
            amountField.dispatchEvent(new Event('input', { bubbles: true }));
          }
        } else {
          // add as an extra for another project
          var extras = getExtras();
          // try to find existing extras entry for this project id (empty string allowed for placeholders)
          var found = null;
          if(btnPid !== ''){
            found = extras.find(function(x){ return x.project_id && x.project_id.toString() === btnPid.toString(); });
          }
          if(found){ found.amount = (parseNumber(found.amount) + amt); }
          else { extras.push({ project_id: btnPid || null, amount: amt }); }
          setExtras(extras);

          // Also increment visible total but do not change primary amount input
          // (we show total in donation_total_value)
        }

        // scroll to donation form and refresh displays
        if(!amountField) amountField = document.getElementById('donation_amount');
        var formScroll = amountField ? amountField.closest('form') : null;
        if(formScroll) formScroll.scrollIntoView({ behavior: 'smooth', block: 'center' });
        updatePrimaryHidden();
        updateTotalDisplay();
      });
    });

    // simple tab switching for More ways to help
    var tabButtons = Array.prototype.slice.call(document.querySelectorAll('.tab-button'));
    tabButtons.forEach(function(tb){
      tb.addEventListener('click', function(e){
        var target = this.getAttribute('data-tab-target');
        if(!target) return;
        document.querySelectorAll('.tab-panel').forEach(function(p){ p.classList.add('hidden'); });
        document.querySelectorAll('.tab-button').forEach(function(b){ b.classList.remove('bg-blue-800', 'text-white'); b.classList.add('border'); });
        var panel = document.querySelector(target);
        if(panel) panel.classList.remove('hidden');
        this.classList.add('bg-blue-800', 'text-white');
        this.classList.remove('border');
      });
    });
  } catch (e) {
    // avoid breaking other pages
    console.error('project_donation init error', e);
  }
}

document.addEventListener('turbo:load', function() {
  initDonationCard();
});

// Also run on initial load in case Turbo isn't present
if(!window.Turbo) {
  document.addEventListener('DOMContentLoaded', initDonationCard);
}

export default initDonationCard;
