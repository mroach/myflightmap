Myflightmap::Application.routes.draw do

  # Indicate what action responds to "/" requests
  root 'home#index'

  # The import namespace uses non-standard routes. Set them up.
  namespace :import do
    root to: :index
    namespace :flight_memory do
      root to: :index
      post 'upload'
    end
  end

  get 'airports/search', to: 'airports#search'
  get 'airports/distance_between', to: 'airports#distance_between'
  get 'flights/duration', to: 'flights#duration'
  get 'audits/:type/:id', to: 'audits#index', as: 'audits'

  resources :airlines
  resources :airports, constraint: { id: /[A-Z]{3}/ }

  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations",
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  # Routes that are prefixed with the username
  # Ex) /mroach/map, /mroach/trips, /mroach/flights
  scope ':username', as: 'user' do
    get '/', to: 'map#show'
    get 'map', to: 'map#show', as: 'map'

    #get 'flights(-:style)', to: 'flights#index', as: 'user_flights'
    patch 'flights/batch_update', to: 'flights#batch_update', as: 'flight_batch_update'

    resources :flights
    resources :trips
  end

end
