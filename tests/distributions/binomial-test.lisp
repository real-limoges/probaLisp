;;;; tests/distributions/binomial-test.lisp

(in-package #:probalisp/tests)

(in-suite :probalisp)

;;; Tests for binomial-sample
(test binomial-sample-basic
  "Test basic binomial sampling properties"
  ;; With n=0, should always return 0
  (is (= 0 (binomial-sample 0 0.5)))

  ;; With p=0, should always return 0
  (is (= 0 (binomial-sample 10 0)))

  ;; With p=1, should always return n
  (is (= 10 (binomial-sample 10 1)))

  ;; Result should be in valid range [0, n]
  (let ((sample (binomial-sample 20 0.5)))
    (is (<= 0 sample 20))))

(test binomial-sample-returns-two-values
  "Test that binomial-sample returns both sample and new state"
  (multiple-value-bind (sample state)
      (binomial-sample 10 0.5 *random-state*)
    (is (integerp sample))
    (is (typep state 'random-state))
    ;; State should be different from input
    (is (not (eq state *random-state*)))))

(test binomial-sample-purity
  "Test that binomial-sample doesn't modify input state"
  (let* ((original-state (make-random-state *random-state*))
         (state-copy (make-random-state original-state)))
    (binomial-sample 10 0.5 original-state)
    ;; Generate same sequence to verify state unchanged
    (is (= (random 1000 original-state)
           (random 1000 state-copy)))))

(test binomial-sample-parameter-validation
  "Test parameter validation"
  ;; Negative n should signal error
  (signals error (binomial-sample -1 0.5))

  ;; p outside [0,1] should signal error
  (signals error (binomial-sample 10 -0.1))
  (signals error (binomial-sample 10 1.5)))

;;; Tests for Church encoding
(test binomial-returns-function
  "Test that binomial returns a function"
  (let ((dist (binomial 10 0.5)))
    (is (functionp dist))))

(test binomial-function-works
  "Test that the returned function samples correctly"
  (let ((dist (binomial 10 0.5)))
    (multiple-value-bind (sample state)
        (funcall dist *random-state*)
      (is (integerp sample))
      (is (<= 0 sample 10))
      (is (typep state 'random-state)))))
