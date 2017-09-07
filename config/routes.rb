Rails.application.routes.draw do
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

end
