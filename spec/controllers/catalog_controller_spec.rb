#catalog_controller_spec.rb

require "rails_helper"

RSpec.describe CatalogController, :type => :controller do

  describe "GET #index" do
    it "responds successfully with an HTTP 200 status code" do
      get :index
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it "renders the index template" do
      get :index
      expect(response).to render_template("index")
    end

    it "populates a @document_list when the search term is in solr" do
      get :index, params: { q: 'rotc', publication: 'the-michigan-daily' }
      expect(response).to be_success
      expect(response).to render_template('catalog/index')
      expect(assigns(:document_list)).to_not be_empty
    end

    it "gets @response from solr" do
      get :index, params: { q: 'rotc', publication: 'the-michigan-daily' }
      expect(response).to be_success
      expect(response).to render_template('catalog/index')
      expect(assigns(:response)).to_not be_empty
    end

    it "return an empty @document_list array when the search term is not in solr" do
     pending "Not sure how to set this up properly, maybe need to use rake?" 
     # get :index, params: { date_filter: 'any', date_issued_begin_dd: '-', date_issued_begin_mm: '-', date_issued_end_dd: '-',  date_issued_end_mm: '-', date_issued_begin_yyyy: '', date_issued_end_yyyy: '', search_field: 'all_fields', q: 'xyyx', controller: 'catalog', action: 'index', publication: 'the-michigan-daily' }      
     #  expect(assigns(:document_list)).to match_array([])
    end

    it "includes response with responseHeader and response when search term is not found" do
      get :index, params: { q: 'rotc', publication: 'the-michigan-daily' }
      expect(response).to be_success
      expect(assigns(:response)).to include( :responseHeader )
      expect(assigns(:response)).to include( :response )
    end

    # it "includes response with numFound zero when search term is not found" do
    #   get :index, params: { q: 'xyyx', publication: 'the-michigan-daily' }
    #   expect(response).to be_success
    #   expect(assigns(:response)).to include( :responseHeader )
    #   expect(assigns(:response)).to_not include(  { :response => :numFound } )
    # end

  end #index



  describe "GET #home" do
    it "responds successfully with an HTTP 200 status code" do
      get :home
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it "renders the home template" do
      get :home
      expect(response).to render_template("home")
    end
  end #home

  describe "GET #browse" do
    it "responds successfully with an HTTP 200 status code" do
      get :browse
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it "renders the browse template" do
      get :browse
      expect(response).to render_template("browse")
    end
  end #browse

end