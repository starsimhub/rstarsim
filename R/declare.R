# Declaring models in R: transitions written as arrow strings, with rates as formulas

#' A transition between states
#'
#' Declares a transition of a model built with \code{\link{disease}}: who moves
#' from which state to which, and how fast. A rate can be a number or a formula,
#' whose names are the model's states and parameters, e.g. \code{~ beta * I$frac}.
#'
#' @param arrow Character. The states, e.g. \code{"S -> I"}, \code{"I -> R | D"}
#'   (branches), \code{"-> S"} (an inflow), or \code{"I ->"} (an outflow).
#' @param rate The rate per person per unit time: a number or a formula.
#' @param dur The mean time spent in the source state (instead of \code{rate}).
#' @param beta The transmission rate, for a transmission (instead of \code{rate}).
#' @param p Branch probabilities, with several destinations.
#' @param source Character. The infectious states, for a transmission.
#' @param name Character. The transition's name (inferred if not given).
#'
#' @return A transition, to give to \code{\link{disease}}.
#'
#' @seealso \code{\link{disease}}, \code{\link{results_df}}
#'
#' @export
#' @examples
#' transition("S -> I", beta = ~ beta)
#' transition("I -> R", rate = ~ gamma)
transition <- function(arrow, rate = NULL, dur = NULL, beta = NULL, p = NULL, source = NULL, name = NULL) {
  if (!is.character(arrow) || length(arrow) != 1 || !grepl("->", arrow, fixed = TRUE)) {
    stop("'arrow' is one arrow string, e.g. \"S -> I\"")
  }
  args <- list(rate = rate, dur = dur, beta = beta, p = p)
  structure(list(arrow = arrow, args = args, source = source, name = name), class = "starsim_transition")
}

# The states on each side of an arrow string ("I -> R | D" gives src "I", dst c("R", "D"))
parse_arrow <- function(arrow) {
  sides <- trimws(strsplit(arrow, "->", fixed = TRUE)[[1]])
  sides <- c(sides, "")[1:2]
  ends <- lapply(sides, function(side) {
    names <- trimws(strsplit(side, "|", fixed = TRUE)[[1]])
    names[nzchar(names)]
  })
  list(src = ends[[1]], dst = ends[[2]])
}

#' A disease declared from transitions
#'
#' Builds a Starsim disease (\code{ss$Disease}) from transitions written with
#' \code{\link{transition}}. Every other named argument that is a number is a
#' parameter, which the formulas can use by name (and which a fit can change).
#'
#' @param ... Transitions, and parameters as named numbers.
#' @param init A named list of initial numbers in states, e.g. \code{list(I = 10)}.
#' @param init_prev The share of people infected at the start (instead of \code{init}).
#' @param name Character. The disease's name.
#'
#' @return An \code{ss$Disease}, to give to \code{ss$Sim}.
#'
#' @seealso \code{\link{transition}}, \code{\link{results_df}}
#'
#' @export
#' @examplesIf interactive()
#' load_starsim()
#' sir <- disease(
#'   transition("S -> I", beta = ~ beta),
#'   transition("I -> R", rate = ~ gamma),
#'   beta = 0.3, gamma = 0.1, init = list(I = 10), name = "sir"
#' )
#' sim <- ss$Sim(sir, stop = 100)
#' invisible(sim$run())
#' head(results_df(sim))
disease <- function(..., init = NULL, init_prev = NULL, name = NULL) {
  ss <- reticulate::import("starsim", convert = FALSE)
  args <- list(...)
  is_tr <- vapply(args, inherits, logical(1), "starsim_transition")
  trs <- args[is_tr]
  pars <- args[!is_tr]
  if (length(pars) && (is.null(names(pars)) || any(!nzchar(names(pars))))) {
    stop("Arguments of disease() other than transitions are parameters, so they need names, e.g. beta = 0.3")
  }

  # The states, in order of first appearance, and the parameters, as Starsim objects
  ends <- lapply(trs, function(tr) parse_arrow(tr$arrow))
  state_names <- unique(unlist(ends))
  states <- stats::setNames(lapply(state_names, function(n) ss$State(n)), state_names)
  objs <- c(states, stats::setNames(lapply(names(pars), function(n) ss$par(pars[[n]], name = n)), names(pars)))

  # A formula is evaluated with the states and parameters in scope, so its arithmetic builds a Starsim expression
  value <- function(x) {
    if (inherits(x, "formula")) eval(x[[length(x)]], objs, environment(x)) else x
  }
  side <- function(names) {
    if (!length(names)) ss$null else if (length(names) == 1) states[[names]] else unname(states[names])
  }
  members <- lapply(seq_along(trs), function(i) {
    tr <- trs[[i]]
    kw <- Filter(Negate(is.null), lapply(tr$args, value))
    if (!is.null(tr$source)) kw$source <- unname(states[tr$source])
    if (!is.null(tr$name)) kw$name <- tr$name
    do.call(ss$Transition, c(list(side(ends[[i]]$src), side(ends[[i]]$dst)), kw))
  })
  kw <- Filter(Negate(is.null), list(init = init, init_prev = init_prev, name = name))
  do.call(ss$Disease, c(members, kw))
}

#' Results as a data frame
#'
#' All of a sim's results, one row per time point, with a column for each result
#' (named \code{<module>_<result>} in lowercase, e.g. \code{sir_n_i}), and the time in the first.
#'
#' @param sim A sim that has been run.
#'
#' @return A data frame.
#'
#' @export
results_df <- function(sim) {
  reticulate::py_to_r(sim$to_df())
}
