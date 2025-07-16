class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_recipe, only: [:create]
  before_action :set_review, only: [:destroy]

  def create
    @review = @recipe.reviews.build(review_params)
    @review.user = current_user
    
    if @review.save
      redirect_to @recipe, notice: 'Review was successfully added.'
    else
      redirect_to @recipe, alert: "Error adding review: #{@review.errors.full_messages.join(', ')}"
    end
  end

  def destroy
    @recipe = @review.recipe
    if @review.user == current_user || @recipe.user == current_user
      @review.destroy
      redirect_to @recipe, notice: 'Review was successfully deleted.'
    else
      redirect_to @recipe, alert: 'You can only delete your own reviews.'
    end
  end

  private

  def set_recipe
    @recipe = Recipe.find(params[:recipe_id])
  end
  
  def set_review
    @review = Review.find(params[:id])
  end

  def review_params
    params.require(:review).permit(:rating, :comment)
  end
end
