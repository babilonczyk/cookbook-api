class AuthorsController < ApplicationController
  def index
    authors = AuthorResource.all(params)
    respond_with(authors)
  end

  def show
    author = AuthorResource.find(params)
    respond_with(author)
  end

  def recipe_stats
    timeframe = params[:group_by] || 'month'

    author = Author.find_by(id: params[:id])
    return render json: { errors: ['Author not found'] }, status: :not_found unless author

    data = RecipeManagement::StatsService.new.call(recipes: author.recipes, timeframe: timeframe)
    return render json: { errors: [data[:error]] }, status: :unprocessable_entity if data[:error]

    render json: { data: data[:stats] }, status: :ok
  end
end
