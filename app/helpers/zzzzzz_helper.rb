module ZzzzzzHelper

  # def presenter(document)
  #   STDERR.puts "AHOY AHOY AHOY #{action_name}"
  #   case action_name
  #   when 'show', 'citation'
  #     show_presenter(document)
  #   when 'index', 'browse'
  #     index_presenter(document)
  #   else
  #     Deprecation.warn(Blacklight::BlacklightHelperBehavior, "Unable to determine presenter type for #{action_name} on #{controller_name}, falling back on deprecated Blacklight::DocumentPresenter")
  #     presenter_class.new(document, self)
  #   end
  # end

  def document_index_view_type query_params=params
    if query_params["action"] == 'browse'
      :grid
    else
      default_document_index_view_type
    end
  end


end