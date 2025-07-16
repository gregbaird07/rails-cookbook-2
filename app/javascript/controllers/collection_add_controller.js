import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  addRecipe(event) {
    // Add visual feedback
    const link = event.currentTarget
    const icon = link.querySelector('i')
    
    // Add loading state
    const originalContent = link.innerHTML
    link.innerHTML = '<i class="bi bi-clock"></i> Adding...'
    link.classList.add('disabled')
    
    // Reset after a short delay (Turbo Stream will update the content)
    setTimeout(() => {
      link.classList.remove('disabled')
    }, 500)
  }
}
