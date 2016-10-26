Rails.application.routes.draw do

  concern :searchable, Blacklight::Routes::Searchable.new

  root to: redirect("/#{Settings.default_publication}")

  resource :search, only: [:index], controller: 'catalog', as: 'catalog' do
    concerns :searchable
  end

  get '/browse' => 'catalog#browse', as: :browse
  get '/search' => 'catalog#search', as: :search

  resources :solr_documents, only: [:show], path: '/pages', controller: 'catalog',
    constraints: { id: /[^\/]+/ }  do
    member do
      post 'toggle_highlight'
      get 'download_text'
      get 'download_issue_text'
      get 'issue_data'
    end
  end

  match '/contacts', to: 'contacts#new', via: 'get'
  resources "contacts", only: [:new, :create]

  post 'static/search' => 'static#search'

  get 'static/:action' => 'static', as: :static

  get 'services/manifests/:id'  => 'services_api#manifests', as: :services_manifests, format: false, defaults: { format: :json }
  get 'services/annotations/:id' => 'services_api#annotations', as: :services_annotations, format: false, defaults: { format: :json }
  get 'services/coords/:id' => 'services_api#coords', as: :services_coords, format: false, defaults: { format: :json }

  get '/:publication', to: 'catalog#home', as: 'publication_home'

end