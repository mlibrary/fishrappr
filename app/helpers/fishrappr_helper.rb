module FishrapprHelper

  def fishrappr_render(partial)
    render partial: "publications/#{@publication['slug']}/static/#{partial}"
  end
 end
