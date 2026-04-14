# R-Starsim


## Version 1.1.0 (2026-04-14)

* Updated to use new version of `reticulate`.


## Version 1.0.0 (2024-11-19)

* Initial release of R-Starsim, an R wrapper for [Starsim](https://starsim.org).
* Three exported functions: `init_starsim()`, `reinstall_starsim()`, and `load_starsim()`.
* Automatic Miniconda installation and conda environment setup via `reticulate`.
* Convenience shortcuts for core Starsim classes (`Sim`, `Disease`, `Network`, etc.) in the global environment.
* Vignettes covering installation, simple usage, advanced usage (custom SEIR module), and troubleshooting.
