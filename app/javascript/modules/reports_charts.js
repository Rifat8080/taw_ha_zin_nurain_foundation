// app/javascript/modules/reports_charts.js
// Imports ApexCharts via importmap-pinned path (or served from /node_modules)
import ApexCharts from "apexcharts";

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
  new ApexCharts(el, options).render();
}

function initSourceChart(el, breakdown) {
  const options = {
    chart: { type: 'donut', height: 260 },
    series: [breakdown.project || 0, breakdown.healthcare || 0],
    labels: ['Project','Healthcare'],
    colors: ['#16a34a','#2563eb'],
    legend: { position: 'bottom' }
  };
  new ApexCharts(el, options).render();
}

export default function mountReportsCharts() {
  const trendEl = document.getElementById('trendChart');
  if (trendEl) {
    try {
      const labels = JSON.parse(trendEl.dataset.chartLabels || '[]');
      const donations = JSON.parse(trendEl.dataset.donationSeries || '[]');
      const expenses = JSON.parse(trendEl.dataset.expenseSeries || '[]');
      initTrendChart(trendEl, labels, donations, expenses);
    } catch (e) {
      // fail silently
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

// Auto-run when module is imported
try {
  mountReportsCharts();
} catch (e) {
  // ignore in case DOM isn't ready yet; Turbo/Stimulus can re-run if needed
}
