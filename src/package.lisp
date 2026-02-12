;;;; package.lisp

(defpackage #:probaLisp
  (:use #:cl)
  (:export
   ;; Distributions
   #:binomial
   #:binomial-sample

   ;; Probability monad
   #:return-prob
   #:>>=
   #:>>
   #:fmap
   #:run-prob
   #:run-prob-with-state))
