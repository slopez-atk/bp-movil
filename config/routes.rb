Rails.application.routes.draw do

  mount RailsAdmin::Engine => '/administracion', as: 'rails_admin'
  resources :history_credits do
    collection { post :report }
    collection { post :store }
    collection { get :monitoreo }
    collection { post :eliminar }
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
  resources :discarded_trials, only:[:destroy] do
    collection {post :ingresar}
  end
  devise_for :users, controllers: {
      sessions: 'authentication/sessions',
      registrations: 'authentication/registrations'
  }

  authenticated :user do
    root to: "main#dashboard", as: :authenticated_root
  end

  root to: "main#home"
  # Ruta para la busqueda de un juicio
  get '/juicios/search', to: "main#search", as: :search_juicios
  # Pantalla principal del modulo de juicios
  get 'home_creditos', to: "main#home_creditos", as: :creditos_root
  # Ruta de la pantalla para la gestion de etapas
  get '/list/stages', to: "main#stage", as: :stages_root
  # CPantalla donde se muestran los nuevos creditos de la base de datos Oracle
  get '/creditos/new', to: "main#new_trial", as: :new_trials_root
  # Ruta de la pantalla de evaluacion de resultados
  get '/evaluacion_resultados', to: "main#evaluacion_resultados", as: :evaluacion_resultados
  # Ruta del controlador para crear un pending_trial
  post '/creditos/create', to: "main#create_trial", as: :create_trial_root
  # Ruta para actualizar el estado de un juicio
  post '/juicio/:id/update', to: "main#change_state", as: :update_trial_state
  # Ruta para manejar los reingresos de juicios
  post '/reingresos/:id', to: "main#reingresos", as: :reingreso_juicios
  #   Ruta que muestra todos los juicios
  get '/juicios', to: 'main#listado_juicios', as: :listado_juicios
  # Ruta del metodo para cambiar un juicio de bienes a sin bienes y al contrario
  post '/juicio/update', to: "main#change_trial_type", as: :cambiar_tipo_juicio


#   Modulo de creditos
  get '/credits', to: 'credits#index', as: :credits_root

  namespace :credits do
    post 'creditos_por_vencer'
    post 'creditos_vencidos'
    post 'creditos_concedidos'
    post 'cosechas'
    post 'matrices'
    get 'cartera_recuperada'
    get 'report'
    get 'clientes_vip'
  end
end
