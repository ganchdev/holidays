# frozen_string_literal: true

module ApplicationHelper

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

end
