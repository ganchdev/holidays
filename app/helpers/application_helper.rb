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

end
