# Contributing to R-Starsim

Thank you for your interest in contributing to R-Starsim! This document explains how to set up a development environment, run tests, and submit changes.


## Getting started

1. Fork and clone the repository:
   ```bash
   git clone https://github.com/starsimhub/rstarsim.git
   cd rstarsim
   ```

2. Open the project in RStudio by double-clicking `starsim.Rproj`.

3. Install development dependencies:
   ```R
   install.packages(c("devtools", "testthat", "roxygen2", "pkgdown"))
   ```

4. Install the package in development mode:
   ```R
   devtools::load_all()
   ```


## Running tests

R-Starsim uses `testthat` for testing. Run the test suite with:

```R
devtools::test()
```


## Building documentation

Roxygen2 docstrings are used to generate man pages. After editing docstrings in `R/starsim.R`, regenerate the man pages with:

```R
devtools::document()
```

To build the pkgdown site locally:

```R
pkgdown::build_site()
```


## Submitting changes

1. Create a feature branch from `main`.
2. Make your changes and add tests if applicable.
3. Run `devtools::check()` to ensure the package passes R CMD check.
4. Submit a pull request with a clear description of the changes.


## Reporting issues

If you find a bug or have a feature request, please [open an issue](https://github.com/starsimhub/rstarsim/issues/new/choose) or [email us](mailto:info@starsim.org).
