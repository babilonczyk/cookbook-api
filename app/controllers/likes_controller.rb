class LikesController < ApplicationController
  def index
    likes = LikeResource.all(params)
    respond_with(likes)
  end
end
