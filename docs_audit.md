# Documentation audit report: R-Starsim

*Audited 2026-04-14*

---

## 1. Summary

R-Starsim's documentation is in good shape for a small wrapper package. The README is well structured with installation, usage, and a working example. Vignettes provide a clear tutorial progression from installation through advanced custom module creation. The main gaps are: no explanation-type documentation (e.g., why R-Starsim works the way it does, how the Python/R bridge operates), no LMIC context acknowledgment, and limited policy-facing framing on the landing page.

---

## 2. Strengths

- **README is comprehensive and well structured.** Includes what the package does, installation (multiple paths), usage guidance, a complete working example with output image, project structure table, contributing link, and contact info.
- **Tutorial progression is excellent.** Installation -> Simple usage -> Advanced usage (custom SEIR module) provides a natural learning arc. The simple tutorial shows both parameter-based and object-based configuration, which is a good teaching choice.
- **Troubleshooting guide exists and is practical.** Addresses real pain points (plotting in RStudio, backend issues, font scaling) that R users actually encounter with reticulate-based packages.
- **All exported functions have complete roxygen2 docstrings.** Each includes a one-line summary, description, `@param`, `@return`, `@seealso` cross-references, and `@examplesIf` sections.
- **Standard repo files are all present.** LICENSE (MIT), NEWS.md (changelog), CONTRIBUTING.md, CODE_OF_CONDUCT.md.
- **pkgdown site is configured** with organized navigation separating vignettes from user guides.
- **Vignettes link to each other** with "Next steps" sections, guiding readers through the docs.

---

## 3. Weaknesses

- **No explanation-type documentation.** There is no content explaining *why* R-Starsim works the way it does -- how reticulate bridges Python/R, why `ss$` syntax is used, what the tradeoffs are vs. using Python directly, or how the conda environment management works under the hood. This affects model-extenders and model-builders who need to debug or extend beyond the tutorials. *(Affects: model-extenders, model-builders)*
- **Landing page lacks policy-facing framing.** The README opens with a technical description. There is no mention of real-world applications, policy questions Starsim can answer, or evidence of trustworthiness (publications, deployments). Policy-influencers visiting the GitHub page get no signal about whether this tool is relevant to their work. *(Affects: policy-makers, policy-influencers)*
- **No LMIC context acknowledgment anywhere.** Tutorials assume reliable internet for Miniconda download and conda environment setup. No mention of offline installation, low-bandwidth alternatives, or infrastructure constraints. *(Affects: model-users in LMIC settings)*
- **No folder-level READMEs.** The `R/`, `man/`, `vignettes/`, `tests/`, `examples/`, and `sandbox/` directories lack README.md files. The top-level README's project structure table partially compensates, but someone browsing on GitHub still has to navigate back to the root to understand folder purposes. *(Minor -- the project structure table in README covers this adequately per IDM standards)*
- **Changelog is sparse.** NEWS.md has only two entries and the v1.1.0 entry ("Updated to use new version of `reticulate`") gives no detail on what changed or why. *(Affects: model-extenders, model-builders tracking compatibility)*
- **Advanced tutorial jumps steeply from simple.** The simple tutorial configures existing modules; the advanced tutorial creates a full custom PyClass disease module. There is no intermediate tutorial (e.g., adding an intervention, running a MultiSim, or doing custom analysis). The advanced tutorial itself acknowledges this gap in its "Next steps" section. *(Affects: model-users, model-extenders)*
- **Troubleshooting is classified as "User guide" in pkgdown nav but reads as a how-to guide.** The `_pkgdown.yml` puts troubleshooting under "User guides" while the three tutorials are under "Vignettes." This is a minor Diataxis misclassification -- troubleshooting is a how-to guide, not a user guide.

---

## 4. Recommendations

| # | Recommendation | Why it matters | Effort |
|---|----------------|----------------|--------|
| 1 | **Add a one-paragraph policy-facing opener to the README** before the technical description. Frame what policy questions Starsim can help answer, mention real-world applications, and link to the main Starsim site for evidence. | Policy-influencers and program officers visiting GitHub need to quickly assess relevance and trustworthiness. Currently the README speaks only to technical users. | Low |
| 2 | **Add an explanation page on the Python/R bridge.** Cover how reticulate works, why `ss$` syntax is needed, what `load_starsim()` actually does behind the scenes, and common gotchas (object conversion, None vs NULL, etc.). Link from the troubleshooting guide. | Model-extenders and model-builders who hit issues beyond the FAQ need to understand the interop layer to debug effectively. This is the biggest conceptual gap in the docs. | Medium |
| 3 | **Add an intermediate tutorial** between simple and advanced. Good candidates: adding an intervention (e.g., vaccination), running a MultiSim for scenario comparison, or extracting and analyzing results in R. | The jump from "configure existing modules" to "write a custom PyClass" is too steep. Model-users and model-extenders need a stepping stone. | Medium |
| 4 | **Add a note about LMIC/offline installation** to the installation vignette. Mention that Miniconda download requires internet, suggest pre-downloading conda packages, or point to offline setup instructions. | Model-users in LMIC settings with unreliable internet may fail at `init_starsim()` without understanding why or how to work around it. | Low |
| 5 | **Flesh out NEWS.md entries** with more detail. For each version, list specific changes, breaking changes, and migration notes. | Users upgrading need to know what changed. "Updated to use new version of reticulate" doesn't explain whether their code needs changes. | Low |
| 6 | **Reclassify troubleshooting in pkgdown nav.** Move it from "User guides" to a "How-to guides" or "Troubleshooting" section, or merge it under Vignettes with a clear label. | Proper Diataxis categorization helps users find content where they expect it. | Low |
| 7 | **Add folder-level READMEs** to `R/`, `vignettes/`, `tests/`, and `examples/`. One to two sentences each. | Improves GitHub browsability, though the project structure table in the top-level README already partially covers this. | Low |

---

## 5. Diataxis coverage

| Type | Status | Notes |
|------|--------|-------|
| **Tutorials** | Good | Three vignettes (install, simple, advanced) form a clear progression. Could use an intermediate tutorial. |
| **How-to guides** | Partial | Troubleshooting is the only how-to content. No guides for common tasks like "how to use a custom conda env," "how to export results to CSV," etc. |
| **Reference** | Good | Auto-generated from roxygen2 via pkgdown. All 3 public functions fully documented with params, returns, examples, and cross-references. |
| **Explanation** | Missing | No content explaining design decisions, architecture, or the Python/R interop layer. |

---

## 6. Persona targeting

| Doc section | Target personas | Fit | Notes |
|-------------|----------------|-----|-------|
| README opening | policy-maker, policy-influencer | Needs work | Opens with technical description. No policy framing, applications, or trust signals. |
| README body | model-user, model-extender, model-builder | Good | Clear install, usage, example. Project structure table helps orientation. |
| Installation vignette | model-user | Good | Step-by-step, concrete, appropriate level. Missing LMIC/offline note. |
| Simple tutorial | model-user, model-extender | Good | Leads with workflow, shows two configuration approaches, includes custom plotting. |
| Advanced tutorial | model-extender, model-builder | Good | Realistic PyClass example with clear explanation of customization points. |
| Troubleshooting | model-user | Good | Practical, addresses real RStudio pain points. |
| API reference (man pages) | model-builder | Good | Complete for the 3-function API. Cross-references between functions. |

---

## 7. Docstring / roxygen2 quality

*Note: This is an R package, so the Python docstring guidelines are not directly applicable. Evaluated against roxygen2 best practices and IDM standards.*

| Criterion | Status | Notes |
|-----------|--------|-------|
| All public functions documented | Present | 3/3 exported functions have full roxygen2 blocks |
| One-line summary | Present | Each function has a clear title |
| Parameter descriptions | Present | All `@param` entries include type, description, and defaults |
| Return values | Present | `@return` sections describe side effects and invisible NULL |
| Cross-references | Present | `@seealso` links between all three functions |
| Usage examples | Present | `@examplesIf interactive()` on all functions |
| Researcher workflow context | Partial | `load_starsim()` documents what objects are created; `init_starsim()` explains the one-time vs. per-session distinction. Could benefit from noting which stage of the workflow each function belongs to. |

---

## 8. Completeness checklist

| Component | Status | Notes |
|-----------|--------|-------|
| README.md | Present | Comprehensive; missing policy-facing opener |
| LICENSE | Present | MIT |
| Changelog | Partial | NEWS.md exists but entries are sparse |
| Contributing guide | Present | CONTRIBUTING.md with dev setup, tests, docs, and PR workflow |
| Code of conduct | Present | Contributor Covenant v1.4 |
| Folder-level READMEs | Missing | Compensated by project structure table in top-level README |
| Docs site config | Present | `_pkgdown.yml` with organized navigation |
| Hello-world tutorial | Present | `install.Rmd` + `simple.Rmd` |
| Advanced tutorial(s) | Present | `advanced.Rmd` (custom SEIR module) |
| Intermediate tutorial | Missing | Gap between simple and advanced |
| User guide | N/A | Package is small enough that tutorials + reference suffice |
| API reference | Present | Auto-generated from roxygen2 via pkgdown |
| Diataxis coverage | Partial | Tutorials and reference good; how-to guides limited; explanation missing |
| Persona targeting | Partial | Good for technical personas; weak for policy-facing personas |
| Docstring quality | Good | All public functions fully documented with params, returns, examples, cross-refs |
