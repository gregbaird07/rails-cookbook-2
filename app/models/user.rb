class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_many :recipes, dependent: :destroy

  # Validations
  validates :username, uniqueness: { case_sensitive: false }, 
                      allow_blank: true,
                      format: { with: /\A[a-zA-Z0-9_]+\z/, message: "can only contain letters, numbers, and underscores" },
                      length: { in: 3..20 }
  validates :bio, length: { maximum: 500 }
  validates :avatar_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL" }, 
                        allow_blank: true

  # Display name with preference for username, fallback to email
  def display_name
    username.present? ? username : email.split('@').first.capitalize
  end

  # Get user's initials for avatar fallback
  def initials
    if username.present?
      username.first(2).upcase
    else
      email.split('@').first.first(2).upcase
    end
  end

  # Check if user has a complete profile
  def profile_complete?
    username.present? && bio.present?
  end
end
