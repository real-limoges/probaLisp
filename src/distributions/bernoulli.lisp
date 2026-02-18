;;;; bernoulli.lisp
;;;; Bernoulli distribution implementation

(in-package #:probalisp)

;;;; Pure sampling function
(defun bernoulli-sample (p &optional (rng-state *random-state*))
  "Sample from Bernoulli(p).
     Returns: Multiple values: (sample-value new-random-state)"
  (assert (and (numberp p) (<= 0 p 1)) (p)
      "p must be in [0, 1], got ~A" p)

  (let ((state (make-random-state rng-state)))
    (values
      (< (random 1.0 state) p)
      state)))

;;; Church encoding: distribution as a function
(defun bernoulli (p)
  "Create a Bernoulli distribution as a first-class function.
    Returns: A function (lambda (rng-state) -> (values sample new-state))"

  (lambda (rng-state)
    (bernoulli-sample p rng-state)))