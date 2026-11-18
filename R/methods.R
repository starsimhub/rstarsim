# R methods for Starsim objects: printing, plotting, and results as data frames

# A Starsim object without reticulate's conversion of what its methods return, so that this package converts them
raw <- function(x) {
  reticulate::r_to_py(x, convert = FALSE)
}

# A method of a Starsim object, without reticulate's conversion of what it returns (nor this package's: see dollar_starsim())
method <- function(x, name) {
  reticulate::py_get_attr(raw(x), name)
}

#' Plot a sim, multisim, fit, or result
#'
#' Plots with Starsim's own plots, as \code{x$plot()} does, on the current R
#' graphics device (so they appear in the console, RStudio, and R Markdown alike).
#' A figure made by Starsim or Matplotlib (e.g. by \code{x$plot()}) appears
#' when it is printed, as a ggplot does.
#'
#' @param x A sim (or one of its modules), multisim, fit, result, or figure.
#' @param ... Passed to \code{x$plot()}.
#'
#' @return The Matplotlib figure, invisibly.
#'
#' @name plot.starsim
#' @rawNamespace S3method(plot, starsim.internals.modules.Base, plot_starsim)
#' @rawNamespace S3method(plot, starsim.run.MultiSim, plot_starsim)
#' @rawNamespace S3method(plot, starsim.internals.fitting.Fit, plot_starsim)
#' @rawNamespace S3method(plot, starsim.results.Result, plot_starsim)
#' @rawNamespace S3method(plot, starsim.results.Results, plot_starsim)
#' @examplesIf starsim::starsim_available()
#' sim <- Sim(ss$SIR(), stop = 100)
#' sim$run()
#' plot(sim)
#' sim$plot() # The same, at the top level, where it is printed
NULL

plot_starsim <- function(x, ...) {
  fig <- method(x, "plot")(...)
  if (!inherits(fig, "python.builtin.NoneType")) {
    print(fig)
  }
  invisible(fig)
}

#' @rdname plot.starsim
#' @export
print.matplotlib.figure.Figure <- function(x, ...) {
  # Drawn at the device's size, so the text is in proportion; Matplotlib then saves it and R shows it
  size <- grDevices::dev.size("in")
  x$set_size_inches(size[1], size[2])
  file <- tempfile(fileext = ".png")
  on.exit(unlink(file))
  x$savefig(file, dpi = 150L)
  grid::grid.newpage()
  grid::grid.raster(png::readPNG(file))
  invisible(x)
}

#' Results as a data frame
#'
#' A sim's results, one row per time point, with a column for each result
#' (named \code{<module>_<result>}, e.g. \code{sir_I}) and the time in the first;
#' or a multisim's, one row per time point, result, scenario, and quantile.
#' Dates are \code{Date}s.
#'
#' @param x A sim, multisim, or result (e.g. \code{sim$results$sir}).
#' @param row.names,optional Not used.
#' @param ... Passed to \code{x$to_df()}.
#'
#' @return A data frame.
#'
#' @name as.data.frame.starsim
#' @rawNamespace S3method(as.data.frame, starsim.internals.modules.Base, df_starsim)
#' @rawNamespace S3method(as.data.frame, starsim.run.MultiSim, df_starsim)
#' @rawNamespace S3method(as.data.frame, starsim.results.Result, df_starsim)
#' @rawNamespace S3method(as.data.frame, starsim.results.Results, df_starsim)
#' @examplesIf starsim::starsim_available()
#' sim <- Sim(ss$SIR(), stop = 100)
#' sim$run()
#' df <- as.data.frame(sim)
#' plot(df$time, df$sir_I, type = "l")
NULL

df_starsim <- function(x, row.names = NULL, optional = FALSE, ...) {
  r_df(method(x, "to_df")(...))
}

#' Summarize a sim or multisim
#'
#' Each result over the whole run: the total of a flow (such as infections) and
#' the final value of a state.
#'
#' @param object A sim or multisim.
#' @param ... Passed to \code{object$summarize()}.
#'
#' @return For a sim, a named vector; for a multisim, a data frame of the median,
#'   low and high ends of the range that holds 95\% of the runs, the mean, and
#'   the standard deviation of each result in each scenario.
#'
#' @name summary.starsim
#' @examplesIf starsim::starsim_available()
#' msim <- parallel(Sim(ss$SIR(), stop = 100)$new(solver = "binomial"), n_runs = 20)
#' summary(msim)
NULL

#' @rdname summary.starsim
#' @export
summary.starsim.sim.Sim <- function(object, ...) {
  unlist(reticulate::py_to_r(method(object, "summarize")(...)$value$to_dict()))
}

#' @rdname summary.starsim
#' @export
summary.starsim.run.MultiSim <- function(object, ...) {
  r_df(method(object, "summarize")(...))
}

# Printed as in Python, in one line, not as reticulate prints a Python object (with its signature, if it can be called)
#' @rawNamespace S3method(print, starsim.internals.modules.Base, print_starsim)
#' @rawNamespace S3method(print, starsim.run.MultiSim, print_starsim)
#' @rawNamespace S3method(print, starsim.internals.expressions.Expr, print_starsim)
#' @noRd
print_starsim <- function(x, ...) {
  cat(reticulate::py_repr(x), "\n", sep = "")
  invisible(x)
}

# A pandas DataFrame as an R one, with its index as columns, text as character, and dates as Dates; also used for
# reticulate's conversion of Sciris dataframes (which Starsim returns), but not of other pandas ones, which are reticulate's
#' @rawNamespace S3method(reticulate::py_to_r, sciris.sc_dataframe.dataframe, r_df)
#' @noRd
r_df <- function(df) {
  df <- raw(df)
  pd <- reticulate::import("pandas", convert = FALSE)
  if (!reticulate::py_to_r(reticulate::import_builtins()$isinstance(df$index, pd$RangeIndex))) {
    df <- df$reset_index()
  }
  cols <- reticulate::py_to_r(df$columns$astype("str")$tolist())
  out <- lapply(cols, function(col) r_column(df$`__getitem__`(col)))
  structure(stats::setNames(out, cols), class = "data.frame", row.names = seq_len(reticulate::py_len(df)))
}

r_column <- function(col) {
  kind <- reticulate::py_to_r(col$dtype$kind)
  if (kind == "M") {
    times <- unlist(reticulate::py_to_r(col$dt$strftime("%Y-%m-%d %H:%M:%S")$tolist()))
    if (all(endsWith(times, "00:00:00"))) as.Date(substr(times, 1, 10)) else as.POSIXct(times, tz = "UTC")
  } else if (kind %in% c("b", "i", "u", "f")) {
    as.vector(reticulate::py_to_r(col$to_numpy()))
  } else {
    unlist(reticulate::py_to_r(col$astype("str")$tolist()))
  }
}

# A method of a Starsim object, called with R arguments as the functions of this package are (see py_args() and
# with_names()), and returning R values: a table as a data frame, and text (e.g. sim$equations()) printed as text;
# anything else is as reticulate gives it
#' @rawNamespace S3method("$", starsim.internals.modules.Base, dollar_starsim)
#' @rawNamespace S3method("$", starsim.run.MultiSim, dollar_starsim)
#' @rawNamespace S3method("$", starsim.internals.fitting.Fit, dollar_starsim)
#' @noRd
dollar_starsim <- function(x, name) {
  fn <- reticulate::py_get_attr(raw(x), name, silent = TRUE)
  if (!inherits(fn, c("python.builtin.method", "python.builtin.function", "python.builtin.builtin_function_or_method"))) {
    return(NextMethod())
  }
  function(...) {
    envir <- parent.frame()
    out <- with_names(envir, do.call(fn, py_args(list(...))))
    if (reticulate::py_id(out) == reticulate::py_id(x)) { # The object itself, changed (e.g. disease$stratify()), so not printed again
      return(invisible(x))
    }
    r_value(out)
  }
}

# What a method returned, as an R value (see dollar_starsim())
r_value <- function(x) {
  if (inherits(x, c("pandas.DataFrame", "pandas.core.frame.DataFrame"))) { # Its name in pandas 3, and before
    return(r_df(x))
  }
  x <- reticulate::r_to_py(x, convert = TRUE)
  if (inherits(x, "starsim.internals.display.Text")) x else reticulate::py_to_r(x)
}

# Text that shows itself in Python (sim$describe(), sim$equations()), printed as it is
#' @rawNamespace S3method(print, starsim.internals.display.Text, print_text)
#' @noRd
print_text <- function(x, ...) {
  cat(reticulate::py_str(x), "\n", sep = "")
  invisible(x)
}

# A dictionary of Starsim's (e.g. sim$diseases, sim$interventions) by position as well as by name: sim$interventions[[0]],
# with 0 an integer, as Python needs, though R's numbers are not
#' @rawNamespace S3method("[[", sciris.sc_odict.odict, item_odict)
#' @noRd
item_odict <- function(x, i, ...) {
  if (is.numeric(i)) {
    i <- as.integer(i)
  }
  reticulate::py_get_item(x, i)
}

# The sims of a multisim (msim$sims), by position (from 0, as in Python) or scenario: msim$sims[[0]], msim$sims[["Vaccine"]];
# as.list() for an R list, e.g. to loop over (for (sim in as.list(msim$sims))). Not converted to an R list as they come,
# since a sim that was restarted for its runs is made again only when it is asked for
#' @rawNamespace S3method("[[", starsim.run.ByScenario, item_sims)
#' @rawNamespace S3method(length, starsim.run.ByScenario, length_sims)
#' @rawNamespace S3method(as.list, starsim.run.ByScenario, list_sims)
#' @noRd
item_sims <- function(x, i, ...) {
  if (is.numeric(i)) {
    i <- as.integer(i)
  }
  reticulate::py_get_item(x, i)
}

length_sims <- function(x) {
  reticulate::py_len(x)
}

list_sims <- function(x, ...) {
  lapply(seq_len(length(x)) - 1L, function(i) x[[i]])
}
