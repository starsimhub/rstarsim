test_that("A model declared in R runs", {

  load_starsim()
  sir <- disease(
    transition("S -> I", beta = ~ beta),
    transition("I -> R", rate = ~ gamma),
    beta = 0.3, gamma = 0.1, init = list(I = 10), name = "sir"
  )
  sim <- ss$Sim(sir, stop = 100L, verbose = 0L)
  sim$run()

  # The epidemic grows, and the results are a data frame
  df <- results_df(sim)
  expect_gt(max(df$sir_n_i), 100)
})
