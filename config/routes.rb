Rails.application.routes.draw do

  concern :searchable, Blacklight::Routes::Searchable.new

  root to: redirect("/#{Settings.default_publication}")

  resource :search, only: [:index], controller: 'catalog', as: 'catalog' do
    concerns :searchable
  end

  # scope ":publication" do
  #   resource :search, only: [:index], controller: 'catalog', as: 'catalog' do
  #     concerns :searchable
  #   end
  # end
  
  # get '/browse' => 'catalog#browse', as: :browse
  # get '/search' => 'catalog#search', as: :

  get '/:publication/browse' => 'catalog#browse', as: :browse
  get '/:publication/search' => 'catalog#index', as: :search
  
  get '/browse', to: redirect { |params, request| "/midaily/browse?#{request.params.to_query}" }
  get '/search', to: redirect { |params, request| "/midaily/search?#{request.params.to_query}" }

  devise_for :users, path: '', path_names: {sign_in: 'login', sign_out: 'logout'}, controllers: {sessions: 'sessions'}
  get '/logout_now', to: 'sessions#logout_now'
  get '/go_back', to: 'sessions#go_back'
  get '/login_info', to: 'sessions#login_info'
  
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

  # redirect old static links for daily to new daily locations
  get '/static/donors', to: redirect('/midaily/donors')
  get '/static/about_project', to: redirect('/midaily/project')
  get '/static/daily_about', to: redirect('/midaily/about')
  get '/static/rights', to: redirect('/midaily/rights')
  get '/static/about_daily', to: redirect('/midaily/project')

  get '/static/how_to_search', to: redirect('/midaily/how_to_search')
  get '/static/using_page_viewer', to: redirect('/midaily/using_page_viewer')

  post 'static/search' => 'static#search'

  get '/:publication/:page', to: 'static#show'

  #get 'static/:action' => 'static', as: :static

  get 'services/manifests/:id'  => 'services_api#manifests', as: :services_manifests, format: false, defaults: { format: :json }
  get 'services/annotations/:id' => 'services_api#annotations', as: :services_annotations, format: false, defaults: { format: :json }
  get 'services/coords/:id' => 'services_api#coords', as: :services_coords, format: false, defaults: { format: :json }

  get '/:publication', to: 'catalog#home', as: 'publication_home'

end
