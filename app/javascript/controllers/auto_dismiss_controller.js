import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Ensure notification starts visible
    this.element.style.opacity = '1'
    this.element.style.transition = ''
    
    // Auto-dismiss after 4 seconds
    setTimeout(() => {
      this.dismiss()
    }, 4000)
  }
  
  dismiss() {
    // Add fade-out animation
    this.element.style.transition = 'opacity 0.3s ease-out'
    this.element.style.opacity = '0'
    
    // Remove from DOM after animation
    setTimeout(() => {
      if (this.element.parentNode) {
        this.element.remove()
      }
    }, 300)
  }
}
