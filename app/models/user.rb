class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_many :recipes, dependent: :destroy

  # Extract display name from email (e.g., "chef@example.com" becomes "Chef")
  def display_name
    email.split('@').first.capitalize
  end
end
