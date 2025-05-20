class AddFeaturedToRecipes < ActiveRecord::Migration[7.0]
  def change
    add_column :recipes, :featured, :boolean, default: false, null: false
  end
end
