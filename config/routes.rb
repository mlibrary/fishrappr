Rails.application.routes.draw do

  # concern :range_searchable, BlacklightRangeLimit::Routes::RangeSearchable.new
  # get 'pub/:publication_link/:ht_barcode/:date_issued_link/:sequence' => 'catalog#show', as: :in_context

  # mount Blacklight::Engine => '/'
  # mount BlacklightAdvancedSearch::Engine => '/'

  # root to: "catalog#index"
  root to: "catalog#home"
  concern :searchable, Blacklight::Routes::Searchable.new


  resource :catalog, only: [:index], as: 'catalog', path: '/search', controller: 'catalog' do
    concerns :searchable
    ## concerns :range_searchable

  end

  # devise_for :users
  # concern :exportable, Blacklight::Routes::Exportable.new

  # resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
  #   concerns :exportable
  # end

  resources :solr_documents, only: [:show], path: '/view', controller: 'catalog',
    constraints: { id: /[^\/]+/ }  do
    member do
      post 'toggle_highlight'
      get 'download_text'
      get 'download_issue_text'
      get 'issue_data'
    end

  end

  # resources :bookmarks do
  #   concerns :exportable

  #   collection do
  #     delete 'clear'
  #   end
  # end

  match '/contacts', to: 'contacts#new', via: 'get'
  resources "contacts", only: [:new, :create]

  post 'static/search' => 'static#search'
  
  get '/home' => 'catalog#home'

  get '/browse' => 'catalog#browse', as: :browse

  get 'static/:action' => 'static', as: :static

  get 'services/manifests/:id'  => 'services_api#manifests', as: :services_manifests, format: false, defaults: { format: :json }
  get 'services/annotations/:id' => 'services_api#annotations', as: :services_annotations, format: false, defaults: { format: :json }
  get 'services/coords/:id' => 'services_api#coords', as: :services_coords, format: false, defaults: { format: :json }


end