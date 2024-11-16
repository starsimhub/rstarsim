# All publicly visible functions

#' Install Starsim (and Python if needed)
#'
#' @return
#' @export
#'
#' @examples
install_starsim <- function(..., envname = "r-starsim") {
  reticulate::install_python(version='3.12')
  reticulate::py_install("starsim", envname = envname, ...)
}
.onLoad <- function(..., envname = "r-starsim") {
  reticulate::use_virtualenv(envname, required = FALSE)
}

#' Load all components of the Starsim environment
#'
#' @return
#' @export
#'
#' @examples
load_starsim <- function() {

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
