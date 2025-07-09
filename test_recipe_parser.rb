#!/usr/bin/env ruby

# Test script for the Recipe URL Parser
require_relative '../config/environment'

# Test URLs from popular recipe sites
test_urls = [
  'https://www.allrecipes.com/recipe/213742/cheesy-chicken-broccoli-casserole/',
  'https://www.foodnetwork.com/recipes/alton-brown/baked-macaroni-and-cheese-recipe-1939524',
  'https://www.tasteofhome.com/recipes/classic-beef-stew/',
  'https://www.epicurious.com/recipes/food/views/chocolate-chip-cookies-107139'
]

puts "Testing Recipe URL Parser..."
puts "=" * 50

test_urls.each do |url|
  puts "\nTesting: #{url}"
  puts "-" * 40
  
  begin
    result = RecipeUrlParser.parse(url)
    
    if result
      puts "✅ Successfully parsed!"
      puts "Title: #{result[:title]}"
      puts "Description: #{result[:description]&.truncate(100)}"
      puts "Prep Time: #{result[:prep_time]} minutes"
      puts "Cook Time: #{result[:cook_time]} minutes"
      puts "Servings: #{result[:servings]}"
      puts "Ingredients (sample): #{result[:ingredients]&.lines&.first&.strip}"
      puts "Instructions (sample): #{result[:instructions]&.lines&.first&.strip}"
    else
      puts "❌ Failed to parse recipe"
    end
  rescue => e
    puts "❌ Error: #{e.message}"
  end
end

puts "\n" + "=" * 50
puts "Test completed!"
