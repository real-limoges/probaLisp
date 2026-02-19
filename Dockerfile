FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    sbcl \
    ca-certificates \
    curl \
 && rm -rf /var/lib/apt/lists/*

# Install Quicklisp
COPY quicklisp.lisp /tmp/quicklisp.lisp
RUN sbcl --non-interactive \
         --load /tmp/quicklisp.lisp \
         --eval '(quicklisp-quickstart:install :path "/root/quicklisp/")' \
         --eval '(ql:add-to-init-file)' \
  && rm /tmp/quicklisp.lisp

# Pre-install test dependency
RUN sbcl --non-interactive \
         --eval '(ql:quickload :fiveam)'

WORKDIR /root/quicklisp/local-projects/probalisp

COPY . .

# Load system to verify it compiles
RUN sbcl --non-interactive \
         --eval '(ql:quickload :probalisp)'

CMD ["sbcl", "--eval", "(ql:quickload :probalisp)", "--eval", "(in-package :probalisp)"]
