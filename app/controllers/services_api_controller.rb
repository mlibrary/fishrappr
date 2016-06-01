class ServicesApiController < ApplicationController
  include Blacklight::SearchHelper


  def manifests
    identifier = params[:id]
    response, document = fetch identifier

    response = {}
    response['@context'] = 'http://www.shared-canvas.org/ns/context.json'
    response['@id'] = Rails.application.routes.url_helpers.services_manifests_url(identifier, host: request.host_with_port)
    response['@type'] = 'sc:Manifest'
    response['label'] = 'Page Image'
    response['description'] = '...'
    response['attribution'] = 'Michigan Daily / Bentley Library'

    image_href = "#{Rails.configuration.iiif_service}#{document.fetch('ht_namespace')}.#{document.fetch('ht_barcode')}/#{document.fetch('img_link')}"
    height = document.fetch('image_height_ti')
    width = document.fetch('image_width_ti')
    response['sequences'] = []
    response['sequences'] << {
      '@id' => "#{response['@id']}/normal",
      '@type' => 'sc:Sequence',
      'label' => 'Current page',
      'canvases' => [
        {
          '@id' => "#{response['@id']}/canvas/canvas-1",
          '@type' => "sc:Canvas",
          'label' => 'page image',
          'height' => height,
          'width' => width,
          'images' => [
            {
              '@id' => "#{response['@id']}/imageanno/anno-1",
              '@type' => "oa:Annotation",
              'motivation' => 'sc:painting',
              'resource' => {
                '@id' => image_href,
                '@type' => "dctypes:Image",
                'format' => "image/jpeg",
                'height' => height,
                'width' => width,
                'service' => {
                  '@id' => image_href,
                  '@context' => "http://iiif.io/api/image/2/context.json",
                  'profile' => "http://iiif.io/api/image/2/level1.json"
                }
              },
              "on" => "#{response['@id']}/canvas/canvas-1",
            },
          ],
          'otherContent' => [
            {
              '@id' => "#{Rails.application.routes.url_helpers.services_annotations_url(identifier, host: request.host_with_port)}",
              '@type' => "sc:AnnotationsList"
            }
          ]
        }
      ]
    }

    headers['Access-Control-Allow-Origin'] = '*'
    render json: response
  end

  def annotations
    identifier = params[:id]
    response, document = fetch identifier
    data = JSON.parse(document.fetch('coordinates_data_ssm').first)

    services_manifests_url = Rails.application.routes.url_helpers.services_manifests_url(identifier, host: request.host_with_port)
    
    non_lexemes = Regexp.new("^[^a-zA-Z0-9]+|[^a-zA-Z0-9]+$|'s$")

    response = {}
    response['@context'] = 'http://www.shared-canvas.org/ns/context.json'
    response['@id'] = services_manifests_url
    response['@type'] = 'sc:AnnotationsList'
    response['resources'] = []

    data.keys.each_with_index do |word, i|
      new_word = word.gsub(non_lexemes, '').strip
      next if new_word.empty?
      data[word].each_with_index do |coord, j|
        resource = {}
        resource['@id'] = "_:N#{i}#{j}"
        resource['@type'] = 'oa:Annotation'
        resource['motivation'] = 'sc:painting'
        resource['resource'] = {
          '@id' => "_:NN#{i}#{j}",
          '@type' => "cnt:ContentAsText",
          'format' => "text/plain",
          'chars' => new_word,
          'language' => 'frm'
        }
        resource['on'] = "#{services_manifests_url}/canvas/canvas-1#xywh=#{coord['HPOS']},#{coord['VPOS']},#{coord['WIDTH']},#{coord['HEIGHT']}"
        response['resources'] << resource
      end
    end

    headers['Access-Control-Allow-Origin'] = '*'
    render json: response
    
  end

end
