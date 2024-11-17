# R-Starsim

R-Starsim is a package to facilitate the usage of [Starsim](https://starsim.org) from R. It is primarily a wrapper for [reticulate](https://rstudio.github.io/reticulate/index.html), which facilitates communication between Python and R.


## Installation

Although R-Starsim will be released on CRAN in future, for the time being, it can be installed via GitHub:

```R
# install.packages("devtools")
devtools::install_github("starsimhub/rstarsim")
library(starsim)
init_starsim()
```

If you do not already have a `reticulate` Python environment set up, R-Starsim will try to make one for you (by downloading Miniconda, creating an `r-reticulate` environment, and activating it).

If you want to reinstall Starsim (e.g. to update the version), you can use:
```R
library(starsim)
reinstall_starsim()
```


## Usage

All Starsim Python functions and classes are available in R. In Python, usage is typically `import starsim as ss`. To emulate this behavior in R, Starsim is made available as the variable `ss`, e.g. `sim = ss.Sim()` in Python becomes `sim <- ss$Sim()` in R. In addition, major Starsim classes (such as `Sim`, `Network`, `Disease`, etc.) are imported directly into the R namespace (e.g. `sim <- Sim()` also works).


## Example

```R
# Load Starsim
library(starsim)
load_starsim()

# Set the simulation parameters
pars <- list(
    n_agents = 10000,
    birth_rate = 20,
    death_rate = 15,
    networks = list(
        type = 'randomnet',
        n_contacts = 4
    ),
    diseases = list(
        type = 'sir',
        dur_inf = 10,
        beta = 0.1
    )
)

# Create, run, and plot the simulation
sim <- ss$Sim(pars)
sim$run()
sim$diseases$sir$plot()
```
<img src="man/example-r.png" alt="SIR dynamics" />


## Troubleshooting

### Installation

If `init_starsim()` fails, try creating your own Python environment (via `conda` or `miniconda`), installing Starsim manually, and then calling `load_starsim()` with an argument. For example, if your custom environment is called `r-starsim`, you would use:
```R
load_starsm("r-starsim")
```

### Plotting

- If plots don't appear, try `plt$show()` after calling `plot()`, or set `ss$options(reticulate=True)` before plotting.
- If the plots don't appear _and_ they cause RStudio to crash, either set the backend to Agg (Tools > General Options > General > Graphics > Backend), or call `X11()` somewhere in your script before calling `plot()`.
- If plots appear but the scaling is wrong (e.g. the text is colliding), you can either (a) zoom out in RStudio (this changes the inferred scaling factor), or (b) change the default font size with e.g. `sc$options(fontsize=6)` (note s**c** = Sciris rather than s**s** = Starsim).
- If all else fails, plotting seems to work better from VS Code than RStudio.

### Other issues

Questions? Comments? Bugs? Please [open an issue](https://github.com/starsimhub/rstarsim/issues/new/choose) or [email us](mailto:info@starsim.org) for help.
