;;;; tests/distributions/exponential-test.lisp

(in-package #:probalisp/tests)

(in-suite :probalisp)

;;; Tests for exponential-sample
(test exponential-sample-basic
  "Test basic exponential sampling properties"
  ;; Sample should always be non-negative
  (let ((sample (exponential-sample 1.0)))
    (is (>= sample 0)))

  ;; Multiple samples to check consistency
  (dotimes (i 10)
    (let ((sample (exponential-sample 2.0)))
      (is (numberp sample))
      (is (>= sample 0)))))

(test exponential-sample-returns-two-values
  "Test that exponential-sample returns both sample and new state"
  (multiple-value-bind (sample state)
      (exponential-sample 1.0 *random-state*)
    (is (numberp sample))
    (is (typep state 'random-state))
    (is (not (eq state *random-state*)))))

(test exponential-sample-purity
  "Test that exponential-sample doesn't modify input state"
  (let* ((original-state (make-random-state *random-state*))
         (state-copy (make-random-state original-state)))
    (exponential-sample 1.0 original-state)
    (is (= (random 1000 original-state)
           (random 1000 state-copy)))))

(test exponential-sample-parameter-validation
  "Test parameter validation"
  ;; lambda <= 0 should signal error
  (signals error (exponential-sample 0))
  (signals error (exponential-sample -1.0)))

(test exponential-returns-function
  "Test that exponential returns a function"
  (let ((dist (exponential 1.0)))
    (is (functionp dist))))
