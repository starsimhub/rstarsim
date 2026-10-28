# R-Starsim


## Version 2.0.0 (in development, for Starsim 4)

* `transition()` and `disease()` declare a Starsim 4 model in R, with arrow strings and rates as formulas (`transition("S -> I", rate = ~ beta * I$frac)`); `results_df()` gives a sim's results as a data frame.
* The advanced vignette builds on `ss$library$CodedSIR` (Starsim 3's `ss.SIR`; in Starsim 4, `ss$SIR` is declared) and `ss$BoolState`, and keeps UIDs as Python objects, so that it runs; an example of a model declared in R (`examples/declared.R`, and the README).
* The simple vignette and `examples/example.R` give births and deaths as `demographics = list(...)`, since Starsim 4 has no `birth_rate=` or `death_rate=` on the sim.


## Version 1.1.0 (2026-04-14)

* Updated to use new version of `reticulate`.


## Version 1.0.0 (2024-11-19)

* Initial release of R-Starsim, an R wrapper for [Starsim](https://starsim.org).
* Three exported functions: `init_starsim()`, `reinstall_starsim()`, and `load_starsim()`.
* Automatic Miniconda installation and conda environment setup via `reticulate`.
* Convenience shortcuts for core Starsim classes (`Sim`, `Disease`, `Network`, etc.) in the global environment.
* Vignettes covering installation, simple usage, advanced usage (custom SEIR module), and troubleshooting.
