class Review < ApplicationRecord
  belongs_to :recipe
  belongs_to :user
  
  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :comment, presence: true, length: { minimum: 10, maximum: 1000 }
  validates :user_id, uniqueness: { scope: :recipe_id, message: "You can only review a recipe once" }
  
  scope :by_rating, ->(rating) { where(rating: rating) }
  scope :recent, -> { order(created_at: :desc) }
end
