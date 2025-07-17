class RecipesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_recipe, only: [:show, :edit, :update, :destroy]
  before_action :check_owner, only: [:edit, :update, :destroy]

  def index
    @recipes = Recipe.includes(:user, :reviews).all
    @recipes = @recipes.where(user_id: params[:user]) if params[:user].present?
    
    # Sort by different criteria
    case params[:sort]
    when 'rating'
      @recipes = @recipes.left_joins(:reviews)
                        .group('recipes.id')
                        .order(Arel.sql('AVG(reviews.rating) DESC NULLS LAST, recipes.created_at DESC'))
    when 'reviews'
      @recipes = @recipes.left_joins(:reviews)
                        .group('recipes.id')
                        .order(Arel.sql('COUNT(reviews.id) DESC, recipes.created_at DESC'))
    else
      @recipes = @recipes.order(created_at: :desc)
    end
  end

  def show
    @reviews = @recipe.reviews.includes(:user).recent
    @review = Review.new if user_signed_in? && !@recipe.reviewed_by?(current_user)
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
    Rails.logger.info "=== PARSE_URL ACTION CALLED ==="
    Rails.logger.info "Request method: #{request.method}"
    Rails.logger.info "Content type: #{request.content_type}"
    Rails.logger.info "Params: #{params.inspect}"
    Rails.logger.info "Headers: X-CSRF-Token = #{request.headers['X-CSRF-Token']}"
    Rails.logger.info "Headers: X-Requested-With = #{request.headers['X-Requested-With']}"
    Rails.logger.info "Authenticity token valid? #{verified_request?}"
    
    # Handle both JSON and form data
    url = params[:url]
    
    if url.blank?
      Rails.logger.error "URL parameter is blank"
      render json: { error: 'URL is required' }, status: :bad_request
      return
    end
    
    Rails.logger.info "About to call RecipeUrlParser.parse with URL: #{url}"
    
    begin
      parsed_data = RecipeUrlParser.parse(url)
      Rails.logger.info "RecipeUrlParser returned: #{parsed_data.inspect}"
    rescue => e
      Rails.logger.error "RecipeUrlParser raised exception: #{e.message}"
      Rails.logger.error "Backtrace: #{e.backtrace.first(3).join(', ')}"
      parsed_data = nil
    end
    
    if parsed_data
      render json: { success: true, recipe: parsed_data }
    else
      # Check if it's a known site that blocks automated access
      domain = URI.parse(url).host.downcase rescue ""
      
      if domain.include?('maangchi.com')
        guide = RecipeSiteHelpers.manual_extraction_guide(url)
        error_message = "#{guide[:site_name]} blocks automated requests. Please manually copy the recipe details from the page."
        render json: { 
          error: error_message,
          manual_guide: guide
        }, status: :unprocessable_entity
      else
        error_message = 'Could not parse recipe from this URL. This may be due to bot protection or an unsupported website format. Supported sites include Food.com, AllRecipes, Taste of Home, etc.'
        render json: { error: error_message }, status: :unprocessable_entity
      end
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
