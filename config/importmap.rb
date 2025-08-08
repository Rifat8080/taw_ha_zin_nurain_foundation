# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "flowbite", to: "https://cdnjs.cloudflare.com/ajax/libs/flowbite/2.3.0/flowbite.turbo.min.js"
pin "flowbite-datepicker", to: "https://cdnjs.cloudflare.com/ajax/libs/flowbite/2.3.0/datepicker.turbo.min.js"

# Pin custom JavaScript modules with explicit mappings
pin "modules/donor_modal", to: "modules/donor_modal.js"
pin "modules/qr_scanner", to: "modules/qr_scanner.js"
pin "modules/ticket_utils", to: "modules/ticket_utils.js"
pin "modules/zakat_calculator", to: "modules/zakat_calculator.js"
pin "modules/guests", to: "modules/guests.js"
