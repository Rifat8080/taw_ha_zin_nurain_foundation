const flowbite = require("flowbite/plugin")

module.exports = {
  content: [
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*',
    './node_modules/flowbite/**/*.js'
  ],
  safelist: [
    'bg-forange',
    'hover:bg-forange/90',
    'focus:ring-forange/50',
    'text-forange',
    'border-forange',
    'bg-foundationprimarygreen',
    'text-foundationprimarygreen',
    'border-foundationprimarygreen',
    'hover:bg-foundationprimarygreen',
    'hover:text-foundationprimarygreen'
  ],
  theme: {
    extend: {
      fontFamily: {
        'body': [
          'Roboto', 
          'ui-sans-serif', 
          'system-ui', 
          '-apple-system', 
          'Segoe UI', 
          'Helvetica Neue', 
          'Arial', 
          'Noto Sans', 
          'sans-serif', 
          'Apple Color Emoji', 
          'Segoe UI Emoji', 
          'Segoe UI Symbol', 
          'Noto Color Emoji'
        ],
        'sans': [
          'Roboto', 
          'ui-sans-serif', 
          'system-ui', 
          '-apple-system', 
          'Segoe UI', 
          'Helvetica Neue', 
          'Arial', 
          'Noto Sans', 
          'sans-serif', 
          'Apple Color Emoji', 
          'Segoe UI Emoji', 
          'Segoe UI Symbol', 
          'Noto Color Emoji'
        ]
      },
      colors: {
        // Foundation Colors
        foundation: {
          primary: 'rgb(var(--color-foundation-primary) / <alpha-value>)',
          secondary: 'rgb(var(--color-foundation-secondary) / <alpha-value>)',
          accent: 'rgb(var(--color-foundation-accent) / <alpha-value>)',
          neutral: 'rgb(var(--color-foundation-neutral) / <alpha-value>)',
          light: 'rgb(var(--color-foundation-light) / <alpha-value>)',
          dark: 'rgb(var(--color-foundation-dark) / <alpha-value>)',
        },
        // Custom Foundation Primary Green
        foundationprimarygreen: 'rgb(var(--color-foundationprimarygreen) / <alpha-value>)',
        // Custom Foundation Orange
        forange: 'rgb(var(--color-forange) / <alpha-value>)',
        // Charity/Action Colors
        charity: {
          green: 'rgb(var(--color-charity-green) / <alpha-value>)',
          blue: 'rgb(var(--color-charity-blue) / <alpha-value>)',
          orange: 'rgb(var(--color-charity-orange) / <alpha-value>)',
        },
        // Status Colors
        success: 'rgb(var(--color-success) / <alpha-value>)',
        warning: 'rgb(var(--color-warning) / <alpha-value>)',
        error: 'rgb(var(--color-error) / <alpha-value>)',
        info: 'rgb(var(--color-info) / <alpha-value>)',
      }
    }
  },
  plugins: [
    flowbite.plugin
  ]
}
