class Recipe < ApplicationRecord
  belongs_to :user
  
  validates :title, presence: true, length: { minimum: 3, maximum: 100 }
  validates :description, presence: true, length: { minimum: 10, maximum: 500 }
  validates :ingredients, presence: true, length: { minimum: 10 }
  validates :instructions, presence: true, length: { minimum: 20 }
  validates :prep_time, presence: true, numericality: { greater_than: 0 }
  validates :cook_time, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :servings, presence: true, numericality: { greater_than: 0 }
end
