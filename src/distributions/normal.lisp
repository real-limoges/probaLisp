;;;; normal.lisp
;;;; Normal distribution implementation

(in-package #:probalisp)

(defun box-muller-sample (&optional (rng-state *random-state*))
  "Sample two independent standard normal variables using Box-Muller transform.
   Returns: Multiple values: (z1 z2 new-state)"
  (let ((state (make-random-state rng-state)))
    (let* ((u1 (loop for rand = (random 1.0 state)
                     unless (zerop rand)
                     return rand))
           (u2 (random 1.0 state))
           (r (sqrt (* -2.0 (log u1))))
           (theta (* 2.0 3.141592653589793d0 u2)))
      (values
        (* r (cos theta))
        (* r (sin theta))
        state))))

(defun normal-sample (mu sigma &optional (rng-state *random-state*))
  "Sample from Normal(mu, sigma) using Box-Muller transform.
   Returns: Multiple values: (sample new-state)"
  (assert (numberp mu) (mu) "mu must be a number, got ~A" mu)
  (assert (numberp sigma) (sigma) "sigma must be a number, got ~A" sigma)
  (assert (> sigma 0) (sigma) "sigma must be positive, got ~A" sigma)
  
  (let ((state (make-random-state rng-state)))
    (multiple-value-bind (z1 z2 new-state) (box-muller-sample state)
      (declare (ignore z2))
      (values
        (+ mu (* sigma z1))
        new-state))))

;; Church encoding: distribution as a function
(defun normal (mu sigma)
  "Create a normal distribution as a first-class function
  Returns: A function (lambda (rng-state) -> (values sample new-state))"
  (lambda (rng-state)
    (normal-sample mu sigma rng-state)))