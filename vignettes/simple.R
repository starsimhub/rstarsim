# Pull out the commands for generating the plots

library(starsim)
load_starsim()

# For a nicer figure for saving
sc$options(dpi=200)

pars <- list(
  n_agents = 10000,
  birth_rate = 20,
  death_rate = 15,
  networks = list(
    type = 'randomnet',
    n_contacts = 4
  ),
  diseases = list(
    type = 'sir',
    dur_inf = 10,
    beta = 0.1
  )
)

sim <- Sim(pars)

sim$run()

sim$plot()
plt$show()

sim$diseases$sir$plot()
plt$show()

library(ggplot2)
df <- sim$results$sir$to_df()

ggplot(df, aes(timevec)) + 
  geom_line(aes(y = n_susceptible, colour = "Susceptible")) + 
  geom_line(aes(y = n_infected, colour = "Infected")) +
  geom_line(aes(y = n_recovered, colour = "Recovered"))
