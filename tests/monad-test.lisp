;;;; tests/monad-test.lisp

(in-package #:probalisp/tests)

(in-suite :probalisp)

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
