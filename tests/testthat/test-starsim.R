test_that("Starsim runs", {

  # Install and load Starsim
  library(starsim)
  init_starsim()
  load_starsim()

  # Create and run a simple simulation
  sim <- Sim(diseases='sis', networks='random')
  sim$run()

  # Check that results are reasonable (prevalence should be ~50%)
  mean_prev <- sim$results$sis$prevalence$mean()
  min_prev = 0.3
  expect_gt(mean_prev, min_prev)
})
