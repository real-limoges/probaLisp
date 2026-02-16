;;;; tests/main.lisp

(in-package #:probalisp/tests)

(def-suite :probalisp
  :description "Test suite for probalisp")

(in-suite :probalisp)

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

(test mixed-distribution-composition
  "Test composition of different distribution types"
  (let ((dist (>>= (uniform 0.1 0.9)
                   (lambda (p)
                     (>>= (binomial 10 p)
                          (lambda (n)
                            (return-prob (list p n))))))))
    (let ((result (run-prob dist)))
      (is (listp result))
      (is (= 2 (length result)))
      (destructuring-bind (p n) result
        (is (<= 0.1 p 0.9))
        (is (<= 0 n 10))))))

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

(test reproducibility-exponential
  "Test exponential reproducibility with same seed"
  (let* ((seed (make-random-state t))
         (state1 (make-random-state seed))
         (state2 (make-random-state seed))
         (dist (exponential 2.0)))
    (multiple-value-bind (sample1 _)
        (funcall dist state1)
      (declare (ignore _))
      (multiple-value-bind (sample2 _)
          (funcall dist state2)
        (declare (ignore _))
        (is (= sample1 sample2))))))
