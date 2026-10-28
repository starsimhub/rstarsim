# Project Engineering Score

- **Project**: `/home/cliffk/idm/rstarsim`
- **Tier**: 2 (Small-scale project)
- **Overall Score**: 82/100
- **Status**: PASS
- **Date**: 2026-04-13
- **Version**: idm-eng-plugin:eng-quality-checker v1.3_2026.04.13
- **Time spent**: 170s

## Summary

| Category | Score | Weight |
| -- | -- | -- |
| Quality | 75/100 | 40% |
| Usability | 86/100 | 40% |
| Safety | 88/100 | 20% |
| **Total** | **82/100** | 100% |

| Metric | Score | Notes |
| -- | -- | -- |
| correct | 7/10 | One basic integration test exists but no tests for argument validation, reinstall_starsim, or load_starsim branches; no CI running tests |
| clear | 8/10 | All exported functions have roxygen2 docstrings with examples; .onLoad lacks documentation |
| concise | 10/10 | No duplication; appropriately minimal wrapper delegating to Python Starsim |
| simple | 9/10 | Clean 3-function API with sensible defaults and input validation; minor pkgdown reference gap |
| powerful | 8/10 | Exposes full Python ss namespace and supports custom PyClass subclassing; flexibility is by design delegated to Python |
| performant | 8/10 | Thin reticulate wrapper with no R-side computational overhead; no benchmarks needed |
| documented | 9/10 | Four vignettes, roxygen2 docstrings with examples, pkgdown site; minor gap in docs/reference pages |
| accessible | 9/10 | Public GitHub repo with MIT license, installable via devtools::install_github; not yet on CRAN |
| compliant | 10/10 | MIT license present, no secrets or restrictive dependencies |
| reproducible | 7/10 | DESCRIPTION pins reticulate >= 1.34 and has v1.0.0 git tag; Python starsim dep is unpinned and seed handling not exposed in R |

This is a well-structured R wrapper package with strong documentation, clean API design, and full compliance. The biggest gaps are in test coverage (only one basic test, no CI running tests) and reproducibility (unpinned Python dependency, no seed exposure in R layer). The usability and safety categories are strong, reflecting good API design and proper licensing.

## Recommendations

1. **[correct] -- Add tests for all exported functions and branches** *(effort: medium; automated: yes)*
   Add testthat tests for `reinstall_starsim()`, `load_starsim(envname=FALSE)`, and the argument validation error paths in `init_starsim()` (e.g., test that passing a non-string envname raises an error). This would improve correct from 7 to 9.

2. **[correct] -- Add a CI workflow that runs testthat** *(effort: quick; automated: yes)*
   Create a `.github/workflows/R-CMD-check.yaml` workflow (or extend the existing pkgdown workflow) to run `R CMD check` or `devtools::test()` on push/PR. The current pkgdown.yaml only builds the docs site. This would help raise correct toward 10.

3. **[reproducible] -- Pin the Python starsim version** *(effort: quick; automated: yes)*
   In `reinstall_starsim()`, default to installing a specific version of starsim (e.g., `starsim==2.x.y`) or document a recommended version. Consider adding a `Config/reticulate` version pin in DESCRIPTION. This would raise reproducible from 7 to 8-9.

4. **[reproducible] -- Expose or document seed handling in the R interface** *(effort: quick; automated: no)*
   Add documentation (or a helper) showing how to set random seeds via the Python starsim API from R (e.g., `ss$set_seed(42)`). This ensures users know how to get deterministic results. This would contribute to raising reproducible toward 9-10.

5. **[performant] -- Add a simple benchmark vignette** *(effort: medium; automated: no)*
   A short vignette or example showing typical simulation runtimes would help users set expectations. This is low priority given the wrapper nature but would raise performant from 8 to 9-10.

6. **[accessible] -- Publish to CRAN** *(effort: large; automated: no)*
   Submitting to CRAN would make installation a single `install.packages("starsim")` command and improve discoverability. This would raise accessible from 9 to 10.

7. **[simple] -- Fix missing pkgdown reference page** *(effort: quick; automated: yes)*
   Ensure `reinstall_starsim` and `load_starsim` both appear in the pkgdown reference index at docs/reference/. This would raise simple from 9 to 10.

8. **[documented] -- Ensure all man pages render on pkgdown site** *(effort: quick; automated: yes)*
   The `load_starsim.html` reference page appears to be missing from the built pkgdown site. Rebuild with `pkgdown::build_site()` to ensure all pages are generated. This would raise documented from 9 to 10.

## Full Results

```yaml
project: /home/cliffk/idm/rstarsim
tier: 2
overall_score: 82
failed: false
quality:
  correct:
    score: 7
    weight: 7
    reason: "One basic integration test exists covering a single SIS sim run, but no tests for reinstall_starsim, argument-validation branches, or load_starsim(envname=FALSE); the only CI workflow builds the docs site and does not run testthat."
  clear:
    score: 8
    weight: 2
    reason: "All three exported functions have roxygen2 docstrings with @return, @export, and @examplesIf; the .onLoad hook lacks documentation and inline comments are minimal but adequate for the straightforward logic."
  concise:
    score: 10
    weight: 1
    reason: "No code duplication detected; the package is appropriately minimal and delegates all simulation logic to the Python Starsim library via reticulate."
usability:
  simple:
    score: 9
    weight: 3
    reason: "The public API is just three functions with sensible defaults and input validation via stop() calls; the README example runs a full SIR sim in ~10 lines."
  powerful:
    score: 8
    weight: 2
    reason: "The wrapper exposes the full Python ss namespace plus direct class imports and supports custom PyClass subclassing; flexibility is delegated to Python Starsim by design."
  performant:
    score: 8
    weight: 2
    reason: "Thin reticulate wrapper with no R-side computational loops; all heavy computation runs in Python/Starsim with no performance anti-patterns in R code."
  documented:
    score: 9
    weight: 2
    reason: "All exported functions have roxygen2 docstrings with runnable examples; four vignettes cover installation, simple usage, advanced usage, and troubleshooting; pkgdown site built at r.starsim.org."
  accessible:
    score: 9
    weight: 1
    reason: "Public GitHub repo with MIT license, installable via devtools::install_github in one command; not yet on CRAN."
safety:
  compliant:
    score: 10
    weight: 6
    reason: "MIT license present with clear copyright; no exposed secrets, hardcoded credentials, or restrictive-licensed dependencies."
  reproducible:
    score: 7
    weight: 4
    reason: "Dependencies specified with lower-bound pins in DESCRIPTION and a semantic v1.0.0 git tag exists; however, the Python starsim dependency is installed unpinned and random seed handling is not exposed in the R interface."
```
