
<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- badges: start -->

[![Travis build
status](https://travis-ci.org/softloud/simeta.svg?branch=master)](https://travis-ci.org/softloud/simeta)
<!-- badges: end -->

# `simeta::`

The goal of `simeta::` is to simulate meta-analysis data.

I found I was rewriting the same types of analyses. How to make a
modular set of tools for simulating meta-anlaysis data.

In particular, I’m interested in simulating for different values of

- $k$, number of studies
- $\tau^2$, variation between studies
- $\varepsilon^2$, variation within a study
- numbers of trials, say 10, 100, 1000
- distributions, *and* parameters; e.g., $\exp(\lambda = 1)$ and
  $\exp(\lambda = 2)$.

## work in progress

This package is a work in progress, can’t guarantee anything works as
intended.

## installation

You can install `simeta::` from github with:

``` r
# install.packages("devtools")
devtools::install_github("softloud/simeta")
```

## examples

``` r
# packages
library(simeta)
library(tidyverse)
library(gt)
library(metafor)

# so these results are reproducible
set.seed(39) 
```

## simulate meta-analysis data

Suppose we are interested in comparing how variation between studies and
overall sample size influence the likelihood of significance in
meta-analyses with small to large effects.

### set simulation-level parameters

``` r
# set default parameters, useful to store as an object for visualisation 
# labelling

# set effect ratios of interest
sim_effect_ratio <- c(1, 1.5)
# set desired variance between studies
sim_tau_sq <- c(0, 0.2)
# set minimum sample size per study
sim_min_n <- 5
# set maximum sample size per study
sim_max_n <- 150
```

Use `sim_df` to set up a dataframe of simulation parameters, wherein
every row represents one combination of simulation parameters.

``` r

# see ?sim_df to see what other things can be specified

sim_parameters <- sim_df(
  # choose three default distributions to sample from to keep example small
  dist_df = default_parameters %>% sample_n(3),
  tau_sq = sim_tau_sq,
  effect_ratio = sim_effect_ratio,
  min_n = sim_min_n,
  max_n = sim_max_n
)
```

### Generate samples

Use `sim_samples` to create a dataframe where each row of the simulation
parameter level dataframe is repeated `trials` times, and a new
list-column of meta-analysis samples are generated using the row-level
simulation parameters.

``` r
# Generate simulated meta-analyses from simulation parameters dataframe
# Number of trials represents number of repeated rows per simulation parameter
# set

samples_df <- 
  sim_samples(
  measure = "mean",
  measure_spread = "sd",
  sim_dat = sim_parameters,
  # small for the purposes of example
  trials = 3
)

# take a look at a few rows
samples_df %>% sample_n(5)
#> # A tibble: 5 × 8
#>       k tau_sq_true effect_ratio rdist  parameters   n        sim_id sample  
#>   <dbl>       <dbl>        <dbl> <chr>  <list>       <list>   <chr>  <list>  
#> 1     7         0.2          1   pareto <named list> <tibble> sim 13 <tibble>
#> 2     7         0            1.5 pareto <named list> <tibble> sim 22 <tibble>
#> 3     7         0            1   pareto <named list> <tibble> sim 4  <tibble>
#> 4     3         0            1.5 norm   <named list> <tibble> sim 21 <tibble>
#> 5     3         0.2          1.5 pareto <named list> <tibble> sim 28 <tibble>
```

``` r
# example simulated dataset meta-analysed
samples_df %>% sample_n(1) %>% pluck("sample")
#> [[1]]
#> # A tibble: 3 × 7
#>   study        effect_c effect_spread_c   n_c effect_i effect_spread_i   n_i
#>   <chr>           <dbl>           <dbl> <dbl>    <dbl>           <dbl> <dbl>
#> 1 Arvegil_1989     72.4            23.6    16     63.8            12.9    17
#> 2 Borlas_1991      70.3            14.0    26     71.7            23.6    25
#> 3 Gundor_1999      44.5            11.2    12    108.             21.2    13
```

### Meta-analyse each sample

``` r
# Generate meta-anlyses and extract a parameter of interest, such as p-value.
sim_metafor <-
  samples_df %>%
  # making small for purposes of example (simulations scale fast!)
  sample_n(20) %>% 
  mutate(
    rma = map(sample,
      function(x) {
        metafor::rma(data = x,
          measure = "SMD",
          m1i = effect_c,
          sd1i = effect_spread_c,
          n1i = n_c,
          m2i = effect_i,
          sd2i = effect_spread_i,
          n2i = n_i
            )}

      )
  ) %>%
  # extract pvalues
  mutate(
    p_val = map_dbl(rma, pluck, "pval")
  )

# take a look
sim_metafor %>% mutate(p_val = round(p_val, 2)) %>% select(p_val, everything())
#> # A tibble: 20 × 10
#>    p_val     k tau_sq_true effect_…¹ rdist parameters   n        sim_id sample  
#>    <dbl> <dbl>       <dbl>     <dbl> <chr> <list>       <list>   <chr>  <list>  
#>  1  0.03     3         0         1   lnorm <named list> <tibble> sim 2  <tibble>
#>  2  0.41     3         0.2       1.5 lnorm <named list> <tibble> sim 29 <tibble>
#>  3  0.02     7         0.2       1.5 pare… <named list> <tibble> sim 31 <tibble>
#>  4  0        3         0.2       1.5 pare… <named list> <tibble> sim 28 <tibble>
#>  5  0        3         0         1.5 norm  <named list> <tibble> sim 21 <tibble>
#>  6  0.12     7         0.2       1.5 lnorm <named list> <tibble> sim 32 <tibble>
#>  7  0.18    20         0.2       1   pare… <named list> <tibble> sim 16 <tibble>
#>  8  0.18     3         0.2       1   pare… <named list> <tibble> sim 10 <tibble>
#>  9  0.16     7         0         1.5 pare… <named list> <tibble> sim 22 <tibble>
#> 10  0       20         0.2       1.5 pare… <named list> <tibble> sim 34 <tibble>
#> 11  0        7         0         1.5 lnorm <named list> <tibble> sim 23 <tibble>
#> 12  0        7         0         1.5 norm  <named list> <tibble> sim 24 <tibble>
#> 13  0.08    20         0.2       1.5 pare… <named list> <tibble> sim 34 <tibble>
#> 14  0       20         0.2       1.5 norm  <named list> <tibble> sim 36 <tibble>
#> 15  0.02     3         0.2       1   norm  <named list> <tibble> sim 12 <tibble>
#> 16  0.81     7         0.2       1   lnorm <named list> <tibble> sim 14 <tibble>
#> 17  0.6      7         0         1.5 pare… <named list> <tibble> sim 22 <tibble>
#> 18  0.3      7         0         1   lnorm <named list> <tibble> sim 5  <tibble>
#> 19  0.37    20         0         1   lnorm <named list> <tibble> sim 8  <tibble>
#> 20  0        7         0         1.5 lnorm <named list> <tibble> sim 23 <tibble>
#> # … with 1 more variable: rma <list>, and abbreviated variable name
#> #   ¹​effect_ratio
```

NB: Caching is needed as simulations ramp in scale. The `targets`
package can help.

### Some details

Without specification, the function uses the default parameters dataset
(`?default_parameters`).

``` r
default_parameters %>% gt()
```

<div id="ykftgvtxcc" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>html {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
}

#ykftgvtxcc .gt_table {
  display: table;
  border-collapse: collapse;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}

#ykftgvtxcc .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#ykftgvtxcc .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}

#ykftgvtxcc .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#ykftgvtxcc .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 0;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#ykftgvtxcc .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#ykftgvtxcc .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#ykftgvtxcc .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}

#ykftgvtxcc .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#ykftgvtxcc .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#ykftgvtxcc .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#ykftgvtxcc .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}

#ykftgvtxcc .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}

#ykftgvtxcc .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}

#ykftgvtxcc .gt_from_md > :first-child {
  margin-top: 0;
}

#ykftgvtxcc .gt_from_md > :last-child {
  margin-bottom: 0;
}

#ykftgvtxcc .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#ykftgvtxcc .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}

#ykftgvtxcc .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}

#ykftgvtxcc .gt_row_group_first td {
  border-top-width: 2px;
}

#ykftgvtxcc .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#ykftgvtxcc .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}

#ykftgvtxcc .gt_first_summary_row.thick {
  border-top-width: 2px;
}

#ykftgvtxcc .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#ykftgvtxcc .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#ykftgvtxcc .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#ykftgvtxcc .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#ykftgvtxcc .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#ykftgvtxcc .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#ykftgvtxcc .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-left: 4px;
  padding-right: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#ykftgvtxcc .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#ykftgvtxcc .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#ykftgvtxcc .gt_left {
  text-align: left;
}

#ykftgvtxcc .gt_center {
  text-align: center;
}

#ykftgvtxcc .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#ykftgvtxcc .gt_font_normal {
  font-weight: normal;
}

#ykftgvtxcc .gt_font_bold {
  font-weight: bold;
}

#ykftgvtxcc .gt_font_italic {
  font-style: italic;
}

#ykftgvtxcc .gt_super {
  font-size: 65%;
}

#ykftgvtxcc .gt_footnote_marks {
  font-style: italic;
  font-weight: normal;
  font-size: 75%;
  vertical-align: 0.4em;
}

#ykftgvtxcc .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}

#ykftgvtxcc .gt_indent_1 {
  text-indent: 5px;
}

#ykftgvtxcc .gt_indent_2 {
  text-indent: 10px;
}

#ykftgvtxcc .gt_indent_3 {
  text-indent: 15px;
}

#ykftgvtxcc .gt_indent_4 {
  text-indent: 20px;
}

#ykftgvtxcc .gt_indent_5 {
  text-indent: 25px;
}
</style>
<table class="gt_table">
  
  <thead class="gt_col_headings">
    <tr>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="dist">dist</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="par">par</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="dist" class="gt_row gt_left">pareto</td>
<td headers="par" class="gt_row gt_center">2, 1</td></tr>
    <tr><td headers="dist" class="gt_row gt_left">norm</td>
<td headers="par" class="gt_row gt_center">50, 17</td></tr>
    <tr><td headers="dist" class="gt_row gt_left">lnorm</td>
<td headers="par" class="gt_row gt_center">4, 0.3</td></tr>
    <tr><td headers="dist" class="gt_row gt_left">exp</td>
<td headers="par" class="gt_row gt_center">10</td></tr>
    <tr><td headers="dist" class="gt_row gt_left">pareto</td>
<td headers="par" class="gt_row gt_center">3.57611907634418, 2.74580756155774</td></tr>
    <tr><td headers="dist" class="gt_row gt_left">norm</td>
<td headers="par" class="gt_row gt_center">75.2093830518425, 6.73904117546044</td></tr>
    <tr><td headers="dist" class="gt_row gt_left">lnorm</td>
<td headers="par" class="gt_row gt_center">2.39001823496073, 0.338360257190652</td></tr>
    <tr><td headers="dist" class="gt_row gt_left">exp</td>
<td headers="par" class="gt_row gt_center">4.867169567151</td></tr>
  </tbody>
  
  
</table>
</div>

This dataset also provides a template for how to set up a dataframe
specifying the distributions and parameters of interest for `sim_df`.
The default sampling distributions are designed to provide a mix of
common symmetric and asymmetric families, with both fixed and
randomly-generated parameters.

``` r
sim_dat <-
  # defaults to using default_parameters if we do not specify dist_df argument
  sim_df(
  # different effect sizes
  # what is small, medium large effect
  effect_ratio = sim_effect_ratio,
  # what is small medium large variance
  tau_sq = sim_tau_sq,
  min_n = sim_min_n,
  max_n = sim_max_n
)
```

``` r

# take a look at the top of the dataset
sim_dat %>% head(3) 
#> # A tibble: 3 × 7
#>       k tau_sq_true effect_ratio rdist  parameters       n                sim_id
#>   <dbl>       <dbl>        <dbl> <chr>  <list>           <list>           <chr> 
#> 1     3           0            1 pareto <named list [2]> <tibble [6 × 3]> sim 1 
#> 2     3           0            1 norm   <named list [2]> <tibble [6 × 3]> sim 2 
#> 3     3           0            1 lnorm  <named list [2]> <tibble [6 × 3]> sim 3

# the end of the dataset
sim_dat %>% tail(3) 
#> # A tibble: 3 × 7
#>       k tau_sq_true effect_ratio rdist parameters       n                 sim_id
#>   <dbl>       <dbl>        <dbl> <chr> <list>           <list>            <chr> 
#> 1    20         0.2          1.5 norm  <named list [2]> <tibble [40 × 3]> sim 94
#> 2    20         0.2          1.5 lnorm <named list [2]> <tibble [40 × 3]> sim 95
#> 3    20         0.2          1.5 exp   <named list [1]> <tibble [40 × 3]> sim 96

# take a look at a random handful of rows
sim_dat %>% sample_n(5)
#> # A tibble: 5 × 7
#>       k tau_sq_true effect_ratio rdist  parameters       n                sim_id
#>   <dbl>       <dbl>        <dbl> <chr>  <list>           <list>           <chr> 
#> 1    20         0            1.5 norm   <named list [2]> <tibble>         sim 66
#> 2     3         0            1.5 lnorm  <named list [2]> <tibble [6 × 3]> sim 55
#> 3    20         0.2          1.5 norm   <named list [2]> <tibble>         sim 94
#> 4     7         0            1.5 exp    <named list [1]> <tibble>         sim 64
#> 5    20         0.2          1   pareto <named list [2]> <tibble>         sim 41
```

`sim_df` uses `sim_n` as explained below to create each dataset of
sample sizes.

### simulate paired sample sizes

This is a function I have often wished I’ve had on hand when simulating
meta-analysis data. Thing is, running, say, 1000 simulations, I want to
do this for the *same* sample sizes. So, I need to generate the sample
sizes for each study and for each group (control or intervention).

Given a specific $k$, generate a set of sample sizes.

``` r

# defaults to k = 3
sim_n() %>% gt()
```

<div id="xwbqsxidif" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>html {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
}

#xwbqsxidif .gt_table {
  display: table;
  border-collapse: collapse;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}

#xwbqsxidif .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#xwbqsxidif .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}

#xwbqsxidif .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#xwbqsxidif .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 0;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#xwbqsxidif .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#xwbqsxidif .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#xwbqsxidif .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}

#xwbqsxidif .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#xwbqsxidif .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#xwbqsxidif .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#xwbqsxidif .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}

#xwbqsxidif .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}

#xwbqsxidif .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}

#xwbqsxidif .gt_from_md > :first-child {
  margin-top: 0;
}

#xwbqsxidif .gt_from_md > :last-child {
  margin-bottom: 0;
}

#xwbqsxidif .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#xwbqsxidif .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}

#xwbqsxidif .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}

#xwbqsxidif .gt_row_group_first td {
  border-top-width: 2px;
}

#xwbqsxidif .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#xwbqsxidif .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}

#xwbqsxidif .gt_first_summary_row.thick {
  border-top-width: 2px;
}

#xwbqsxidif .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#xwbqsxidif .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#xwbqsxidif .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#xwbqsxidif .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#xwbqsxidif .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#xwbqsxidif .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#xwbqsxidif .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-left: 4px;
  padding-right: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#xwbqsxidif .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#xwbqsxidif .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#xwbqsxidif .gt_left {
  text-align: left;
}

#xwbqsxidif .gt_center {
  text-align: center;
}

#xwbqsxidif .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#xwbqsxidif .gt_font_normal {
  font-weight: normal;
}

#xwbqsxidif .gt_font_bold {
  font-weight: bold;
}

#xwbqsxidif .gt_font_italic {
  font-style: italic;
}

#xwbqsxidif .gt_super {
  font-size: 65%;
}

#xwbqsxidif .gt_footnote_marks {
  font-style: italic;
  font-weight: normal;
  font-size: 75%;
  vertical-align: 0.4em;
}

#xwbqsxidif .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}

#xwbqsxidif .gt_indent_1 {
  text-indent: 5px;
}

#xwbqsxidif .gt_indent_2 {
  text-indent: 10px;
}

#xwbqsxidif .gt_indent_3 {
  text-indent: 15px;
}

#xwbqsxidif .gt_indent_4 {
  text-indent: 20px;
}

#xwbqsxidif .gt_indent_5 {
  text-indent: 25px;
}
</style>
<table class="gt_table">
  
  <thead class="gt_col_headings">
    <tr>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="study">study</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="group">group</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="n">n</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="study" class="gt_row gt_left">Estelmo_1960</td>
<td headers="group" class="gt_row gt_left">control</td>
<td headers="n" class="gt_row gt_right">89</td></tr>
    <tr><td headers="study" class="gt_row gt_left">Snaga_1953</td>
<td headers="group" class="gt_row gt_left">control</td>
<td headers="n" class="gt_row gt_right">20</td></tr>
    <tr><td headers="study" class="gt_row gt_left">Théoden_1959</td>
<td headers="group" class="gt_row gt_left">control</td>
<td headers="n" class="gt_row gt_right">76</td></tr>
    <tr><td headers="study" class="gt_row gt_left">Estelmo_1960</td>
<td headers="group" class="gt_row gt_left">intervention</td>
<td headers="n" class="gt_row gt_right">91</td></tr>
    <tr><td headers="study" class="gt_row gt_left">Snaga_1953</td>
<td headers="group" class="gt_row gt_left">intervention</td>
<td headers="n" class="gt_row gt_right">20</td></tr>
    <tr><td headers="study" class="gt_row gt_left">Théoden_1959</td>
<td headers="group" class="gt_row gt_left">intervention</td>
<td headers="n" class="gt_row gt_right">77</td></tr>
  </tbody>
  
  
</table>
</div>

sim_n(k = 3) %>% gt()
<div id="lfidvbwccq" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>html {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
}

#lfidvbwccq .gt_table {
  display: table;
  border-collapse: collapse;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}

#lfidvbwccq .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#lfidvbwccq .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}

#lfidvbwccq .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#lfidvbwccq .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 0;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#lfidvbwccq .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#lfidvbwccq .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#lfidvbwccq .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}

#lfidvbwccq .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#lfidvbwccq .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#lfidvbwccq .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#lfidvbwccq .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}

#lfidvbwccq .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}

#lfidvbwccq .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}

#lfidvbwccq .gt_from_md > :first-child {
  margin-top: 0;
}

#lfidvbwccq .gt_from_md > :last-child {
  margin-bottom: 0;
}

#lfidvbwccq .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#lfidvbwccq .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}

#lfidvbwccq .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}

#lfidvbwccq .gt_row_group_first td {
  border-top-width: 2px;
}

#lfidvbwccq .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#lfidvbwccq .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}

#lfidvbwccq .gt_first_summary_row.thick {
  border-top-width: 2px;
}

#lfidvbwccq .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#lfidvbwccq .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#lfidvbwccq .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#lfidvbwccq .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#lfidvbwccq .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#lfidvbwccq .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#lfidvbwccq .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-left: 4px;
  padding-right: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#lfidvbwccq .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#lfidvbwccq .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#lfidvbwccq .gt_left {
  text-align: left;
}

#lfidvbwccq .gt_center {
  text-align: center;
}

#lfidvbwccq .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#lfidvbwccq .gt_font_normal {
  font-weight: normal;
}

#lfidvbwccq .gt_font_bold {
  font-weight: bold;
}

#lfidvbwccq .gt_font_italic {
  font-style: italic;
}

#lfidvbwccq .gt_super {
  font-size: 65%;
}

#lfidvbwccq .gt_footnote_marks {
  font-style: italic;
  font-weight: normal;
  font-size: 75%;
  vertical-align: 0.4em;
}

#lfidvbwccq .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}

#lfidvbwccq .gt_indent_1 {
  text-indent: 5px;
}

#lfidvbwccq .gt_indent_2 {
  text-indent: 10px;
}

#lfidvbwccq .gt_indent_3 {
  text-indent: 15px;
}

#lfidvbwccq .gt_indent_4 {
  text-indent: 20px;
}

#lfidvbwccq .gt_indent_5 {
  text-indent: 25px;
}
</style>
<table class="gt_table">
  
  <thead class="gt_col_headings">
    <tr>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="study">study</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="group">group</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="n">n</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="study" class="gt_row gt_left">Thengel_2012</td>
<td headers="group" class="gt_row gt_left">control</td>
<td headers="n" class="gt_row gt_right">63</td></tr>
    <tr><td headers="study" class="gt_row gt_left">Beleg_1964</td>
<td headers="group" class="gt_row gt_left">control</td>
<td headers="n" class="gt_row gt_right">107</td></tr>
    <tr><td headers="study" class="gt_row gt_left">Annael_1979</td>
<td headers="group" class="gt_row gt_left">control</td>
<td headers="n" class="gt_row gt_right">22</td></tr>
    <tr><td headers="study" class="gt_row gt_left">Thengel_2012</td>
<td headers="group" class="gt_row gt_left">intervention</td>
<td headers="n" class="gt_row gt_right">70</td></tr>
    <tr><td headers="study" class="gt_row gt_left">Beleg_1964</td>
<td headers="group" class="gt_row gt_left">intervention</td>
<td headers="n" class="gt_row gt_right">91</td></tr>
    <tr><td headers="study" class="gt_row gt_left">Annael_1979</td>
<td headers="group" class="gt_row gt_left">intervention</td>
<td headers="n" class="gt_row gt_right">26</td></tr>
  </tbody>
  
  
</table>
</div>

# set k to a different value

sim_n(k = 6) %>% gt()
<div id="inhprwcjps" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>html {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
}

#inhprwcjps .gt_table {
  display: table;
  border-collapse: collapse;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}

#inhprwcjps .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#inhprwcjps .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}

#inhprwcjps .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#inhprwcjps .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 0;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#inhprwcjps .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#inhprwcjps .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#inhprwcjps .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}

#inhprwcjps .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#inhprwcjps .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#inhprwcjps .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#inhprwcjps .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}

#inhprwcjps .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}

#inhprwcjps .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}

#inhprwcjps .gt_from_md > :first-child {
  margin-top: 0;
}

#inhprwcjps .gt_from_md > :last-child {
  margin-bottom: 0;
}

#inhprwcjps .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#inhprwcjps .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}

#inhprwcjps .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}

#inhprwcjps .gt_row_group_first td {
  border-top-width: 2px;
}

#inhprwcjps .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#inhprwcjps .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}

#inhprwcjps .gt_first_summary_row.thick {
  border-top-width: 2px;
}

#inhprwcjps .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#inhprwcjps .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#inhprwcjps .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#inhprwcjps .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#inhprwcjps .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#inhprwcjps .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#inhprwcjps .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-left: 4px;
  padding-right: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#inhprwcjps .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#inhprwcjps .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#inhprwcjps .gt_left {
  text-align: left;
}

#inhprwcjps .gt_center {
  text-align: center;
}

#inhprwcjps .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#inhprwcjps .gt_font_normal {
  font-weight: normal;
}

#inhprwcjps .gt_font_bold {
  font-weight: bold;
}

#inhprwcjps .gt_font_italic {
  font-style: italic;
}

#inhprwcjps .gt_super {
  font-size: 65%;
}

#inhprwcjps .gt_footnote_marks {
  font-style: italic;
  font-weight: normal;
  font-size: 75%;
  vertical-align: 0.4em;
}

#inhprwcjps .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}

#inhprwcjps .gt_indent_1 {
  text-indent: 5px;
}

#inhprwcjps .gt_indent_2 {
  text-indent: 10px;
}

#inhprwcjps .gt_indent_3 {
  text-indent: 15px;
}

#inhprwcjps .gt_indent_4 {
  text-indent: 20px;
}

#inhprwcjps .gt_indent_5 {
  text-indent: 25px;
}
</style>
<table class="gt_table">
  
  <thead class="gt_col_headings">
    <tr>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="study">study</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="group">group</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="n">n</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="study" class="gt_row gt_left">Oropher_2012</td>
<td headers="group" class="gt_row gt_left">control</td>
<td headers="n" class="gt_row gt_right">36</td></tr>
    <tr><td headers="study" class="gt_row gt_left">Fréa_2018</td>
<td headers="group" class="gt_row gt_left">control</td>
<td headers="n" class="gt_row gt_right">80</td></tr>
    <tr><td headers="study" class="gt_row gt_left">Telchar_1972</td>
<td headers="group" class="gt_row gt_left">control</td>
<td headers="n" class="gt_row gt_right">25</td></tr>
    <tr><td headers="study" class="gt_row gt_left">Asgon_1998</td>
<td headers="group" class="gt_row gt_left">control</td>
<td headers="n" class="gt_row gt_right">95</td></tr>
    <tr><td headers="study" class="gt_row gt_left">Vëantur_1955</td>
<td headers="group" class="gt_row gt_left">control</td>
<td headers="n" class="gt_row gt_right">95</td></tr>
    <tr><td headers="study" class="gt_row gt_left">Araval_1950</td>
<td headers="group" class="gt_row gt_left">control</td>
<td headers="n" class="gt_row gt_right">104</td></tr>
    <tr><td headers="study" class="gt_row gt_left">Oropher_2012</td>
<td headers="group" class="gt_row gt_left">intervention</td>
<td headers="n" class="gt_row gt_right">40</td></tr>
    <tr><td headers="study" class="gt_row gt_left">Fréa_2018</td>
<td headers="group" class="gt_row gt_left">intervention</td>
<td headers="n" class="gt_row gt_right">83</td></tr>
    <tr><td headers="study" class="gt_row gt_left">Telchar_1972</td>
<td headers="group" class="gt_row gt_left">intervention</td>
<td headers="n" class="gt_row gt_right">22</td></tr>
    <tr><td headers="study" class="gt_row gt_left">Asgon_1998</td>
<td headers="group" class="gt_row gt_left">intervention</td>
<td headers="n" class="gt_row gt_right">98</td></tr>
    <tr><td headers="study" class="gt_row gt_left">Vëantur_1955</td>
<td headers="group" class="gt_row gt_left">intervention</td>
<td headers="n" class="gt_row gt_right">91</td></tr>
    <tr><td headers="study" class="gt_row gt_left">Araval_1950</td>
<td headers="group" class="gt_row gt_left">intervention</td>
<td headers="n" class="gt_row gt_right">93</td></tr>
  </tbody>
  
  
</table>
</div>
<!-- Suppose we require data that mimics small cohorts, say as small as 3, and as large as 50.  -->

``` r
# control upper and lower bounds
sim_n(min_n = 3, max_n = 50) %>% gt()
```

<div id="wozdvcigiq" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>html {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
}

#wozdvcigiq .gt_table {
  display: table;
  border-collapse: collapse;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}

#wozdvcigiq .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#wozdvcigiq .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}

#wozdvcigiq .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#wozdvcigiq .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 0;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#wozdvcigiq .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#wozdvcigiq .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#wozdvcigiq .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}

#wozdvcigiq .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#wozdvcigiq .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#wozdvcigiq .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#wozdvcigiq .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}

#wozdvcigiq .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}

#wozdvcigiq .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}

#wozdvcigiq .gt_from_md > :first-child {
  margin-top: 0;
}

#wozdvcigiq .gt_from_md > :last-child {
  margin-bottom: 0;
}

#wozdvcigiq .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#wozdvcigiq .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}

#wozdvcigiq .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}

#wozdvcigiq .gt_row_group_first td {
  border-top-width: 2px;
}

#wozdvcigiq .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#wozdvcigiq .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}

#wozdvcigiq .gt_first_summary_row.thick {
  border-top-width: 2px;
}

#wozdvcigiq .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#wozdvcigiq .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#wozdvcigiq .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#wozdvcigiq .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#wozdvcigiq .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#wozdvcigiq .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#wozdvcigiq .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-left: 4px;
  padding-right: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#wozdvcigiq .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#wozdvcigiq .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#wozdvcigiq .gt_left {
  text-align: left;
}

#wozdvcigiq .gt_center {
  text-align: center;
}

#wozdvcigiq .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#wozdvcigiq .gt_font_normal {
  font-weight: normal;
}

#wozdvcigiq .gt_font_bold {
  font-weight: bold;
}

#wozdvcigiq .gt_font_italic {
  font-style: italic;
}

#wozdvcigiq .gt_super {
  font-size: 65%;
}

#wozdvcigiq .gt_footnote_marks {
  font-style: italic;
  font-weight: normal;
  font-size: 75%;
  vertical-align: 0.4em;
}

#wozdvcigiq .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}

#wozdvcigiq .gt_indent_1 {
  text-indent: 5px;
}

#wozdvcigiq .gt_indent_2 {
  text-indent: 10px;
}

#wozdvcigiq .gt_indent_3 {
  text-indent: 15px;
}

#wozdvcigiq .gt_indent_4 {
  text-indent: 20px;
}

#wozdvcigiq .gt_indent_5 {
  text-indent: 25px;
}
</style>
<table class="gt_table">
  
  <thead class="gt_col_headings">
    <tr>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="study">study</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="group">group</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="n">n</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="study" class="gt_row gt_left">Annael_1979</td>
<td headers="group" class="gt_row gt_left">control</td>
<td headers="n" class="gt_row gt_right">3</td></tr>
    <tr><td headers="study" class="gt_row gt_left">Ragnir_2002</td>
<td headers="group" class="gt_row gt_left">control</td>
<td headers="n" class="gt_row gt_right">2</td></tr>
    <tr><td headers="study" class="gt_row gt_left">Lindo_1966</td>
<td headers="group" class="gt_row gt_left">control</td>
<td headers="n" class="gt_row gt_right">16</td></tr>
    <tr><td headers="study" class="gt_row gt_left">Annael_1979</td>
<td headers="group" class="gt_row gt_left">intervention</td>
<td headers="n" class="gt_row gt_right">2</td></tr>
    <tr><td headers="study" class="gt_row gt_left">Ragnir_2002</td>
<td headers="group" class="gt_row gt_left">intervention</td>
<td headers="n" class="gt_row gt_right">3</td></tr>
    <tr><td headers="study" class="gt_row gt_left">Lindo_1966</td>
<td headers="group" class="gt_row gt_left">intervention</td>
<td headers="n" class="gt_row gt_right">17</td></tr>
  </tbody>
  
  
</table>
</div>

We expect cohorts from the same study to have roughly the same size,
proportional to that size. We can control this proportion with the
`prop` argument.

Suppose we wish to mimic data for which the cohorts are almost exactly
the same (say becaues of classes of undergrads being split in half and
accounting for dropouts).

``` r
# small variation between sample sizes of studies
sim_n(k = 2, prop = 0.05, max_n = 50) %>% gt()
```

<div id="jkuxnkvpqe" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>html {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
}

#jkuxnkvpqe .gt_table {
  display: table;
  border-collapse: collapse;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}

#jkuxnkvpqe .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#jkuxnkvpqe .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}

#jkuxnkvpqe .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#jkuxnkvpqe .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 0;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#jkuxnkvpqe .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#jkuxnkvpqe .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#jkuxnkvpqe .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}

#jkuxnkvpqe .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#jkuxnkvpqe .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#jkuxnkvpqe .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#jkuxnkvpqe .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}

#jkuxnkvpqe .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}

#jkuxnkvpqe .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}

#jkuxnkvpqe .gt_from_md > :first-child {
  margin-top: 0;
}

#jkuxnkvpqe .gt_from_md > :last-child {
  margin-bottom: 0;
}

#jkuxnkvpqe .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#jkuxnkvpqe .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}

#jkuxnkvpqe .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}

#jkuxnkvpqe .gt_row_group_first td {
  border-top-width: 2px;
}

#jkuxnkvpqe .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#jkuxnkvpqe .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}

#jkuxnkvpqe .gt_first_summary_row.thick {
  border-top-width: 2px;
}

#jkuxnkvpqe .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#jkuxnkvpqe .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#jkuxnkvpqe .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#jkuxnkvpqe .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#jkuxnkvpqe .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#jkuxnkvpqe .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#jkuxnkvpqe .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-left: 4px;
  padding-right: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#jkuxnkvpqe .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#jkuxnkvpqe .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#jkuxnkvpqe .gt_left {
  text-align: left;
}

#jkuxnkvpqe .gt_center {
  text-align: center;
}

#jkuxnkvpqe .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#jkuxnkvpqe .gt_font_normal {
  font-weight: normal;
}

#jkuxnkvpqe .gt_font_bold {
  font-weight: bold;
}

#jkuxnkvpqe .gt_font_italic {
  font-style: italic;
}

#jkuxnkvpqe .gt_super {
  font-size: 65%;
}

#jkuxnkvpqe .gt_footnote_marks {
  font-style: italic;
  font-weight: normal;
  font-size: 75%;
  vertical-align: 0.4em;
}

#jkuxnkvpqe .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}

#jkuxnkvpqe .gt_indent_1 {
  text-indent: 5px;
}

#jkuxnkvpqe .gt_indent_2 {
  text-indent: 10px;
}

#jkuxnkvpqe .gt_indent_3 {
  text-indent: 15px;
}

#jkuxnkvpqe .gt_indent_4 {
  text-indent: 20px;
}

#jkuxnkvpqe .gt_indent_5 {
  text-indent: 25px;
}
</style>
<table class="gt_table">
  
  <thead class="gt_col_headings">
    <tr>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="study">study</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="group">group</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="n">n</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="study" class="gt_row gt_left">Eilinel_1953</td>
<td headers="group" class="gt_row gt_left">control</td>
<td headers="n" class="gt_row gt_right">33</td></tr>
    <tr><td headers="study" class="gt_row gt_left">Khamûl_2016</td>
<td headers="group" class="gt_row gt_left">control</td>
<td headers="n" class="gt_row gt_right">44</td></tr>
    <tr><td headers="study" class="gt_row gt_left">Eilinel_1953</td>
<td headers="group" class="gt_row gt_left">intervention</td>
<td headers="n" class="gt_row gt_right">2</td></tr>
    <tr><td headers="study" class="gt_row gt_left">Khamûl_2016</td>
<td headers="group" class="gt_row gt_left">intervention</td>
<td headers="n" class="gt_row gt_right">3</td></tr>
  </tbody>
  
  
</table>
</div>

It can be useful, for more human-interpretable purposes, to display the
sample sizes in wide format.

### simulation parameters

Adding a few values of $\tau$, different numbers of studies $k$, and so
forth can ramp up the number of combinations of simulation parameters
very quickly.

I haven’t settled on a *way* of simulating data, and haven’t found heaps
in the way of guidance yet. So, this is all a bit experimental. My
guiding star is packaging what I’d use right now.

What I do always end up with is generating a dataset that summarises
what I would like to iterate over in simulation.

The `sim_df` takes user inputs for distributions, numbers of studies,
between-study error $\tau$, within-study error $\varepsilon$, and the
proportion $\rho$ of sample size we expect the sample sizes to different
within study cohorts.

``` r
# defaults
sim_df() 
#> # A tibble: 216 × 7
#>        k tau_sq_true effect_ratio rdist  parameters       n        sim_id
#>    <dbl>       <dbl>        <dbl> <chr>  <list>           <list>   <chr> 
#>  1     3           0            1 pareto <named list [2]> <tibble> sim 1 
#>  2     3           0            1 norm   <named list [2]> <tibble> sim 2 
#>  3     3           0            1 lnorm  <named list [2]> <tibble> sim 3 
#>  4     3           0            1 exp    <named list [1]> <tibble> sim 4 
#>  5     3           0            1 pareto <named list [2]> <tibble> sim 5 
#>  6     3           0            1 norm   <named list [2]> <tibble> sim 6 
#>  7     3           0            1 lnorm  <named list [2]> <tibble> sim 7 
#>  8     3           0            1 exp    <named list [1]> <tibble> sim 8 
#>  9     7           0            1 pareto <named list [2]> <tibble> sim 9 
#> 10     7           0            1 norm   <named list [2]> <tibble> sim 10
#> # … with 206 more rows

sim_df() %>% str(1)
#> tibble [216 × 7] (S3: tbl_df/tbl/data.frame)

# only consider small values of k
sim_df(k = c(2, 5, 7)) %>% str(1)
#> tibble [216 × 7] (S3: tbl_df/tbl/data.frame)
```

For the list-column of tibbles `n`, the `sim_df` function calls `sim_n`
and generates a set of sample sizes based on the value in the column
`k`.

``` r
demo_k <- sim_df() 

# the variable n is a list-column of tibbles
demo_k %>% pluck("n") %>% head(3)
#> [[1]]
#> # A tibble: 6 × 3
#>   study        group            n
#>   <chr>        <chr>        <dbl>
#> 1 Mandos_2000  control         23
#> 2 Niënor_1955  control         62
#> 3 Yavanna_2015 control         17
#> 4 Mandos_2000  intervention    25
#> 5 Niënor_1955  intervention    70
#> 6 Yavanna_2015 intervention    19
#> 
#> [[2]]
#> # A tibble: 6 × 3
#>   study       group            n
#>   <chr>       <chr>        <dbl>
#> 1 Aravir_1953 control         35
#> 2 Anborn_1982 control         74
#> 3 Elphir_1984 control         17
#> 4 Aravir_1953 intervention    34
#> 5 Anborn_1982 intervention    71
#> 6 Elphir_1984 intervention    17
#> 
#> [[3]]
#> # A tibble: 6 × 3
#>   study        group            n
#>   <chr>        <chr>        <dbl>
#> 1 Aragost_1981 control         67
#> 2 Orcobal_1994 control         88
#> 3 Khîm_1954    control         15
#> 4 Aragost_1981 intervention    64
#> 5 Orcobal_1994 intervention    82
#> 6 Khîm_1954    intervention    16


# compare the number of rows in the dataframe in the n column with the k value
# divide by two because there are two rows for each study,
# one for each group, control and intervention
demo_k %>% pluck("n") %>% map_int(nrow) %>% head(3) / 2
#> [1] 3 3 3
demo_k %>% pluck("k") %>% head(3)
#> [1] 3 3 3
```

## simulating data

Once we have established a set of sample sizes for a given distribution,
with parameters, and so forth, I usually want to generate a sample for
each of those `n`. We need to adjust the value of the sampled data based
on the median ratio, and whether the `n` is from a control or
intervention group.

A random effect is added to account for the between study error $\tau$
and within study error $\varepsilon$.

For meta-analysis data, we work with summmary statistics, so we drop the
sample and return tabulated summary stats.

``` r
sim_stats()  %>% gt()
```

<div id="qednxxyozs" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>html {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
}

#qednxxyozs .gt_table {
  display: table;
  border-collapse: collapse;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}

#qednxxyozs .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#qednxxyozs .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}

#qednxxyozs .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#qednxxyozs .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 0;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#qednxxyozs .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#qednxxyozs .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#qednxxyozs .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}

#qednxxyozs .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#qednxxyozs .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#qednxxyozs .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#qednxxyozs .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}

#qednxxyozs .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}

#qednxxyozs .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}

#qednxxyozs .gt_from_md > :first-child {
  margin-top: 0;
}

#qednxxyozs .gt_from_md > :last-child {
  margin-bottom: 0;
}

#qednxxyozs .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#qednxxyozs .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}

#qednxxyozs .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}

#qednxxyozs .gt_row_group_first td {
  border-top-width: 2px;
}

#qednxxyozs .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#qednxxyozs .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}

#qednxxyozs .gt_first_summary_row.thick {
  border-top-width: 2px;
}

#qednxxyozs .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#qednxxyozs .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#qednxxyozs .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#qednxxyozs .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#qednxxyozs .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#qednxxyozs .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#qednxxyozs .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-left: 4px;
  padding-right: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#qednxxyozs .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#qednxxyozs .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#qednxxyozs .gt_left {
  text-align: left;
}

#qednxxyozs .gt_center {
  text-align: center;
}

#qednxxyozs .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#qednxxyozs .gt_font_normal {
  font-weight: normal;
}

#qednxxyozs .gt_font_bold {
  font-weight: bold;
}

#qednxxyozs .gt_font_italic {
  font-style: italic;
}

#qednxxyozs .gt_super {
  font-size: 65%;
}

#qednxxyozs .gt_footnote_marks {
  font-style: italic;
  font-weight: normal;
  font-size: 75%;
  vertical-align: 0.4em;
}

#qednxxyozs .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}

#qednxxyozs .gt_indent_1 {
  text-indent: 5px;
}

#qednxxyozs .gt_indent_2 {
  text-indent: 10px;
}

#qednxxyozs .gt_indent_3 {
  text-indent: 15px;
}

#qednxxyozs .gt_indent_4 {
  text-indent: 20px;
}

#qednxxyozs .gt_indent_5 {
  text-indent: 25px;
}
</style>
<table class="gt_table">
  
  <thead class="gt_col_headings">
    <tr>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="study">study</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="effect_c">effect_c</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="effect_spread_c">effect_spread_c</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="n_c">n_c</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="effect_i">effect_i</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="effect_spread_i">effect_spread_i</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="n_i">n_i</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="study" class="gt_row gt_left">Bob_2004</td>
<td headers="effect_c" class="gt_row gt_right">58.77079</td>
<td headers="effect_spread_c" class="gt_row gt_right">0.2146638</td>
<td headers="n_c" class="gt_row gt_right">48</td>
<td headers="effect_i" class="gt_row gt_right">51.03713</td>
<td headers="effect_spread_i" class="gt_row gt_right">0.1810027</td>
<td headers="n_i" class="gt_row gt_right">42</td></tr>
    <tr><td headers="study" class="gt_row gt_left">Oromë_1981</td>
<td headers="effect_c" class="gt_row gt_right">49.68544</td>
<td headers="effect_spread_c" class="gt_row gt_right">0.2232972</td>
<td headers="n_c" class="gt_row gt_right">45</td>
<td headers="effect_i" class="gt_row gt_right">60.28628</td>
<td headers="effect_spread_i" class="gt_row gt_right">0.1896956</td>
<td headers="n_i" class="gt_row gt_right">43</td></tr>
    <tr><td headers="study" class="gt_row gt_left">Ufthak_1965</td>
<td headers="effect_c" class="gt_row gt_right">68.67402</td>
<td headers="effect_spread_c" class="gt_row gt_right">0.2019829</td>
<td headers="n_c" class="gt_row gt_right">42</td>
<td headers="effect_i" class="gt_row gt_right">43.72458</td>
<td headers="effect_spread_i" class="gt_row gt_right">0.1893396</td>
<td headers="n_i" class="gt_row gt_right">48</td></tr>
  </tbody>
  
  
</table>
</div>

# Archived PhD work (see [phd-scripts/](TODO%20link%20to%20GITHUB%20archive%20dir))

## trial

In a trial, we’d first want to simulate some data, for a given
distribution, for this we use the `sim_stats` function discussed in the
above section.

With the summary statistics, we then calculate an estimate of the effect
or the variance of the effect.

1.  simulate data
2.  calculate summary statistics
3.  **calculate estimates using summary statistics**
4.  calculate effects using estimates (difference, standardised,
    log-ratio)[^1]
5.  meta-analyse
6.  return simulation results of interest

The first two steps are taken care of by the `sim_stats` function. The
third step will by necessity be bespoke.

But the rest could be automated, assuming there are the same kinds of
results.

| step                | input                                     | output                         |
|---------------------|-------------------------------------------|--------------------------------|
| calculate estimates | summary statistics as produced by `sim_n` | summary stats                  |
| calculate effects   | summary stats                             | `effect` and `effect_se`       |
| meta-analyse        | `effect` and `effect_se`                  | `rma` object                   |
| summary stats       | `rma` object                              | some kind of `broom`ing script |

``` r
metatrial()
```

## summarising simulation results

So, now we can put together some generic summarisations. Things I always
want to do. Like calculate the coverage probability, confidence interval
width, and bias. Most results here are mean values across all trials,
the exceptions being `cp_` variables.

`metasim` calls `metatrial` many times and summarises the results.

``` r
metasim()
```

## simulate over parameters

``` r
(sim <- metasims())
```

## visualise

``` r
sim %>% coverage_plot()
```

[^1]: Ideally this would be configurable but let’s hardcode it for now.
