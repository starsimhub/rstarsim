# All publicly visible functions

#' Install Starsim
#'
#' @return
#' @export
#'
#' @examples
install_starsim <- function(..., envname = "r-starsim") {
  reticulate::install_python(version='3.12')
  reticulate::py_install("starsim", envname = envname, ...)
}
.onLoad <- function(...) {
  reticulate::use_virtualenv("r-starsim", required = FALSE)
}

#' Load Starsim alone
#'
#' @return
#' @export
#'
#' @examples
load_starsim <- function() {
  reticulate::import('starsim')
}


#' Load all components of the Starsim environment
#'
#' @return
#' @export
#'
#' @examples
load_starsim_env <- function() {

  # Imports
  ss <- reticulate::import('starsim')
  sc <- reticulate::import('sciris')
  np <- reticulate::import('numpy')
  pd <- reticulate::import('pandas')
  plt <- reticulate::import('matplotlib.pyplot')

  # Assign imports
  assign("ss", ss, envir = .GlobalEnv)
  assign("sc", sc, envir = .GlobalEnv)
  assign("np", np, envir = .GlobalEnv)
  assign("pd", pd, envir = .GlobalEnv)
  assign("plt", plt, envir = .GlobalEnv)

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
