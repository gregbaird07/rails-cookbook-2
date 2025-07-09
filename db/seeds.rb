# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "🌱 Starting database seeding..."

# Clear existing data in development
if Rails.env.development?
  puts "🧹 Clearing existing data..."
  Recipe.destroy_all
  User.destroy_all
end

# Create sample users
puts "👥 Creating sample users..."

users = [
  {
    email: "chef@example.com",
    password: "password123",
    password_confirmation: "password123"
  },
  {
    email: "baker@example.com", 
    password: "password123",
    password_confirmation: "password123"
  },
  {
    email: "foodie@example.com",
    password: "password123", 
    password_confirmation: "password123"
  }
]

created_users = []
users.each do |user_data|
  user = User.find_or_create_by(email: user_data[:email]) do |u|
    u.password = user_data[:password]
    u.password_confirmation = user_data[:password_confirmation]
  end
  created_users << user
  puts "  ✅ Created user: #{user.email}"
end

# Create sample recipes
puts "🍳 Creating sample recipes..."

recipes_data = [
  {
    title: "Classic Chocolate Chip Cookies",
    description: "Soft, chewy, and loaded with chocolate chips. These cookies are perfect for any occasion and loved by kids and adults alike.",
    ingredients: "• 2 1/4 cups all-purpose flour\n• 1 tsp baking soda\n• 1 tsp salt\n• 1 cup butter, softened\n• 3/4 cup granulated sugar\n• 3/4 cup brown sugar\n• 2 large eggs\n• 2 tsp vanilla extract\n• 2 cups chocolate chips",
    instructions: "1. Preheat oven to 375°F (190°C)\n2. Mix flour, baking soda, and salt in a bowl\n3. Cream butter and sugars until fluffy\n4. Beat in eggs and vanilla\n5. Gradually mix in flour mixture\n6. Stir in chocolate chips\n7. Drop rounded tablespoons onto ungreased baking sheets\n8. Bake 9-11 minutes until golden brown\n9. Cool on baking sheet for 2 minutes, then transfer to wire rack",
    prep_time: 15,
    cook_time: 10,
    servings: 24,
    user: created_users[1] # baker
  },
  {
    title: "Spaghetti Carbonara",
    description: "An authentic Italian pasta dish with eggs, cheese, pancetta, and black pepper. Simple ingredients come together to create something magical.",
    ingredients: "• 1 lb spaghetti\n• 6 oz pancetta or guanciale, diced\n• 4 large egg yolks\n• 1 whole egg\n• 1 cup freshly grated Parmigiano-Reggiano\n• 1/2 cup freshly grated Pecorino Romano\n• Freshly ground black pepper\n• Salt for pasta water",
    instructions: "1. Bring large pot of salted water to boil\n2. Cook pancetta in large skillet until crispy\n3. Whisk eggs and cheese in large bowl\n4. Cook spaghetti according to package directions\n5. Reserve 1 cup pasta cooking water\n6. Add hot pasta to pancetta pan\n7. Remove from heat and quickly toss with egg mixture\n8. Add pasta water as needed for creaminess\n9. Season with black pepper and serve immediately",
    prep_time: 10,
    cook_time: 15,
    servings: 4,
    user: created_users[0] # chef
  },
  {
    title: "Homemade Pizza Dough",
    description: "Perfect pizza dough that's easy to make and results in a crispy yet chewy crust. Great for family pizza night!",
    ingredients: "• 3 cups bread flour\n• 1 tsp instant yeast\n• 1 1/4 tsp salt\n• 1 1/3 cups warm water\n• 2 tbsp olive oil\n• 1 tsp sugar",
    instructions: "1. Combine flour, yeast, salt, and sugar in large bowl\n2. Add warm water and olive oil\n3. Mix until shaggy dough forms\n4. Knead on floured surface for 10 minutes until smooth\n5. Place in oiled bowl, cover with damp towel\n6. Let rise in warm place for 1-2 hours until doubled\n7. Punch down and divide into 2 portions\n8. Roll out and add your favorite toppings\n9. Bake at 475°F for 12-15 minutes",
    prep_time: 20,
    cook_time: 15,
    servings: 8,
    user: created_users[0] # chef
  },
  {
    title: "Chicken Tikka Masala",
    description: "Tender chunks of chicken in a rich, creamy tomato-based sauce with aromatic spices. A restaurant favorite you can make at home!",
    ingredients: "• 2 lbs boneless chicken, cubed\n• 1 cup plain yogurt\n• 2 tbsp lemon juice\n• 2 tsp garam masala\n• 1 tsp cumin\n• 1 can crushed tomatoes\n• 1 cup heavy cream\n• 1 onion, diced\n• 4 cloves garlic, minced\n• 1 inch ginger, grated\n• 2 tsp paprika\n• Salt and pepper to taste",
    instructions: "1. Marinate chicken in yogurt, lemon juice, and spices for 30 minutes\n2. Grill or pan-fry chicken until cooked through\n3. Sauté onion, garlic, and ginger until fragrant\n4. Add tomatoes and spices, simmer 10 minutes\n5. Stir in cream and cooked chicken\n6. Simmer until sauce thickens\n7. Adjust seasoning and serve with rice\n8. Garnish with fresh cilantro",
    prep_time: 45,
    cook_time: 30,
    servings: 6,
    user: created_users[2] # foodie
  },
  {
    title: "Fresh Garden Salad",
    description: "A vibrant mix of fresh greens, vegetables, and a simple vinaigrette. Perfect as a side dish or light meal.",
    ingredients: "• 6 cups mixed greens\n• 1 cucumber, sliced\n• 2 tomatoes, chopped\n• 1/2 red onion, thinly sliced\n• 1/4 cup olive oil\n• 2 tbsp balsamic vinegar\n• 1 tsp Dijon mustard\n• 1 tsp honey\n• Salt and pepper to taste",
    instructions: "1. Wash and dry all vegetables thoroughly\n2. Combine greens, cucumber, tomatoes, and onion in large bowl\n3. Whisk together olive oil, vinegar, mustard, and honey\n4. Season dressing with salt and pepper\n5. Toss salad with dressing just before serving\n6. Serve immediately for best texture",
    prep_time: 15,
    cook_time: 0,
    servings: 4,
    user: created_users[2] # foodie
  },
  {
    title: "Banana Bread",
    description: "Moist and flavorful banana bread made with overripe bananas. Perfect for breakfast or an afternoon snack.",
    ingredients: "• 3 ripe bananas, mashed\n• 1/3 cup melted butter\n• 3/4 cup sugar\n• 1 egg, beaten\n• 1 tsp vanilla extract\n• 1 tsp baking soda\n• Pinch of salt\n• 1 1/2 cups all-purpose flour\n• Optional: 1/2 cup chopped walnuts",
    instructions: "1. Preheat oven to 350°F (175°C)\n2. Grease a 9x5 inch loaf pan\n3. Mix mashed bananas with melted butter\n4. Add sugar, egg, and vanilla\n5. Sprinkle baking soda and salt over mixture\n6. Add flour and mix until just combined\n7. Pour into prepared loaf pan\n8. Bake for 60-65 minutes until toothpick comes out clean\n9. Cool in pan for 10 minutes, then turn out onto wire rack",
    prep_time: 15,
    cook_time: 65,
    servings: 8,
    user: created_users[1] # baker
  }
]

recipes_data.each do |recipe_data|
  recipe = Recipe.find_or_create_by(
    title: recipe_data[:title],
    user: recipe_data[:user]
  ) do |r|
    r.description = recipe_data[:description]
    r.ingredients = recipe_data[:ingredients]
    r.instructions = recipe_data[:instructions]
    r.prep_time = recipe_data[:prep_time]
    r.cook_time = recipe_data[:cook_time]
    r.servings = recipe_data[:servings]
  end
  puts "  ✅ Created recipe: #{recipe.title}"
end

# Add 5 additional recipes with random user assignment
puts "🎲 Creating additional random recipes..."

additional_recipes = [
  {
    title: "Thai Green Curry",
    description: "Aromatic and spicy Thai curry with coconut milk, vegetables, and fragrant herbs. A perfect balance of heat and creaminess.",
    ingredients: "• 2 tbsp green curry paste\n• 1 can coconut milk\n• 1 lb chicken breast, sliced\n• 1 Thai eggplant, cubed\n• 1/4 cup bamboo shoots\n• 2 kaffir lime leaves\n• 1 tbsp fish sauce\n• 1 tbsp palm sugar\n• Thai basil leaves\n• Red chilies for garnish",
    instructions: "1. Heat 1/3 of coconut milk in wok over medium heat\n2. Add curry paste and cook until fragrant\n3. Add chicken and cook until done\n4. Add remaining coconut milk and bring to boil\n5. Add eggplant and bamboo shoots\n6. Season with fish sauce and palm sugar\n7. Add lime leaves and simmer 5 minutes\n8. Garnish with basil and chilies\n9. Serve with jasmine rice",
    prep_time: 20,
    cook_time: 25,
    servings: 4
  },
  {
    title: "French Onion Soup",
    description: "Classic French comfort food with caramelized onions in rich beef broth, topped with melted Gruyère cheese.",
    ingredients: "• 6 large yellow onions, sliced\n• 4 tbsp butter\n• 2 tbsp olive oil\n• 1 tsp sugar\n• 1/2 tsp salt\n• 6 cups beef broth\n• 1/2 cup dry white wine\n• 2 bay leaves\n• 1/4 tsp thyme\n• 6 slices French bread\n• 1 1/2 cups grated Gruyère cheese",
    instructions: "1. Melt butter with oil in large pot\n2. Add onions, sugar, and salt\n3. Cook slowly for 45 minutes until caramelized\n4. Add wine and cook 2 minutes\n5. Add broth, bay leaves, and thyme\n6. Simmer 30 minutes\n7. Preheat broiler\n8. Ladle soup into oven-safe bowls\n9. Top with bread and cheese\n10. Broil until cheese is bubbly and golden",
    prep_time: 15,
    cook_time: 90,
    servings: 6
  },
  {
    title: "Beef Tacos with Cilantro Lime Rice",
    description: "Flavorful seasoned ground beef tacos served with fresh toppings and aromatic cilantro lime rice.",
    ingredients: "• 1 lb ground beef\n• 1 packet taco seasoning\n• 8 corn tortillas\n• 1 cup jasmine rice\n• 1/4 cup fresh cilantro, chopped\n• 2 limes, juiced\n• 1 diced tomato\n• 1/2 diced onion\n• 1 cup shredded lettuce\n• 1 cup shredded cheese\n• Sour cream\n• Hot sauce",
    instructions: "1. Cook rice according to package directions\n2. Brown ground beef in large skillet\n3. Add taco seasoning and water per package\n4. Simmer until thickened\n5. Mix cilantro and lime juice into cooked rice\n6. Warm tortillas in dry skillet\n7. Assemble tacos with beef and toppings\n8. Serve with cilantro lime rice\n9. Add hot sauce to taste",
    prep_time: 15,
    cook_time: 30,
    servings: 4
  },
  {
    title: "Mediterranean Quinoa Salad",
    description: "Fresh and healthy quinoa salad with vegetables, feta cheese, and a zesty lemon vinaigrette.",
    ingredients: "• 1 cup quinoa\n• 1 cucumber, diced\n• 2 tomatoes, diced\n• 1/2 red onion, finely diced\n• 1/2 cup kalamata olives\n• 1/2 cup crumbled feta cheese\n• 1/4 cup olive oil\n• 2 lemons, juiced\n• 2 cloves garlic, minced\n• 1 tsp dried oregano\n• Salt and pepper to taste",
    instructions: "1. Rinse quinoa and cook in 2 cups water\n2. Bring to boil, then simmer 15 minutes\n3. Let quinoa cool completely\n4. Dice cucumber, tomatoes, and onion\n5. Whisk together oil, lemon juice, garlic, oregano\n6. Combine quinoa with vegetables\n7. Add olives and feta cheese\n8. Toss with dressing\n9. Chill for 30 minutes before serving\n10. Adjust seasoning and serve",
    prep_time: 25,
    cook_time: 15,
    servings: 6
  },
  {
    title: "Chocolate Lava Cake",
    description: "Decadent individual chocolate cakes with molten chocolate centers. Perfect for special occasions!",
    ingredients: "• 4 oz dark chocolate, chopped\n• 4 tbsp butter\n• 2 large eggs\n• 2 large egg yolks\n• 1/4 cup granulated sugar\n• Pinch of salt\n• 2 tbsp all-purpose flour\n• Butter for ramekins\n• Cocoa powder for dusting\n• Vanilla ice cream for serving",
    instructions: "1. Preheat oven to 425°F (220°C)\n2. Butter 4 ramekins and dust with cocoa\n3. Melt chocolate and butter in double boiler\n4. Whisk eggs, yolks, and sugar until thick\n5. Fold in melted chocolate mixture\n6. Add salt and flour, mix gently\n7. Divide batter among ramekins\n8. Bake 12-14 minutes until edges are firm\n9. Let stand 1 minute, then invert onto plates\n10. Serve immediately with ice cream",
    prep_time: 20,
    cook_time: 14,
    servings: 4
  }
]

# Randomly assign recipes to users
additional_recipes.each do |recipe_data|
  random_user = created_users.sample # Randomly pick a user
  recipe = Recipe.find_or_create_by(
    title: recipe_data[:title],
    user: random_user
  ) do |r|
    r.description = recipe_data[:description]
    r.ingredients = recipe_data[:ingredients]
    r.instructions = recipe_data[:instructions]
    r.prep_time = recipe_data[:prep_time]
    r.cook_time = recipe_data[:cook_time]
    r.servings = recipe_data[:servings]
  end
  puts "  🎲 Created recipe: #{recipe.title} (assigned to #{random_user.email})"
end

puts ""
puts "🎉 Seeding completed successfully!"
puts "📊 Database summary:"
puts "  👥 Users: #{User.count}"
puts "  🍳 Recipes: #{Recipe.count}"
puts ""
puts "🔑 Test login credentials:"
puts "  📧 chef@example.com / password123"
puts "  📧 baker@example.com / password123" 
puts "  📧 foodie@example.com / password123"
