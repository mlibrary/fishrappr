json.set! :@context, 'http://www.shared-canvas.org/ns/context.json'
json.set! :@id, services_manifests_url(@identifier)
json.set! :@type, 'sc:Manifest'
json.label "#{@document.fetch('publication_label')} - #{@document.fetch('date_issued_display').first} - #{@document.fetch('sequence')}"
json.description 'Page Image'
json.attribution 'Michigan Daily / Bentley Library'

json.sequences Jbuilder.new.array!(['']) do |sequence|
  json.set! :@id, "#{@identifier}/normal"
  json.set! :@type, 'sc:Sequence'
  json.label "#{@document.fetch('sequence')}"
  json.canvases Jbuilder.new.array!(['']) do |canvas|
    json.set! :@id, "#{@identifier}/canvas/canvas-1"
    json.set! :@type, 'sc:Canvas'
    json.label 'page image'
    json.height @document.fetch('image_height_ti')
    json.width @document.fetch('image_width_ti')
    json.images Jbuilder.new.array!(['']) do |image|
      json.set! :@id, "#{@identifier}/imageanno/anno-1"
      json.set! :@type, 'sc:Annotation'
      json.motivation 'sc:Painting'
      json.resource do
        json.set! :@id, hathitrust_image_src(@document)
        json.set! :@type, 'dctypes:Image'
        json.format 'image/jpeg'
        json.height @document.fetch('image_height_ti')
        json.width @document.fetch('image_width_ti')
        json.service do
          json.set! :@id, hathitrust_image_src(@document)
          json.set! :@context, "http://iiif.io/api/image/2/context.json"
          json.profile "http://iiif.io/api/image/2/level1.json"
        end
        json.on "#{@identifier}/canvas/canvas-1"
      end
    end
    json.otherContent Jbuilder.new.array!(['']) do
      json.set! :@id, services_annotations_url(@identifier)
      json.set! :@type, 'sc:AnnotationsList'
    end
  end

end
