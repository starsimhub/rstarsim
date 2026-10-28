#' @keywords internal
"_PACKAGE"

#' Starsim, as a Python module
#'
#' All of Starsim, as in Python's \code{import starsim as ss}: e.g.
#' \code{ss$Sim()} in R is \code{ss.Sim()} in Python. It is loaded the first time it
#' is used. The most commonly used parts of Starsim are also R functions in this
#' package (see \code{\link{Sim}}); \code{ss} has everything else, and is always there
#' if one of those names is taken by a variable of your own.
#'
#' @format A Python module (see \code{reticulate::import()}).
#' @export
#' @examplesIf interactive()
#' sim <- ss$Sim(ss$SIR(), stop = 100)
ss <- NULL

.onLoad <- function(libname, pkgname) {
  # Prefer the environment made by init_starsim(), if there is one; RETICULATE_PYTHON or use_python() still take precedence.
  # Its Python is looked for directly, since asking conda takes about a second
  python <- miniconda_python("r-starsim")
  if (!nzchar(Sys.getenv("RETICULATE_PYTHON")) && file.exists(python)) {
    reticulate::use_python(python, required = FALSE)
  }
  ss <<- reticulate::import("starsim", delay_load = list(before_load = before_load, on_load = on_load))
}

# Plots are drawn on R's graphics device (see print.matplotlib.figure.Figure), so Matplotlib never opens windows of its own
before_load <- function() {
  reticulate::py_run_string("import matplotlib; matplotlib.use('Agg')")
}

# Figures are returned to R rather than shown by Python, and Python's output appears in order with R's (as in Rscript, where it would otherwise be buffered)
on_load <- function() {
  version <- ss$`__version__`
  if (utils::compareVersion(version, "4.0.0") < 0) {
    warning("R-Starsim ", utils::packageVersion("starsim"), " needs Starsim 4, but Starsim ", version, " is installed; update it with reinstall_starsim()", call. = FALSE)
  }
  ss$options(show = FALSE)
  reticulate::py_run_string("import sys\nif hasattr(sys.stdout, 'reconfigure'): sys.stdout.reconfigure(line_buffering=True)")
}

miniconda_python <- function(envname) {
  env <- file.path(reticulate::miniconda_path(), "envs", envname)
  if (.Platform$OS.type == "windows") file.path(env, "python.exe") else file.path(env, "bin", "python")
}

conda_env_exists <- function(envname) {
  tryCatch(reticulate::condaenv_exists(envname), error = function(e) FALSE)
}

#' Install Starsim
#'
#' Installs Starsim, with Python if needed: installs Miniconda (if it is not
#' there), creates a conda environment, and installs Starsim into it. This only
#' needs to be run once; after that, \code{library(starsim)} is all that's needed.
#'
#' @param ... Passed to \code{reticulate::py_install()}.
#' @param envname Character. The conda environment to create and install
#'   Starsim into.
#' @param required Logical. Whether to raise an error if the environment
#'   cannot be activated.
#' @param package Character. What to install, as given to pip: e.g.
#'   \code{"starsim==4.0.0"} for a particular version, or a Git URL.
#' @param python_version Character. The version of Python for a new environment.
#'
#' @return \code{NULL}, invisibly; called to install Starsim.
#'
#' @seealso \code{\link{load_starsim}} to use another environment,
#'   \code{\link{reinstall_starsim}} to update Starsim.
#'
#' @export
#' @examplesIf interactive()
#' init_starsim()
init_starsim <- function(..., envname = "r-starsim", required = FALSE, package = "starsim", python_version = "3.12") {
  check_envname(envname)

  if (!dir.exists(reticulate::miniconda_path())) {
    message("Miniconda not found, installing ...")
    reticulate::install_miniconda()
  }
  if (!conda_env_exists(envname)) {
    message("Creating the environment \"", envname, "\" ...")
    reticulate::conda_create(envname = envname, python_version = python_version)
  }
  reticulate::use_condaenv(envname, required = required)
  message("Installing Starsim ...")
  reticulate::py_install(package, envname = envname, pip = TRUE, ...)
  invisible(NULL)
}

#' Reinstall Starsim
#'
#' Reinstalls Starsim into its conda environment: to update it, change its
#' version, or repair an installation.
#'
#' @inheritParams init_starsim
#' @param ... Passed to \code{reticulate::py_install()}.
#'
#' @return \code{NULL}, invisibly; called to reinstall Starsim.
#'
#' @seealso \code{\link{init_starsim}} for the first installation.
#'
#' @export
#' @examplesIf interactive()
#' reinstall_starsim()
#' reinstall_starsim(package = "git+https://github.com/starsimhub/starsim.git@v4")
reinstall_starsim <- function(..., envname = "r-starsim", package = "starsim") {
  reticulate::py_install(package, envname = envname, pip = TRUE, ignore_installed = TRUE, ...)
  invisible(NULL)
}

#' Load Starsim
#'
#' Loads Starsim from the given Python environment, and says which version it
#' is. This is optional: Starsim is loaded the first time it is used, from the
#' environment made by \code{\link{init_starsim}} if there is one, or else
#' from the Python that \code{reticulate} would use. Call this first to use
#' another environment, or to check that Starsim loads.
#'
#' @param envname Character. The conda environment to use, or \code{FALSE} to
#'   use the Python that \code{reticulate} has already chosen.
#' @param required Logical. Whether to raise an error if the environment
#'   cannot be activated.
#'
#' @return The version of Starsim, invisibly.
#'
#' @seealso \code{\link{init_starsim}} to install Starsim.
#'
#' @export
#' @examplesIf interactive()
#' load_starsim()
#' load_starsim("my_env")
load_starsim <- function(envname = "r-starsim", required = FALSE) {
  if (!isFALSE(envname)) {
    check_envname(envname)
    if (conda_env_exists(envname) || required) {
      reticulate::use_condaenv(envname, required = required)
    }
  }
  version <- ss$`__version__`
  message("Starsim ", version, " loaded from ", reticulate::py_config()$python)
  invisible(version)
}

check_envname <- function(envname) {
  if (!is.character(envname) || length(envname) != 1 || !nzchar(envname)) {
    stop("'envname' is the name of a conda environment, e.g. \"r-starsim\"")
  }
}
