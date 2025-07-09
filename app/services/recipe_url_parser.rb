class RecipeUrlParser
  include HTTParty

  def self.parse(url)
    new(url).parse
  end

  def initialize(url)
    @url = url
  end

  def parse
    response = self.class.get(@url, headers: {
      'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
    })
    
    return nil unless response.success?
    
    doc = Nokogiri::HTML(response.body)
    
    # Try to parse JSON-LD structured data first (most common)
    recipe_data = parse_json_ld(doc) || parse_microdata(doc) || parse_fallback(doc)
    
    recipe_data
  rescue => e
    Rails.logger.error "Recipe URL parsing failed: #{e.message}"
    nil
  end

  private

  def parse_json_ld(doc)
    script_tags = doc.css('script[type="application/ld+json"]')
    
    script_tags.each do |script|
      begin
        json_data = JSON.parse(script.content)
        
        # Handle both single objects and arrays
        recipes = json_data.is_a?(Array) ? json_data : [json_data]
        
        recipes.each do |item|
          # Handle nested @graph structure
          if item['@graph']
            item['@graph'].each do |graph_item|
              if graph_item['@type'] == 'Recipe'
                return extract_recipe_data(graph_item)
              end
            end
          elsif item['@type'] == 'Recipe'
            return extract_recipe_data(item)
          end
        end
      rescue JSON::ParserError
        next
      end
    end
    
    nil
  end

  def parse_microdata(doc)
    recipe_elem = doc.css('[itemtype*="Recipe"]').first
    return nil unless recipe_elem
    
    {
      title: extract_microdata_text(recipe_elem, '[itemprop="name"]'),
      description: extract_microdata_text(recipe_elem, '[itemprop="description"]'),
      prep_time: parse_duration(extract_microdata_text(recipe_elem, '[itemprop="prepTime"]')),
      cook_time: parse_duration(extract_microdata_text(recipe_elem, '[itemprop="cookTime"]')),
      servings: extract_microdata_text(recipe_elem, '[itemprop="recipeYield"]')&.to_i || 4,
      ingredients: extract_microdata_list(recipe_elem, '[itemprop="recipeIngredient"]'),
      instructions: extract_microdata_list(recipe_elem, '[itemprop="recipeInstruction"]')
    }
  end

  def parse_fallback(doc)
    # Basic fallback parsing using common selectors
    {
      title: extract_fallback_text(doc, 'h1, .recipe-title, .entry-title'),
      description: extract_fallback_text(doc, '.recipe-description, .recipe-summary, .entry-summary'),
      prep_time: 15, # Default values
      cook_time: 30,
      servings: 4,
      ingredients: extract_fallback_list(doc, '.recipe-ingredients li, .ingredients li'),
      instructions: extract_fallback_list(doc, '.recipe-instructions li, .instructions li, .recipe-method li')
    }
  end

  def extract_recipe_data(recipe_json)
    {
      title: recipe_json['name'],
      description: recipe_json['description'],
      prep_time: parse_duration(recipe_json['prepTime']),
      cook_time: parse_duration(recipe_json['cookTime']),
      servings: parse_yield(recipe_json['recipeYield']),
      ingredients: extract_ingredients(recipe_json['recipeIngredient']),
      instructions: extract_instructions(recipe_json['recipeInstruction'])
    }
  end

  def parse_duration(duration_str)
    return 30 unless duration_str # Default
    
    # Parse ISO 8601 duration (PT15M) or simple numbers
    if duration_str.match(/PT(\d+)M/)
      $1.to_i
    elsif duration_str.match(/(\d+)/)
      $1.to_i
    else
      30
    end
  end

  def parse_yield(yield_data)
    return 4 unless yield_data # Default
    
    if yield_data.is_a?(Array)
      yield_data.first.to_i
    else
      yield_data.to_i
    end
  end

  def extract_ingredients(ingredients_data)
    return "" unless ingredients_data
    
    ingredients = ingredients_data.is_a?(Array) ? ingredients_data : [ingredients_data]
    ingredients.map { |ing| "• #{ing}" }.join("\n")
  end

  def extract_instructions(instructions_data)
    return "" unless instructions_data
    
    instructions = instructions_data.is_a?(Array) ? instructions_data : [instructions_data]
    instructions.map.with_index(1) do |instruction, index|
      text = instruction.is_a?(Hash) ? instruction['text'] : instruction
      "#{index}. #{text}"
    end.join("\n")
  end

  def extract_microdata_text(element, selector)
    elem = element.css(selector).first
    elem&.text&.strip
  end

  def extract_microdata_list(element, selector)
    elements = element.css(selector)
    elements.map(&:text).map(&:strip).reject(&:empty?).join("\n")
  end

  def extract_fallback_text(doc, selector)
    elem = doc.css(selector).first
    elem&.text&.strip
  end

  def extract_fallback_list(doc, selector)
    elements = doc.css(selector)
    elements.map(&:text).map(&:strip).reject(&:empty?).map.with_index(1) { |text, i| "#{i}. #{text}" }.join("\n")
  end
end
