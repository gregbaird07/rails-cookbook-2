// Recipe URL Parser
class RecipeUrlParser {
  constructor() {
    this.setupEventListeners();
  }

  setupEventListeners() {
    document.addEventListener('DOMContentLoaded', () => {
      const parseButton = document.getElementById('parse-url-btn');
      const urlInput = document.getElementById('recipe-url-input');
      
      if (parseButton && urlInput) {
        parseButton.addEventListener('click', () => this.parseUrl());
        urlInput.addEventListener('keypress', (e) => {
          if (e.key === 'Enter') {
            e.preventDefault();
            this.parseUrl();
          }
        });
      }
    });
  }

  parseUrl() {
    const urlInput = document.getElementById('recipe-url-input');
    const parseButton = document.getElementById('parse-url-btn');
    const errorDiv = document.getElementById('parse-error');
    const successDiv = document.getElementById('parse-success');
    
    if (!urlInput || !parseButton) return;
    
    const url = urlInput.value.trim();
    
    if (!url) {
      this.showError('Please enter a recipe URL');
      return;
    }
    
    // Show loading state
    const originalText = parseButton.textContent;
    parseButton.disabled = true;
    parseButton.innerHTML = '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Parsing...';
    
    // Clear previous messages
    this.clearMessages();
    
    // Make the request
    fetch('/recipes/parse_url', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      },
      body: JSON.stringify({ url: url })
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        this.populateForm(data.recipe);
        this.showSuccess('Recipe parsed successfully! Please review and adjust the fields as needed.');
        urlInput.value = ''; // Clear the URL input
      } else {
        this.showError(data.error || 'Failed to parse recipe from URL');
      }
    })
    .catch(error => {
      console.error('Error:', error);
      this.showError('An error occurred while parsing the recipe URL');
    })
    .finally(() => {
      // Reset button state
      parseButton.disabled = false;
      parseButton.textContent = originalText;
    });
  }

  populateForm(recipe) {
    const fields = {
      'recipe_title': recipe.title,
      'recipe_description': recipe.description,
      'recipe_prep_time': recipe.prep_time,
      'recipe_cook_time': recipe.cook_time,
      'recipe_servings': recipe.servings,
      'recipe_ingredients': recipe.ingredients,
      'recipe_instructions': recipe.instructions
    };

    Object.entries(fields).forEach(([fieldName, value]) => {
      const field = document.getElementById(fieldName);
      if (field && value) {
        field.value = value;
        
        // Trigger change event for any listeners
        const event = new Event('change', { bubbles: true });
        field.dispatchEvent(event);
      }
    });
  }

  showError(message) {
    const errorDiv = document.getElementById('parse-error');
    if (errorDiv) {
      errorDiv.textContent = message;
      errorDiv.style.display = 'block';
    }
  }

  showSuccess(message) {
    const successDiv = document.getElementById('parse-success');
    if (successDiv) {
      successDiv.textContent = message;
      successDiv.style.display = 'block';
    }
  }

  clearMessages() {
    const errorDiv = document.getElementById('parse-error');
    const successDiv = document.getElementById('parse-success');
    
    if (errorDiv) errorDiv.style.display = 'none';
    if (successDiv) successDiv.style.display = 'none';
  }
}

// Initialize the parser
new RecipeUrlParser();
