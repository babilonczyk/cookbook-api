class User < ApplicationRecord
  before_create :generate_token

  has_one :author, dependent: :destroy
  has_many :likes
  has_many :liked_recipes, through: :likes, source: :recipe
    
  def generate_token
    self.token = SecureRandom.hex
  end
end
