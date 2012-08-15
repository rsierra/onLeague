OnLeague::Application.routes.draw do
  resources :teams, only: [:index, :new, :create, :show] do
    resources :team_files, only: [:new, :create, :destroy] do
      collection do
        match 'search' => 'team_files#search', :via => [:post], :as => :search
      end
    end
  end

  resources :games, only: [:show]
  match '/games(/:season(/:week))' => "games#index", as: :games

  resources :clubs, only: [:index, :show]

  match 'leagues/:id/change' => 'leagues#change', via: :get, as: 'change_league'

  devise_for :admins

  # Remember add path for default route with translations
  devise_for :users, path: "usuarios", controllers: { registrations: 'users/registrations', omniauth_callbacks: "users/omniauth_callbacks" }
  as :user do
    delete 'users/auth/:provider/delete' => 'users/omniauth_callbacks#delete', as: :user_omniauth_delete
  end

  resources :auth_providers

  root to: "home#index"

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end

ActionDispatch::Routing::Translator.translate_from_file('config/locales/routes.yml')

# To avoid conflicts, rails admin routes should be declared out of translate routes
# and local routes should be added by hand
OnLeague::Application.routes.draw do
  # Engine rout should be different to /admin, becouse crashes with devise routes
  mount RailsAdmin::Engine => '/administracion', :as => 'rails_admin', :locale => :es
  mount RailsAdmin::Engine => '/en/administration', :as => 'rails_admin', :locale => :en
end
