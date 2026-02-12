;;;; binomial.lisp
;;;; Binomial distribution implementation

(in-package #:probaLisp)

;;; Pure sampling function
(defun binomial-sample (n p &optional (rng-state *random-state*))
  "Sample from Binomial(n, p) using Bernoulli trials.

   Args:
     n: number of trials (non-negative integer)
     p: success probability (0 <= p <= 1)
     rng-state: random state to use (optional, defaults to *random-state*)

   Returns:
     Multiple values: (sample-value new-random-state)

   This is a pure function - it doesn't modify the input rng-state,
   but returns a new one along with the sampled value."
  (assert (and (integerp n) (>= n 0)) (n)
          "n must be a non-negative integer, got ~A" n)
  (assert (and (numberp p) (<= 0 p 1)) (p)
          "p must be in [0, 1], got ~A" p)

  ;; Create a new random state to preserve purity
  (let ((state (make-random-state rng-state)))
    (values
     ;; Count successes from n Bernoulli trials
     (loop repeat n
           count (< (random 1.0 state) p))
     ;; Return the new state
     state)))

;;; Church encoding: distribution as a function
(defun binomial (n p)
  "Create a binomial distribution as a first-class function.

   Args:
     n: number of trials
     p: success probability

   Returns:
     A function (lambda (rng-state) -> (values sample new-state))

   Example:
     (let ((dist (binomial 10 0.5)))
       (funcall dist *random-state*))  ; => sample value, new state"
  (lambda (rng-state)
    (binomial-sample n p rng-state)))
