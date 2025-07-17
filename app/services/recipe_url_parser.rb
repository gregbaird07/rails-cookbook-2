class RecipeUrlParser
  include HTTParty

  def self.parse(url)
    new(url).parse
  end

  def initialize(url)
    @url = url
  end

  def parse
    Rails.logger.info "=== RECIPE URL PARSER START ==="
    Rails.logger.info "URL: #{@url}"
    
    # Enhanced headers to appear more like a real browser
    headers = {
      'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
      'Accept-Language' => 'en-US,en;q=0.5',
      'Accept-Encoding' => 'gzip, deflate, br',
      'Connection' => 'keep-alive',
      'Upgrade-Insecure-Requests' => '1',
      'Sec-Fetch-Dest' => 'document',
      'Sec-Fetch-Mode' => 'navigate',
      'Sec-Fetch-Site' => 'none',
      'Cache-Control' => 'max-age=0'
    }
    
    # Try with delay to avoid rate limiting
    sleep(1) if @url.include?('maangchi.com')
    
    response = self.class.get(@url, headers: headers, timeout: 30)
    
    Rails.logger.info "HTTP Response: #{response.code} #{response.message}"
    Rails.logger.info "Response success: #{response.success?}"
    
    unless response.success?
      case response.code
      when 403
        Rails.logger.error "HTTP 403 Forbidden - Website may be blocking automated requests"
        Rails.logger.error "This is common with sites that use CloudFlare or bot protection"
        Rails.logger.error "Try visiting the URL manually to check if it works in a browser"
      when 429
        Rails.logger.error "HTTP 429 Too Many Requests - Rate limited"
      else
        Rails.logger.error "HTTP request failed: #{response.code} #{response.message}"
      end
      return nil
    end
    
    doc = Nokogiri::HTML(response.body)
    Rails.logger.info "HTML parsed, document length: #{response.body.length}"
    
    # Try to parse JSON-LD structured data first (most common)
    Rails.logger.info "Attempting JSON-LD parsing..."
    recipe_data = parse_json_ld(doc)
    
    if recipe_data
      Rails.logger.info "JSON-LD parsing successful: #{recipe_data[:title]}"
      return recipe_data
    end
    
    Rails.logger.info "JSON-LD failed, attempting microdata parsing..."
    recipe_data = parse_microdata(doc)
    
    if recipe_data
      Rails.logger.info "Microdata parsing successful: #{recipe_data[:title]}"
      return recipe_data
    end
    
    Rails.logger.info "Microdata failed, attempting fallback parsing..."
    recipe_data = parse_fallback(doc)
    
    if recipe_data
      Rails.logger.info "Fallback parsing result: #{recipe_data[:title]}"
      return recipe_data
    end
    
    Rails.logger.error "All parsing methods failed"
    recipe_data
  rescue => e
    Rails.logger.error "Recipe URL parsing failed: #{e.message}"
    Rails.logger.error "Backtrace: #{e.backtrace.first(3).join(', ')}"
    nil
  end

  private

  def parse_json_ld(doc)
    script_tags = doc.css('script[type="application/ld+json"]')
    Rails.logger.info "Found #{script_tags.length} JSON-LD script tags"
    
    script_tags.each_with_index do |script, index|
      begin
        Rails.logger.info "Processing JSON-LD script tag #{index + 1}"
        json_data = JSON.parse(script.content)
        Rails.logger.info "JSON parsed successfully, type: #{json_data.class}"
        
        # Handle both single objects and arrays
        recipes = json_data.is_a?(Array) ? json_data : [json_data]
        Rails.logger.info "Processing #{recipes.length} JSON items"
        
        recipes.each_with_index do |item, item_index|
          Rails.logger.info "Item #{item_index + 1}: @type = #{item['@type']}"
          
          # Handle nested @graph structure
          if item['@graph']
            Rails.logger.info "Found @graph with #{item['@graph'].length} items"
            item['@graph'].each_with_index do |graph_item, graph_index|
              Rails.logger.info "Graph item #{graph_index + 1}: @type = #{graph_item['@type']}"
              if graph_item['@type'] == 'Recipe'
                Rails.logger.info "Found Recipe in @graph!"
                return extract_recipe_data(graph_item)
              end
            end
          elsif item['@type'] == 'Recipe'
            Rails.logger.info "Found direct Recipe!"
            return extract_recipe_data(item)
          end
        end
      rescue JSON::ParserError => e
        Rails.logger.error "JSON parsing failed for script #{index + 1}: #{e.message}"
        next
      end
    end
    
    Rails.logger.info "No Recipe found in JSON-LD data"
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
    Rails.logger.info "=== EXTRACTING RECIPE DATA ==="
    Rails.logger.info "Recipe JSON keys: #{recipe_json.keys}"
    Rails.logger.info "recipeInstruction: #{recipe_json['recipeInstruction'].inspect}"
    Rails.logger.info "recipeInstructions: #{recipe_json['recipeInstructions'].inspect}"
    
    instructions_data = recipe_json['recipeInstruction'] || recipe_json['recipeInstructions']
    Rails.logger.info "Instructions data to process: #{instructions_data.inspect}"
    
    {
      title: recipe_json['name'],
      description: recipe_json['description'],
      prep_time: parse_duration(recipe_json['prepTime']),
      cook_time: parse_duration(recipe_json['cookTime']),
      servings: parse_yield(recipe_json['recipeYield']),
      ingredients: extract_ingredients(recipe_json['recipeIngredient']),
      instructions: extract_instructions(instructions_data)
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
    Rails.logger.info "=== EXTRACTING INSTRUCTIONS ==="
    Rails.logger.info "Instructions data: #{instructions_data.inspect}"
    Rails.logger.info "Instructions data class: #{instructions_data.class}"
    
    return "" unless instructions_data
    
    instructions = instructions_data.is_a?(Array) ? instructions_data : [instructions_data]
    Rails.logger.info "Instructions array: #{instructions.inspect}"
    
    result = instructions.map.with_index(1) do |instruction, index|
      text = instruction.is_a?(Hash) ? instruction['text'] : instruction
      Rails.logger.info "Instruction #{index}: #{text.inspect}"
      "#{index}. #{text}"
    end.join("\n")
    
    Rails.logger.info "Final instructions result: #{result}"
    result
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
