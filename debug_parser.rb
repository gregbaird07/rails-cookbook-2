#!/usr/bin/env ruby

# Simple test script for the recipe parser
require_relative 'config/environment'

puts "🧪 Testing RecipeUrlParser service directly..."
puts "=" * 50

url = "https://www.food.com/recipe/easy-chocolate-chip-cookies-16721"
puts "Testing URL: #{url}"
puts

begin
  puts "Step 1: Creating parser instance..."
  parser = RecipeUrlParser.new(url)
  puts "✅ Parser instance created"
  
  puts "Step 2: Testing HTTP request..."
  response = HTTParty.get(url, headers: {
    'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
  })
  puts "✅ HTTP response received: #{response.code} #{response.message}"
  puts "   Response size: #{response.body.length} bytes"
  puts "   Success: #{response.success?}"
  
  if !response.success?
    puts "❌ HTTP request failed"
    exit 1
  end
  
  puts "Step 3: Testing HTML parsing..."
  doc = Nokogiri::HTML(response.body)
  puts "✅ HTML parsed successfully"
  
  puts "Step 4: Looking for JSON-LD scripts..."
  script_tags = doc.css('script[type="application/ld+json"]')
  puts "   Found #{script_tags.length} JSON-LD script tags"
  
  script_tags.each_with_index do |script, index|
    puts "   Script #{index + 1} length: #{script.content.length} characters"
    begin
      json_data = JSON.parse(script.content)
      puts "   Script #{index + 1} JSON valid: #{json_data.class}"
      
      if json_data.is_a?(Array)
        puts "     Array with #{json_data.length} items"
        json_data.each_with_index do |item, i|
          puts "       Item #{i + 1}: @type = #{item['@type']}"
          if item['@type'] == 'Recipe'
            puts "         Recipe found! Checking instructions..."
            puts "         recipeInstruction: #{item['recipeInstruction'].inspect}"
          end
        end
      else
        puts "     Single object: @type = #{json_data['@type']}"
        if json_data['@type'] == 'Recipe'
          puts "       Recipe found! Checking instructions..."
          puts "       recipeInstruction: #{json_data['recipeInstruction'].inspect}"
        end
        if json_data['@graph']
          puts "     Has @graph with #{json_data['@graph'].length} items"
          json_data['@graph'].each_with_index do |item, i|
            puts "       Graph item #{i + 1}: @type = #{item['@type']}"
            if item['@type'] == 'Recipe'
              puts "         Recipe found in graph! Checking instructions..."
              puts "         recipeInstruction: #{item['recipeInstruction'].inspect}"
            end
          end
        end
      end
    rescue JSON::ParserError => e
      puts "   Script #{index + 1} JSON invalid: #{e.message}"
    end
  end
  
  puts "Step 5: Calling RecipeUrlParser.parse..."
  result = RecipeUrlParser.parse(url)
  
  puts "Result class: #{result.class}"
  
  if result
    puts "\n✅ SUCCESS! Parsed recipe data:"
    result.each do |key, value|
      puts "  #{key}: #{value}"
    end
    
    puts "\n📝 INSTRUCTIONS DETAIL:"
    puts result[:instructions]
  else
    puts "\n❌ FAILED: Parser returned nil"
  end
  
rescue => e
  puts "\n💥 ERROR: #{e.message}"
  puts "Backtrace:"
  e.backtrace.first(10).each { |line| puts "  #{line}" }
end

puts "\n" + "=" * 50
puts "Test complete"
