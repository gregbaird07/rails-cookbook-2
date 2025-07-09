#!/usr/bin/env ruby
require_relative 'config/environment'

url = "https://www.food.com/recipe/easy-chocolate-chip-cookies-16721"
puts "Fetching #{url}"

response = HTTParty.get(url, headers: {
  'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
})

if response.success?
  doc = Nokogiri::HTML(response.body)
  script_tags = doc.css('script[type="application/ld+json"]')
  
  puts "Found #{script_tags.length} JSON-LD script tags"
  
  script_tags.each_with_index do |script, index|
    puts "\n=== SCRIPT TAG #{index + 1} ==="
    
    begin
      json_data = JSON.parse(script.content)
      puts "JSON Structure:"
      puts JSON.pretty_generate(json_data)
      
      # Look for recipe instructions specifically
      if json_data['@type'] == 'Recipe'
        puts "\n--- RECIPE INSTRUCTIONS ---"
        puts json_data['recipeInstruction'].inspect
      end
      
    rescue JSON::ParserError => e
      puts "JSON parsing failed: #{e.message}"
    end
  end
else
  puts "HTTP request failed: #{response.code}"
end
