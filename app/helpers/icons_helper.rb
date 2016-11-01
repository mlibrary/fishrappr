module IconsHelper

  def icon_class(classes, options={})
    # all_classes = ['mdi']
    # all_classes.concat classes.split.each.map { |name| "mdi-#{name}" }
    # all_classes.concat Array(options.delete(:class))
    all_classes = []
    all_classes.concat classes.split.each.map { |name| "icon_#{name}" }
    all_classes = all_classes.join(' ')
    unless all_classes.index('px')
      all_classes += " icon_16px"
    end
    all_classes
  end

  def icon_tag(classes, options={})
    all_classes = icon_class(classes, options)
    content_tag(:i, nil, class: all_classes, 'aria-hidden': 'true')
  end

  def use_icon(key, options={})
    icon_tag("#{Settings.icons[key]}", options)
  end

  def use_icon_class(key)
    icon_class("#{Settings.icons[key]}")
  end

  # def icon_label(key)
  #   "#{use_icon(key)} #{raw(t('views.issue.zoom_out')}".html_safe
  # end


end