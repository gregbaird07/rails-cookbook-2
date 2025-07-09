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

  def parse_url
    url = params[:url]
    
    if url.blank?
      render json: { error: 'URL is required' }, status: :bad_request
      return
    end
    
    parsed_data = RecipeUrlParser.parse(url)
    
    if parsed_data
      render json: { success: true, recipe: parsed_data }
    else
      render json: { error: 'Could not parse recipe from this URL. Please try a different recipe website.' }, status: :unprocessable_entity
    end
  rescue => e
    Rails.logger.error "Recipe URL parsing error: #{e.message}"
    render json: { error: 'An error occurred while parsing the recipe URL.' }, status: :internal_server_error
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
