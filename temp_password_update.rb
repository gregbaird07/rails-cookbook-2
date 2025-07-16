puts "🔒 Updating production user passwords..."

# Update chef@example.com
user = User.find_by(email: "chef@example.com")
if user
  user.password = "kJ8#mN2$pQ9@vX7!wZ4&"
  user.password_confirmation = "kJ8#mN2$pQ9@vX7!wZ4&"
  if user.save
    puts "  ✅ Updated password for: chef@example.com"
  else
    puts "  ❌ Failed to update chef@example.com: #{user.errors.full_messages.join(', ')}"
  end
else
  puts "  ⚠️  User not found: chef@example.com"
end

# Update baker@example.com
user = User.find_by(email: "baker@example.com")
if user
  user.password = "rT6%yU3*bN8@hK2$mL9#"
  user.password_confirmation = "rT6%yU3*bN8@hK2$mL9#"
  if user.save
    puts "  ✅ Updated password for: baker@example.com"
  else
    puts "  ❌ Failed to update baker@example.com: #{user.errors.full_messages.join(', ')}"
  end
else
  puts "  ⚠️  User not found: baker@example.com"
end

# Update foodie@example.com
user = User.find_by(email: "foodie@example.com")
if user
  user.password = "dF5!gH8&jK2@sD7*qW3%"
  user.password_confirmation = "dF5!gH8&jK2@sD7*qW3%"
  if user.save
    puts "  ✅ Updated password for: foodie@example.com"
  else
    puts "  ❌ Failed to update foodie@example.com: #{user.errors.full_messages.join(', ')}"
  end
else
  puts "  ⚠️  User not found: foodie@example.com"
end

puts "🔒 Password update complete!"
