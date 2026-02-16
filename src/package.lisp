;;;; package.lisp

(defpackage #:probalisp
  (:use #:cl)
  (:export
   ;; Distributions
   #:binomial
   #:binomial-sample
   #:exponential
   #:exponential-sample
   #:uniform
   #:uniform-sample
   #:geometric
   #:geometric-sample
   #:normal
   #:normal-sample

   ;; Probability monad
   #:return-prob
   #:>>=
   #:>>
   #:fmap
   #:run-prob
   #:run-prob-with-state))
