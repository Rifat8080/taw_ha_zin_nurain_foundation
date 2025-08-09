Rails.application.routes.draw do
  devise_for :users

  # Zakat Calculator Routes
  resources :zakat_calculations do
    collection do
      post :quick_calculate
    end
  end

  # Nisab Rates Management (Admin only)
  resources :nisab_rates

  # Admin-only user management routes
  resources :users, only: [ :index, :show, :edit, :update, :destroy ] do
    collection do
      get :admin_index
    end
  end

  resources :expenses
  resources :donations
  resources :projects

  # Volunteer Management System Routes
  resources :volunteers
  resources :volunteers_teams
  resources :team_assignments, except: [ :edit, :update ]
  resources :work_orders

  # Healthcare Management System Routes
  resources :healthcare_requests do
    resources :healthcare_donations, only: [ :new, :create ], path: "donations"
    resources :healthcare_expenses, path: "expenses"
    member do
      patch :approve
      patch :reject
      patch :complete
    end
  end

  resources :healthcare_donations, only: [ :index, :show ]

  # Event Management System Routes
  resources :events do
    resources :event_users, only: [ :create, :destroy ], path: "registrations"
    resources :tickets, only: [ :create, :destroy ] do
      collection do
        post :bulk_create
      end
    end
    member do
      get :attendees
    end
  end

  resources :tickets, only: [ :index, :show ] do
    member do
      get :qr_code
      patch :use_ticket
    end
    collection do
      get :qr_scan
      post :validate_qr
    end
  end

  root "home#index"
end
