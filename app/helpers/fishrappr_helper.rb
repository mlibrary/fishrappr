module FishrapprHelper

  def fishrappr_render(partial)
    render partial: "static/#{@publication['slug']}/#{partial}"
  end
 end
