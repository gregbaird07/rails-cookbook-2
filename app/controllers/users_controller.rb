class UsersController < ApplicationController
  before_action :set_user, only: [:show]

  def show
    @recipes = @user.recipes.order(created_at: :desc).limit(12)
    @total_recipes = @user.recipes.count
  end

  private

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "User not found."
  end
end
