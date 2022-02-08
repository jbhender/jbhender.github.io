#'---
#' title: 'Supporting material for "Agreement measures examining low-value imaging for low back pain"'
#' date: "`r format.Date(Sys.Date(), '%B %d, %Y')`"
#' author: 'James Henderson, Katherine Wilkinson, Timothy P. Hofer, Rob Holleman, Mandi L. Klamerus, R. Sacha Bhatia, Eve A. Kerr'
#' output: 
#'   html_document:
#'     code_folding: hide
#'     
#'---

#' ## Overview
#' In this appendix, we provide counts for all measure components for each of
#' the eight possible combinations of the three measures considered. 
#' These counts are sufficient to reproduce all statistics and figures with the
#' exception of: (1) the demographics in table 1, (2) the specific exclusions
#' listed in table 2, and (3) the population projections in "Joint Measures". 
#' 
#' This file also contains the code used to compute agreement statistics from
#' the counts provided. To view this code, use the `Code` buttons along the 
#' right side of the page or choose "Show All Code" on the upper right.
#' The source code for the html file you are reading is available as an
#'  executable R script, `Appendix2.R`.
#' 
#' ## Tables

#+ setup, include=FALSE
knitr::opts_chunk$set(echo = TRUE)

#+ warning=FALSE
# 79: -------------------------------------------------------------------------
# libraries: ------------------------------------------------------------------
suppressPackageStartupMessages({
  library(tidyverse); library(data.table); library(lubridate)
})

# aggregated data: ------------------------------------------------------------
path = '~/github/USvCA/data/lbp/'

for ( ff in c("idx_tab",  "den_tab",  "num_tab",  "im_tab") ) {
   file = sprintf('%s/%s.csv', path, ff)
   data = fread(file)
   assign(ff, data)
}
rm(data, file)

# map count of TRUE to number of agreements: ----------------------------------
map_k = function(k) {
  if ( k %in% c(0, 3) ) return(3)
  if ( k %in% c(1, 2) ) return(1)
}
mapk = function(k) sapply(k, map_k)

# Agreement: ------------------------------------------------------------------

## Global parameters
N = sum(idx_tab$N)
n = 3
k = 2

## Denominator table

### Kappa
den_tab[, w := mapk(S_ep + C_ep + H_ep)]
Pbar =  with(den_tab, sum(w * N) / {3 * sum(N)} )
p1 = with(den_tab, sum( {S_ep + C_ep + H_ep} * N ) / {sum(N) * 3})
Pe = p1^2 + {1 - p1}^2
kappa_den = {Pbar - Pe} / {1 - Pe}

### Percent Agreement
p = den_tab[, sum(N[{S_ep & C_ep & H_ep} |  {!S_ep & !C_ep & !H_ep}]) / sum(N)]

### Summary statistics
den_stats = list(p = p, kappa = kappa_den, p1 = p1, Pe = Pe, Pbar = Pbar)

#+ excl_tab
mapl = function(x){
  ifelse(x, 'Yes', 'No')
}
excl_cap = "**Table A1.** *Exclusion counts by measure combination.*"

den_tab[order(C_ep, H_ep, S_ep),
        .(Colla = mapl(!C_ep),
          HEDIS = mapl(!H_ep),
          Scwhartz = mapl(!S_ep),
          N = format(N, big.mark = ','),
          `# Agreements` = w
         )] %>% 
  knitr::kable(format = 'html', caption = excl_cap) %>%
  kableExtra::kable_styling("striped", full_width = TRUE) %>%
  kableExtra::add_header_above(c("Excluded by Measure" = 3, " " = 1, " " = 1))


# Imaging: --------------------------------------------------------------------
im_tab[, w := mapk(Schwartz_im + Colla_im + Hedis_im)]
Pbar = with(im_tab, sum(w * N) / {3 * sum(N)})
p1 = with(im_tab, sum( {Schwartz_im + Colla_im + Hedis_im} * N) / {sum(N) * 3})
Pe = p1^2 + {1 - p1}^2
kappa_im = {Pbar - Pe} / {1 - Pe}

p = im_tab[ , sum(N[{Schwartz_im & Colla_im & Hedis_im} |
{!Schwartz_im & !Colla_im & !Hedis_im}]) / sum(N)]
im_stats = list(p = p, kappa = kappa_im, p1 = p1, Pe = Pe, Pbar = Pbar)

#+ im_tab
im_cap = "**Table A2.** *Imaging counts by measure combination.*"

im_tab[order(Colla_im, Hedis_im, Schwartz_im),
        .(Colla = mapl(Colla_im),
          HEDIS = mapl(Hedis_im),
          Scwhartz = mapl(Schwartz_im),
          N = format(N, big.mark = ','),
          `# Agreements` = w
        )] %>% 
  knitr::kable(format = 'html', caption = im_cap) %>%
  kableExtra::kable_styling("striped", full_width = TRUE) %>%
  kableExtra::add_header_above(c("LBP Imaging by Measure" = 3, " "= 1, " "= 1))

# Numerator: ------------------------------------------------------------------
num_tab[, w := mapk(S_im + C_im + H_im)]
Pbar = with(num_tab, sum(w * N) / {3 * sum(N)})
p1 = with(num_tab, sum( {S_im + C_im + H_im} * N) / {sum(N) * 3})
Pe = p1^2 + {1 - p1}^2
kappa_num = {Pbar - Pe} / {1 - Pe}

p = num_tab[, sum(N[{S_im & C_im & H_im} |  {!S_im & !C_im & !H_im}]) / sum(N)]
num_stats = list(p = p,  kappa = kappa_num, p1 = p1, Pe = Pe, Pbar = Pbar)

#+ num_tab
n0 = "**Table A3.** *Numerator counts by measure combination.* "
n1 = "A patient is in the numerator if both recieved imaging and are included "
n2 = "in the denominator, i.e. not excluded."
num_cap = paste0(n0, n1, n2)

num_tab[order(C_im, H_im, S_im),
       .(Colla = mapl(C_im),
         HEDIS = mapl(H_im),
         Scwhartz = mapl(S_im),
         N = format(N, big.mark = ','),
         `# Agreements` = w
       )] %>% 
  knitr::kable(format = 'html', caption = num_cap) %>%
  kableExtra::kable_styling("striped", full_width = TRUE) %>%
  kableExtra::add_header_above(
    c("Low-value LBP Imaging by Measure" = 3, " " = 1, " " = 1)
  )

#' ## Additional Methods
#' 
#' ### Computation of percent agreement
#' 
#' Percent agreement is computed as,
#' 
#' $$
#' P_A = \frac{N_A}{N} \times 100
#' $$
#' 
#' where $N$ is the total number of cases and 
#' $N_A$ is the number of cases for which all three measures agree (all "Yes" 
#' or all "No") that a
#' given definition has, or has not, been met for: an index LBP diagnosis
#' (cohort entry event), an exclusion diagnosis indicating potentially 
#' appropriate LBP imaging (exclusions), or an LBP imaging event (outcome).
#' 
#' 
#' ### Computation of $\kappa$
#' 
#' Fleiss's $\kappa$ is an agreement statistic that reports the relative amount
#' by which the observed agreement between pairs of measures exceeds that 
#' expected if all measures assigned values uniformly at random 
#' according to the aggregrate marginal probabilities. Specifically, if $Y_{nk}$
#' is a binary variable indicating membership for case $n$ $(n = 1, \cdots, N)$
#' in a particular component as defined by measure $k$ $(k = 1, \cdots, K)$,
#'then
#' 
#' $$
#' \kappa = \frac{P_O - P_E}{1 - P_E}.
#' $$
#' 
#' In the definition above, the observed agreement probability, $P_O$, 
#' is computed as,
#' 
#' $$
#' P_O = \frac{1}{N \times \left(K, 2\right)} \sum_{n=1}^N \sum_{k \ne j}
#'  Y_{nk} = Y_{nj}
#' $$
#' 
#' where, $(K, 2)$ is the number of combinations of $K$ measures taken 2 at a 
#' time; for $K = 3$ as here, we have $(3, 2) = 3$. $P_O$ can also be 
#' computed directly from tables A1-A3 by multiplying "$N$" by "# Agreements" 
#' and then dividing by the  maximum possible number of agreements, 
#' 3 $\times$ `r format(N, big.mark=',')` = `r format(3*N, big.mark = ',')`. 
#' 
#' Similarly, the expected agreement, $P_E$, is computed as,
#' 
#' $$
#' P_E = p^2 + (1-p)^2, \quad p = \frac{1}{NK} \sum_{n=1}^N \sum_{k=1}^K Y_{nk}.
#' $$
#' 
#' Table A4 provides these statistics for LBP measure exclusions, LBP measure 
#' imaging events, and LBP measure numerators. 
#' 

#+ kappa_tab
p_cap = "**Table A4.** Components of agreement statistics."
cbind( data.table("Component" = c("Exclusions", "Imaging", "Numerator")),
 rbind(as.data.table(den_stats),
      as.data.table(im_stats),
      as.data.table(num_stats)
 ))[,.(Component, `$P_A$` = p, `$P_O$`=Pbar, `$p$` = p1, 
       `$P_E$` = Pe, `$\\kappa$` = kappa)
  ] %>%
  knitr::kable(format='html', digits = 2, caption = p_cap) %>%
  kableExtra::kable_styling("striped", full_width = TRUE)
  

