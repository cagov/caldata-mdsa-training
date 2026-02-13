// Interactive Quiz Functionality
document.addEventListener('DOMContentLoaded', function() {
  // Find all quiz options
  const quizOptions = document.querySelectorAll('.quiz-option');

  quizOptions.forEach(option => {
    option.addEventListener('click', function() {
      // Get the parent quiz container
      const quizContainer = this.closest('.quiz-container');
      const allOptions = quizContainer.querySelectorAll('.quiz-option');
      const explanation = quizContainer.querySelector('.quiz-explanation');

      // Check if this quiz has already been answered
      const alreadyAnswered = Array.from(allOptions).some(opt =>
        opt.classList.contains('correct') || opt.classList.contains('incorrect')
      );

      if (alreadyAnswered) {
        return; // Don't allow re-answering
      }

      // Mark the clicked option
      if (this.dataset.correct === 'true') {
        this.classList.add('correct');
      } else {
        this.classList.add('incorrect');

        // Also highlight the correct answer
        allOptions.forEach(opt => {
          if (opt.dataset.correct === 'true') {
            opt.classList.add('correct');
          }
        });
      }

      // Show explanation if available
      if (explanation) {
        explanation.classList.add('show');
      }

      // Disable all options to prevent further clicks
      allOptions.forEach(opt => {
        opt.style.cursor = 'default';
      });
    });
  });
});
