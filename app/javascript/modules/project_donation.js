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
