#!/usr/bin/env ruby
require_relative 'config/environment'

# Test with the exact JSON structure we saw from Food.com
test_json = {
  "@context" => "http://schema.org",
  "@type" => "Recipe",
  "name" => "Easy Steak and Gravy",
  "recipeInstructions" => [
    {
      "@type" => "HowToStep",
      "text" => "Mix flour, salt, and pepper."
    },
    {
      "@type" => "HowToStep", 
      "text" => "Pound into steak (you'll have some left)."
    },
    {
      "@type" => "HowToStep",
      "text" => "Cut steak into 6 pieces."
    }
  ]
}

puts "Testing extract_recipe_data with known JSON..."
puts "JSON: #{test_json.inspect}"
puts

parser = RecipeUrlParser.new("test")
result = parser.send(:extract_recipe_data, test_json)

puts "Result: #{result.inspect}"
puts
puts "Instructions: #{result[:instructions]}"
