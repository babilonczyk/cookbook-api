class Author < ApplicationRecord
  belongs_to :user
  has_many :recipes, dependent: :destroy

  def featured_recipes
    recipes.where(featured: true)
  end
end
