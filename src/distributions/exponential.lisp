;;;; exponential.lisp
;;;; Exponential distribution implementation

(in-package #:probalisp)

;;; Pure sampling function
(defun exponential-sample (lam &optional (rng-state *random-state*))
  "Sample from Exp(lambda)

    Returns: Multiple values: (sample-value new-random-state)"
  (assert (and (numberp lam) (> lam 0)) (lam)
      "lambda must be in (0, inf), got ~A" lam)

  (let ((state (make-random-state rng-state)))
    (let ((u (loop for rand = (random 1.0 state)
                   unless (zerop rand)
                   return rand)))
      (values (/ (- (log u)) lam) state))))


;; Church encoding: distribution as a function
(defun exponential (lam)
  "Create an exponential distribution as a first-class function
   Returns: A function (lambda (rng-state) -> (values sample new-state))"

  (lambda (rng-state)
    (exponential-sample lam rng-state)))