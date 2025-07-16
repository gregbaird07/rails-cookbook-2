class FavoritesController < ApplicationController
  before_action :authenticate_user!
  
  def toggle
    @recipe = Recipe.find(params[:recipe_id])
    
    if current_user.favorited?(@recipe)
      current_user.remove_from_favorites(@recipe)
      @favorited = false
      @message = "Recipe removed from favorites."
    else
      current_user.add_to_favorites(@recipe)
      @favorited = true
      @message = "Recipe added to favorites!"
    end
    
    respond_to do |format|
      format.html { redirect_back(fallback_location: @recipe, notice: @message) }
      format.turbo_stream
      format.json { render json: { favorited: @favorited, message: @message } }
    end
  end
end
