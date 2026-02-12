;;;; tests/main.lisp

(in-package #:probaLisp/tests)

(def-suite :probaLisp
  :description "Test suite for probaLisp")

(in-suite :probaLisp)

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

;;; Tests for monadic combinators
(test return-prob-basic
  "Test return-prob lifts values"
  (let ((dist (return-prob 42)))
    (is (= 42 (run-prob dist)))))

(test bind-composition
  "Test >>= composes distributions"
  (let* ((dist (>>= (return-prob 5)
                    (lambda (x) (return-prob (* x 2)))))
         (result (run-prob dist)))
    (is (= 10 result))))

(test bind-threads-state
  "Test that >>= threads state correctly"
  (let ((dist (>>= (binomial 10 0.5)
                   (lambda (x) (binomial x 0.5)))))
    (multiple-value-bind (result state)
        (funcall dist *random-state*)
      (is (integerp result))
      (is (typep state 'random-state)))))

(test fmap-transforms
  "Test fmap transforms results"
  (let* ((dist (fmap (lambda (x) (* x 2))
                     (return-prob 21)))
         (result (run-prob dist)))
    (is (= 42 result))))

(test sequence-operator
  "Test >> sequences and discards first result"
  (let* ((dist (>> (return-prob 99)
                   (return-prob 42)))
         (result (run-prob dist)))
    (is (= 42 result))))

;;; Integration tests
(test complex-composition
  "Test complex composition of distributions"
  (let ((dist (>>= (binomial 20 0.6)
                   (lambda (x)
                     (>>= (binomial x 0.5)
                          (lambda (y)
                            (return-prob (list x y))))))))
    (let ((result (run-prob dist)))
      (is (listp result))
      (is (= 2 (length result)))
      (destructuring-bind (x y) result
        (is (<= 0 x 20))
        (is (<= 0 y x))))))

(test reproducibility-with-seed
  "Test that same seed gives same results"
  (let* ((seed (make-random-state t))
         (state1 (make-random-state seed))
         (state2 (make-random-state seed))
         (dist (binomial 100 0.5)))
    (multiple-value-bind (sample1 _)
        (funcall dist state1)
      (declare (ignore _))
      (multiple-value-bind (sample2 _)
          (funcall dist state2)
        (declare (ignore _))
        (is (= sample1 sample2))))))
