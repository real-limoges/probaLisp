(defsystem "probalisp"
  :description "Probabilistic programming library for Common Lisp using Church encoding and monadic composition"
  :version "0.1.0"
  :author "Your Name"
  :license "MIT"
  :depends-on ()
  :serial t
  :components ((:file "src/package")
               (:file "src/probalisp")
               (:file "src/monad")
               (:module "distributions"
                :pathname "src/distributions"
                :serial t
                :components ((:file "binomial")
                             (:file "bernoulli")
                             (:file "exponential")
                             (:file "geometric")
                             (:file "normal")
                             (:file "poisson")
                             (:file "uniform"))))
  :in-order-to ((test-op (test-op "probalisp/tests"))))

(defsystem "probalisp/tests"
  :description "Test suite for probalisp"
  :depends-on ("probalisp" "fiveam")
  :serial t
  :components ((:file "tests/package")
               (:file "tests/main")
               (:file "tests/monad-test")
               (:module "distributions"
                :pathname "tests/distributions"
                :serial t
                :components ((:file "binomial-test")
                             (:file "exponential-test")
                             (:file "geometric-test")
                             (:file "normal-test")
                             (:file "uniform-test"))))
  :perform (test-op (o c) (symbol-call :fiveam :run! :probalisp)))
