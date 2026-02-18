# probalisp

**A probabilistic programming language in Common Lisp**

### _Real <b.real.limoges@gmail.com>_

probalisp is a probabilistic programming library that combines functional purity with elegant DSL design. Built on Church encoding and monadic composition, it provides a clean foundation for building and reasoning about probabilistic models.

## Features

- 🎲 **Pure probabilistic computations** - No hidden global state
- 🔗 **Monadic composition** - Chain distributions with `>>=`
- 🎯 **Church encoding** - Distributions as first-class functions
- 📦 **Extensible** - Easy to add new distributions
- 🛡️ **Numerically safe** - Guards against `log(0)` in all inverse-transform samplers
- 🚀 **Future DSL syntax** - Clean macro sugar coming soon

## Quick Example

```lisp
(use-package :probalisp)

;; Simple sampling
(run-prob (binomial 10 0.5))
;; => 6

;; Compose distributions
(run-prob
  (>>= (binomial 10 0.5)
       (lambda (x)
         (binomial x 0.3))))
;; => 2
```

## Getting Started

See [docs/GETTING_STARTED.md](docs/GETTING_STARTED.md) for detailed documentation and examples.

```lisp
(ql:quickload :probalisp)
(in-package :probalisp)
(load "examples/examples.lisp")
```

## Architecture

probalisp uses a **hybrid approach**:
1. **Foundation**: Church encoding (distributions as functions) + probability monad
2. **User interface** (future): Clean DSL with `~` sampling syntax
3. **Benefits**: First-class distributions + readable code

See [docs/PROJECT_STRUCTURE.md](docs/PROJECT_STRUCTURE.md) for detailed project organization.

## Current Distributions

- [x] Binomial
- [x] Normal/Gaussian
- [x] Uniform
- [x] Geometric
- [x] Exponential
- [x] Poisson
- [x] Bernoulli

Coming soon:
- [ ] Beta
- [ ] Gamma

## License

MIT

