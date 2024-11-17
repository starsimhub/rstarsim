# Pull out the commands for generating the plots

library(starsim)
library(reticulate)
load_starsim("r_star", required = TRUE)

# Create a new class for an SEIR disease
SEIR <- PyClass("SEIR", 
  inherit = ss$SIR, # Inherit from the SIR class
  defs = list(
    `__module__` = "SEIR",
    name = py_none(),

    # Define the __init__ method
    `__init__` = function(self, pars = py_none(), ...) {
      ss$SIR$`__init__`(self) # Call the parent init method

      # Parameters specific to SEIR: duration of exposure
      self$define_pars(
          dur_exp = ss$lognorm_ex(0.5),
      )
      self$update_pars(pars, ...)

      # Additional states beyond the SIR ones
      self$define_states(
          ss$State('exposed', label='Exposed'),
          ss$FloatArr('ti_exposed', label='TIme of exposure'),
      )
      py_none()
    },

    # Make all the updates from the SEIR model
    step_state = function(self) {
        ss$SIR$step_state(self) # Perform SIR updates

        # Additional updates: progress exposed -> infected
        infected <- self$exposed & (self$ti_infected <= self$ti)
        self$exposed[infected] = FALSE
        self$infected[infected] = TRUE
        py_none()
    },

    # Ensure that exposed is set to False for people who die
    step_die = function(self, uids) {
      ss$SIR$step_die(self, uids) # Perform SIR updates
      self$exposed[uids] = False
      py_none()
    },

    # Carry out state changes associated with infection
    set_prognoses = function(self, uids, sources = py_none()) {
      print('HIIIIIII')
      uids <- ss$uids(uids)
      print(uids)
      ss$SIR$set_prognoses(self, uids, sources) # Perform SIR updates
      ti <- self$ti
      self$susceptible[uids] = FALSE
      self$exposed[uids] = TRUE
      self$ti_exposed[uids] = ti

      # Calculate and schedule future outcomes
      dur_exp <- self$pars['dur_exp']$rvs(uids)
      self$ti_infected[uids] <- ti + dur_exp
      dur_inf <- self$pars['dur_inf']$rvs(uids)
      will_die <- self$pars['p_death']$rvs(uids)
      self$ti_recovered[uids[~will_die]] <- ti + dur_inf[~will_die]
      self$ti_dead[uids[will_die]] <- ti + dur_inf[will_die]

      # Update result count of new infections
      new_inf <- self$results['new_infections']
      new_inf[self$ti] = new_inf[self$ti] + len(uids)
      py_none()
    },

    # Plot results
    plot = function(self) {
      library(ggplot2)
      df <- self$results$to_df()

      ggplot(df, aes(timevec)) + 
        geom_line(aes(y = n_susceptible, colour = "Susceptible")) + 
        geom_line(aes(y = n_exposed, colour = "Exposed")) +
        geom_line(aes(y = n_infected, colour = "Infected")) +
        geom_line(aes(y = n_recovered, colour = "Recovered"))
    }
  )
)

# For a nicer figure for saving
sc$options(dpi=200)

# Run and plot
print(ss$`__file__`)
print(ss$`__version__`)
seir <- SEIR()
sim <- ss$Sim(diseases=seir, networks='random')
sim$run()
sim$diseases$seir$plot()