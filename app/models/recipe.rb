class Recipe < ApplicationRecord
  belongs_to :user
  has_many :reviews, dependent: :destroy
  has_many :collection_recipes, dependent: :destroy
  has_many :collections, through: :collection_recipes
  
  validates :title, presence: true, length: { minimum: 3, maximum: 100 }
  validates :description, presence: true, length: { minimum: 10, maximum: 500 }
  validates :ingredients, presence: true, length: { minimum: 10 }
  validates :instructions, presence: true, length: { minimum: 20 }
  validates :prep_time, presence: true, numericality: { greater_than: 0 }
  validates :cook_time, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :servings, presence: true, numericality: { greater_than: 0 }
  
  # Calculate average rating
  def average_rating
    return 0 if reviews.empty?
    reviews.average(:rating).round(1)
  end
  
  # Get total number of reviews
  def total_reviews
    reviews.count
  end
  
  # Check if a user has already reviewed this recipe
  def reviewed_by?(user)
    return false unless user
    reviews.exists?(user: user)
  end
  
  # Get review by specific user
  def review_by(user)
    return nil unless user
    reviews.find_by(user: user)
  end
  
  # Get rating distribution
  def rating_distribution
    distribution = Hash.new(0)
    reviews.group(:rating).count.each { |rating, count| distribution[rating] = count }
    (1..5).each { |rating| distribution[rating] ||= 0 }
    distribution
  end
  
  # Get percentage of 5-star reviews
  def five_star_percentage
    return 0 if reviews.empty?
    (reviews.where(rating: 5).count.to_f / reviews.count * 100).round(1)
  end
  
  # Get total number of times this recipe has been added to collections
  def total_saves
    collection_recipes.count
  end
  
  # Get total number of times this recipe has been favorited
  def total_favorites
    collections.joins(:user).where(collections: { name: 'Favorites' }).count
  end
end
