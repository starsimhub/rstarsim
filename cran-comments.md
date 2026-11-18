## Submission

This is a new submission. R-Starsim is an R interface to Starsim (https://starsim.org), a disease modeling framework written in Python, and works through 'reticulate', as 'tensorflow' and 'keras3' do.

## Python

- Python and the Starsim Python package are declared in SystemRequirements. Nothing is installed or downloaded when the package is installed, loaded, checked, or tested.
- `install_starsim()` installs Miniconda and Starsim only when the user calls it. In an interactive session it lists what it will install and asks first; `ask = FALSE` skips the question in scripts.
- Examples run only if Starsim is available (`@examplesIf starsim::starsim_available()`), and tests that need it are skipped otherwise. Examples that install software or change the Python environment run only interactively.

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new submission.

## Test environments

- Local: Ubuntu 24.04, R 4.6.2, with and without Starsim installed
- TODO: win-builder (devel and release), R-hub
