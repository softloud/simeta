
<!-- README.md is generated from README.Rmd. Please edit that file -->

[![Travis build
status](https://travis-ci.org/softloud/metasim.svg?branch=master)](https://travis-ci.org/softloud/metasim)

[![Coverage
status](https://codecov.io/gh/softloud/metasim/branch/master/graph/badge.svg)](https://codecov.io/github/softloud/metasim?branch=master)

# metasim

The goal of metasim is to simulate meta-analysis data.

I found I was rewriting the same types of analyses. I got to thinking
how to make a modular set of tools for simulating meta-anlaysis data.

In particular, I’m interested in simulating for different values of

  - \(k\), number of studies
  - \(\tau^2\), variation between studies
  - \(\varepsilon^2\), variation within a study
  - numbers of trials, say 10, 100, 1000
  - distributions, *and* parameters; e.g., \(\exp(\lambda = 1)\) and
    \(\exp(\lambda = 2)\).

## work in progress

This package is a work in progress, can’t guarantee anything works as
intended.

## installation

You can install metasim from github with:

``` r
# install.packages("devtools")
devtools::install_github("softloud/metasim")
```

## examples

### simulate paired sample sizes

``` r
# packages
library(metasim)
library(tidyverse)

# so these results are reproducible
set.seed(38) 

# I like to set.seed with my age. It makes me feel smug that I'm a middle-aged woman who codes. 
```

This is a function I have often wished I’ve had on hand when simulating
meta-analysis data. Thing is, running, say, 1000 simulations, I want to
do this for the *same* sample sizes. So, I need to generate the sample
sizes for each study and for each group (control or intervention).

Given a specific \(k\), generate a set of sample sizes.

``` r

# defaults to k = 3
sim_n() %>% knitr::kable()
```

| study    | group        |  n |
| :------- | :----------- | -: |
| study\_1 | control      | 59 |
| study\_2 | control      | 32 |
| study\_3 | control      | 44 |
| study\_1 | intervention | 57 |
| study\_2 | intervention | 36 |
| study\_3 | intervention | 44 |

``` r

sim_n(k = 3) %>% knitr::kable()
```

| study    | group        |  n |
| :------- | :----------- | -: |
| study\_1 | control      | 15 |
| study\_2 | control      | 93 |
| study\_3 | control      | 16 |
| study\_1 | intervention | 15 |
| study\_2 | intervention | 94 |
| study\_3 | intervention | 18 |

``` r

# set k to a different value

sim_n(k = 6) %>% knitr::kable()
```

| study    | group        |  n |
| :------- | :----------- | -: |
| study\_1 | control      | 47 |
| study\_2 | control      | 17 |
| study\_3 | control      | 40 |
| study\_4 | control      | 24 |
| study\_5 | control      | 26 |
| study\_6 | control      | 94 |
| study\_1 | intervention | 50 |
| study\_2 | intervention | 15 |
| study\_3 | intervention | 36 |
| study\_4 | intervention | 19 |
| study\_5 | intervention | 34 |
| study\_6 | intervention | 96 |

Suppose we require data that mimics small cohorts, say as small as 3,
and as large as 50.

``` r
# control upper and lower bounds
sim_n(min_n = 3, max_n = 50) %>% knitr::kable()
```

| study    | group        |  n |
| :------- | :----------- | -: |
| study\_1 | control      | 15 |
| study\_2 | control      | 22 |
| study\_3 | control      | 14 |
| study\_1 | intervention | 16 |
| study\_2 | intervention | 23 |
| study\_3 | intervention | 17 |

We expect cohorts from the same study to have roughly the same size,
proportional to that size. We can control this proportion with the
`prop` argument.

Suppose we wish to mimic data for which the cohorts are almost exactly
the same (say becaues of classes of undergrads being split in half and
accounting for dropouts).

``` r
# small variation between sample sizes of studies
sim_n(k = 2, prop = 0.05, max_n = 50) %>% knitr::kable()
```

| study    | group        |  n |
| :------- | :----------- | -: |
| study\_1 | control      | 39 |
| study\_2 | control      | 48 |
| study\_1 | intervention |  6 |
| study\_2 | intervention |  1 |

It can be useful, for more human-interpretable purposes, to display the
sample sizes in wide format.

This is also useful for calculations that convert two measures to one,
say, the standardised mean difference of the control and intervention
groups.

Consider four classrooms of children, who may have one or two away for
illness.

``` r
sim_n(k = 4, prop = 0.05, max_n = 30, wide = TRUE) %>%
  # from here I'm just relabelling the class variable for prettiness
  separate(study, into = c("remove", "class"), sep = "_") %>% 
  select(-remove) %>% 
  mutate(class = letters[as.numeric(class)]) %>% knitr::kable()
```

| class | intervention | control |
| :---- | -----------: | ------: |
| a     |            3 |      26 |
| b     |            1 |      27 |
| c     |            1 |      20 |
| d     |            1 |      21 |

### simulation parameters

Adding a few values of \(\tau\), different numbers of studies \(k\), and
so forth can ramp up the number of combinations of simulation parameters
very quickly.

I haven’t settled on a *way* of simulating data, and haven’t found heaps
in the way of guidance yet. So, this is all a bit experimental. My
guiding star is packaging what I’d use right now.

What I do always end up with is generating a dataset that summarises
what I would like to iterate over in simulation.

The `sim_df` takes user inputs for distributions, numbers of studies,
between-study error \(\tau\), within-study error \(\varepsilon\), and
the proportion \(\rho\) of sample size we expect the sample sizes to
different within study cohorts.

``` r
# defaults
sim_df() 
#> # A tibble: 108 x 8
#>        k tau_sq_true effect_ratio rdist  parameters n     id    true_effect
#>    <dbl>       <dbl>        <dbl> <chr>  <list>     <lis> <chr>       <dbl>
#>  1     3           0            1 norm   <named li… <tib… sim_1       2    
#>  2     3           0            1 exp    <named li… <tib… sim_2       0.347
#>  3     3           0            1 pareto <named li… <tib… sim_3       0.780
#>  4     3           0            1 pareto <named li… <tib… sim_4       0.414
#>  5     3           0            1 pareto <named li… <tib… sim_5       3    
#>  6     3           0            1 lnorm  <named li… <tib… sim_6       2.72 
#>  7     7           0            1 norm   <named li… <tib… sim_7       2    
#>  8     7           0            1 exp    <named li… <tib… sim_8       0.347
#>  9     7           0            1 pareto <named li… <tib… sim_9       0.780
#> 10     7           0            1 pareto <named li… <tib… sim_…       0.414
#> # … with 98 more rows

sim_df() %>% str(1)
#> Classes 'tbl_df', 'tbl' and 'data.frame':    108 obs. of  8 variables:
#>  $ k           : num  3 3 3 3 3 3 7 7 7 7 ...
#>  $ tau_sq_true : num  0 0 0 0 0 0 0 0 0 0 ...
#>  $ effect_ratio: num  1 1 1 1 1 1 1 1 1 1 ...
#>  $ rdist       : chr  "norm" "exp" "pareto" "pareto" ...
#>  $ parameters  :List of 108
#>  $ n           :List of 108
#>  $ id          : chr  "sim_1" "sim_2" "sim_3" "sim_4" ...
#>  $ true_effect : num  2 0.347 0.78 0.414 3 ...

# only consider small values of k
sim_df(k = c(2, 5, 7)) %>% str(1)
#> Classes 'tbl_df', 'tbl' and 'data.frame':    108 obs. of  8 variables:
#>  $ k           : num  2 2 2 2 2 2 5 5 5 5 ...
#>  $ tau_sq_true : num  0 0 0 0 0 0 0 0 0 0 ...
#>  $ effect_ratio: num  1 1 1 1 1 1 1 1 1 1 ...
#>  $ rdist       : chr  "norm" "exp" "pareto" "pareto" ...
#>  $ parameters  :List of 108
#>  $ n           :List of 108
#>  $ id          : chr  "sim_1" "sim_2" "sim_3" "sim_4" ...
#>  $ true_effect : num  2 0.347 0.78 0.414 3 ...
```

For the list-column of tibbles `n`, the `sim_df` function calls `sim_n`
and generates a set of sample sizes based on the value in the column
`k`.

``` r
demo_k <- sim_df() 

# the variable n is a list-column of tibbles
demo_k %>% pluck("n") %>% head(3)
#> [[1]]
#> # A tibble: 6 x 3
#>   study   group            n
#>   <chr>   <chr>        <dbl>
#> 1 study_1 control         81
#> 2 study_2 control         30
#> 3 study_3 control         41
#> 4 study_1 intervention    76
#> 5 study_2 intervention    29
#> 6 study_3 intervention    37
#> 
#> [[2]]
#> # A tibble: 6 x 3
#>   study   group            n
#>   <chr>   <chr>        <dbl>
#> 1 study_1 control         77
#> 2 study_2 control         30
#> 3 study_3 control         51
#> 4 study_1 intervention    94
#> 5 study_2 intervention    29
#> 6 study_3 intervention    41
#> 
#> [[3]]
#> # A tibble: 6 x 3
#>   study   group            n
#>   <chr>   <chr>        <dbl>
#> 1 study_1 control         95
#> 2 study_2 control         84
#> 3 study_3 control         87
#> 4 study_1 intervention    81
#> 5 study_2 intervention    85
#> 6 study_3 intervention    79


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

A random effect is added to account for the between study error \(\tau\)
and within study error \(\varepsilon\).

For meta-analysis data, we work with summmary statistics, so we drop the
sample and return tabulated summary stats.

``` r
sim_stats()  %>% knitr::kable()
```

| study    | group        |   effect | effect\_spread |  n |
| :------- | :----------- | -------: | -------------: | -: |
| study\_1 | control      | 66.39775 |      0.2417787 | 64 |
| study\_1 | intervention | 45.18561 |      0.2534450 | 85 |
| study\_2 | control      | 43.86020 |      0.2415023 | 48 |
| study\_2 | intervention | 68.36120 |      0.2254957 | 59 |
| study\_3 | control      | 56.82204 |      0.2305867 | 61 |
| study\_3 | intervention | 52.82040 |      0.3316609 | 71 |

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
    log-ratio)\[1\]
5.  meta-analyse
6.  return simulation results of interest

The first two steps are taken care of by the `sim_stats` function. The
third step will by necessity be bespoke.

But the rest could be automated, assuming there are the same kinds of
results.

| step                | input                                     | output                         |
| ------------------- | ----------------------------------------- | ------------------------------ |
| calculate estimates | summary statistics as produced by `sim_n` | summary stats                  |
| calculate effects   | summary stats                             | `effect` and `effect_se`       |
| meta-analyse        | `effect` and `effect_se`                  | `rma` object                   |
| summary stats       | `rma` object                              | some kind of `broom`ing script |

``` r
metatrial()
#> Joining, by = "study"
#> # A tibble: 2 x 10
#>   measure conf_low conf_high  tau_sq     k effect true_effect coverage
#>   <chr>      <dbl>     <dbl>   <dbl> <int>  <dbl>       <dbl> <lgl>   
#> 1 median      3.29    105.   416.        3 54.0        50     TRUE    
#> 2 lr_med…    -1.79      2.05   0.596     3  0.128       0.182 TRUE    
#> # … with 2 more variables: bias <dbl>, scaled_bias <dbl>
```

## summarising simulation results

So, now we can put together some generic summarisations. Things I always
want to do. Like calculate the coverage probability, confidence interval
width, and bias. Most results here are mean values across all trials,
the exceptions being `cp_` variables.

`metasim` calls `metatrial` many times and summarises the results.

``` r
metasim()
#> # A tibble: 2 x 12
#>   measure tau_sq ci_width   bias coverage_count successful_tria… coverage
#>   <chr>    <dbl>    <dbl>  <dbl>          <int>            <int>    <dbl>
#> 1 lr_med…  0.117     1.46  0.140              3                4     0.75
#> 2 median  97.8      38.6  -1.91               3                4     0.75
#> # … with 5 more variables: id <chr>, errors <int>, warnings <int>,
#> #   messages <int>, result <int>
```

## simulate over parameters

``` r
# metasims is not working yet.
```

1.  Ideally this would be configurable but let’s hardcode it for now.
