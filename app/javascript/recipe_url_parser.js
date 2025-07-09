// Recipe URL Parser
class RecipeUrlParser {
  constructor() {
    this.setupEventListeners();
  }

  setupEventListeners() {
    // Handle both initial load and Turbo navigation
    document.addEventListener('DOMContentLoaded', () => this.initializeElements());
    document.addEventListener('turbo:load', () => this.initializeElements());
  }

  initializeElements() {
    const parseButton = document.getElementById('parse-url-btn');
    const urlInput = document.getElementById('recipe-url-input');
    
    if (parseButton && urlInput) {
      // Remove existing event listeners to prevent duplicates
      parseButton.removeEventListener('click', this.parseUrl);
      urlInput.removeEventListener('keypress', this.handleKeypress);
      
      // Add new event listeners
      parseButton.addEventListener('click', (e) => {
        e.preventDefault();
        this.parseUrl();
      });
      
      urlInput.addEventListener('keypress', (e) => {
        if (e.key === 'Enter') {
          e.preventDefault();
          this.parseUrl();
        }
      });
      
      console.log('Recipe URL Parser initialized successfully');
    } else {
      console.log('Parse button or URL input not found');
    }
  }

  parseUrl() {
    console.log('parseUrl method called');
    
    const urlInput = document.getElementById('recipe-url-input');
    const parseButton = document.getElementById('parse-url-btn');
    const errorDiv = document.getElementById('parse-error');
    const successDiv = document.getElementById('parse-success');
    
    if (!urlInput || !parseButton) {
      console.error('Required elements not found');
      return;
    }
    
    const url = urlInput.value.trim();
    console.log('URL to parse:', url);
    
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
    
    // Get CSRF token
    const csrfToken = document.querySelector('[name="csrf-token"]');
    if (!csrfToken) {
      console.error('CSRF token not found');
      this.showError('Security token not found. Please refresh the page.');
      parseButton.disabled = false;
      parseButton.textContent = originalText;
      return;
    }
    
    console.log('Making fetch request to /recipes/parse_url');
    
    // Make the request
    fetch('/recipes/parse_url', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken.content
      },
      body: JSON.stringify({ url: url })
    })
    .then(response => {
      console.log('Response status:', response.status);
      return response.json();
    })
    .then(data => {
      console.log('Response data:', data);
      if (data.success) {
        this.populateForm(data.recipe);
        this.showSuccess('Recipe parsed successfully! Please review and adjust the fields as needed.');
        urlInput.value = ''; // Clear the URL input
      } else {
        this.showError(data.error || 'Failed to parse recipe from URL');
      }
    })
    .catch(error => {
      console.error('Fetch error:', error);
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
