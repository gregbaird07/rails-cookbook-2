user = User.create!(
  email: 'gregbaird07@gmail.com',
  password: 'titleist',
  password_confirmation: 'titleist'
)
puts "User created successfully!"
puts "Email: #{user.email}"
puts "ID: #{user.id}"
puts "Total users: #{User.count}"
