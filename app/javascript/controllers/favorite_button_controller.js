import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggle(event) {
    // Add visual feedback
    const button = event.currentTarget
    const icon = button.querySelector('i')
    
    // Add a subtle animation
    button.style.transform = 'scale(0.95)'
    setTimeout(() => {
      button.style.transform = 'scale(1)'
    }, 150)
    
    // Add loading state
    button.disabled = true
    const originalText = button.innerHTML
    button.innerHTML = '<i class="bi bi-heart"></i> Updating...'
    
    // Reset after a short delay (Turbo Stream will update the content)
    setTimeout(() => {
      button.disabled = false
    }, 500)
  }
}
