;;;; probaLisp.asd

(asdf:defsystem #:probaLisp
  :description "A probabilistic programming language in Common Lisp"
  :author "Real <b.real.limoges@gmail.com>"
  :license "MIT"
  :version "0.0.1"
  :serial t
  :pathname "src/"
  :components ((:file "package")
               (:file "probaLisp")
               (:file "monad")
               (:module "distributions"
                :components ((:file "binomial"))))
  :in-order-to ((test-op (test-op #:probaLisp/tests))))

(asdf:defsystem #:probaLisp/tests
  :description "Tests for probaLisp"
  :author "Your Name <your.name@example.com>"
  :license "Specify license here"
  :depends-on (#:probaLisp #:fiveam)
  :pathname "tests/"
  :components ((:file "package")
               (:file "main"))
  :perform (test-op (o c) (symbol-call :fiveam :run! :probaLisp)))
