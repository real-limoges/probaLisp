;;;; tests/distributions/uniform-test.lisp

(in-package #:probalisp/tests)

(in-suite :probalisp)

;;; Tests for uniform-sample
(test uniform-sample-basic
  "Test basic uniform sampling properties"
  ;; Sample should be in range [a, b]
  (let ((sample (uniform-sample 0.0 10.0)))
    (is (<= 0.0 sample 10.0)))

  ;; Test with negative range
  (let ((sample (uniform-sample -5.0 5.0)))
    (is (<= -5.0 sample 5.0))))

(test uniform-sample-returns-two-values
  "Test that uniform-sample returns both sample and new state"
  (multiple-value-bind (sample state)
      (uniform-sample 0.0 1.0 *random-state*)
    (is (numberp sample))
    (is (typep state 'random-state))
    (is (not (eq state *random-state*)))))

(test uniform-sample-purity
  "Test that uniform-sample doesn't modify input state"
  (let* ((original-state (make-random-state *random-state*))
         (state-copy (make-random-state original-state)))
    (uniform-sample 0.0 1.0 original-state)
    (is (= (random 1000 original-state)
           (random 1000 state-copy)))))

(test uniform-sample-parameter-validation
  "Test parameter validation"
  ;; a >= b should signal error
  (signals error (uniform-sample 10.0 5.0))
  (signals error (uniform-sample 5.0 5.0)))

(test uniform-returns-function
  "Test that uniform returns a function"
  (let ((dist (uniform 0.0 1.0)))
    (is (functionp dist))))
