// Minimal JS for the demo site
document.addEventListener('DOMContentLoaded', function () {
  // Example: enhance login register forms, etc.
  var forms = document.querySelectorAll('form');
  Array.prototype.forEach.call(forms, function (f) {
    f.addEventListener('submit', function (e) {
      // Could add client-side validation here
    });
  });
});
