# All publicly visible functions

#' Initialize Starsim
#'
#' Perform the steps needed to initialize Starsim: install Miniconda, create a
#' conda virtual environment, and install Starsim into it. This only needs to be
#' run once; after initialization, use \code{\link{load_starsim}} to load
#' Starsim in each session.
#'
#' @param ... Additional arguments passed to \code{reticulate::conda_create()}
#'   and \code{reticulate::py_install()}.
#' @param envname Character. Name of the conda environment to create and install
#'   Starsim into. Defaults to \code{"r-starsim"}.
#' @param required Logical. If \code{TRUE}, an error is raised if the environment
#'   cannot be activated. Defaults to \code{FALSE}.
#'
#' @return Called for its side effects (installs Miniconda, creates a conda
#'   environment, and installs Starsim). Returns \code{NULL} invisibly.
#'
#' @seealso \code{\link{load_starsim}} to load Starsim after initialization,
#'   \code{\link{reinstall_starsim}} to update or reinstall Starsim.
#'
#' @export
#' @examplesIf interactive()
#' init_starsim()
init_starsim <- function(..., envname = "r-starsim", required = FALSE) {

  if (!is.character(envname) || length(envname) != 1 || !nzchar(envname)) {
    stop("'envname' must be a non-empty string (e.g., 'r-starsim')")
  }

  # Install Miniconda if not available
  if (!dir.exists(reticulate::miniconda_path())) {
    print('Miniconda not found, installing ...')
    reticulate::install_miniconda()
  } else {
    print('Miniconda found, continuing ...')
  }

  # Check that the environment exists, and create it if not
  if (!reticulate::condaenv_exists(envname)) {
    print('Environment not found, installing ...')
    reticulate::conda_create(envname = envname, ...)
  } else {
    print('Environment found, continuing ...')
  }

  # Activate the environment
  print('Activating environment...')
  reticulate::use_condaenv(envname, required = required)

  # Install Starsim
  print('Installing Starsim ...')
  reticulate::py_install("starsim", envname = envname, pip = TRUE, ...)
}
.onLoad <- function(..., envname = "r-starsim", required = FALSE) {
  reticulate::use_condaenv(envname, required = required)
}

#' Reinstall Starsim
#'
#' Reinstalls Starsim into the specified conda environment. Use this to update
#' Starsim to the latest version or to repair a broken installation.
#'
#' @param ... Additional arguments passed to \code{reticulate::py_install()}.
#' @param envname Character. Name of the conda environment to install Starsim
#'   into. Defaults to \code{"r-starsim"}.
#'
#' @return Called for its side effect (reinstalls the Starsim Python package).
#'   Returns \code{NULL} invisibly.
#'
#' @seealso \code{\link{init_starsim}} for first-time setup,
#'   \code{\link{load_starsim}} to load Starsim after installation.
#'
#' @export
#' @examplesIf interactive()
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
#' Load all components of the Starsim environment into the global namespace.
#' After installation (via \code{\link{init_starsim}}), this is the only
#' function that needs to be called from R-Starsim; everything else is
#' accessed via \code{ss}.
#'
#' The following objects are created in the global environment:
#' \itemize{
#'   \item \strong{Python libraries:} \code{ss} (Starsim), \code{sc} (Sciris),
#'     \code{np} (NumPy), \code{pd} (pandas), \code{plt} (Matplotlib), \code{os}
#'   \item \strong{Starsim class shortcuts:} \code{Sim}, \code{MultiSim},
#'     \code{Module}, \code{Demographics}, \code{Network}, \code{Connector},
#'     \code{Disease}, \code{Intervention}, \code{Analyzer}
#'   \item \strong{Reticulate helpers:} \code{import}, \code{py_none},
#'     \code{PyClass}
#' }
#'
#' @param envname Character. Name of the conda environment to activate, or
#'   \code{FALSE} to skip environment activation (e.g. if you have already
#'   activated an environment manually). Defaults to \code{"r-starsim"}.
#' @param required Logical. If \code{TRUE}, an error is raised if the environment
#'   cannot be activated. Defaults to \code{FALSE}.
#'
#' @return Called for its side effect of creating objects in the global
#'   environment (see Details). Returns \code{NULL} invisibly.
#'
#' @seealso \code{\link{init_starsim}} for first-time setup,
#'   \code{\link{reinstall_starsim}} to update Starsim.
#'
#' @export
#' @examplesIf interactive()
#' load_starsim()
#' sim <- ss$Sim(diseases='sis', networks='random')
#' sim$run()
load_starsim <- function(envname = "r-starsim", required = FALSE) {

  if (!isFALSE(envname) && (!is.character(envname) || length(envname) != 1 || !nzchar(envname))) {
    stop("'envname' must be a non-empty string (e.g., 'r-starsim') or FALSE to skip environment activation")
  }

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
