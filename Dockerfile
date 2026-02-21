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
  && rm /tmp/quicklisp.lisp \
  && printf '%s\n' \
       '#-quicklisp' \
       '(let ((ql-init (merge-pathnames "quicklisp/setup.lisp" (user-homedir-pathname))))' \
       '  (when (probe-file ql-init) (load ql-init)))' \
       >> /root/.sbclrc

# Pre-install dependencies (cached layer - before COPY so it survives code changes)
RUN sbcl --non-interactive \
         --eval '(ql:quickload :fiveam)' \
         --eval '(ql:quickload :cl-json)' \
         --eval '(ql:quickload :usocket)'

WORKDIR /root/quicklisp/local-projects/probalisp

COPY . .

# Build a self-contained executable with the system pre-loaded.
# save-lisp-and-die embeds the full compiled image so startup is fast (~100ms).
RUN mkdir -p /app && \
    sbcl --non-interactive \
         --eval '(ql:quickload :probalisp)' \
         --eval '(sb-ext:save-lisp-and-die "/app/probalisp-server" :executable t :toplevel (function probalisp:start-server))'

ENV PROBALISP_PORT=4001
EXPOSE 4001

CMD ["/app/probalisp-server"]
