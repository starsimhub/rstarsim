# The commonly used parts of Starsim, as R functions that take R arguments

# R values as a Python user would type them: whole numbers as integers (2, not 2.0), named lists with numbers for names as
# dicts with numbers for keys (list("0" = 0.3) as {0: 0.3}), and functions with their arguments; anything else as reticulate converts it
py_args <- function(x) {
  if (inherits(x, "python.builtin.object") || is.data.frame(x)) {
    return(x)
  }
  if (is.function(x)) { # As a Python function with the same arguments, which Starsim reads (e.g. sim, or sim and uids)
    return(reticulate::py_func(x))
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

# An R function that calls a function of Starsim with R arguments, naming what it makes after R's variables
ss_function <- function(name) {
  force(name)
  function(...) {
    envir <- parent.frame()
    with_names(envir, do.call(reticulate::py_get_attr(ss, name), py_args(list(...))))
  }
}

# Evaluates `expr` with R's variables (the global ones, and those of `envir`) given to Starsim, which can't see them, as
# Python's are: so that Disease(infection, recovery) names its transitions, and a parameter (beta <- par(0.3)) its parameter,
# after the variables that hold them, as in Python (see ss.utils.named())
with_names <- function(envir, expr) {
  envs <- if (identical(envir, globalenv())) list(globalenv()) else list(globalenv(), envir)
  spaces <- lapply(envs, function(env) {
    keys <- ls(env) # Not those starting with ".", as Python leaves out those starting with "_"
    vals <- mget(keys, envir = env)
    keep <- vapply(vals, inherits, logical(1), "python.builtin.object")
    reticulate::py_dict(as.list(keys[keep]), unname(vals[keep]))
  })
  with(do.call(ss$utils$named, spaces), expr)
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
#'   \item \strong{Parameters and time:} \code{par} (see below); durations, \code{days},
#'     \code{weeks}, \code{months}, \code{years}; rates, \code{per}, \code{perday}, \code{perweek},
#'     \code{permonth}, \code{peryear}; probabilities over a time, \code{probperday},
#'     \code{probperweek}, \code{probpermonth}, \code{probperyear}; and values by group, \code{by} (see below)
#'   \item \strong{Demographics:} \code{birth}, \code{death}
#'   \item \strong{Contacts and interventions:} \code{contacts}, \code{vaccinate}, \code{modify}
#'   \item \strong{Running:} \code{Sim}, \code{MultiSim}, \code{parallel}
#' }
#'
#' \code{par} is also R's \code{graphics::par()}, which it calls when it is given
#' graphical parameters (\code{par(mfrow = c(1, 2))}) or nothing: it is Starsim's when its
#' first argument is a value (\code{par(0.3, bounds = c(0.1, 1))}) or it is given
#' one of Starsim's keywords (\code{value}, \code{bounds}, \code{prior}, ...).
#' Likewise \code{by} is also R's \code{base::by()}, which it calls when it is given
#' a function (\code{by(df, df$group, summary)}); otherwise it is Starsim's
#' (\code{by(age = c(0.8, 0.9, 0.95))}).
#'
#' @param ... Arguments, as for the same function in Python.
#'
#' @return A Starsim object (a Python object, see \code{reticulate}).
#'
#' @seealso \code{\link{states}}, \code{\link{ss}}, and \code{plot()}, \code{as.data.frame()} and
#'   \code{summary()}, which work on sims, multisims, fits and results.
#'
#' @name starsim-functions
#' @examplesIf starsim::starsim_available()
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

ss_parallel <- ss_function("parallel")

#' @rdname starsim-functions
#' @export
parallel <- function(...) {
  args <- list(...)
  if (is.null(args$workers) && calls_r(args)) {
    args$workers <- 1L
  }
  do.call(ss_parallel, args, envir = parent.frame()) # Called from the caller's frame, so what it makes is named after the caller's variables
}

# Whether running these needs this R session: true if they hold an R function, which Starsim's worker processes can't call
# (they would wait for it for ever). They are then run one after another here (workers = 1), with a message saying why
calls_r <- function(x) {
  if (is.null(r_finder$calls_r)) {
    r_finder$calls_r <- reticulate::import_from_path("calls_r", system.file("python", package = "starsim"))$calls_r
  }
  found <- isTRUE(tryCatch(r_finder$calls_r(py_args(x)), error = function(e) FALSE))
  if (found) {
    message("Running one after another in this R session (workers = 1), since the sims call an R function, which Starsim's worker processes can't")
  }
  found
}
r_finder <- new.env()

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
weeks <- ss_function("weeks")

#' @rdname starsim-functions
#' @export
months <- ss_function("months")

#' @rdname starsim-functions
#' @export
per <- ss_function("per")

#' @rdname starsim-functions
#' @export
perday <- ss_function("perday")

#' @rdname starsim-functions
#' @export
perweek <- ss_function("perweek")

#' @rdname starsim-functions
#' @export
permonth <- ss_function("permonth")

#' @rdname starsim-functions
#' @export
peryear <- ss_function("peryear")

#' @rdname starsim-functions
#' @export
probperday <- ss_function("probperday")

#' @rdname starsim-functions
#' @export
probperweek <- ss_function("probperweek")

#' @rdname starsim-functions
#' @export
probpermonth <- ss_function("probpermonth")

#' @rdname starsim-functions
#' @export
probperyear <- ss_function("probperyear")

#' @rdname starsim-functions
#' @export
birth <- ss_function("birth")

#' @rdname starsim-functions
#' @export
death <- ss_function("death")

ss_by <- ss_function("by")

#' @rdname starsim-functions
#' @export
by <- function(...) {
  args <- list(...)
  base_by <- any(c("INDICES", "FUN") %in% names(args)) || any(vapply(args, is.function, logical(1))) # base::by() always takes a function; Starsim's never does
  if (base_by) base::by(...) else ss_by(...)
}

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
par_keywords <- c("value", "bounds", "prior", "source", "doc", "name", "label")

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
#' @examplesIf starsim::starsim_available()
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
  inherits(x, "starsim.internals.transitions.State")
}

#' Define a class of Starsim's in R
#'
#' Makes a Python class from R, as \code{class Wealth(ss.Module):} does in Python:
#' a module, disease, intervention, analyzer, connector, or network written as code,
#' with its parameters, states and methods. Methods are R functions whose first
#' argument is the object (\code{self}); they are given their arguments as Starsim's
#' objects, so what they compute stays Starsim's, as in Python (e.g. UIDs stay UIDs),
#' and \code{reticulate::py_to_r()} gives an R value. Starsim's arrays and results
#' are indexed and assigned to with \code{[} and \code{[<-} as in Python: an array by
#' UIDs or a mask, a result by the step (\code{self$ti}, which counts from 0, as Python
#' does); \code{x[]} is the whole of either. A method of the class it inherits from
#' is called as \code{ss$Module$init_results(self)} (Python's \code{super()}).
#'
#' Starsim's worker processes can't run R, so sims with a class defined in R are run
#' one after another in this R session by \code{parallel()}.
#'
#' @param ... First, the name of the class (a string), and the class it inherits
#'   from, e.g. \code{ss$Module} or \code{ss$Disease} (or a list of them), unnamed or
#'   as \code{name =} and \code{inherit =}; then its attributes and methods, by name:
#'   parameters (\code{par()}), states (e.g. \code{ss$FloatArr()}), other values, and
#'   methods (R functions).
#'
#' @return The class, a Python class: call it to make a module (\code{Wealth()}).
#'
#' @seealso \code{\link{starsim-functions}}
#'
#' @export
#' @examplesIf starsim::starsim_available()
#' Wealth <- Class("Wealth", ss$Module,
#'   wealth = ss$FloatArr(default = 1),
#'   step = function(self) {
#'     self$wealth[] <- self$wealth * 1.01 # Everyone's wealth grows by 1% a step
#'   }
#' )
#' sim <- Sim(Wealth(), n_agents = 100, stop = 10)
#' sim$run()
Class <- function(...) { # Arguments read here, so that an attribute such as n isn't taken as name, as R would partially match it
  defs <- list(...)
  keys <- if (is.null(names(defs))) rep("", length(defs)) else names(defs)
  take <- function(key, pos) { # name and inherit: by that name exactly, or else the first unnamed arguments
    i <- if (key %in% keys) match(key, keys) else which(!nzchar(keys))[pos]
    if (is.na(i)) stop("Class() takes the name of the class and the class it inherits from, e.g. Class(\"Wealth\", ss$Module, ...)")
    val <- defs[[i]]
    defs[[i]] <<- NULL
    keys <<- keys[-i]
    val
  }
  name <- take("name", 1)
  inherit <- take("inherit", 1)
  if (length(defs) && any(!nzchar(keys))) {
    stop("Class() takes the attributes and methods of the class by name, e.g. step = function(self) {...}")
  }
  names(defs) <- keys
  defs <- lapply(defs, function(x) if (is.function(x)) r_method(x) else py_args(x))
  defs <- c(list(`__module__` = "__main__", `__qualname__` = name), defs)
  bases <- if (is.list(inherit)) do.call(reticulate::tuple, inherit) else reticulate::tuple(inherit)
  reticulate::import_builtins()$type(name, bases, reticulate::py_dict(names(defs), unname(defs))) # String keys, which reticulate::PyClass() doesn't give for names that are also variables
}

# An R function as a Python method: with its arguments, which it is given unconverted (see Class())
r_method <- function(f) {
  if (is.null(rclass$method)) {
    rclass$method <- reticulate::import_from_path("rclass", system.file("python", package = "starsim"))$method
  }
  args <- formals(f)
  dots <- "..." %in% names(args)
  args <- args[names(args) != "..."]
  has_default <- vapply(args, function(a) !identical(a, quote(expr = )), logical(1))
  rclass$method(reticulate::r_to_py(f, convert = FALSE), as.list(names(args)[!has_default]), as.list(names(args)[has_default]), dots)
}
rclass <- new.env()

#' @rawNamespace S3method("[", starsim.internals.arrays.BaseArr, item_arr)
#' @rawNamespace S3method("[<-", starsim.internals.arrays.BaseArr, set_item_arr)
#' @noRd
item_arr <- function(x, i) {
  reticulate::py_get_item(x, arr_index(x, i))
}

set_item_arr <- function(x, i, value) {
  reticulate::py_set_item(x, arr_index(x, i), value)
  x
}

# An index of a Starsim array as Python takes it: all of it if none is given (x[], as x[:] in Python); whole numbers into
# the arrays of people as UIDs, which is what Starsim means by them (R has them as numbers, e.g. from (x > 0)$uids); and
# anything else (a mask, a step of a result) as it is
arr_index <- function(x, i) {
  if (missing(i)) {
    return(reticulate::import_builtins()$slice(NULL))
  }
  if (is.numeric(i) && inherits(x, "starsim.internals.arrays.Arr")) {
    return(ss$uids(as.integer(i)))
  }
  py_args(i)
}
