class ServicesApiController < ApplicationController
  include Blacklight::SearchContext


  def manifests
    @identifier = params[:id]
    @response, @document = fetch @identifier
    
    headers['Access-Control-Allow-Origin'] = '*'
  end

  def annotations
    @identifier = params[:id]
    @response, @document = fetch @identifier
    coordinates_data = JSON.parse(@document.fetch('coordinates_data_ssm').first)
    @data = []

    non_lexemes = Regexp.new("^[^a-zA-Z0-9]+|[^a-zA-Z0-9]+$|'s$")
    coordinates_data.keys.each_with_index do |word, i|
      new_word = word.gsub(non_lexemes, '').strip
      next if new_word.empty?
      coordinates_data[word].each_with_index do |coord, j|
        @data << {
          # id: "_:N#{i}#{j}",
          index: "#{i}.#{j}",
          chars: new_word,          
          HPOS: coord[0],
          VPOS: coord[1],
          WIDTH: coord[2],
          HEIGHT: coord[3],
        }
      end
    end

    headers['Access-Control-Allow-Origin'] = '*'
    # render json: response
  
  end

  def coords
    @identifier = params[:id]
    @response, @document = fetch @identifier
    coordinates_data = JSON.parse(@document.fetch('coordinates_data_ssm').first)

    @data = {}
    @data['height'] = @document.fetch('image_height_ti')
    @data['width'] = @document.fetch('image_width_ti')

    @data['coords'] = {}

    non_lexemes = Regexp.new("^[^a-zA-Z0-9]+|[^a-zA-Z0-9]+$|'s$")
    coordinates_data.keys.each_with_index do |word, i|
      new_word = word.gsub(non_lexemes, '').strip
      next if new_word.empty?
      @data['coords'][new_word] = [] unless @data['coords'][new_word]
      coordinates_data[word].each_with_index do |coord, j|
        @data['coords'][new_word] << coord
      end
    end

    headers['Access-Control-Allow-Origin'] = '*'
    render json: @data
  end
end
