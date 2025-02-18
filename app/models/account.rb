# frozen_string_literal: true

# == Schema Information
#
# Table name: accounts
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Account < ApplicationRecord

  has_many :users
  has_many :properties

  validates :name, presence: true, uniqueness: true

end
