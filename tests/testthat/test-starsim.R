skip_if_no_starsim <- function() {
  skip_if_not(reticulate::py_module_available("starsim"), "Starsim is not installed")
}

test_that("A model runs, plots, and gives its results", {
  skip_if_no_starsim()

  states("S I R")
  sir <- Disease(
    infection = Transition(S, I, rate = 0.3 * I),
    recovery  = Transition(I, R, dur = 10)
  )
  sim <- Sim(sir, stop = 100, verbose = 0)
  sim$run()
  df <- as.data.frame(sim)
  expect_gt(max(df$sir_I), 1000) # The epidemic grows
  expect_equal(df$time[1:2], c(0, 1)) # Time is the first column
  expect_named(summary(sim)[1:3], c("sir_S", "sir_I", "sir_R"))

  pdf(NULL)
  on.exit(dev.off())
  expect_s3_class(plot(sim), "matplotlib.figure.Figure")

  msim <- sim$run(solver = "binomial", n_runs = 20) # Counts given as R numbers
  s <- summary(msim)
  expect_equal(s$result[1:3], c("sir_S", "sir_I", "sir_R")) # The index is a column
  expect_true(all(s$low <= s$median & s$median <= s$high))
})

test_that("R values are passed as a Python user would type them", {
  skip_if_no_starsim()

  expect_identical(py_args(list(2, 2.5, c(0, 15))), list(2L, 2.5, c(0L, 15L))) # Whole numbers are integers
  shares <- reticulate::py_to_r(reticulate::py_str(py_args(list("0" = 0.3, "65" = 0.7))))
  expect_equal(shares, "{0: 0.3, 65: 0.7}") # Numbers as names are numbers as keys
  expect_identical(py_args(list(a = NULL))$a, NULL) # NULL is None

  expect_s3_class(par(0.3, bounds = c(0.1, 1)), "starsim.internals.expressions.par")
  pdf(NULL)
  on.exit(dev.off())
  expect_type(par("mar"), "double") # Graphical parameters are R's
})

test_that("States are put in scope, and replace only states", {
  skip_if_no_starsim()

  local({
    states("S I R")
    expect_s3_class(I, "starsim.transitions.State")
    states("S I R") # Run again
    R <- 5
    expect_error(states("S I R"), "would replace R")
    st <- states("S I R", envir = NULL)
    expect_named(st, c("S", "I", "R"))
  })
})

test_that("Scenarios, data, and fitting work from R", {
  skip_if_no_starsim()

  states("S I R")
  beta <- par(0.02, bounds = c(0.005, 0.1))
  infection <- Transition(S, I, rate = beta * I)
  sir <- Disease(
    infection = infection,
    recovery = Transition(I, R, dur = days(10)),
    cases = outcome(0.2 * infection),
    init_prev = 0.0001,
    stratify = list(age = list("0" = 0.3, "15" = 0.6, "65" = 0.1))
  )
  pars <- list(
    networks = contacts(ages = c(0, 15, 65), matrix = rbind(c(10, 6, 1), c(3, 8, 1), c(3, 6, 3))),
    total_pop = 1e6, start = "2025-01-01", stop = "2025-07-01", verbose = 0
  )
  vaccine <- vaccinate(efficacy = 0.9, where = sir$age >= 65, coverage = 0.8, at = "2025-02-01")
  masks <- modify(sir$pars$beta, multiply = 0.6, start = "2025-02-01")
  scenarios <- list("No intervention" = NULL, "Vaccine" = vaccine, "Masks" = masks)
  sims <- lapply(scenarios, function(iv) do.call(Sim, c(list(sir, interventions = iv), pars)))
  msim <- parallel(sims)
  s <- summary(msim)
  infections <- s$median[s$result == "sir_infection"]
  expect_equal(unique(s$scenario), names(scenarios))
  expect_true(all(infections[2:3] < infections[1])) # The interventions work

  truth <- do.call(Sim, c(list(sir, pars = list(beta = 0.025), rand_seed = 2), pars))
  truth$run()
  df <- as.data.frame(truth)
  expect_equal(df$time[1], as.Date("2025-01-01")) # Dates are Dates
  data <- truth$to_data("cases", resample = "week")
  sim <- do.call(Sim, c(list(sir, data = data), pars))
  fit <- sim$fit(verbose = 0)
  expect_equal(fit$pars$beta, 0.025, tolerance = 0.05)
})
