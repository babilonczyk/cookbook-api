class UserResource < ApplicationResource
  attribute :email, :string
  attribute :created_at, :datetime

  has_many :likes
  has_one :author
end