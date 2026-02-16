;;;; tests/distributions/normal-test.lisp

(in-package #:probalisp/tests)

(in-suite :probalisp)

;;; Tests for normal-sample
(test normal-sample-basic
  "Test basic normal sampling properties"
  ;; Sample from standard normal should be a number
  (let ((sample (normal-sample 0.0 1.0)))
    (is (numberp sample)))

  ;; Sample from N(10, 2) should be around 10
  ;; (not a strict test, just checking it works)
  (let ((sample (normal-sample 10.0 2.0)))
    (is (numberp sample))))

(test normal-sample-returns-two-values
  "Test that normal-sample returns both sample and new state"
  (multiple-value-bind (sample state)
      (normal-sample 0.0 1.0 *random-state*)
    (is (numberp sample))
    (is (typep state 'random-state))
    (is (not (eq state *random-state*)))))

(test normal-sample-purity
  "Test that normal-sample doesn't modify input state"
  (let* ((original-state (make-random-state *random-state*))
         (state-copy (make-random-state original-state)))
    (normal-sample 0.0 1.0 original-state)
    (is (= (random 1000 original-state)
           (random 1000 state-copy)))))

(test normal-sample-parameter-validation
  "Test parameter validation"
  ;; sigma <= 0 should signal error
  (signals error (normal-sample 0.0 0))
  (signals error (normal-sample 0.0 -1.0)))

(test normal-returns-function
  "Test that normal returns a function"
  (let ((dist (normal 0.0 1.0)))
    (is (functionp dist))))
