module ApplicationHelper
  def markdown(text)
    renderer = Redcarpet::Render::XHTML.new()
    markdown = Redcarpet::Markdown.new(renderer)
    markdown.render(text).html_safe
  end

  def airline_logo(airline, size = :large)
    if airline.nil?
      image_tag image_path("airlines/logos/#{size}/missing.png"),
                alt:   'No Airline',
                class: 'airline-logo'
    else
      image_tag airline.logo.url(size),
                alt:   airline.name,
                title: airline.name,
                class: 'airline-logo'
    end
  end

  def flag_image(country, size = 64)
    if country.is_a?(Country)
      c = country
    else
      country = country.downcase # can't use downcase! when the string is frozen
      country = 'gb' if country == 'uk'
      c = Country.new(country.upcase)
    end
    image_tag "flags/#{size}/#{c.alpha2.downcase}.png",
              alt:   c.name,
              title: c.name,
              class: 'flag'
  end

  def alliance_logo(alliance, size = :large)
    return nil if alliance.blank?
    name = (Airline::ALLIANCES[alliance.to_sym] rescue alliance.titleize)
    image_tag "alliances/#{size}/#{alliance.downcase}.png",
              alt:   name,
              title: name,
              class: 'alliance-logo'
  end

  def social_login_button(provider, template)
    link_to t(template, provider: provider.to_s.titleize),
            omniauth_authorize_path(:user, provider),
            class: "btn social #{provider}"
  end

  # Eventually maybe support locale formatting
  def format_time(time)
    return nil if time.nil?
    time.strftime('%H:%M')
  end

  # Eventually maybe support locale formatting
  def format_date(date)
    return nil if date.nil?
    l date, format: :medium
  end

  # Hardcoded to km
  # Ex) 3,456 km
  def format_distance(distance, style = :long)
    return nil if distance.nil?
    if style == :short
      # 934267 => 934k
      s = number_to_human(distance, units: { thousand: 'k', million: 'm' }).sub(/\s/, '')
    else
      s = number_with_delimiter(distance)
    end
    "#{s} km"
  end

  def format_duration(seconds, style = :short)
    change = Duration.new(seconds: seconds)
    time_label = case
                 when change.total < 3600 then 'minutes'
                 when change.total % 3600 != 0 then'hours_minutes'
      else 'hours'
    end
    time_label = "duration.formats.#{time_label}.#{style}"
    change.format(I18n.t(time_label))
  end

  def icon_link(link_text, link_path, icon_name, link_options = {})
    content_tag(:a, link_options.merge(href: link_path)) do
      content_tag(:i, '', class: "fa fa-#{icon_name}") + ' ' + content_tag(:span, link_text)
    end
  end

  def auto_active_nav_link(link_text, link_path, link_options = {})
    classes = []
    classes.push 'active' if link_path == request.fullpath
    content_tag(:li, class: classes.join(' ')) do
      link_to(link_text, link_path, link_options)
    end
  end

  def error_messages(model = nil)
    model ||= resource
    return nil if model.errors.empty?
    content_tag(:ul, class: 'form-errors alert alert-danger') do
      model.errors.full_messages.collect { |msg| concat(content_tag(:li, msg)) }
    end
  end
end
