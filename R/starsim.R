# All publicly visible functions

#' Initialize Starsim
#'
#' Perform the steps needed to initialize Starsim: install Miniconda, create a virtual
#' environment ("r-starsim"), and install Starsim into it
#'
#' @return NULL
#' @export
#' @examplesIf FALSE
#' init_starsim()
init_starsim <- function(..., envname = "r-starsim", required = FALSE) {

  # Install Miniconda if not available (will skip if already installed)
  reticulate::install_miniconda()

  # Check that the environment exists, and create it if not
  if (!reticulate::condaenv_exists(envname)) {
    reticulate::conda_create(envname = envname, ...)
  }

  # Activate the environment
  reticulate::use_condaenv(envname, required = required)

  # Install Starsim
  reticulate::py_install("starsim", envname = envname, pip = TRUE, ...)
}
.onLoad <- function(..., envname = "r-starsim", required = FALSE) { # Not sure if this is needed?
  reticulate::use_condaenv(envname, required = required)
}

#' Reinstall Starsim
#'
#' Reinstalls Starsim into the current environment ("r-starsim" by default).
#' You can also use this function to install Starsim into your own environment.
#'
#' @return NULL
#' @export
#' @examplesIf FALSE
#' reinstall_starsim()
reinstall_starsim <- function(..., envname = "r-starsim") {
  reticulate::py_install(
    "starsim",
    envname = envname,
    pip = TRUE,
    ignore_installed = TRUE,
    ...)
}

#' Load Starsim
#'
#' Load all components of the Starsim environment, including: `ss` (all
#' Starsim functionality); NumPy (`np`), pandas (`pd`), Sciris (`sc`), and
#' Matplotlib (`plt`), for additional Python functionality; and some of
#' the core Starsim classes (e.g. `Sim`, `Disease`). After installation,
#' this is the only function that needs to be called from R-Starsim;
#' everything else is accessed via `ss`.
#'
#' @return NULL
#' @export
#' @examplesIf FALSE
#' load_starsim()
#' sim <- ss$Sim(diseases='sis', networks='random')
#' sim$run()
load_starsim <- function(envname = "r-starsim", required = FALSE) {

  # Set the virtual environment if an environment name is given
  if (!(isFALSE(envname)) && nzchar(envname)) {
    reticulate::use_condaenv(envname, required = required)
  }

  # Import OS and set the environment variable (used when importing Starsim)
  os <- reticulate::import('os')
  os$environ['STARSIM_RETICULATE'] = '1'

  # Finish imports
  sc <- reticulate::import('sciris')
  np <- reticulate::import('numpy')
  pd <- reticulate::import('pandas')
  plt <- reticulate::import('matplotlib.pyplot')
  ss <- reticulate::import('starsim')

  # Assign imports
  assign("os", os, envir = .GlobalEnv)
  assign("sc", sc, envir = .GlobalEnv)
  assign("np", np, envir = .GlobalEnv)
  assign("pd", pd, envir = .GlobalEnv)
  assign("plt", plt, envir = .GlobalEnv)
  assign("ss", ss, envir = .GlobalEnv)

  # Shortcuts to important classes
  Sim <- ss$Sim
  MultiSim <- ss$MultiSim
  Module <- ss$Module
  Demographics <- ss$Demographics
  Network <- ss$Network
  Connector <- ss$Connector
  Disease <- ss$Disease
  Intervention <- ss$Intervention
  Analyzer <- ss$Analyzer

  # Assign classes
  assign("Sim", Sim, envir = .GlobalEnv)
  assign("MultiSim", MultiSim, envir = .GlobalEnv)
  assign("Module", Module, envir = .GlobalEnv)
  assign("Demographics", Demographics, envir = .GlobalEnv)
  assign("Network", Network, envir = .GlobalEnv)
  assign("Connector", Connector, envir = .GlobalEnv)
  assign("Disease", Disease, envir = .GlobalEnv)
  assign("Intervention", Intervention, envir = .GlobalEnv)
  assign("Analyzer", Analyzer, envir = .GlobalEnv)

  # Shortcuts to reticulate functions
  assign("import", reticulate::import, envir = .GlobalEnv)
  assign("py_none", reticulate::py_none, envir = .GlobalEnv)
  assign("PyClass", reticulate::PyClass, envir = .GlobalEnv)
}
