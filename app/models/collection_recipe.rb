class CollectionRecipe < ApplicationRecord
  belongs_to :collection
  belongs_to :recipe
  
  validates :collection_id, uniqueness: { scope: :recipe_id, message: "Recipe already in this collection" }
  
  scope :ordered, -> { order(:position) }
  
  # Set position before creation
  before_create :set_position
  
  private
  
  def set_position
    self.position ||= (collection.collection_recipes.maximum(:position) || 0) + 1
  end
end
