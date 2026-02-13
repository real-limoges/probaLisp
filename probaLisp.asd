;;;; probalisp.asd

(asdf:defsystem #:probalisp
  :description "A probabilistic programming language in Common Lisp"
  :author "Real <b.real.limoges@gmail.com>"
  :license "MIT"
  :version "0.0.1"
  :serial t
  :pathname "src/"
  :components ((:file "package")
               (:file "probalisp")
               (:file "monad")
               (:module "distributions"
                :components ((:file "binomial"))))
  :in-order-to ((test-op (test-op #:probalisp/tests))))

(asdf:defsystem #:probalisp/tests
  :description "Tests for probalisp"
  :author "Your Name <your.name@example.com>"
  :license "Specify license here"
  :depends-on (#:probalisp #:fiveam)
  :pathname "tests/"
  :components ((:file "package")
               (:file "main"))
  :perform (test-op (o c) (symbol-call :fiveam :run! :probalisp)))
