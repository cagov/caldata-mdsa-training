# Quiz Example

This page shows how to create interactive quizzes in your training materials.

## Example Quiz 1: Simple Question

<div class="quiz-container">
  <div class="quiz-question">What is the purpose of staging models in dbt?</div>
  <ul class="quiz-options">
    <li class="quiz-option" data-correct="false">To perform complex business logic transformations</li>
    <li class="quiz-option" data-correct="true">To provide a clean, one-to-one representation of source data with basic transformations</li>
    <li class="quiz-option" data-correct="false">To create final analytical tables for end users</li>
    <li class="quiz-option" data-correct="false">To test data quality</li>
  </ul>
  <div class="quiz-explanation">
    <strong>Explanation:</strong> Staging models create a one-to-one relationship with source data and perform only basic transformations like column renaming, type casting, and simple computations. Complex business logic belongs in intermediate and mart models.
  </div>
</div>

## Example Quiz 2: Another Question

<div class="quiz-container">
  <div class="quiz-question">Which materialization is typically used for staging models?</div>
  <ul class="quiz-options">
    <li class="quiz-option" data-correct="false">Table</li>
    <li class="quiz-option" data-correct="true">View or ephemeral</li>
    <li class="quiz-option" data-correct="false">Incremental</li>
    <li class="quiz-option" data-correct="false">Snapshot</li>
  </ul>
  <div class="quiz-explanation">
    <strong>Explanation:</strong> Staging models are typically materialized as views or ephemeral because they're cheap to rebuild and are queried by downstream models rather than end users.
  </div>
</div>

## How to Create Your Own Quiz

Use the following HTML structure in your markdown files:

```html
<div class="quiz-container">
  <div class="quiz-question">Your question here?</div>
  <ul class="quiz-options">
    <li class="quiz-option" data-correct="false">Wrong answer 1</li>
    <li class="quiz-option" data-correct="true">Correct answer</li>
    <li class="quiz-option" data-correct="false">Wrong answer 2</li>
    <li class="quiz-option" data-correct="false">Wrong answer 3</li>
  </ul>
  <div class="quiz-explanation">
    <strong>Explanation:</strong> Optional explanation text that appears after answering.
  </div>
</div>
```

### Key Points:

1. Set `data-correct="true"` on the correct answer
2. Set `data-correct="false"` on all incorrect answers
3. The explanation div is optional - remove it if you don't need it
4. Once a user clicks an answer, they can't change it
5. Wrong answers will show in red, correct answer will show in green
6. If the user clicks wrong, the correct answer will also be highlighted
