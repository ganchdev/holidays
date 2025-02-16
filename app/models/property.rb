# frozen_string_literal: true

# == Schema Information
#
# Table name: properties
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  account_id :integer          not null
#
# Indexes
#
#  index_properties_on_account_id  (account_id)
#
class Property < ApplicationRecord

  belongs_to :account

end
