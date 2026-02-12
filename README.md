# probaLisp

**A probabilistic programming language in Common Lisp**

### _Real <b.real.limoges@gmail.com>_

probaLisp is a probabilistic programming library that combines functional purity with elegant DSL design. Built on Church encoding and monadic composition, it provides a clean foundation for building and reasoning about probabilistic models.

## Features

- 🎲 **Pure probabilistic computations** - No hidden global state
- 🔗 **Monadic composition** - Chain distributions with `>>=`
- 🎯 **Church encoding** - Distributions as first-class functions
- 📦 **Extensible** - Easy to add new distributions
- 🚀 **Future DSL syntax** - Clean macro sugar coming soon

## Quick Example

```lisp
(use-package :probaLisp)

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
(ql:quickload :probaLisp)
(in-package :probaLisp)
(load "examples/examples.lisp")
```

## Architecture

probaLisp uses a **hybrid approach**:
1. **Foundation**: Church encoding (distributions as functions) + probability monad
2. **User interface** (future): Clean DSL with `~` sampling syntax
3. **Benefits**: First-class distributions + readable code

See [docs/PROJECT_STRUCTURE.md](docs/PROJECT_STRUCTURE.md) for detailed project organization.

## Current Distributions

- [x] Binomial

Coming soon:
- [ ] Normal/Gaussian
- [ ] Poisson
- [ ] Bernoulli
- [ ] Beta
- [ ] Gamma

## License

MIT

