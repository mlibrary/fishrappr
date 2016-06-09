json.set! :@context, 'http://www.shared-canvas.org/ns/context.json'
json.set! :@id, services_manifests_url(@identifier)
json.set! :@type, 'sc:AnnotationsList'

json.resources @data do |datum|
  json.set! :@id, blank_identifier(@identifier, datum[:index], 'anontation')
  json.set! :@type, 'oa:Annotation'
  json.motivation 'sc:Painting'
  json.resource do
    json.set! :@id, blank_identifier(@identifier, datum[:index], 'resource')
    json.set! :@type, "cnt:ContentAsType"
    json.format 'text/plain'
    json.chars datum[:chars]
    json.language 'frm'
  end
  json.on "#{services_manifests_url(@identifier)}/canvas/canvas-1#xywh=#{datum[:HPOS]},#{datum[:VPOS]},#{datum[:WIDTH]},#{datum[:HEIGHT]}"
end
