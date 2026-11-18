# R-Starsim


## Version 2.0.0 (in development, for Starsim v4)

* R-Starsim now uses Starsim v4, in which a model is written as its states and the transitions between them, and runs as an ODE, a stochastic model, or with agents.
* `library(starsim)` is all that's needed: Starsim is loaded the first time it is used, and `load_starsim()` is only needed to choose a Python environment. It no longer puts `ss`, `sc`, `np`, `pd`, `plt`, `os`, Starsim's classes, or `reticulate`'s functions in the global environment: `ss` is part of the package, and the others can be imported with `reticulate::import()`.
* The most commonly used parts of Starsim are R functions: `Sim()`, `MultiSim()`, `parallel()`, `Disease()`, `Transition()`, `outcome()`, `par()`, `contacts()`, `vaccinate()`, `modify()`, `days()`, and `years()`. They pass whole numbers to Python as integers, and named lists with numbers as names as dicts with numbers as keys. `par()` is also `graphics::par()` when given graphical parameters.
* `states("S I R")` makes the states S, I and R, and puts them in scope.
* What these functions make is named after R's variables, as in Python: `Disease(infection, recovery)` names its transitions `infection` and `recovery`, and `beta <- par(0.3)` is the parameter `beta`, without `name=`.
* Methods of sims, modules, multisims and fits (`sim$new()`, `disease$stratify()`, ...) take R values as these functions do, and return R values: a table as a data frame (e.g. `fit$summarize()`), and text such as `sim$equations()` and `sim$describe()` printed as text. A table that Starsim prints and returns is shown once.
* Starsim's dictionaries (`sim$diseases`, `sim$interventions`) and a multisim's sims can be indexed by position, from 0 as in Python (`sim$interventions[[0]]`); `as.list(msim$sims)` gives the sims as an R list, e.g. to loop over.
* `ssl` is Starsim's library of diseases and networks, as `import starsim.library as ssl` in Python (`ssl$Measles()`).
* `plot()` plots sims, multisims, fits and results on R's graphics device, so plots appear in the console, RStudio, and R Markdown alike, and figures from `sim$plot()` and the like appear when printed.
* `as.data.frame()` gives the results of a sim or multisim as a data frame, and `summary()` summarizes them; dates are `Date`s.
* `init_starsim()` is renamed `install_starsim()`, as in other packages that use Python (`install_tensorflow()`, `install_keras()`). It says what it will install and asks first in an interactive session (`ask = FALSE` to skip). It and `reinstall_starsim()` take `package`, to install a particular version of Starsim.
* `starsim_available()` says whether a supported version of Starsim can be found, without loading it.
* The vignettes are rewritten for Starsim v4: a first model, then age groups, interventions, and fitting.


## Version 1.1.0 (2026-04-14)

* Updated to use new version of `reticulate`.


## Version 1.0.0 (2024-11-19)

* Initial release of R-Starsim, an R wrapper for [Starsim](https://starsim.org).
* Three exported functions: `init_starsim()`, `reinstall_starsim()`, and `load_starsim()`.
* Automatic Miniconda installation and conda environment setup via `reticulate`.
* Convenience shortcuts for core Starsim classes (`Sim`, `Disease`, `Network`, etc.) in the global environment.
* Vignettes covering installation, simple usage, advanced usage (custom SEIR module), and troubleshooting.
