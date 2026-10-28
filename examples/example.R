# An SIR model in Starsim, run as an ODE and then 20 times as a stochastic model
library(starsim)

states("S I R") # Puts S, I and R in scope
sir <- Disease(
  infection = Transition(S, I, rate = 0.3 * I),
  recovery  = Transition(I, R, dur = 10),
  init_prev = 0.01
)
sim <- Sim(sir, stop = 100)
sim$run()
sim$plot()

msim <- sim$run(solver = "binomial", n_runs = 20)
msim$plot()
summary(msim)
