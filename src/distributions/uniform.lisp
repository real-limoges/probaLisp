;;;; uniform.lisp
;;;; Uniform distribution implementation

(in-package #:probalisp)

;;; Pure sampling function
(defun uniform-sample (a b &optional (rng-state *random-state*))
  "Sample from Uniform(a, b)
    
    Returns: Multiple values: (sample-value new-random-state)"
  (assert (and (numberp a) (numberp b) (< a b)) (a b)
      "a and b must be numbers with a < b, got ~A and ~A" a b)

  (let ((state (make-random-state rng-state)))
    (values
      (+ a (* (- b a) (random 1.0 state)))
      state)))

;; Church encoding: distribution as a function
(defun uniform (a b)
  "Create a uniform distribution as a first-class function
  Returns: A function (lambda (rng-state) -> (values sample new-state))"
  (lambda (rng-state)
    (uniform-sample a b rng-state)))