Rails.application.routes.draw do

  concern :searchable, Blacklight::Routes::Searchable.new

  root to: redirect("/#{Settings.default_publication}")

  resource :search, only: [:index], controller: 'catalog', as: 'catalog' do
    concerns :searchable
  end

  get '/browse' => 'catalog#browse', as: :browse

  if true

    constraints = { volume_identifier: /[^\/]+/, volume_sequence: /\d+/ }

    # --- this is of minimal use
    # get '/:publication/:volume_identifier' => 'catalog#volume',
    #   constraints: constraints

    get '/:publication/:volume_identifier/:volume_sequence' => 'catalog#show',
      constraints: constraints

    post '/:publication/:volume_identifier/:volume_sequence/toggle_highlight' => 'catalog#toggle_highlight',
      constraints: constraints #, as: :toggle_highlight_solr_document

    get '/:publication/:volume_identifier/:volume_sequence/download_issue_text' => 'catalog#download_issue_text',
      constraints: constraints #, as: :download_issue_text_solr_document

    get '/:publication/:volume_identifier/:volume_sequence/download_text' => 'catalog#download_text',
      constraints: constraints #, as: :download_text_solr_document

    get '/:publication/:volume_identifier/:volume_sequence/issue_data' => 'catalog#issue_data',
      constraints: constraints #, as: :issue_data_solr_document

  end

  if false
    resources :solr_documents, only: [:show], path: '/pages', controller: 'catalog',
      constraints: { id: /[^\/]+/ }  do
      member do
        post 'toggle_highlight'
        get 'download_text'
        get 'download_issue_text'
        get 'issue_data'
      end
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