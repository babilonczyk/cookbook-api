class RecipesController < ApplicationController
  def index
    recipes = RecipeResource.all(params)
    
    respond_with(recipes)
  end

  def show
    recipe = RecipeResource.find(params)
    respond_with(recipe)
  end

  def like
    recipe = Recipe.find_by(id: params[:id])
    return render json: { errors: ['Recipe not found'] }, status: :not_found unless recipe

    existing_like = current_user.likes.find_by(recipe: recipe)
    return render json: { errors: ['Recipe already liked'] }, status: :unprocessable_entity if existing_like

    like = current_user.likes.create(recipe: recipe)
    return render json: { errors: ['Recipe can\'t be liked'] }, status: :unprocessable_entity unless like.persisted?

    render json: { message: 'Recipe liked successfully' }, status: :created
  end

  def unlike
    recipe = current_user.liked_recipes.find_by(id: params[:id])
    return render json: { errors: ['Recipe not found'] }, status: :not_found unless recipe

    like = current_user.likes.find_by(recipe: recipe)
    return render json: { errors: ['Recipie wasn\'t liked'] }, status: :not_found unless like

    like.destroy
    render json: { message: 'Recipe unliked successfully' }, status: :ok
  end
end
