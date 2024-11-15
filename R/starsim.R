# All publicly visible functions

# Imports
# sc <- import('sciris')
# np <- import('numpy')
# pd <- import('pandas')
# plt <- reticulate::import('matplotlib.pyplot')

# Shortcuts to important classes
# Sim <- ss$Sim
# MultiSim <- ss$MultiSim
# People <- ss$People
# Module <- ss$Module
# Demographics <- ss$Demographics
# Network <- ss$Network
# Disease <- ss$Disease
# Intervention <- ss$Intervention
# Analyzer <- ss$Analyzer

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

#' Load Starsim
#'
#' @return
#' @export
#'
#' @examples
load_starsim <- function() {
  reticulate::import('starsim')
}

#' @name ss
#' @title Starsim module
#' @description The complete Starsim module
#' @export
ss <- reticulate::import('starsim')

#' #' Show any Python plots that have been generated
#' #'
#' #' @return
#' #' @export
#' #'
#' #' @examples
#' pyshow <- function() {
#'     plt$show
#' }
