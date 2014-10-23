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

  get 'map/(:id)' => 'map#show'
  get 'airports/search' => 'airports#search'
  get 'airports/distance_between' => 'airports#distance_between'
  get 'flights/duration' => 'flights#duration'

  resources :flights, :trips, :airlines
  resources :airports, constraint: { id: /[A-Z]{3}/ }

  devise_for :users, controllers: { :omniauth_callbacks => "users/omniauth_callbacks" }

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".



  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
