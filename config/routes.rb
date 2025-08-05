Rails.application.routes.draw do
  devise_for :users
  
  # Admin-only user management routes
  resources :users, only: [:index, :show, :edit, :update, :destroy] do
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

  # Event Management System Routes
  resources :events do
    resources :event_users, only: [:create, :destroy], path: 'registrations'
    resources :tickets, only: [:create, :destroy]
    member do
      get :attendees
    end
  end
  
  resources :tickets, only: [:index, :show] do
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
