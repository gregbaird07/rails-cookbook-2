#!/usr/bin/env ruby

# Load Rails environment
require_relative 'config/environment'

# Create sample reviews
recipe = Recipe.first
if recipe
  puts "Working with recipe: #{recipe.title}"
  
  # Get users who are not the recipe owner
  available_users = User.where.not(id: recipe.user_id).limit(3)
  
  if available_users.any?
    # Sample review data
    sample_reviews = [
      {
        rating: 5,
        comment: "Absolutely delicious! This recipe turned out perfectly. The instructions were clear and easy to follow. My family loved it and asked for seconds!"
      },
      {
        rating: 4,
        comment: "Great recipe overall! I made a small modification by adding a bit more seasoning to suit my taste. Will definitely make this again."
      },
      {
        rating: 5,
        comment: "Amazing! This has become our family's go-to recipe. Easy to make and always delicious. Highly recommend!"
      }
    ]
    
    available_users.each_with_index do |user, index|
      review_data = sample_reviews[index] || sample_reviews.last
      
      # Only create if review doesn't already exist
      unless Review.exists?(recipe: recipe, user: user)
        review = Review.create!(
          recipe: recipe,
          user: user,
          rating: review_data[:rating],
          comment: review_data[:comment]
        )
        puts "Created review by #{user.display_name}: #{review_data[:rating]} stars"
      else
        puts "Review by #{user.display_name} already exists"
      end
    end
    
    recipe.reload
    puts "\nResults:"
    puts "Total reviews: #{recipe.total_reviews}"
    puts "Average rating: #{recipe.average_rating}"
  else
    puts "No available users to create reviews (need users other than recipe owner)"
  end
else
  puts "No recipes found in database"
end
