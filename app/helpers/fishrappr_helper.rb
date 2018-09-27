module FishrapprHelper

  def fishrappr_render(partial)
    # render partial: "#{@publication['slug']}/static/#{partial}"
    # render partial: "publications/#{@publication['slug']}/views/static/#{partial}"
    render "publications/#{@publication['slug']}/views/static/#{partial}"
  end

    def fishrappr_path(partial)
    #render partial: "#{@publication['slug']}/static/#{partial}"
    url_for("/#{@publication['slug']}/#{partial}")
  end

end
