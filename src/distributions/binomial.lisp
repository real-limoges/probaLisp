;;;; binomial.lisp
;;;; Binomial distribution implementation

(in-package #:probalisp)

;;; Pure sampling function
(defun binomial-sample (n p &optional (rng-state *random-state*))
  "Sample from Binomial(n, p) using Bernoulli trials.

   Returns: Multiple values: (sample-value new-random-state)"
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
      state)))

;;; Church encoding: distribution as a function
(defun binomial (n p)
  "Create a binomial distribution as a first-class function.

   Returns: A function (lambda (rng-state) -> (values sample new-state))"

  (lambda (rng-state)
    (binomial-sample n p rng-state)))
