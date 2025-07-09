#!/usr/bin/env ruby
require_relative 'config/environment'

# Create a test user
begin
  user = User.find_or_create_by(email: 'test@example.com') do |u|
    u.password = 'password123'
    u.password_confirmation = 'password123'
  end
  puts "✓ Test user available: #{user.email}"
rescue => e
  puts "✗ Error creating user: #{e.message}"
end

# Test the RecipeUrlParser service
begin
  # Test with a simple URL first
  test_url = "https://example.com"
  puts "\n🧪 Testing RecipeUrlParser with: #{test_url}"
  
  result = RecipeUrlParser.parse(test_url)
  puts "📋 Result: #{result.inspect}"
  
  if result
    puts "✓ Parser returned data"
  else
    puts "✗ Parser returned nil"
  end
rescue => e
  puts "✗ Parser error: #{e.message}"
  puts "   #{e.backtrace.first}"
end

puts "\n🌐 You can now:"
puts "1. Go to http://localhost:3000/users/sign_in"
puts "2. Sign in with: test@example.com / password123"
puts "3. Go to http://localhost:3000/recipes/new"
puts "4. Test the URL parser with any URL"
puts "5. Check the browser console and Rails logs for debugging info"
