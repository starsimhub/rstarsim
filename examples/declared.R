# A model declared in R with Starsim 4: transitions as arrow strings, rates as formulas
library(starsim)
load_starsim()

seir <- disease(
    transition("S -> E", beta = ~ beta, source = "I"),
    transition("E -> I", dur = ~ latent),
    transition("I -> R", rate = ~ gamma),
    beta = 0.3, latent = 5, gamma = 0.1, init = list(I = 10), name = "seir"
)

# The same model as an ODE, and as agents
ode <- ss$Sim(seir, stop = 120L)
ode$run()
abm <- ss$Sim(seir, stop = 120L, solver = "abm", n_agents = 10000L)
abm$run()

df <- results_df(ode)
plot(df$timevec, df$seir_n_i, type = "l", xlab = "Day", ylab = "Infectious")
lines(results_df(abm)$timevec, results_df(abm)$seir_n_i, lty = 2)
