class LikeResource < ApplicationResource
  attribute :created_at, :datetime

  belongs_to :user
  belongs_to :recipe
end