module IconsHelper
  def icon_tag(classes, options={})
    all_classes = ['mdi']
    all_classes.concat classes.split.each.map { |name| "mdi-#{name}" }
    all_classes.concat Array(options.delete(:class))
    content_tag(:i, nil, class: all_classes.join(' '))
  end

  def use_icon(key)
    icon_tag("#{Settings.icons[key]} 20px")
  end

  # def icon_label(key)
  #   "#{use_icon(key)} #{raw(t('views.issue.zoom_out')}".html_safe
  # end


end