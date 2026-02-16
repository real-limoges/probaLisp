;;;; examples.lisp
;;;; Usage examples for probalisp

(in-package #:probalisp)

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

;;; Example 7: Simple exponential sampling
;;; Sample from Exp(1.5) - mean waiting time = 1/1.5 ≈ 0.67
(defun example-7 ()
  "Simple exponential sampling"
  (run-prob (exponential 1.5)))

;;; Example 8: Composing exponential with binomial
;;; Model: wait for an exponential time, then flip coins based on that
(defun example-8 ()
  "Use exponential result to parameterize a binomial"
  (run-prob
   (>>= (exponential 2.0)
        (lambda (wait-time)
          (>>= (binomial 10 0.5)
               (lambda (flips)
                 (return-prob
                  (list :wait-time wait-time
                        :flips flips))))))))

;;; Example 9: Modeling time between events
;;; Simulate arrival times for a Poisson process (rate = 3 events/unit time)
(defun arrival-times-model (n-events rate)
  "Generate n arrival times for events with exponential inter-arrival times"
  (labels ((generate-arrivals (remaining current-time acc)
             (if (<= remaining 0)
                 (return-prob (reverse acc))
                 (>>= (exponential rate)
                      (lambda (inter-arrival)
                        (let ((arrival-time (+ current-time inter-arrival)))
                          (generate-arrivals (1- remaining)
                                           arrival-time
                                           (cons arrival-time acc))))))))
    (generate-arrivals n-events 0.0 nil)))

(defun example-9 ()
  "Generate 5 arrival times with rate 3.0"
  (run-prob (arrival-times-model 5 3.0)))

;;; Example 10: Transform exponential samples
;;; Sample waiting time and convert to integer seconds
(defun example-10 ()
  "Transform exponential result using fmap"
  (run-prob
   (fmap (lambda (time) (ceiling time))
         (exponential 0.5))))

;;; Example 11: Simple uniform sampling
;;; Sample from Uniform(0, 10)
(defun example-11 ()
  "Simple uniform sampling"
  (run-prob (uniform 0.0 10.0)))

;;; Example 12: Composing uniform with binomial
;;; Sample a probability from Uniform(0,1), then use it for a binomial
(defun example-12 ()
  "Use a uniform sample as a binomial probability"
  (run-prob
   (>>= (uniform 0.0 1.0)
        (lambda (p)
          (>>= (binomial 20 p)
               (lambda (successes)
                 (return-prob
                  (list :prob p :successes successes))))))))

;;; Example 13: Simple geometric sampling
;;; Sample from Geometric(0.3) - expected number of failures before first success
(defun example-13 ()
  "Simple geometric sampling"
  (run-prob (geometric 0.3)))

;;; Example 14: Composing geometric with uniform
;;; Model: sample a success probability, then count failures until first success
(defun example-14 ()
  "Use a uniform sample as geometric probability"
  (run-prob
   (>>= (uniform 0.1 0.9)
        (lambda (p)
          (>>= (geometric p)
               (lambda (failures)
                 (return-prob
                  (list :prob p :failures-before-success failures))))))))

;;; Example 15: Combining all distributions
;;; A model that uses binomial, exponential, uniform, and geometric together
(defun example-15 ()
  "Combine all four distributions in a single model"
  (run-prob
   (>>= (uniform 0.2 0.8)
        (lambda (p)
          (>>= (binomial 10 p)
               (lambda (successes)
                 (>>= (geometric p)
                      (lambda (wait)
                        (>>= (exponential 1.0)
                             (lambda (time)
                               (return-prob
                                (list :p p
                                      :successes successes
                                      :wait-until-success wait
                                      :time time))))))))))))

;;; To try these examples:
;;; (ql:quickload :probalisp)
;;; (in-package :probalisp)
;;; (example-1)
;;; (example-2)
;;; etc.
