class RecipeResource < ApplicationResource  
  attribute :title, :string
  attribute :text, :string
  attribute :difficulty, :string
  attribute :likes_count, :integer
  attribute :preparation_time, :integer
  attribute :created_at, :datetime

  belongs_to :author
  many_to_many :categories
  has_many :likes

  def likes_count
    @object.likes_count
  end

  filter :liked_by_user_ids, :integer do
    eq do |scope, user_ids|
      scope.joins(:likes).where(likes: { user_id: user_ids })
    end
  end
end
