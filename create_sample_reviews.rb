# Sample script to create test reviews
# Run this in Rails console: rails console

# Make sure we have users and recipes first
user1 = User.first
user2 = User.second || User.create!(
  email: 'reviewer@example.com',
  password: 'password123',
  username: 'foodcritic'
)

recipe = Recipe.first

if recipe && user1 && user2 && user1 != recipe.user
  # Create sample reviews
  Review.create!(
    recipe: recipe,
    user: user1,
    rating: 5,
    comment: "Absolutely delicious! This recipe turned out perfectly. The instructions were clear and easy to follow. My family loved it and asked for seconds!"
  )
end

if recipe && user2 && user2 != recipe.user
  Review.create!(
    recipe: recipe,
    user: user2,
    rating: 4,
    comment: "Great recipe overall! I made a small modification by adding a bit more seasoning to suit my taste. Will definitely make this again."
  )
end

puts "Sample reviews created!"
puts "Recipe: #{recipe&.title}"
puts "Total reviews: #{recipe&.total_reviews || 0}"
puts "Average rating: #{recipe&.average_rating || 0}"
