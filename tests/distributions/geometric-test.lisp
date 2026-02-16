;;;; tests/distributions/geometric-test.lisp

(in-package #:probalisp/tests)

(in-suite :probalisp)

;;; Tests for geometric-sample
(test geometric-sample-basic
  "Test basic geometric sampling properties"
  ;; With p=1, should always return 0
  (is (= 0 (geometric-sample 1.0)))

  ;; Sample should always be non-negative integer
  (let ((sample (geometric-sample 0.5)))
    (is (integerp sample))
    (is (>= sample 0)))

  ;; High probability should give lower values on average
  (let ((samples (loop repeat 100 collect (geometric-sample 0.9))))
    (is (< (/ (reduce #'+ samples) 100) 5))))

(test geometric-sample-returns-two-values
  "Test that geometric-sample returns both sample and new state"
  (multiple-value-bind (sample state)
      (geometric-sample 0.5 *random-state*)
    (is (integerp sample))
    (is (typep state 'random-state))
    (is (not (eq state *random-state*)))))

(test geometric-sample-purity
  "Test that geometric-sample doesn't modify input state"
  (let* ((original-state (make-random-state *random-state*))
         (state-copy (make-random-state original-state)))
    (geometric-sample 0.5 original-state)
    (is (= (random 1000 original-state)
           (random 1000 state-copy)))))

(test geometric-sample-parameter-validation
  "Test parameter validation"
  ;; p <= 0 or p > 1 should signal error
  (signals error (geometric-sample 0))
  (signals error (geometric-sample -0.1))
  (signals error (geometric-sample 1.5)))

(test geometric-returns-function
  "Test that geometric returns a function"
  (let ((dist (geometric 0.5)))
    (is (functionp dist))))
