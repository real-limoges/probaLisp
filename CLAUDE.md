# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

probaLisp is a probabilistic programming library for Common Lisp built on Church encoding and monadic composition. The core design uses distributions as first-class functions that thread random state explicitly for purity and reproducibility.

## Development Commands

### Loading the System
```lisp
;; Load with Quicklisp (preferred)
(ql:quickload :probaLisp)

;; Or with ASDF
(asdf:load-system :probaLisp)

;; Force reload after changes
(asdf:load-system :probaLisp :force t)

;; Switch to package
(in-package :probaLisp)
```

### Running Tests
```lisp
;; Run all tests
(asdf:test-system :probaLisp)

;; Or manually
(ql:quickload :probaLisp/tests)
(fiveam:run! :probaLisp)

;; Run specific test
(fiveam:run! 'test-name)
```

### Interactive Development
```lisp
;; Load and try examples
(load "examples/examples.lisp")
(example-1)  ; Simple sampling
(example-2)  ; Composition

;; Quick test
(run-prob (binomial 10 0.5))

;; Trace execution for debugging
(trace binomial-sample)
(run-prob (binomial 5 0.5))
(untrace binomial-sample)
```

## Architecture

### Core Abstraction: Church Encoding + Probability Monad

Distributions are represented as functions with signature:
```lisp
RandomState -> (values Sample RandomState)
```

This enables:
- First-class distributions (can be passed, returned, stored)
- Pure computations (no global state mutation)
- Explicit state threading for reproducibility
- Natural monadic composition

### Key Components

**Probability Monad** (`src/monad.lisp`):
- `return-prob value` - Lift pure value into monad
- `>>= dist fn` - Monadic bind (sequence distributions)
- `>> dist1 dist2` - Sequence, discard first result
- `fmap fn dist` - Map pure function over distribution
- `run-prob dist` - Execute computation, return sample
- `run-prob-with-state dist` - Execute, return sample and final state

**Distribution Pattern** (every distribution follows this):
1. Pure sampling function: `<name>-sample params... &optional rng-state`
   - Returns `(values sample new-state)`
   - Never mutates input state
   - Validates parameters with assertions
2. Church encoding: `<name> params...`
   - Returns lambda that calls sampling function
   - No RNG state parameter (handled by lambda)

Example from binomial:
```lisp
(defun binomial-sample (n p &optional (rng-state *random-state*))
  (let ((state (make-random-state rng-state)))
    (values (loop repeat n count (< (random 1.0 state) p))
            state)))

(defun binomial (n p)
  (lambda (rng-state)
    (binomial-sample n p rng-state)))
```

## Adding New Distributions

Follow this checklist:

1. Create `src/distributions/<name>.lisp` with:
   - `<name>-sample` - Pure sampling function
   - `<name>` - Church encoding wrapper
   - Docstrings with parameter descriptions
   - Parameter validation with `assert`

2. Update `probaLisp.asd`:
   ```lisp
   (:module "distributions"
    :components ((:file "binomial")
                 (:file "yourname")))
   ```

3. Export symbols in `src/package.lisp`:
   ```lisp
   #:yourname
   #:yourname-sample
   ```

4. Add tests in `tests/main.lisp`:
   - Boundary conditions (edge cases)
   - Parameter validation
   - Purity (no state mutation)
   - State threading
   - Reproducibility with seeds

5. Add examples in `examples/examples.lisp`

## Testing Philosophy

Tests verify:
- **Correctness**: Boundary conditions, deterministic cases
- **Purity**: Functions don't modify input state
- **Composability**: Distributions work with monadic combinators
- **Reproducibility**: Same seed produces same results
- **Validation**: Invalid parameters raise errors

Use FiveAM framework. All tests live in `tests/main.lisp` under the `:probaLisp` suite.

## Code Style

### Naming
- Pure functions: `<distribution>-sample`
- Church encodings: `<distribution>`
- Monadic operators: Haskell conventions (`>>=`, `return-prob`, `fmap`, `>>`)

### Purity Requirements
- Never mutate input RNG state - use `make-random-state` to copy
- Always return `(values sample new-state)`
- No global state or side effects
- Enable reproducibility and testing

### Documentation
- Docstrings for all public functions
- Describe parameters and return values
- Include usage examples
- Document multiple value returns explicitly

## Project Structure

```
src/
├── package.lisp          # Package definition & exports
├── probaLisp.lisp        # Main entry (currently empty)
├── monad.lisp            # Monadic combinators
└── distributions/        # One file per distribution
    └── binomial.lisp

tests/
├── package.lisp          # Test package
└── main.lisp            # All tests (FiveAM)

examples/
└── examples.lisp        # Usage demonstrations
```

## Common Patterns

### Composing Distributions
```lisp
;; Sample from one, use result in another
(>>= (binomial 10 0.5)
     (lambda (x) (binomial x 0.3)))

;; Transform results
(fmap (lambda (x) (* x 2))
      (binomial 10 0.5))

;; Build models
(defun my-model ()
  (>>= (binomial 20 0.6)
       (lambda (n)
         (>>= (binomial n 0.5)
              (lambda (k)
                (return-prob (list n k)))))))
```

### Explicit State Threading
```lisp
(let ((dist (binomial 10 0.5)))
  (multiple-value-bind (sample1 state1)
      (funcall dist *random-state*)
    (multiple-value-bind (sample2 state2)
        (funcall dist state1)
      (list sample1 sample2))))
```

## Implementation Notes

- Use `make-random-state` to copy RNG state (preserves purity)
- Validate parameters with `assert` (clear error messages)
- Return multiple values: `(values sample state)`
- Current distributions use simple algorithms (e.g., Bernoulli trials for binomial)
- Optimization opportunities exist for large parameters (BTPE for binomial, Box-Muller for normal)
