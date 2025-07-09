// Simple test for recipe URL parser button
document.addEventListener('DOMContentLoaded', function() {
  console.log('Testing recipe URL parser button...');
  
  const button = document.getElementById('parse-url-btn');
  const input = document.getElementById('recipe-url-input');
  
  if (button && input) {
    console.log('Button and input found');
    button.addEventListener('click', function() {
      alert('Button clicked! URL: ' + input.value);
    });
  } else {
    console.log('Button or input not found');
  }
});
