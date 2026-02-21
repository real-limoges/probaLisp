;;;; server.lisp
;;;; TCP server for probalisp - newline-delimited JSON protocol over TCP
;;;;
;;;; Protocol: one JSON object per line, one JSON response per line.
;;;; Supported ops:
;;;;   {"op":"list"}
;;;;     -> {"status":"ok","distributions":["binomial","normal",...]}
;;;;   {"op":"describe","distribution":"NAME"}
;;;;     -> {"status":"ok","name":"NAME","params":["p1",...],"description":"..."}
;;;;   {"op":"sample","distribution":"NAME","params":{...}}
;;;;     -> {"status":"ok","sample":<value>}
;;;;   {"op":"compose","steps":[{"distribution":"NAME","params":{...}},...]}
;;;;     -> {"status":"ok","sample":<value>}

(in-package #:probalisp)

;;; Distribution registry - name -> plist with :params and :description

(defparameter *distribution-info*
  '(("binomial"    :params ("n" "p")
                   :description "Binomial(n, p) - count of successes in n trials each with probability p")
    ("bernoulli"   :params ("p")
                   :description "Bernoulli(p) - 1 with probability p, 0 otherwise")
    ("exponential" :params ("lambda")
                   :description "Exponential(lambda) - waiting time with rate lambda")
    ("geometric"   :params ("p")
                   :description "Geometric(p) - number of trials until first success")
    ("normal"      :params ("mu" "sigma")
                   :description "Normal(mu, sigma) - Gaussian distribution")
    ("poisson"     :params ("lambda")
                   :description "Poisson(lambda) - count of events in a fixed interval")
    ("uniform"     :params ("a" "b")
                   :description "Uniform(a, b) - uniform distribution on [a, b]"))
  "Registry of known distributions and their metadata.")

(defun distribution-names ()
  "Return list of known distribution name strings."
  (mapcar #'car *distribution-info*))

(defun distribution-entry (name)
  "Return the plist for NAME, or NIL if unknown."
  (cdr (assoc name *distribution-info* :test #'string=)))

;;; Build a distribution function from a JSON-decoded name + params alist.
;;; cl-json decodes JSON object keys as keywords (uppercase), so
;;; {"n":10,"p":0.5} -> ((:N . 10) (:P . 0.5)).

(defun build-distribution (name params)
  "Build a distribution thunk from NAME (string) and PARAMS (keyword alist).
   Signals an error for unknown distributions or missing parameters."
  (flet ((param (key)
           (let ((pair (assoc key params)))
             (unless pair
               (error "Missing parameter ~A for distribution ~A" key name))
             (cdr pair))))
    (cond
      ((string= name "binomial")
       (binomial (round (param :n)) (param :p)))
      ((string= name "bernoulli")
       (bernoulli (param :p)))
      ((string= name "exponential")
       (exponential (param :lambda)))
      ((string= name "geometric")
       (geometric (param :p)))
      ((string= name "normal")
       (normal (param :mu) (param :sigma)))
      ((string= name "poisson")
       (poisson (param :lambda)))
      ((string= name "uniform")
       (uniform (param :a) (param :b)))
      (t
       (error "Unknown distribution: ~A" name)))))

;;; Response constructors - produce alists that cl-json encodes as JSON objects.
;;; cl-json encodes keyword keys as lowercase strings:
;;;   :status -> "status", :sample -> "sample", etc.

(defun ok (&rest pairs)
  "Build a success response alist.  (ok (cons :foo 1)) -> {\"status\":\"ok\",\"foo\":1}"
  (cons (cons :status "ok") pairs))

(defun err (message)
  "Build an error response alist."
  (list (cons :status "error") (cons :message message)))

;;; Operation handlers

(defun op-list (req)
  (declare (ignore req))
  (ok (cons :distributions (distribution-names))))

(defun op-describe (req)
  (let* ((name (cdr (assoc :distribution req)))
         (entry (distribution-entry name)))
    (if entry
        (ok (cons :name name)
            (cons :params (getf entry :params))
            (cons :description (getf entry :description)))
        (err (format nil "Unknown distribution: ~A" name)))))

(defun op-sample (req)
  (handler-case
      (let* ((name (cdr (assoc :distribution req)))
             (params (cdr (assoc :params req)))
             (dist (build-distribution name params))
             (value (run-prob dist)))
        (ok (cons :sample value)))
    (error (e)
      (err (format nil "~A" e)))))

(defun op-compose (req)
  "Run a sequence of distributions in order, returning the last sample."
  (handler-case
      (let* ((steps (cdr (assoc :steps req))))
        (unless steps
          (error "compose requires at least one step"))
        (let* ((first-step (first steps))
               (initial (build-distribution (cdr (assoc :distribution first-step))
                                            (cdr (assoc :params first-step))))
               (composed (reduce (lambda (acc step)
                                   (let ((name (cdr (assoc :distribution step)))
                                         (params (cdr (assoc :params step))))
                                     (>> acc (build-distribution name params))))
                                 (rest steps)
                                 :initial-value initial))
               (value (run-prob composed)))
          (ok (cons :sample value))))
    (error (e)
      (err (format nil "~A" e)))))

;;; Dispatch

(defun dispatch (line)
  "Parse LINE as a JSON request and return a response alist."
  (handler-case
      (let* ((req (cl-json:decode-json-from-string line))
             (op (cdr (assoc :op req))))
        (cond
          ((string= op "list")     (op-list req))
          ((string= op "describe") (op-describe req))
          ((string= op "sample")   (op-sample req))
          ((string= op "compose")  (op-compose req))
          (t (err (format nil "Unknown op: ~A" op)))))
    (error (e)
      (err (format nil "Parse error: ~A" e)))))

;;; TCP server

(defun get-port ()
  "Return the port number from PROBALISP_PORT env var, defaulting to 4001."
  (let ((env (uiop:getenv "PROBALISP_PORT")))
    (if env (parse-integer env) 4001)))

(defun handle-client (socket)
  "Read newline-delimited JSON requests from SOCKET and write responses."
  (let ((stream (usocket:socket-stream socket)))
    (handler-case
        (loop for line = (read-line stream nil nil)
              while line
              do (let ((response (cl-json:encode-json-to-string (dispatch line))))
                   (write-string response stream)
                   (write-char #\Newline stream)
                   (force-output stream)))
      (error (e)
        (format *error-output* "Client handler error: ~A~%" e)
        (force-output *error-output*)))))

(defun start-server ()
  "Start the probalisp TCP server.

   Listens on 0.0.0.0:PROBALISP_PORT (default 4001).
   Accepts one connection at a time, serving newline-delimited JSON.

   Supported ops: list, describe, sample, compose."
  (let ((port (get-port)))
    (format t "probalisp server listening on 0.0.0.0:~A~%" port)
    (force-output)
    (let ((server (usocket:socket-listen "0.0.0.0" port
                                         :reuse-address t
                                         :element-type 'character)))
      (unwind-protect
          (loop
            (let ((client (usocket:socket-accept server :element-type 'character)))
              (unwind-protect
                  (handle-client client)
                (usocket:socket-close client))))
        (usocket:socket-close server)))))
