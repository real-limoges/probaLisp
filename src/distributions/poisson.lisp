;;;; poisson.lisp
;;;; Poisson distribution implementation

(in-package #:probalisp)

;;; Pure sampling function
(defun poisson-sample (lam &optional (rng-state *random-state*))
  "Sample from Poisson(lam) using the Knuth algorithm."

  (assert (and (numberp lam) (> lam 0)) (lam)
      "lam must be a positive number, got ~A" lam)

  (let ((state (make-random-state rng-state)))
    (if (< lam 30)
        ;; Use Knuth's algorithm for small lambda
        (let ((L (exp (- lam)))
              (k 0)
              (p 1.0))
          (loop
           (setf k (1+ k))
           (setf p (* p (random 1.0 state)))
           (when (< p L)
                 (return (values (1- k) state)))))
        ;; For larger lambda, use a normal approximation
        (let ((normal-sample-fn (normal lam (sqrt lam))))
          (multiple-value-bind (sampled-value new-state)
              (funcall normal-sample-fn state)
            ;; Round to nearest integer and ensure non-negativity
            (values (max 0 (round sampled-value)) new-state))))))


;;; Church encoding: distribution as a function
(defun poisson (lam)
  "Create a Poisson distribution as a first-class function.
    Returns: A function (lambda (rng-state) -> (values sample new-state))"
  (lambda (rng-state)
    (poisson-sample lam rng-state)))