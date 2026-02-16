;;;; geometric.lisp
;;;; Geometric distribution implementation

(in-package #:probalisp)

(defun geometric-sample (p &optional (rng-state *random-state*))
  "Sample from Geometric(p) - number of failures before first success.

   Args:
     p: Success probability, must be in (0, 1]

   Returns: Multiple values: (sample-value new-random-state)"
  (assert (and (numberp p) (> p 0) (<= p 1)) (p)
      "p must be in (0, 1], got ~A" p)

  (let ((state (make-random-state rng-state)))
    ;; Handle edge case: if p=1, always succeed on first trial (0 failures)
    (if (= p 1)
        (values 0 state)
        ;; Inverse transform sampling: use ceiling of log(U)/log(1-p) - 1
        ;; Ensure U is in (0,1) to avoid log(0)
        (let ((u (loop for rand = (random 1.0d0 state)
                       unless (zerop rand)
                       return rand)))
          (values
            (floor (/ (log u) (log (- 1 p))))
            state)))))

;; Church encoding: distribution as a function
(defun geometric (p)
  "Create a geometric distribution as a first-class function
     Returns: A function (lambda (rng-state) -> (values sample new-state))"
  (lambda (rng-state)
    (geometric-sample p rng-state)))