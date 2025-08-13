// Zakat Calculator Dynamic Form Management
document.addEventListener('DOMContentLoaded', function() {
  let assetIndex = 1;
  let liabilityIndex = 1;

  // Add Asset functionality
  const addAssetButton = document.getElementById('add-asset');
  const assetsSection = document.getElementById('assets-section');
  
  if (addAssetButton && assetsSection) {
    addAssetButton.addEventListener('click', function() {
      const assetHTML = `
        <div class="asset-fields bg-gray-50 rounded-lg p-4">
          <div class="grid grid-cols-1 md:grid-cols-12 gap-4 items-start">
            <div class="md:col-span-3">
              <label class="block text-sm font-medium text-gray-700 mb-1">Category</label>
              <select name="assets[${assetIndex}][category]" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent text-sm">
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
              <textarea name="assets[${assetIndex}][description]" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent text-sm" rows="2" placeholder="Description (optional)"></textarea>
            </div>
            <div class="md:col-span-3">
              <label class="block text-sm font-medium text-gray-700 mb-1">Amount (৳)</label>
              <input type="number" name="assets[${assetIndex}][amount]" step="0.01" min="0" placeholder="0.00" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent text-sm asset-amount">
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
      assetIndex++;
      updateCalculation();
    });
  }

  // Add Liability functionality
  const addLiabilityButton = document.getElementById('add-liability');
  const liabilitiesSection = document.getElementById('liabilities-section');
  
  if (addLiabilityButton && liabilitiesSection) {
    addLiabilityButton.addEventListener('click', function() {
      const liabilityHTML = `
        <div class="liability-fields bg-gray-50 rounded-lg p-4">
          <div class="grid grid-cols-1 md:grid-cols-12 gap-4 items-start">
            <div class="md:col-span-8">
              <label class="block text-sm font-medium text-gray-700 mb-1">Description</label>
              <textarea name="liabilities[${liabilityIndex}][description]" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent text-sm" rows="2" placeholder="Describe the liability..."></textarea>
            </div>
            <div class="md:col-span-3">
              <label class="block text-sm font-medium text-gray-700 mb-1">Amount (৳)</label>
              <input type="number" name="liabilities[${liabilityIndex}][amount]" step="0.01" min="0" placeholder="0.00" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent text-sm liability-amount">
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
      liabilityIndex++;
      updateCalculation();
    });
  }

  // Remove asset/liability functionality
  document.addEventListener('click', function(e) {
    if (e.target.closest('.remove-asset')) {
      e.target.closest('.asset-fields').remove();
      updateCalculation();
    }
    
    if (e.target.closest('.remove-liability')) {
      e.target.closest('.liability-fields').remove();
      updateCalculation();
    }
  });

  // Toggle between detailed and simple calculator
  const toggleButton = document.getElementById('toggle-detailed');
  const simpleCalculator = document.getElementById('simple-calculator');
  const detailedSections = document.querySelectorAll('#assets-section, #liabilities-section');
  
  if (toggleButton && simpleCalculator) {
    let isSimpleMode = false;
    
    toggleButton.addEventListener('click', function() {
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
    });
  }

  // Real-time calculation updates
  function updateCalculation() {
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
    updateFormFields(totalAssets, totalLiabilities);
  }

  // Update form fields for submission
  function updateFormFields(totalAssets, totalLiabilities) {
    let totalAssetsField = document.querySelector('input[name="total_assets"]');
    let totalLiabilitiesField = document.querySelector('input[name="total_liabilities"]');
    
    if (!totalAssetsField) {
      totalAssetsField = document.createElement('input');
      totalAssetsField.type = 'hidden';
      totalAssetsField.name = 'total_assets';
      document.getElementById('detailed-calculator-form').appendChild(totalAssetsField);
    }
    
    if (!totalLiabilitiesField) {
      totalLiabilitiesField = document.createElement('input');
      totalLiabilitiesField.type = 'hidden';
      totalLiabilitiesField.name = 'total_liabilities';
      document.getElementById('detailed-calculator-form').appendChild(totalLiabilitiesField);
    }
    
    totalAssetsField.value = totalAssets;
    totalLiabilitiesField.value = totalLiabilities;
  }

  // Add event listeners for real-time calculation
  document.addEventListener('input', function(e) {
    if (e.target.classList.contains('asset-amount') || e.target.classList.contains('liability-amount')) {
      updateCalculation();
    }
  });

  // Initial calculation update
  updateCalculation();
});
