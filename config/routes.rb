Rails.application.routes.draw do
  resources :history_credits do
    collection { post :report }
    collection { post :store }
    collection { get :monitoreo }
  end
  resources :pending_trials, only: [:index, :show, :destroy, :new, :create]
  resources :insolvencies
  resources :insolvency_activities
  resources :insolvency_stages
  resources :without_goods
  resources :without_good_activities
  resources :withoutgood_stages
  resources :goods
  resources :good_activities
  resources :good_stages
  resources :lawyers
  devise_for :users, controllers: {
      sessions: 'authentication/sessions',
      registrations: 'authentication/registrations'
  }

  authenticated :user do
    root to: "main#dashboard", as: :authenticated_root
  end

  root to: "main#home"

  get 'home_creditos', to: "main#home_creditos", as: :creditos_root
  get '/list/stages', to: "main#stage", as: :stages_root
  get '/creditos/new', to: "main#new_trial", as: :new_trials_root
  post '/creditos/create', to: "main#create_trial", as: :create_trial_root

end
