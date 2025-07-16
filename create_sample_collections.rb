#!/usr/bin/env ruby

# Load Rails environment
require_relative 'config/environment'

puts "Creating sample collections..."

# Get users
users = User.limit(3)

if users.any?
  users.each do |user|
    puts "Creating collections for #{user.display_name}..."
    
    # Create favorites collection automatically (will be created when accessed)
    favorites = user.favorites_collection
    
    # Add some sample collections
    sample_collections = [
      {
        name: "Quick Weeknight Dinners",
        description: "Fast and easy recipes for busy weeknights, all under 30 minutes!",
        is_public: true
      },
      {
        name: "Holiday Specials",
        description: "Special recipes for holidays and celebrations throughout the year.",
        is_public: true
      },
      {
        name: "Comfort Food Classics",
        description: "Hearty, soul-warming dishes that never go out of style.",
        is_public: [true, false].sample
      },
      {
        name: "Healthy Options",
        description: "Nutritious and delicious recipes for a balanced lifestyle.",
        is_public: false
      }
    ]
    
    sample_collections.each do |collection_data|
      # Only create if it doesn't already exist
      unless user.collections.exists?(name: collection_data[:name])
        collection = user.collections.create!(collection_data)
        puts "  Created: #{collection.name} (#{collection.is_public? ? 'Public' : 'Private'})"
        
        # Add some random recipes to each collection
        available_recipes = Recipe.limit(5).sample(rand(2..4))
        available_recipes.each do |recipe|
          collection.add_recipe(recipe) if rand < 0.7 # 70% chance
        end
        
        puts "    Added #{collection.recipe_count} recipes"
      end
    end
    
    # Add some recipes to favorites
    if favorites.recipe_count == 0
      Recipe.limit(3).each { |recipe| user.add_to_favorites(recipe) }
      puts "  Added #{favorites.recipe_count} recipes to Favorites"
    end
    
    puts "  Total collections: #{user.collections.count}"
    puts ""
  end
  
  puts "Sample collections created successfully!"
  puts "Total public collections: #{Collection.public_collections.count}"
  puts "Total private collections: #{Collection.where(is_public: false).count}"
else
  puts "No users found. Please create users first."
end
