# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes

  attribute :account
  attribute :session
  delegate :user, to: :session, allow_nil: true

end
