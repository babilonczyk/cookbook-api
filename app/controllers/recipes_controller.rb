class RecipesController < ApplicationController
  FEATURE_LIMIT = 3
  public_constant :FEATURE_LIMIT

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
    return render json: { errors: ['Recipe wasn\'t liked'] }, status: :not_found unless like

    like.destroy
    render json: { message: 'Recipe unliked successfully' }, status: :ok
  end

  def feature
    recipe = Recipe.find_by(id: params[:id])
    return render json: { errors: ['Recipe not found'] }, status: :not_found unless recipe

    author = current_user.author

    if recipe.author != author
      return render json: { errors: ['You are not the author of this recipe'] },
                    status: :forbidden
    end

    featured_recipes = author.featured_recipes
    if featured_recipes.count >= FEATURE_LIMIT
      return render json: { errors: ['You have reached the feature limit'] },
                    status: :forbidden
    end

    if featured_recipes.include?(recipe)
      return render json: { errors: ['Recipe already featured'] }, status: :unprocessable_entity
    end

    top_recipes = author.recipes
                        .left_joins(:likes)
                        .group('recipes.id')
                        .order('COUNT(likes.id) DESC')
                        .limit(10)

    unless top_recipes.include?(recipe)
      return render json: { errors: ['Recipe is not in the top 10'] },
                    status: :forbidden
    end

    unless recipe.update(featured: true)
      return render json: { errors: ['Recipe can\'t be featured'] },
                    status: :unprocessable_entity
    end

    render json: { message: 'Recipe featured successfully' }, status: :created
  end

  def unfeature
    author = current_user.author

    recipe = Recipe.find_by(id: params[:id])
    return render json: { errors: ['Recipe not found'] }, status: :not_found unless recipe

    if recipe.featured == false
      return render json: { errors: ['Recipe is not featured'] }, status: :unprocessable_entity
    end

    if recipe.author != author
      return render json: { errors: ['You are not the author of this recipe'] },
                    status: :forbidden
    end

    unless recipe.update(featured: false)
      return render json: { errors: ['Recipe can\'t be unfeatured'] },
                    status: :unprocessable_entity
    end

    render json: { message: 'Recipe unfeatured successfully' }, status: :ok
  end
end
