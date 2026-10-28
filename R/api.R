# The commonly used parts of Starsim, as R functions that take R arguments

# R values as a Python user would type them: whole numbers as integers (2, not 2.0), and named lists with
# numbers for names as dicts with numbers for keys (list("0" = 0.3) as {0: 0.3}); anything else as reticulate converts it
py_args <- function(x) {
  if (inherits(x, "python.builtin.object") || is.data.frame(x)) {
    return(x)
  }
  if (is.list(x)) {
    keys <- names(x)
    x <- lapply(x, py_args)
    numbers <- suppressWarnings(as.numeric(keys))
    if (!is.null(keys) && length(x) && !anyNA(numbers)) {
      return(reticulate::py_dict(as.list(py_args(numbers)), unname(x)))
    }
    return(x)
  }
  whole <- is.double(x) && is.null(attributes(x)) && length(x) && all(is.finite(x)) && all(x == round(x)) && all(abs(x) <= .Machine$integer.max)
  if (whole) as.integer(x) else x
}

# An R function that calls a function of Starsim with R arguments
ss_function <- function(name) {
  force(name)
  function(...) do.call(reticulate::py_get_attr(ss, name), py_args(list(...)))
}

#' The commonly used parts of Starsim
#'
#' These are Starsim's own functions and classes, with the same arguments as in
#' Python: e.g. \code{Sim(sir, stop = 100)} in R is \code{ss.Sim(sir, stop=100)}
#' in Python, and \code{Sim} is the same as \code{ss$Sim}. They take R values as
#' a Python user would type them: whole numbers are integers (\code{n_runs = 20}),
#' vectors are lists (\code{ages = c(0, 15, 65)}), named lists are dicts, with
#' numbers as names giving numbers as keys (\code{list("0" = 0.3, "65" = 0.1)} is
#' \code{\{0: 0.3, 65: 0.1\}}), and \code{NULL} is \code{None}. See the
#' \href{https://docs.starsim.org}{Starsim documentation} for each one's arguments.
#'
#' Everything else in Starsim is in \code{\link{ss}}, as is each of these, e.g. if
#' a variable of your own is called \code{Sim}.
#'
#' \itemize{
#'   \item \strong{Models:} \code{Disease}, \code{Transition}, \code{outcome}, and \code{\link{states}}
#'   \item \strong{Parameters and time:} \code{par} (see below), \code{days}, \code{years}
#'   \item \strong{Contacts and interventions:} \code{contacts}, \code{vaccinate}, \code{modify}
#'   \item \strong{Running:} \code{Sim}, \code{MultiSim}, \code{parallel}
#' }
#'
#' \code{par} is also R's \code{graphics::par()}, which it calls when it is given
#' graphical parameters (\code{par(mfrow = c(1, 2))}) or nothing: it is Starsim's when its
#' first argument is a value (\code{par(0.3, bounds = c(0.1, 1))}) or it is given
#' one of Starsim's keywords (\code{value}, \code{bounds}, \code{prior}, ...).
#'
#' @param ... Arguments, as for the same function in Python.
#'
#' @return A Starsim object (a Python object, see \code{reticulate}).
#'
#' @seealso \code{\link{states}}, \code{\link{ss}}, and \code{plot()}, \code{as.data.frame()} and
#'   \code{summary()}, which work on sims, multisims, fits and results.
#'
#' @name starsim-functions
#' @examplesIf interactive()
#' states("S I R")
#' beta <- par(0.3, bounds = c(0.1, 1))
#' sir <- Disease(
#'   infection = Transition(S, I, rate = beta * I),
#'   recovery  = Transition(I, R, dur = days(10))
#' )
#' sim <- Sim(sir, stop = days(100))
#' sim$run()
#' plot(sim)
NULL

#' @rdname starsim-functions
#' @export
Sim <- ss_function("Sim")

#' @rdname starsim-functions
#' @export
MultiSim <- ss_function("MultiSim")

#' @rdname starsim-functions
#' @export
parallel <- ss_function("parallel")

#' @rdname starsim-functions
#' @export
Disease <- ss_function("Disease")

#' @rdname starsim-functions
#' @export
Transition <- ss_function("Transition")

#' @rdname starsim-functions
#' @export
outcome <- ss_function("outcome")

#' @rdname starsim-functions
#' @export
days <- ss_function("days")

#' @rdname starsim-functions
#' @export
years <- ss_function("years")

#' @rdname starsim-functions
#' @export
contacts <- ss_function("contacts")

#' @rdname starsim-functions
#' @export
vaccinate <- ss_function("vaccinate")

#' @rdname starsim-functions
#' @export
modify <- ss_function("modify")

ss_par <- ss_function("par")
par_keywords <- c("value", "bounds", "prior", "source", "doc", "name", "label", "literal")

#' @rdname starsim-functions
#' @export
par <- function(...) {
  args <- list(...)
  keys <- if (is.null(names(args))) rep("", length(args)) else names(args)
  is_value <- length(args) && !nzchar(keys[1]) && (is.numeric(args[[1]]) || inherits(args[[1]], "python.builtin.object"))
  if (is_value || any(keys %in% par_keywords)) ss_par(...) else graphics::par(...)
}

#' Make states
#'
#' Makes a Starsim state for each name, and puts it in scope under that name, as
#' \code{S, I, R = ss.states('S I R')} does in Python.
#'
#' @param names Character. The states' names, in one string (\code{"S I R"}) or
#'   several (\code{c("S", "I", "R")}).
#' @param ... Passed to each state, e.g. \code{people = FALSE} for counts that
#'   are not people (as for mosquitoes).
#' @param envir The environment to put them in: by default, where \code{states()}
#'   is called; \code{NULL} to only return them.
#'
#' @return The states, invisibly, as a named list.
#'
#' @seealso \code{\link{starsim-functions}}
#'
#' @export
#' @examplesIf interactive()
#' states("S I R") # Now S, I and R are states
#' sir <- Disease(
#'   infection = Transition(S, I, rate = 0.3 * I),
#'   recovery  = Transition(I, R, dur = 10)
#' )
states <- function(names, ..., envir = parent.frame()) {
  if (!is.character(names)) {
    stop("states() takes the states' names, e.g. states(\"S I R\")")
  }
  names <- unlist(strsplit(trimws(names), "[[:space:],]+"))
  made <- do.call(reticulate::py_get_attr(ss, "states"), c(list(paste(names, collapse = " ")), py_args(list(...))))
  made <- stats::setNames(as.list(made), names)

  # A state may replace one of the same name (e.g. when a script is run again), but nothing else
  taken <- if (is.null(envir)) character(0) else names[vapply(names, function(n) exists(n, envir = envir, inherits = FALSE) && !is_state(get(n, envir = envir)), logical(1))]
  if (length(taken)) {
    stop("states() would replace ", paste(taken, collapse = ", "), ", which ", if (length(taken) == 1) "is" else "are",
         " not a state; rename ", if (length(taken) == 1) "it" else "them", ", or use st <- states(..., envir = NULL) and st$", taken[1], " instead")
  }
  if (!is.null(envir)) {
    list2env(made, envir = envir)
  }
  invisible(made)
}

is_state <- function(x) {
  inherits(x, "starsim.transitions.State")
}
