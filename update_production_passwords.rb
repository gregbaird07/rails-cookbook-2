#!/usr/bin/env ruby

# Script to update production user passwords to match local seeds.rb
# This ensures consistency between local development and production

require_relative 'config/environment'

puts "🔒 Updating production user passwords to match seeds.rb..."

# Define the passwords from seeds.rb
password_updates = {
  "chef@example.com" => "kJ8#mN2$pQ9@vX7!wZ4&",
  "baker@example.com" => "rT6%yU3*bN8@hK2$mL9#", 
  "foodie@example.com" => "dF5!gH8&jK2@sD7*qW3%"
}

password_updates.each do |email, new_password|
  user = User.find_by(email: email)
  if user
    user.password = new_password
    user.password_confirmation = new_password
    if user.save
      puts "  ✅ Updated password for: #{email}"
    else
      puts "  ❌ Failed to update password for: #{email} - #{user.errors.full_messages.join(', ')}"
    end
  else
    puts "  ⚠️  User not found: #{email}"
  end
end

puts "🔒 Password update complete!"
puts ""
puts "🔑 Updated credentials (for reference only):"
password_updates.each do |email, password|
  puts "  📧 #{email} / #{password}"
end
