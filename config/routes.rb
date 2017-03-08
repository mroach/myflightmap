Myflightmap::Application.routes.draw do
  # Indicate what action responds to "/" requests
  root 'home#index'

  get 'about', to: 'home#about'

  # The import namespace uses non-standard routes. Set them up.
  namespace :import do
    root action: :index
    namespace :flight_memory do
      root action: :index
      post 'upload'
    end
  end

  namespace :callbacks do
    post 'worldmate/receive', to: 'worldmate#receive'
  end

  get 'airports/search', to: 'airports#search'
  get 'airports/:id/update_from_external', to: 'airports#update_from_external',
                                           as: 'update_airport_from_external'

  get 'members', to: 'profiles#index'

  resources :airlines, constraints: { id: /\w{2}/ }
  resources :airports, constraints: { id: /[A-Z]{3}/ }

  devise_for :users, controllers: {
    sessions:           'users/sessions',
    registrations:      'users/registrations',
    omniauth_callbacks: 'users/omniauth_callbacks'
  }

  # Routes that are prefixed with the username
  # Ex) /mroach/map, /mroach/trips, /mroach/flights
  # Explicity note which chars are allowed in usernames
  # The dot is important; by default it'd be rejected
  scope ':username', constraints: { username: /[\p{L}\d\_\.\-]+/ } do
    root to: 'profiles#show', as: 'profile'
    get 'map', to: 'map#show', as: 'map'

    # get 'flights(-:style)', to: 'flights#index', as: 'user_flights'
    patch 'flights/batch_update', to: 'flights#batch_update', as: 'flight_batch_update'

    resources :flights
    resources :trips
  end

  namespace :admin do
    get 'audits/:type/:id', to: 'audits#index', as: 'audits'
  end
end
