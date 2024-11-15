# Load Starsim
library(starsim)

# Run a simple demo
s1 <- ss$demo()

# Full example
pars <- list(
    n_agents = n_agents,
    birth_rate = 20,
    death_rate = 15,
    networks = list(
        type = 'randomnet',
        n_contacts = 4,
    ),
    diseases = list(
        type = 'sir',
        dur_inf = 10,
        beta = 0.1,
    )
)

s2 <- ss$Sim(pars)
s2$run()
s2$plot()