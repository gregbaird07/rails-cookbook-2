class RecipesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_recipe, only: [:show, :edit, :update, :destroy]
  before_action :check_owner, only: [:edit, :update, :destroy]

  def index
    @recipes = Recipe.includes(:user).all
    @recipes = @recipes.where(user_id: params[:user]) if params[:user].present?
    @recipes = @recipes.order(created_at: :desc)
  end

  def show
  end

  def new
    @recipe = current_user.recipes.build
  end

  def create
    @recipe = current_user.recipes.build(recipe_params)
    
    if @recipe.save
      redirect_to @recipe, notice: 'Recipe was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @recipe.update(recipe_params)
      redirect_to @recipe, notice: 'Recipe was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @recipe.destroy
    redirect_to recipes_path, notice: 'Recipe was successfully deleted.'
  end

  private

  def set_recipe
    @recipe = Recipe.find(params[:id])
  end

  def check_owner
    redirect_to recipes_path, alert: 'You can only edit your own recipes.' unless @recipe.user == current_user
  end

  def recipe_params
    params.require(:recipe).permit(:title, :description, :ingredients, :instructions, :prep_time, :cook_time, :servings)
  end
end
