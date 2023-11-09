// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

console.log("LOADED")

document.addEventListener('DOMContentLoaded', function() {
  document.querySelectorAll('.copy-btn').forEach(function(button) {
    button.addEventListener('click', function(event) {
      event.preventDefault();
      navigator.clipboard.writeText(button.getAttribute('data-clipboard-text'))
    });
  });
});
