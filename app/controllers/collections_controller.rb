class CollectionsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_collection, only: [:show, :edit, :update, :destroy, :add_recipe, :remove_recipe]
  before_action :check_owner, only: [:edit, :update, :destroy]
  before_action :check_access, only: [:show]

  def index
    if params[:user_id]
      @user = User.find(params[:user_id])
      @collections = @user.collections.includes(:user, :recipes)
      @collections = @collections.public_collections unless user_signed_in? && @user == current_user
    else
      @collections = Collection.public_collections.includes(:user, :recipes)
    end
    
    @collections = @collections.recent
  end

  def show
    @recipes = @collection.recipes.includes(:user, :reviews).order('collection_recipes.position')
  end

  def new
    @collection = current_user.collections.build
  end

  def create
    @collection = current_user.collections.build(collection_params)
    
    if @collection.save
      redirect_to @collection, notice: 'Collection was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @collection.update(collection_params)
      redirect_to @collection, notice: 'Collection was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @collection.destroy
    redirect_to collections_path, notice: 'Collection was successfully deleted.'
  end

  def add_recipe
    @recipe = Recipe.find(params[:recipe_id])
    
    if @collection.add_recipe(@recipe)
      @success = true
      @message = "Recipe added to #{@collection.name}!"
    else
      @success = false
      @message = "Recipe is already in #{@collection.name}."
    end
    
    respond_to do |format|
      format.html { redirect_to @recipe, notice: @message }
      format.turbo_stream
      format.json { render json: { success: @success, message: @message } }
    end
  end

  def remove_recipe
    @recipe = Recipe.find(params[:recipe_id])
    
    if @collection.remove_recipe(@recipe)
      redirect_back(fallback_location: @collection, notice: "Recipe removed from #{@collection.name}.")
    else
      redirect_back(fallback_location: @collection, alert: "Recipe not found in collection.")
    end
  end

  private

  def set_collection
    @collection = Collection.find(params[:id])
  end
  
  def check_owner
    redirect_to collections_path, alert: 'You can only edit your own collections.' unless @collection.user == current_user
  end
  
  def check_access
    # Allow access if collection is public or user owns it
    unless @collection.is_public || (user_signed_in? && @collection.user == current_user)
      redirect_to collections_path, alert: 'This collection is private.'
    end
  end

  def collection_params
    params.require(:collection).permit(:name, :description, :is_public)
  end
end
