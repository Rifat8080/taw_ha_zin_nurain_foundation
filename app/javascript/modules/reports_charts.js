// app/javascript/modules/reports_charts.js
// Imports ApexCharts via importmap-pinned path (or served from /node_modules)
import ApexCharts from "apexcharts";

let activeCharts = [];

function destroyActiveCharts() {
  try {
    activeCharts.forEach(c => { if (c && typeof c.destroy === 'function') c.destroy(); });
  } catch (e) {
    // ignore
  }
  activeCharts = [];
}

function initTrendChart(el, labels, donationData, expenseData) {
  const options = {
    chart: { type: 'area', height: 280, toolbar: { show: false } },
    series: [
      { name: 'Donations', data: donationData },
      { name: 'Expenses', data: expenseData }
    ],
    xaxis: { categories: labels, type: 'category' },
    stroke: { curve: 'smooth', width: 2 },
    colors: ['#16a34a', '#dc2626'],
    fill: { type: 'gradient', gradient: { shadeIntensity: 1, opacityFrom: 0.12, opacityTo: 0.02 } },
    legend: { position: 'bottom' },
    tooltip: { shared: true }
  };
  const chart = new ApexCharts(el, options);
  chart.render();
  activeCharts.push(chart);
}

function initSourceChart(el, breakdown) {
  const options = {
    chart: { type: 'donut', height: 260 },
    series: [breakdown.project || 0, breakdown.healthcare || 0],
    labels: ['Project','Healthcare'],
    colors: ['#16a34a','#2563eb'],
    legend: { position: 'bottom' }
  };
  const chart = new ApexCharts(el, options);
  chart.render();
  activeCharts.push(chart);
}

export function mountReportsCharts() {
  destroyActiveCharts();

  const trendEl = document.getElementById('trendChart');
  if (trendEl) {
    try {
      const labels = JSON.parse(trendEl.dataset.chartLabels || '[]');
      const donations = JSON.parse(trendEl.dataset.donationSeries || '[]');
      const expenses = JSON.parse(trendEl.dataset.expenseSeries || '[]');
      initTrendChart(trendEl, labels, donations, expenses);
    } catch (e) {
      console.error('Failed to parse trend chart data', e);
    }
  }

  const srcEl = document.getElementById('sourceChart');
  if (srcEl) {
    try {
      const breakdown = JSON.parse(srcEl.dataset.breakdown || '{}');
      initSourceChart(srcEl, breakdown);
    } catch (e) {
      console.error('Failed to parse source chart data', e);
    }
  }
}

// Initialize on Turbo navigation and on initial DOM load
if (typeof window !== 'undefined') {
  const run = () => {
    try { mountReportsCharts(); } catch (e) { /* ignore */ }
  };

  document.addEventListener('turbo:load', run);
  document.addEventListener('DOMContentLoaded', run);
}
