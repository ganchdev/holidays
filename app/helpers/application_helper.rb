# frozen_string_literal: true

module ApplicationHelper

  include OcticonsHelper

  alias icon octicon

  # rubocop:disable Style/OptionalArguments
  def button_to_with_icon(name = nil, path, icon_name, icon_options: {}, **html_options)
    button_to path, **html_options do
      concat(icon(icon_name, **icon_options))
      concat(" ")
      concat(content_tag(:span, name))
    end
  end

  def link_to_with_icon(name = nil, path, icon_name, icon_options: {}, **html_options)
    link_to path, **html_options do
      concat(icon(icon_name, **icon_options))
      concat(" ")
      concat(name)
    end
  end
  # rubocop:enable Style/OptionalArguments

  def form_errors(object)
    return unless object.errors.any?

    content_tag(:div, class: "form-errors") do
      content_tag(:ul) do
        object.errors.full_messages.map do |message|
          content_tag(:li, message)
        end.join.html_safe
      end
    end
  end

  def render_nav(title: nil, back_url: nil, &block)
    menu_content = capture(&block) if block_given?

    nav_partial = render(
      partial: "layouts/nav",
      locals: {
        title: title,
        back_url: back_url,
        menu_content: menu_content
      }
    )

    nav_partial.html_safe
  end

  def room_badge(room)
    content_tag :span, room.name, class: "badge", style: "background-color: #{room.color}"
  end

end
