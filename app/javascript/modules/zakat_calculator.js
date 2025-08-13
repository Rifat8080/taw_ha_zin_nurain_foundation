/**
 * Zakat Calculator Module
 * Handles dynamic form functionality for adding/removing assets and liabilities
 * Compatible with Turbo for SPA-like experience
 * Updated for index page detailed calculator
 */

class ZakatCalculator {
  constructor() {
    this.assetIndex = 0;
    this.liabilityIndex = 0;
    this.initialized = false;
    
    // Bind methods to preserve context
    this.addAsset = this.addAsset.bind(this);
    this.addLiability = this.addLiability.bind(this);
    this.removeField = this.removeField.bind(this);
    this.quickCalculate = this.quickCalculate.bind(this);
    this.updateCalculateButton = this.updateCalculateButton.bind(this);
    this.handleInputChange = this.handleInputChange.bind(this);
    this.updateCalculation = this.updateCalculation.bind(this);
    this.toggleCalculatorMode = this.toggleCalculatorMode.bind(this);
  }

  // Asset template for dynamic adding
  get assetTemplate() {
    return `
      <div class="asset-fields field-group bg-gray-50 rounded-lg p-4 mb-4">
        <div class="grid grid-cols-1 md:grid-cols-12 gap-4 items-start">
          <!-- Category -->
          <div class="md:col-span-3">
            <label class="block text-sm font-medium text-gray-700 mb-1">Category</label>
            <select name="zakat_calculation[assets_attributes][INDEX][category]" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent text-sm">
              <option value="">Select category</option>
              <option value="cash">Cash</option>
              <option value="bank">Bank</option>
              <option value="gold">Gold</option>
              <option value="silver">Silver</option>
              <option value="business_inventory">Business inventory</option>
              <option value="receivables">Receivables</option>
              <option value="livestock">Livestock</option>
              <option value="agriculture">Agriculture</option>
              <option value="investments">Investments</option>
              <option value="property_rent">Property rent</option>
            </select>
          </div>
          
          <!-- Description -->
          <div class="md:col-span-5">
            <label class="block text-sm font-medium text-gray-700 mb-1">Description</label>
            <textarea name="zakat_calculation[assets_attributes][INDEX][description]" 
                      class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent text-sm"
                      rows="2" placeholder="Description (optional)"></textarea>
          </div>
          
          <!-- Amount -->
          <div class="md:col-span-3">
            <label class="block text-sm font-medium text-gray-700 mb-1">Amount</label>
            <input type="number" name="zakat_calculation[assets_attributes][INDEX][amount]" 
                   class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent text-sm"
                   step="0.01" min="0" placeholder="0.00" />
          </div>
          
          <!-- Remove Button -->
          <div class="md:col-span-1 flex items-end">
            <button type="button" class="remove-field w-full px-3 py-2 text-red-600 hover:text-red-800 focus:outline-none">
              <svg class="w-5 h-5 mx-auto" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
              </svg>
            </button>
          </div>
        </div>
      </div>
    `;
  }

  // Liability template for dynamic adding
  get liabilityTemplate() {
    return `
      <div class="liability-fields field-group bg-gray-50 rounded-lg p-4 mb-4">
        <div class="grid grid-cols-1 md:grid-cols-12 gap-4 items-start">
          <!-- Description -->
          <div class="md:col-span-8">
            <label class="block text-sm font-medium text-gray-700 mb-1">Description</label>
            <textarea name="zakat_calculation[liabilities_attributes][INDEX][description]" 
                      class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent text-sm"
                      rows="2" placeholder="Describe the liability..." required></textarea>
          </div>
          
          <!-- Amount -->
          <div class="md:col-span-3">
            <label class="block text-sm font-medium text-gray-700 mb-1">Amount</label>
            <input type="number" name="zakat_calculation[liabilities_attributes][INDEX][amount]" 
                   class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent text-sm"
                   step="0.01" min="0" placeholder="0.00" required />
          </div>
          
          <!-- Remove Button -->
          <div class="md:col-span-1 flex items-end">
            <button type="button" class="remove-field w-full px-3 py-2 text-red-600 hover:text-red-800 focus:outline-none">
              <svg class="w-5 h-5 mx-auto" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
              </svg>
            </button>
          </div>
        </div>
      </div>
    `;
  }

  // Initialize the calculator
  init() {
    if (this.initialized) return;
    
    // Check if we're on the zakat calculation page (new form or index page)
    const form = document.querySelector('form[action*="zakat_calculations"]');
    const indexForm = document.getElementById('detailed-calculator-form');
    if (!form && !indexForm) return;

    // Get initial counts from existing fields
    this.assetIndex = document.querySelectorAll('.asset-fields').length;
    this.liabilityIndex = document.querySelectorAll('.liability-fields').length;

    this.setupEventListeners();
    
    // Initialize based on page type
    if (indexForm) {
      // Index page initialization
      this.updateCalculation();
    } else {
      // New form initialization
      this.initializeForm();
    }
    
    this.initialized = true;
  }

  // Clean up when navigating away (Turbo compatibility)
  destroy() {
    this.removeEventListeners();
    this.initialized = false;
  }

  setupEventListeners() {
    // Add asset button (for both new form and index page)
    const addAssetBtn = document.getElementById('add-asset');
    if (addAssetBtn) {
      // Check if we're on the index page by looking for index-specific elements
      const isIndexPage = document.getElementById('detailed-calculator-form');
      if (isIndexPage) {
        addAssetBtn.addEventListener('click', this.addIndexAsset.bind(this));
      } else {
        addAssetBtn.addEventListener('click', this.addAsset);
      }
    }

    // Add liability button (for both new form and index page)
    const addLiabilityBtn = document.getElementById('add-liability');
    if (addLiabilityBtn) {
      const isIndexPage = document.getElementById('detailed-calculator-form');
      if (isIndexPage) {
        addLiabilityBtn.addEventListener('click', this.addIndexLiability.bind(this));
      } else {
        addLiabilityBtn.addEventListener('click', this.addLiability);
      }
    }

    // Toggle calculator mode button (index page only)
    const toggleBtn = document.getElementById('toggle-detailed');
    if (toggleBtn) {
      toggleBtn.addEventListener('click', this.toggleCalculatorMode);
    }

    // Quick calculate button
    const quickCalculateBtn = document.getElementById('quick-calculate');
    if (quickCalculateBtn) {
      quickCalculateBtn.addEventListener('click', this.quickCalculate);
    }

    // Remove field functionality (using event delegation)
    document.addEventListener('click', this.removeField);

    // Live calculation on input change
    document.addEventListener('input', this.handleInputChange);
  }

  removeEventListeners() {
    const addAssetBtn = document.getElementById('add-asset');
    const addLiabilityBtn = document.getElementById('add-liability');
    const quickCalculateBtn = document.getElementById('quick-calculate');

    if (addAssetBtn) addAssetBtn.removeEventListener('click', this.addAsset);
    if (addLiabilityBtn) addLiabilityBtn.removeEventListener('click', this.addLiability);
    if (quickCalculateBtn) quickCalculateBtn.removeEventListener('click', this.quickCalculate);
    
    document.removeEventListener('click', this.removeField);
    document.removeEventListener('input', this.handleInputChange);
  }

  addAsset() {
    const assetsSection = document.getElementById('assets-section');
    if (!assetsSection) return;

    const newAssetHTML = this.assetTemplate.replace(/INDEX/g, this.assetIndex);
    const tempDiv = document.createElement('div');
    tempDiv.innerHTML = newAssetHTML;
    assetsSection.appendChild(tempDiv.firstElementChild);
    this.assetIndex++;
    this.updateCalculateButton();
  }

  addLiability() {
    const liabilitiesSection = document.getElementById('liabilities-section');
    if (!liabilitiesSection) return;

    const newLiabilityHTML = this.liabilityTemplate.replace(/INDEX/g, this.liabilityIndex);
    const tempDiv = document.createElement('div');
    tempDiv.innerHTML = newLiabilityHTML;
    liabilitiesSection.appendChild(tempDiv.firstElementChild);
    this.liabilityIndex++;
    this.updateCalculateButton();
  }

  removeField(e) {
    // Handle index page remove buttons
    if (e.target.closest('.remove-asset')) {
      e.preventDefault();
      e.target.closest('.asset-fields').remove();
      this.updateCalculation();
      return;
    }
    
    if (e.target.closest('.remove-liability')) {
      e.preventDefault();
      e.target.closest('.liability-fields').remove();
      this.updateCalculation();
      return;
    }

    // Handle new form remove buttons
    if (!e.target.closest('.remove-field')) return;

    e.preventDefault();
    const fieldGroup = e.target.closest('.field-group');
    const destroyField = fieldGroup.querySelector('input[name*="_destroy"]');
    
    if (destroyField) {
      // Mark for destruction if it's an existing record
      destroyField.value = '1';
      fieldGroup.style.display = 'none';
    } else {
      // Remove completely if it's a new record
      fieldGroup.remove();
    }
    this.updateCalculateButton();
  }

  async quickCalculate() {
    const assets = this.calculateTotalAssets();
    const liabilities = this.calculateTotalLiabilities();
    const yearField = document.getElementById('zakat_calculation_calculation_year');
    
    if (!yearField || !yearField.value) {
      alert('Please select a calculation year first.');
      return;
    }
    
    try {
      const response = await fetch('/zakat_calculations/quick_calculate', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify({
          total_assets: assets,
          total_liabilities: liabilities,
          year: yearField.value
        })
      });

      if (!response.ok) {
        throw new Error('Network response was not ok');
      }

      const data = await response.json();
      this.displayQuickResults(data);
    } catch (error) {
      console.error('Error:', error);
      alert('Error calculating zakat. Please try again.');
    }
  }

  displayQuickResults(data) {
    const netAssetsEl = document.getElementById('net-assets');
    const zakatDueEl = document.getElementById('zakat-due');
    const zakatStatusEl = document.getElementById('zakat-status');
    const quickResultsEl = document.getElementById('quick-results');

    if (netAssetsEl) {
      netAssetsEl.textContent = '$' + data.net_assets.toLocaleString('en-US', {minimumFractionDigits: 2});
    }
    if (zakatDueEl) {
      zakatDueEl.textContent = '$' + data.zakat_due.toLocaleString('en-US', {minimumFractionDigits: 2});
    }
    if (zakatStatusEl) {
      zakatStatusEl.textContent = data.zakat_eligible ? 'Zakat Due' : 'Below Nisab';
      zakatStatusEl.className = 'font-medium ' + 
        (data.zakat_eligible ? 'text-green-600' : 'text-gray-600');
    }
    if (quickResultsEl) {
      quickResultsEl.classList.remove('hidden');
    }
  }

  calculateTotalAssets() {
    const assetInputs = document.querySelectorAll('input[name*="[assets_attributes]"][name*="[amount]"]');
    let total = 0;
    assetInputs.forEach(input => {
      const fieldGroup = input.closest('.field-group');
      const destroyField = fieldGroup?.querySelector('input[name*="_destroy"]');
      if (!destroyField || destroyField.value !== '1') {
        total += parseFloat(input.value) || 0;
      }
    });
    return total;
  }

  calculateTotalLiabilities() {
    const liabilityInputs = document.querySelectorAll('input[name*="[liabilities_attributes]"][name*="[amount]"]');
    let total = 0;
    liabilityInputs.forEach(input => {
      const fieldGroup = input.closest('.field-group');
      const destroyField = fieldGroup?.querySelector('input[name*="_destroy"]');
      if (!destroyField || destroyField.value !== '1') {
        total += parseFloat(input.value) || 0;
      }
    });
    return total;
  }

  updateCalculateButton() {
    const totalAssets = this.calculateTotalAssets();
    const totalLiabilities = this.calculateTotalLiabilities();
    const calculateButton = document.getElementById('quick-calculate');
    
    if (!calculateButton) return;

    if (totalAssets > 0 || totalLiabilities > 0) {
      calculateButton.textContent = `Quick Calculate (Assets: $${totalAssets.toLocaleString()}, Liabilities: $${totalLiabilities.toLocaleString()})`;
      calculateButton.classList.remove('border-gray-300', 'text-gray-700', 'bg-white');
      calculateButton.classList.add('border-blue-300', 'text-blue-700', 'bg-blue-50');
    } else {
      calculateButton.textContent = 'Quick Calculate';
      calculateButton.classList.remove('border-blue-300', 'text-blue-700', 'bg-blue-50');
      calculateButton.classList.add('border-gray-300', 'text-gray-700', 'bg-white');
    }
    
    this.updateCounters();
  }

  updateCounters() {
    const assetCount = document.querySelectorAll('.asset-fields:not([style*="display: none"])').length;
    const liabilityCount = document.querySelectorAll('.liability-fields:not([style*="display: none"])').length;
    
    const assetsCountEl = document.getElementById('assets-count');
    const liabilitiesCountEl = document.getElementById('liabilities-count');

    if (assetsCountEl) {
      assetsCountEl.textContent = `${assetCount} asset${assetCount !== 1 ? 's' : ''}`;
    }
    if (liabilitiesCountEl) {
      liabilitiesCountEl.textContent = `${liabilityCount} liabilit${liabilityCount !== 1 ? 'ies' : 'y'}`;
    }
  }

  handleInputChange(e) {
    if (e.target.matches('input[name*="[amount]"]')) {
      this.updateCalculateButton();
    }
    
    // Handle index page calculator inputs
    if (e.target.classList.contains('asset-amount') || e.target.classList.contains('liability-amount')) {
      this.updateCalculation();
    }
  }

  // New methods for index page detailed calculator
  updateCalculation() {
    const assetInputs = document.querySelectorAll('.asset-amount');
    const liabilityInputs = document.querySelectorAll('.liability-amount');
    
    let totalAssets = 0;
    let totalLiabilities = 0;
    
    assetInputs.forEach(input => {
      const value = parseFloat(input.value) || 0;
      totalAssets += value;
    });
    
    liabilityInputs.forEach(input => {
      const value = parseFloat(input.value) || 0;
      totalLiabilities += value;
    });
    
    const netAssets = totalAssets - totalLiabilities;
    const nisabThreshold = 64175; // Default nisab value, should be dynamic
    const zakatDue = netAssets >= nisabThreshold ? (netAssets * 0.025) : 0;
    
    // Update calculation summary if it exists
    const summaryAssets = document.getElementById('summary-assets');
    const summaryLiabilities = document.getElementById('summary-liabilities');
    const summaryNet = document.getElementById('summary-net');
    const summaryZakat = document.getElementById('summary-zakat');
    const calculationSummary = document.getElementById('calculation-summary');
    
    if (summaryAssets && (totalAssets > 0 || totalLiabilities > 0)) {
      calculationSummary.classList.remove('hidden');
      summaryAssets.textContent = `৳${totalAssets.toLocaleString()}`;
      summaryLiabilities.textContent = `৳${totalLiabilities.toLocaleString()}`;
      summaryNet.textContent = `৳${netAssets.toLocaleString()}`;
      summaryZakat.textContent = `৳${zakatDue.toLocaleString()}`;
    } else if (calculationSummary) {
      calculationSummary.classList.add('hidden');
    }
    
    // Update form hidden fields for submission
    this.updateFormFields(totalAssets, totalLiabilities);
  }

  updateFormFields(totalAssets, totalLiabilities) {
    const form = document.getElementById('detailed-calculator-form');
    if (!form) return;
    
    let totalAssetsField = form.querySelector('input[name="total_assets"]');
    let totalLiabilitiesField = form.querySelector('input[name="total_liabilities"]');
    
    if (!totalAssetsField) {
      totalAssetsField = document.createElement('input');
      totalAssetsField.type = 'hidden';
      totalAssetsField.name = 'total_assets';
      form.appendChild(totalAssetsField);
    }
    
    if (!totalLiabilitiesField) {
      totalLiabilitiesField = document.createElement('input');
      totalLiabilitiesField.type = 'hidden';
      totalLiabilitiesField.name = 'total_liabilities';
      form.appendChild(totalLiabilitiesField);
    }
    
    totalAssetsField.value = totalAssets;
    totalLiabilitiesField.value = totalLiabilities;
  }

  toggleCalculatorMode() {
    const toggleButton = document.getElementById('toggle-detailed');
    const simpleCalculator = document.getElementById('simple-calculator');
    const detailedSections = document.querySelectorAll('#assets-section, #liabilities-section');
    
    if (!toggleButton || !simpleCalculator) return;
    
    let isSimpleMode = simpleCalculator.classList.contains('hidden') === false;
    isSimpleMode = !isSimpleMode;
    
    if (isSimpleMode) {
      simpleCalculator.classList.remove('hidden');
      detailedSections.forEach(section => section.parentElement.classList.add('hidden'));
      document.getElementById('toggle-text').textContent = 'Show Detailed Calculator';
    } else {
      simpleCalculator.classList.add('hidden');
      detailedSections.forEach(section => section.parentElement.classList.remove('hidden'));
      document.getElementById('toggle-text').textContent = 'Show Simple Calculator';
    }
  }

  addIndexAsset() {
    const assetsSection = document.getElementById('assets-section');
    if (!assetsSection) return;
    
    const assetHTML = `
      <div class="asset-fields bg-gray-50 rounded-lg p-4">
        <div class="grid grid-cols-1 md:grid-cols-12 gap-4 items-start">
          <div class="md:col-span-3">
            <label class="block text-sm font-medium text-gray-700 mb-1">Category</label>
            <select name="assets[${this.assetIndex}][category]" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent text-sm">
              <option value="">Select category</option>
              <option value="cash">Cash</option>
              <option value="bank">Bank</option>
              <option value="gold">Gold</option>
              <option value="silver">Silver</option>
              <option value="business_inventory">Business Inventory</option>
              <option value="receivables">Receivables</option>
              <option value="livestock">Livestock</option>
              <option value="agriculture">Agriculture</option>
              <option value="investments">Investments</option>
              <option value="property_rent">Property Rent</option>
            </select>
          </div>
          <div class="md:col-span-5">
            <label class="block text-sm font-medium text-gray-700 mb-1">Description</label>
            <textarea name="assets[${this.assetIndex}][description]" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent text-sm" rows="2" placeholder="Description (optional)"></textarea>
          </div>
          <div class="md:col-span-3">
            <label class="block text-sm font-medium text-gray-700 mb-1">Amount (৳)</label>
            <input type="number" name="assets[${this.assetIndex}][amount]" step="0.01" min="0" placeholder="0.00" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent text-sm asset-amount">
          </div>
          <div class="md:col-span-1 flex items-end">
            <button type="button" class="remove-asset w-full px-3 py-2 text-red-600 hover:text-red-800 focus:outline-none">
              <svg class="w-5 h-5 mx-auto" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
              </svg>
            </button>
          </div>
        </div>
      </div>
    `;
    
    assetsSection.insertAdjacentHTML('beforeend', assetHTML);
    this.assetIndex++;
    this.updateCalculation();
  }

  addIndexLiability() {
    const liabilitiesSection = document.getElementById('liabilities-section');
    if (!liabilitiesSection) return;
    
    const liabilityHTML = `
      <div class="liability-fields bg-gray-50 rounded-lg p-4">
        <div class="grid grid-cols-1 md:grid-cols-12 gap-4 items-start">
          <div class="md:col-span-8">
            <label class="block text-sm font-medium text-gray-700 mb-1">Description</label>
            <textarea name="liabilities[${this.liabilityIndex}][description]" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent text-sm" rows="2" placeholder="Describe the liability..."></textarea>
          </div>
          <div class="md:col-span-3">
            <label class="block text-sm font-medium text-gray-700 mb-1">Amount (৳)</label>
            <input type="number" name="liabilities[${this.liabilityIndex}][amount]" step="0.01" min="0" placeholder="0.00" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent text-sm liability-amount">
          </div>
          <div class="md:col-span-1 flex items-end">
            <button type="button" class="remove-liability w-full px-3 py-2 text-red-600 hover:text-red-800 focus:outline-none">
              <svg class="w-5 h-5 mx-auto" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
              </svg>
            </button>
          </div>
        </div>
      </div>
    `;
    
    liabilitiesSection.insertAdjacentHTML('beforeend', liabilityHTML);
    this.liabilityIndex++;
    this.updateCalculation();
  }

  initializeForm() {
    // Initialize button state
    this.updateCalculateButton();

    // Ensure at least one asset and one liability field are present
    if (document.querySelectorAll('.asset-fields').length === 0) {
      this.addAsset();
    }
    
    if (document.querySelectorAll('.liability-fields').length === 0) {
      this.addLiability();
    }
  }
}

// Create a singleton instance
const zakatCalculator = new ZakatCalculator();

// Turbo event listeners for proper initialization and cleanup
document.addEventListener('turbo:load', () => {
  zakatCalculator.init();
});

document.addEventListener('turbo:before-cache', () => {
  zakatCalculator.destroy();
});

// Fallback for traditional page loads (when Turbo is disabled)
document.addEventListener('DOMContentLoaded', () => {
  zakatCalculator.init();
});

// Export for potential external use
export default zakatCalculator;
