# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

probalisp is a Common Lisp probabilistic programming library deployed as a microservice for **Fugue** — an interactive data science showcase. **Tagline**: "probability is intuitive and fun — let's prove it."

**Audience**: Curious non-technical people and technical people without a probability background.

**Role in Fugue**: One self-contained page alongside a Rust/WASM Wikipedia explorer, Julia/WASM birdsong dialect analyzer, and Haskell jazz generator. probalisp handles the Bayesian intuition piece.

The core design uses distributions as first-class functions (Church encoding) that thread random state explicitly for purity and reproducibility, composed via a probability monad.

## Showcase Vision

The page demonstrates Bayesian updating interactively — **prior → likelihood → posterior** — with live histogram updates driven by sliders.

### Conjugate Pair Showcases

| Pair | What it shows | Status |
|---|---|---|
| Beta-Binomial | Proportions — belief about a rate in [0,1] | needs `beta` |
| Gamma-Poisson | Rates — how often does something happen? | needs `gamma` |
| Normal-Normal | Signal in noisy measurements | stretch; `normal` done |

Concrete stories for each pair are TBD and may tie into other Fugue projects.

**Why these pairs**: Beta-Binomial and Gamma-Poisson are chosen because they show fundamentally different kinds of uncertainty (proportions vs. rates). Normal-Normal shows uncertainty narrowing, which is visually distinct from the other two.

### UI Roadmap

- **MVP**: Sliders only. Parameters control prior/likelihood; posterior updates live.
- **Future**: Block-based composition UI below the fold, with read-only generated code display.

### Architecture

```
Phoenix LiveView (Elixir) <--HTTP JSON--> probalisp microservice (CL)
Sliders → params → CL computes posterior samples → LiveView renders histogram
```

### Distribution Status

- **Done**: `binomial`, `normal`, `uniform`, `geometric`
- **Needed for showcase**: `beta`, `gamma`
- **Conjugate update logic** (posterior computation) is a separate layer on top of the distributions

## Development Commands

### Loading the System
```lisp
;; Load with Quicklisp (preferred)
(ql:quickload :probalisp)

;; Or with ASDF
(asdf:load-system :probalisp)

;; Force reload after changes
(asdf:load-system :probalisp :force t)

;; Switch to package
(in-package :probalisp)
```

### Running Tests
```lisp
;; Run all tests
(asdf:test-system :probalisp)

;; Or manually
(ql:quickload :probalisp/tests)
(fiveam:run! :probalisp)

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

2. Update `probalisp.asd`:
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

Use FiveAM framework. All tests live in `tests/main.lisp` under the `:probalisp` suite.

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
├── probalisp.lisp        # Main entry (currently empty)
├── monad.lisp            # Monadic combinators
├── server.lisp           # HTTP microservice for LiveView integration
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
