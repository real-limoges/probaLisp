;;;; monad.lisp
;;;; Probability monad - monadic combinators for composing distributions

(in-package #:probalisp)

;;; The probability monad
;;; A probabilistic computation is a function: RandomState -> (values Result RandomState)

(defun return-prob (value)
  "Lift a pure value into the probability monad."
  (lambda (rng-state)
    (values value rng-state)))

(defun >>= (dist fn)
  "Monadic bind for probability distributions.

   Args:
     dist: a probabilistic computation (rng-state -> (values result state))
     fn: a function (result -> probabilistic computation)

   Returns:
     A new probabilistic computation that:
       1. Runs dist to get a sample and new state
       2. Passes the sample to fn to get a new distribution
       3. Runs that distribution with the new state

   This is the key combinator for sequencing probabilistic computations.

   Example:
     ;; Sample from binomial, then use result as parameter to another binomial
     (>>= (binomial 10 0.5)
          (lambda (x) (binomial x 0.3)))"
  (lambda (rng-state)
    (multiple-value-bind (result new-state)
        (funcall dist rng-state)
      (funcall (funcall fn result) new-state))))

(defun >> (dist1 dist2)
  "Sequence two distributions, discarding the result of the first.

   Returns:
     A distribution that runs both in sequence

   Example:
     (>> (binomial 5 0.5)    ; sample but ignore
         (binomial 10 0.7))  ; return this"
  (>>= dist1 (lambda (ignored)
               (declare (ignore ignored))
               dist2)))

(defun fmap (fn dist)
  "Map a pure function over a distribution (functor operation)"
  (>>= dist (lambda (x) (return-prob (funcall fn x)))))

(defun run-prob (dist &optional (rng-state (make-random-state t)))
  "Run a probabilistic computation and return just the value.

   By default, creates a fresh random state seeded from the current time,
   so each call produces different results. Pass an explicit state for reproducibility."
  (nth-value 0 (funcall dist rng-state)))

(defun run-prob-with-state (dist &optional (rng-state *random-state*))
  "Run a probabilistic computation and return both value and final state."
  (funcall dist rng-state))
