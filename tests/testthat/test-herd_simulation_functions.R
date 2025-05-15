test_that("compute_fecundity_rates returns expected output", {
  res <- compute_fecundity_rates(
    part_rate = 0.8,
    prolif_rate = 2,
    fem_birth_ratio = 0.5
  )

  expect_type(res, "list")
  expect_named(res, c("female_fecundity", "male_fecundity"))
  expect_equal(res$female_fecundity, 0.8 * 2 * 0.5 / 365)
  expect_equal(res$male_fecundity, 0.8 * 2 * 0.5 / 365)  # symmetrical case
})

test_that("compute_transition_probabilities returns named list with correct lengths", {
  dur <- rep(365, 6)
  off <- rep(0.1, 6)
  death <- rep(0.05, 6)

  res <- compute_transition_probabilities(
    duration = dur,
    offtake_rate = off,
    death_rate = death
  )

  expect_type(res, "list")
  expect_named(res, c("hdea", "hoff", "pdea", "poff", "psur", "g"))
  expect_length(res$hdea, 6)
  expect_length(res$pdea, 10)
})

test_that("simulate_steady_state_structure converges and returns valid structure", {
  fec <- compute_fecundity_rates(0.8, 2, 0.5)
  trans <- compute_transition_probabilities(
    duration = rep(365, 6),
    offtake_rate = rep(0.1, 6),
    death_rate = rep(0.05, 6)
  )

  result <- simulate_steady_state_structure(
    initial_structure = c(100, 50, 30, 100, 50, 30),
    max_years = 5,
    min_lambda_change = 1e-6,
    female_fecundity = fec$female_fecundity,
    male_fecundity = fec$male_fecundity,
    pdea = trans$pdea,
    poff = trans$poff,
    g = trans$g
  )

  expect_named(result, c("days_steady", "structure", "share", "growth_rate_pop"))
  expect_true(result$days_steady <= 5 * 365)
  expect_equal(sum(result$structure), 1, tolerance = 1e-6)
})

test_that("project_population_size runs and returns list with expected elements", {
  fec <- compute_fecundity_rates(
    0.8, 2, 0.5
  )
  trans <- compute_transition_probabilities(
    rep(365, 6), rep(0.1, 6), rep(0.05, 6)
  )
  steady <- simulate_steady_state_structure(
    initial_structure = c(100, 50, 30, 100, 50, 30),
    max_years = 5, min_lambda_change = 1e-6,
    female_fecundity = fec$female_fecundity,
    male_fecundity = fec$male_fecundity,
    pdea = trans$pdea,
    poff = trans$poff,
    g = trans$g
  )

  res <- project_population_size(
    size_total = 1000,
    female_fecundity = fec$female_fecundity,
    male_fecundity = fec$male_fecundity,
    pdea = trans$pdea,
    poff = trans$poff,
    g = trans$g,
    growth_rate_pop = steady$growth_rate_pop,
    structure = steady$structure,
    share = steady$share
  )

  expect_named(res, c("size", "size_end", "size_end_exact", "size_avg", "offtake"))
  expect_length(res$size, 6)
})

test_that("summarise_offtake returns all expected components", {
  offtake <- setNames(rep(10, 10), c("FB", "FJ", "FS", "FA", "FC", "MB", "MJ", "MS", "MA", "MC"))
  res <- summarise_offtake(
    size = rep(100, 6),
    size_end = rep(110, 6),
    size_avg = rep(105, 6),
    offtake = offtake
  )

  expect_named(res, c(
    "stock_variation", "offtake_number", "offtake_share", "offtake_share_avg",
    "offtake_sv_number", "offtake_sv_share", "offtake_sv_share_avg"
  ))
  expect_length(res$offtake_number, 6)
})
