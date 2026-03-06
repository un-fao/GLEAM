test_that("no function is defined more than once across R/ files", {
  r_dir <- test_path("../../R")

  r_files <- list.files(r_dir, pattern = "\\.R$", full.names = TRUE)

  all_definitions <- lapply(r_files, function(f) {
    lines <- readLines(f, warn = FALSE)
    # Match top-level assignments: fn_name <- function(, fn_name= function (, etc.
    fn_names <- regmatches(
      lines,
      regexpr("^[a-zA-Z0-9_.]+(?=\\s*(<-|=)\\s*function\\s*\\()", lines, perl = TRUE)
    )
    if (length(fn_names) == 0) return(NULL)
    data.frame(fn = fn_names, file = basename(f), stringsAsFactors = FALSE)
  })

  # filter out NULL and rbind all definitions into a single data frame
  all_definitions <- do.call(rbind, Filter(Negate(is.null), all_definitions))

  dupes <- all_definitions[
    duplicated(all_definitions$fn) | duplicated(all_definitions$fn, fromLast = TRUE),
  ]

  if (nrow(dupes) > 0) {
    dupe_report <- tapply(dupes$file, dupes$fn, paste, collapse = ", ")
    msg <- paste(
      mapply(
        function(fn, files) paste0("  '", fn, "' defined in: ", files),
        names(dupe_report), dupe_report
      ),
      collapse = "\n"
    )
    fail(paste("Duplicate function definitions found:\n", msg))
  }

  expect_true(nrow(dupes) == 0)
})
