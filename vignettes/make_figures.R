# Run the code in the vignettes and the README, and save their figures; run from this folder
library(starsim)

save_png <- function(file, expr, width = 8, height = 6) {
  png(file, width = width, height = height, units = "in", res = 100)
  on.exit(dev.off())
  print(expr)
}

# install.Rmd
sim <- ss$demo(plot = FALSE)
save_png("install-demo.png", sim$plot())

# simple.Rmd
states("S I R")
sir <- Disease(
  infection = Transition(S, I, rate = 0.3 * I),
  recovery  = Transition(I, R, dur = days(10))
)
print(sir$equations())
sim <- Sim(sir, stop = days(100))
sim$run()
save_png("simple-sim.png", sim$plot())
df <- as.data.frame(sim)
print(head(df[, 1:6]))
library(ggplot2)
p <- ggplot(df, aes(time)) +
  geom_line(aes(y = sir_S, colour = "Susceptible")) +
  geom_line(aes(y = sir_I, colour = "Infectious")) +
  geom_line(aes(y = sir_R, colour = "Recovered")) +
  labs(x = "Day", y = "People", colour = NULL)
save_png("simple-custom.png", p, height = 4)
msim <- sim$run(solver = "binomial", n_runs = 20)
save_png("simple-msim.png", msim$plot())
print(summary(msim))
save_png("../man/figures/example-r.png", msim$plot())

# advanced.Rmd
states("S I R")
beta <- par(0.02, bounds = c(0.005, 0.1))
infection <- Transition(S, I, rate = beta * I)
sir <- Disease(
  infection = infection,
  recovery  = Transition(I, R, dur = days(10)),
  cases     = outcome(0.2 * infection),
  init_prev = 0.0001,
  stratify  = list(age = list("0" = 0.3, "15" = 0.6, "65" = 0.1))
)
matrix <- rbind(
  c(10, 6, 1),
  c( 3, 8, 1),
  c( 3, 6, 3)
)
make_sim <- function(...) {
  Sim(sir, networks = contacts(ages = c(0, 15, 65), matrix = matrix),
      total_pop = 1e6, start = "2025-01-01", stop = "2025-07-01", ...)
}
sim <- make_sim()
sim$run()
save_png("advanced-age.png", sim$results$sir$I$by("age")$plot(), height = 4)
vaccine <- vaccinate(efficacy = 0.9, where = sir$age >= 65, coverage = 0.8, at = "2025-02-01")
masks <- modify(sir$pars$beta, multiply = 0.6, start = "2025-02-01")
scenarios <- list("No intervention" = NULL, "Vaccine" = vaccine, "Masks" = masks)
sims <- lapply(scenarios, function(intervention) make_sim(interventions = intervention))
msim <- parallel(sims)
save_png("advanced-scenarios.png", msim$plot())
s <- summary(msim)
print(s[s$result == "sir_infection", ])
truth <- make_sim(pars = list(beta = 0.025), rand_seed = 2)
truth$run()
data <- truth$to_data("cases", resample = "week")
print(head(data))
sim <- make_sim(data = data)
fit <- sim$fit()
save_png("advanced-fit.png", fit$plot(), height = 4)
print(fit$pars$beta)
msim <- fit$sim$run(solver = "binomial", n_runs = 20)
print(class(msim$plot()))

# troubleshooting.Rmd
print(class(truth$results$sir$I$values))
print(head(truth$to_df()[, 1:3], 2))
print(par(value = 0.3))
