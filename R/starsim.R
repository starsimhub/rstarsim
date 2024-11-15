# All publicly visible functions

# Imports
ss <- reticulate::import('starsim')
# sc <- import('sciris')
# np <- import('numpy')
# pd <- import('pandas')
plt <- reticulate::import('matplotlib.pyplot')

# Shortcuts to important classes
Sim <- ss$Sim
MultiSim <- ss$MultiSim
People <- ss$People
Module <- ss$Module
Demographics <- ss$Demographics
Network <- ss$Network
Disease <- ss$Disease
Intervention <- ss$Intervention
Analyzer <- ss$Analyzer

#' Show any Python plots that have been generated
#'
#' @return
#' @export
#'
#' @examples
pyshow <- function() {
    plt$show()
}
