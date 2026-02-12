;;;; examples.lisp
;;;; Usage examples for probaLisp

(in-package #:probaLisp)

;;; Example 1: Simple sampling
;;; Sample from Binomial(10, 0.5)
(defun example-1 ()
  "Simple binomial sampling"
  (run-prob (binomial 10 0.5)))

;;; Example 2: Composing distributions with >>=
;;; Sample from binomial, then use that result as parameter to another binomial
(defun example-2 ()
  "Compose two binomial distributions"
  (run-prob
   (>>= (binomial 10 0.5)
        (lambda (x)
          (binomial x 0.3)))))

;;; Example 3: Multiple compositions
;;; Sample three times in sequence
(defun example-3 ()
  "Chain multiple samples together"
  (run-prob
   (>>= (binomial 20 0.6)
        (lambda (x)
          (>>= (binomial x 0.5)
               (lambda (y)
                 (binomial y 0.4)))))))

;;; Example 4: Using fmap to transform results
;;; Sample and then apply a transformation
(defun example-4 ()
  "Transform the result of sampling"
  (run-prob
   (fmap (lambda (x) (* x 2))
         (binomial 10 0.5))))

;;; Example 5: Building a more complex model
;;; Model where we flip coins and track successes
(defun coin-flip-model (n-rounds rounds-prob success-prob)
  "A model that samples number of rounds, then success in each round"
  (>>= (binomial n-rounds rounds-prob)
       (lambda (actual-rounds)
         (>>= (binomial actual-rounds success-prob)
              (lambda (successes)
                (return-prob
                 (list :rounds actual-rounds
                       :successes successes
                       :rate (/ successes (max actual-rounds 1)))))))))

(defun example-5 ()
  "Run the coin flip model"
  (run-prob (coin-flip-model 100 0.8 0.6)))

;;; Example 6: Multiple samples with explicit state threading
(defun example-6 ()
  "Generate multiple independent samples"
  (let ((dist (binomial 10 0.5)))
    (multiple-value-bind (sample1 state1)
        (funcall dist *random-state*)
      (multiple-value-bind (sample2 state2)
          (funcall dist state1)
        (multiple-value-bind (sample3 state3)
            (funcall dist state2)
          (declare (ignore state3))
          (list sample1 sample2 sample3))))))

;;; To try these examples:
;;; (ql:quickload :probaLisp)
;;; (in-package :probaLisp)
;;; (example-1)
;;; (example-2)
;;; etc.
