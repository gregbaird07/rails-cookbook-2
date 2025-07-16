# Sample seeds for reviews and ratings
puts "Creating sample reviews..."

# Find existing recipes and users
recipes = Recipe.limit(3)
users = User.limit(5)

sample_comments = [
  "Absolutely delicious! This recipe turned out perfectly. The instructions were clear and easy to follow.",
  "Great recipe overall! I made a small modification by adding a bit more seasoning to suit my taste.",
  "Amazing! This has become our family's go-to recipe. Easy to make and always delicious.",
  "Good recipe, though I found it a bit bland. Next time I'll add more herbs and spices.",
  "Perfect for beginners! Very detailed instructions and the result was fantastic.",
  "Loved this recipe! Made it for a dinner party and everyone asked for the recipe.",
  "Solid recipe. Takes a bit longer than expected but worth the wait.",
  "Creative approach to a classic dish. Will definitely try variations of this.",
  "Family-friendly recipe that kids absolutely love. Will be making this regularly.",
  "Impressed with how simple yet flavorful this turned out. Highly recommend!"
]

recipes.each do |recipe|
  # Get users who haven't reviewed this recipe and aren't the recipe owner
  available_users = users.reject { |user| 
    user == recipe.user || Review.exists?(recipe: recipe, user: user) 
  }
  
  # Create 2-4 reviews per recipe
  review_count = [2, 3, 4].sample
  
  available_users.sample(review_count).each do |user|
    Review.create!(
      recipe: recipe,
      user: user,
      rating: [3, 4, 4, 5, 5].sample, # Weighted towards higher ratings
      comment: sample_comments.sample
    )
  end
  
  puts "Created reviews for: #{recipe.title} (#{recipe.total_reviews} total, avg: #{recipe.average_rating})"
end

puts "Sample reviews creation complete!"
