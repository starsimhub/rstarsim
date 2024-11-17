# Load Starsim
library(starsim)
load_starsim()

ss$options(jupyter=TRUE)

# Run a simple demo
s1 <- ss$demo()

# Full example
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

sim <- ss$Sim(pars)
sim$run()
sim$plot()
