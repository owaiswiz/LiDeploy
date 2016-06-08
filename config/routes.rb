Rails.application.routes.draw do
 #devise_scope :user do
 # get '/signup' => 'devise/registrations#new', :as => 'new_user_registration'
 # end
 #devise_for :users
resources :instances
devise_for :users, :skip => [:sessions,:registrations,:confirmations]
as :user do
  #User Signin/Signout
# get '/account/:username/' => "account#index", as: :user_root
  get "/login" => "sessions#new", :as => :new_user_session
  post "/login" => "sessions#create", :as => :user_session
  get "/logout" => "sessions#destroy"
  delete "/logout" => "devise/sessions#destroy", :as => :destroy_user_session
  #User Signup/Delete
  get '/register' => "devise/registrations#new", :as =>:new_user_registration
  get '/deleteaccount' => "devise/registrations#cancel", :as => :cancel_user_registration
  post '/register' => "devise/registrations#create", :as => :user_registration
  #User Account Edit
  get '/account/edit' => "devise/registrations#edit", :as => :edit_user_registration
  patch '/account' => "devise/registrations#update"
  put '/account' => "devise/registrations#update"
  delete '/account' => "devise/registrations#destroy"
  #User Account Confirmation
  post '/account/confirm' => "devise/confirmations#create", :as => :user_confirmation
  get '/account/confirm/new' => "devise/confirmations#new", :as => :new_user_confirmation
  get '/account/confirm' => "devise/confirmations#show"

end
  get '/instances/' => 'instances#index'
  get '/api/get/instances' => 'instances#index'
  get '/instance/new' => "instances#new"
  post '/instance/new' => "instances#create"
  get '/' => 'home#index'

  #Paypal Related routes
  post "/hooks" => "instances#hook"

  delete '/instances/' => "instances#destroy"
  post '/instances/restart' => "instances#restart", :as => :restart_instance
  post '/instances/start' => "instances#start", :as => :start_instance
  post '/instances/shutdown' => "instances#shutdown",:as => :shutdown_instance
  post '/instance/renew' => "instances#renew_post",:as => :renew_post_instance
  put '/instance/renew' => "instances#renew_put",:as => :renew_put_instance
  post '/instances/resize' => "instances#resize",:as => :resize_instance
  post '/instances/resize_process' => "instances#resize_process",:as => :resize_process_instance
  get '/instance/renew' => redirect('/instances/')
  get '/instance/' => redirect('/instances/')

  #Support controller
  get '/support/' => redirect('/support/tickets/')
  get '/support/tickets/' => "tickets#index", :status => "open",:as => :view_tickets
  get '/support/tickets/:status' => "tickets#index"
  get '/support/ticket/:ticketid' => "tickets#index",:as => :ticket
  put '/support/ticket/:ticketid' => "tickets#addreply"
  post '/support/tickets/create' => "tickets#create"
  #Pages controller
  get '/help/:name' => "pages#help"
  get '/help/' => redirect('/help/introduction')
  get '/legal/:name' => "pages#subpage",:page => "legal"
  get '/legal/' => redirect('/legal/terms')
  get '/pricing' => "pages#page", :name => "pricing"
  get '/features' => "pages#page", :name => "features"
  get '/contact' => "pages#page", :name => "contact"
  #Networking Domain Records controller
  get '/domains' => "records#index",:as => :domains
  post '/domains' => "records#create"
  get '/domain/:name' => "records#view_domain",:as => :view_domain,:name => /[^\/]+/
  delete 'delete/domain/:name' => "records#delete_domain",:as => :delete_domain,:name=> /[^\/]+/
  root 'home#index'
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

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
