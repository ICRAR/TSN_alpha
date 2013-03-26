TSNAlpha::Application.routes.draw do




  get "trophies/show"

  root :to => 'pages#index'
  mount Ckeditor::Engine => '/ckeditor'

  devise_for :users
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  get "/pages/home" => "pages#home", :as => 'home'
  get "/pages/:slug" => "pages#show", :as => 'page'

  resources :profiles, :only => [:index, :show, :update] do
    collection do
      get 'search'
    end
  end
  get "/profile" => "profiles#show",  :as => 'my_profile'
  get "/profile/edit" => "profiles#edit", :as => 'edit_profile'
  post "/profile/update_nereus_id"  => "profiles#update_nereus_id", :as => 'update_nereus_id'
  post "/profile/create_boinc_id"  => "profiles#create_boinc_id", :as => 'create_boinc_id'
  post "/profile/update_boinc_id"  => "profiles#update_boinc_id", :as => 'update_boinc_id'


  resources :alliances do
    member do
       get 'join'
    end
    collection do
      get 'leave'
      get 'search'
    end
  end
  get "/alliance" => "alliances#show", :as => 'my_alliance'

  resources :trophies, :only => [:show]

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
