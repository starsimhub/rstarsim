# Explore Reticulate and Starsim

library('reticulate')

ss <- import('starsim')
mod <- ss$modules$Module

Hi <- PyClass("Hi",
inherit = mod,
defs = list(
  `__module__` = "Hi",
  name = NULL,
  count = 0,

  `__init__` = function(self, name) {
    mod$`__init__`(self)
    self$name <- name
    NULL
  },

  say_hi = function(self) {
    paste0("Hi ", self$name)
  },

  step = function(self) {
    self$count <- self$count + 1
    print(paste('Count is', self$count))
    NULL
  }
)
)

a <- Hi("World")

print(a$say_hi())

sim = ss$Sim(connectors=a)
sim$run()
