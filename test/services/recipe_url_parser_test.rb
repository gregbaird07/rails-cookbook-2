require 'test_helper'

class RecipeUrlParserTest < ActiveSupport::TestCase
  test "should parse basic recipe structure" do
    # Mock a basic recipe HTML structure
    html = <<~HTML
      <html>
        <head>
          <script type="application/ld+json">
          {
            "@context": "https://schema.org",
            "@type": "Recipe",
            "name": "Chocolate Chip Cookies",
            "description": "Classic homemade chocolate chip cookies",
            "prepTime": "PT15M",
            "cookTime": "PT10M",
            "recipeYield": "24",
            "recipeIngredient": [
              "2 cups flour",
              "1 cup sugar",
              "1 cup chocolate chips"
            ],
            "recipeInstruction": [
              "Mix dry ingredients",
              "Add wet ingredients",
              "Bake at 375°F"
            ]
          }
          </script>
        </head>
        <body></body>
      </html>
    HTML

    # Mock HTTParty response
    mock_response = mock('response')
    mock_response.stubs(:success?).returns(true)
    mock_response.stubs(:body).returns(html)
    
    RecipeUrlParser.stubs(:get).returns(mock_response)
    
    result = RecipeUrlParser.parse('http://example.com/recipe')
    
    assert_not_nil result
    assert_equal 'Chocolate Chip Cookies', result[:title]
    assert_equal 'Classic homemade chocolate chip cookies', result[:description]
    assert_equal 15, result[:prep_time]
    assert_equal 10, result[:cook_time]
    assert_equal 24, result[:servings]
    assert_includes result[:ingredients], 'flour'
    assert_includes result[:instructions], 'Mix dry ingredients'
  end

  test "should handle failed requests gracefully" do
    # Mock failed response
    mock_response = mock('response')
    mock_response.stubs(:success?).returns(false)
    
    RecipeUrlParser.stubs(:get).returns(mock_response)
    
    result = RecipeUrlParser.parse('http://example.com/invalid')
    
    assert_nil result
  end
end
