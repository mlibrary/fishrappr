Rails.application.routes.draw do

  # concern :range_searchable, BlacklightRangeLimit::Routes::RangeSearchable.new
  # get 'pub/:publication_link/:ht_barcode/:date_issued_link/:sequence' => 'catalog#show', as: :in_context

  mount Blacklight::Engine => '/'
  mount BlacklightAdvancedSearch::Engine => '/'

  # root to: "catalog#index"
  root to: "catalog#home"
  concern :searchable, Blacklight::Routes::Searchable.new


  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
    ## concerns :range_searchable

  end

  devise_for :users
  concern :exportable, Blacklight::Routes::Exportable.new

  # resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
  #   concerns :exportable
  # end

  resources :solr_documents, only: [:show], path: '/view', controller: 'catalog' do
    concerns :exportable
    member do
      post 'toggle_highlight'
      get 'download_text'
      get 'download_issue_text'
      get 'issue_data'
    end

  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  match '/contacts', to: 'contacts#new', via: 'get'
  resources "contacts", only: [:new, :create]

  post 'static/search' => 'static#search'
  
  get '/home' => 'catalog#home'

  get '/browse' => 'catalog#browse'

  get 'static/:action' => 'static', as: :static

  get 'services/manifests/:id'  => 'services_api#manifests', as: :services_manifests, format: false, defaults: { format: :json }
  get 'services/annotations/:id' => 'services_api#annotations', as: :services_annotations, format: false, defaults: { format: :json }
  get 'services/coords/:id' => 'services_api#coords', as: :services_coords, format: false, defaults: { format: :json }

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