class Collection < ApplicationRecord
  belongs_to :user
  has_many :collection_recipes, dependent: :destroy
  has_many :recipes, through: :collection_recipes
  
  validates :name, presence: true, length: { minimum: 1, maximum: 100 }
  validates :name, uniqueness: { scope: :user_id, message: "You already have a collection with this name" }
  validates :description, length: { maximum: 500 }, allow_blank: true
  
  scope :public_collections, -> { where(is_public: true) }
  scope :by_user, ->(user) { where(user: user) }
  scope :recent, -> { order(updated_at: :desc) }
  
  # Check if this is the user's favorites collection
  def favorites?
    name.downcase == 'favorites'
  end
  
  # Get recipe count
  def recipe_count
    recipes.count
  end
  
  # Add recipe to collection
  def add_recipe(recipe)
    return false if recipes.include?(recipe)
    
    next_position = collection_recipes.maximum(:position).to_i + 1
    collection_recipes.create(recipe: recipe, position: next_position)
  end
  
  # Remove recipe from collection
  def remove_recipe(recipe)
    collection_recipes.find_by(recipe: recipe)&.destroy
  end
  
  # Check if collection contains recipe
  def contains_recipe?(recipe)
    recipes.include?(recipe)
  end
end
