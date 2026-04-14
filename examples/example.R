# Load Starsim
library(starsim)
load_starsim()

# Set the simulation parameters
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

# Create, run, and plot the simulation
sim <- ss$Sim(pars)
sim$run()
sim$plot()