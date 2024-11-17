# All publicly visible functions

#' Initialize Starsim: install Miniconda, create a virtual
#' environment ("r-reticulate"), and install Starsim into it
#'
#' @return null
#' @export
#' @examples
#' init_starsim()
init_starsim <- function(..., envname = "r-reticulate", required = FALSE) {
  if (!reticulate::py_available(initialize = TRUE)) {
    print('Python not available, installing Miniconda ...')
    reticulate::install_miniconda()
  } else {
    print('Python available, skipping Miniconda installation ...')
  }
  reticulate::use_condaenv(envname, required = required)
  reticulate::py_install("starsim", envname = envname, pip = TRUE, ...)
}
.onLoad <- function(..., envname = "r-reticulate", required = FALSE) { # Not sure if this is needed?
  reticulate::use_condaenv(envname, required = required)
}

#' Reinstall Starsim into the current environment ("r-reticulate")
#'
#' @return null
#' @export
#' @examples
#' reinstall_starsim('my-starsim-env')
reinstall_starsim <- function(..., envname = "r-reticulate") {
  reticulate::py_install(
    "starsim",
    envname = envname,
    pip = TRUE,
    ignore_installed = TRUE,
    ...)
}

#' Load all components of the Starsim environment, including: `ss` (all
#' Starsim functionality); NumPy (`np`), pandas (`pd`), Sciris (`sc`), and
#' Matplotlib (`plt`), for additional Python functionality; and some of
#' the core Starsim classes (e.g. `Sim`, `Disease`).
#'
#' @return null
#' @export
#' @examples
#' load_starsim()
#' ss$options(jupyter=TRUE)
#' sim <- ss$Sim(diseases='sis', networks='random')
#' sim$run()
load_starsim <- function(envname = "r-reticulate", required = FALSE) {

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
}
