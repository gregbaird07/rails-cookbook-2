import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["urlInput", "parseButton", "errorDiv", "successDiv"]
  static values = { parseUrl: String }
  
  connect() {
    console.log("Recipe URL Parser controller connected")
  }

  async parse(event) {
    event.preventDefault()
    console.log("Parse method called")
    
    const url = this.urlInputTarget.value.trim()
    console.log("URL to parse:", url)
    
    if (!url) {
      this.showError('Please enter a recipe URL')
      return
    }
    
    this.showLoading()
    this.clearMessages()
    
    try {
      // Get the hidden form and its CSRF token
      const hiddenForm = document.getElementById('parse-url-form')
      const hiddenUrlField = document.getElementById('hidden-url-field')
      
      if (!hiddenForm) {
        console.error('Hidden form not found')
        this.showError('Form configuration error')
        return
      }
      
      const csrfTokenInput = hiddenForm.querySelector('input[name="authenticity_token"]')
      if (!csrfTokenInput) {
        console.error('CSRF token input not found in form')
        this.showError('CSRF token not found')
        return
      }
      
      const csrfToken = csrfTokenInput.value
      console.log('Using CSRF token from form:', csrfToken ? 'found' : 'not found')
      console.log('CSRF token length:', csrfToken?.length || 0)
      
      // Set the URL in the hidden field
      hiddenUrlField.value = url
      
      // Create FormData from the hidden form to ensure proper CSRF handling
      const formData = new FormData(hiddenForm)
      console.log('FormData entries:')
      for (let [key, value] of formData.entries()) {
        console.log(`  ${key}: ${value}`)
      }
      
      const response = await fetch('/recipes/parse_url', {
        method: 'POST',
        headers: {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest'
        },
        body: formData,
        credentials: 'same-origin'
      })
      
      console.log('Response status:', response.status)
      console.log('Response headers:', response.headers)
      
      if (!response.ok) {
        const errorText = await response.text()
        console.error('Error response:', errorText)
        throw new Error(`HTTP error! status: ${response.status}`)
      }
      
      const data = await response.json()
      console.log('Response data:', data)
      
      if (data.success) {
        this.populateForm(data.recipe)
        this.showSuccess('Recipe parsed successfully! Please review and adjust the fields as needed.')
        this.urlInputTarget.value = ''
      } else {
        if (data.manual_guide) {
          this.showManualGuide(data.error, data.manual_guide)
        } else {
          this.showError(data.error || 'Failed to parse recipe from URL')
        }
      }
    } catch (error) {
      console.error('Fetch error:', error)
      this.showError('An error occurred while parsing the recipe URL')
    } finally {
      this.hideLoading()
    }
  }
  
  getAuthenticityToken() {
    const token = document.querySelector('meta[name="csrf-token"]')
    return token ? token.getAttribute('content') : ''
  }

  showLoading() {
    this.parseButtonTarget.disabled = true
    this.parseButtonTarget.innerHTML = '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Parsing...'
  }

  hideLoading() {
    this.parseButtonTarget.disabled = false
    this.parseButtonTarget.innerHTML = '<i class="bi bi-magic"></i> Parse Recipe'
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
    }

    Object.entries(fields).forEach(([fieldName, value]) => {
      const field = document.getElementById(fieldName)
      if (field && value) {
        field.value = value
        const event = new Event('change', { bubbles: true })
        field.dispatchEvent(event)
      }
    })
  }

  showError(message) {
    if (this.hasErrorDivTarget) {
      this.errorDivTarget.textContent = message
      this.errorDivTarget.style.display = 'block'
    }
  }

  showManualGuide(errorMessage, guide) {
    if (this.hasErrorDivTarget) {
      let html = `<strong>${errorMessage}</strong><br><br>`
      html += `<strong>Manual extraction guide for ${guide.site_name}:</strong><br><br>`
      html += '<ol class="mb-3">'
      guide.instructions.forEach(instruction => {
        html += `<li>${instruction}</li>`
      })
      html += '</ol>'
      
      if (guide.tips && guide.tips.length > 0) {
        html += '<strong>Tips:</strong><br>'
        html += '<ul class="mb-0">'
        guide.tips.forEach(tip => {
          html += `<li>${tip}</li>`
        })
        html += '</ul>'
      }
      
      this.errorDivTarget.innerHTML = html
      this.errorDivTarget.style.display = 'block'
    }
  }

  showSuccess(message) {
    if (this.hasSuccessDivTarget) {
      this.successDivTarget.textContent = message
      this.successDivTarget.style.display = 'block'
    }
  }

  clearMessages() {
    if (this.hasErrorDivTarget) this.errorDivTarget.style.display = 'none'
    if (this.hasSuccessDivTarget) this.successDivTarget.style.display = 'none'
  }
}
