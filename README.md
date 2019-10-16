Untitled
================

# Background : Steph and Rory’s Results

  - **Endpoint:** Time to filter failure
  - **Treatment:** Type of filter (Heparin (H) vs citrate (C)
  - **Variables:** Two different variables (we can use either of them):
      - `group_ITT` for intention to treat (as randomised)
      - `group_PP` for per protocol (as received/described in protocol)
  - **Covariates:** A bunch of covariates including `age`, `sex`,
    `APACHE` score, `weight` etc.
  - **Random Effect Structure:** *Possible* 2 levels of clustering:
    1.  patient - filter has tobe replaced time to time (may not always
        fail);
    2.  side (left or right kidney). Level 2. is nested within level 1.
  - **Sample size:**
      - patients have a few filters but some have 15-20 and one 62 (\!)
      - size =1 or 2 for site (of course)
  - The censoring scheme is similar to what Daniel simulated as time to
    filter cluster can be censored for each of them (it sometimes is).

Analysis in Brain et al. (2014) was done using a Cox model with 1 random
effect (for `flirrtid = patient`) in `R` i.e. using `coxme()`.

Steph tried to fit various AFT models in Stata using `mestreg` or
`streg` with frailty/shared parameter

Note that `mestreg` can fit up to 2 random effects (normally
distributed) with a bunch of distributions (i.e. log-normal, Weibull,
log-logistic, generalised gamma) for the endpoint.

### Results:

  - `group_ITT` `age` `apache` as covariates

**One random effect**

| **Distribution** | **Log-Likelihood** |
| ---------------- | ------------------ |
| log-logistic     | \-626.6            |
| log-normal       | \-638.24           |
| gen gamma        | \-621.78           |

The last seems to be better

**Two random effects**

  - `group_ITT` `age` `apache` as covariates
  - 2 random effects (Patient ID and site)

Only convergence with log-normal

2 effects better than 1: LL=618.77 vs LL= -636.6

  - also tried to fit a parametric model with a frailty term (gamma or
    inverse gaussian) and shared parameter (patient ID). the problem is
    that the frailty term or random effect is not on the same scale.
  - None of these models (except Weibull’s, may be) gave a good fit
    based on the cox-Snell residuals. I did not pursue this.
  - not always possible to get results with 2 random effects (1 ok
    though)
  - may depend on treatment as well.
  - there is an effect of treatment (as reported in the paper) in the
    `PP` analysis, not in the `ITT` one.
  - Steph tried both but as convergence may work better with one
    treatment than the other depending on the model

### Conclusion:

  - Generalized Gamma may be preferable but not able to fit a model with
    2 random effects (CV issues).
  - May be improved by choosing the starting point
  - Log-normal model with 2 random effects definitely better than 1
    random effect,
  - No tools to check gof.

**New Findings**

May be worth checking more whether the gamma model can be implemented.

I understand that the gamma function may create trouble in TMB. To be
investigated further.

1.  you can fit a log-logistic AF model with 2 random effects
    
      - LL=-626.6 vs LL=-607.5 ==\> 2 random effects better
    
      - Appears to be better than log-normal (although they are not
        nested)
    
    *Indeed, and that’s a problem for us, as it will not fulfill the
    requirements of an AFT*

2.  gen gamma works with a different integration method but results are
    a bit dubious with 2 random effects
    
      - LL=-621.8 with 1 random effect (ok here) vs LL=-601.8 with 2
        random effects
    
      - but lots of “non concave” warnings along the way (dubious?).
    
    *Perhaps because they are not nested?*
    
    One of the variance estimates is extremely small (flirrtid), hem\!

<!-- end list -->

3)  Weibull
    
      - LL=-620.66 vs ??
    
      - Still we may have an example where log-normal is not necessarily
        the best model

# Implementation with `TMB`

We attempted to use the templates created in the previous examples on
this dataset.

## One-Way Random Intercept Model

### Fixed Effects

The Estimates and S.E. obtained with `TMB` **differ when the Log-Normal
distribution is specified**, yet they are **similar when the
Log-Logistic distribution is
assumed**.

  - \(\beta_0\)

<table class="table table-striped table-hover table-condensed" style="margin-left: auto; margin-right: auto;">

<thead>

<tr>

<th style="text-align:left;">

Distributions

</th>

<th style="text-align:left;">

Procedures

</th>

<th style="text-align:right;">

Estimate

</th>

<th style="text-align:right;">

Std.Error

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

Log-Normal

</td>

<td style="text-align:left;">

STATA

</td>

<td style="text-align:right;">

4.675779

</td>

<td style="text-align:right;">

0.8448544

</td>

</tr>

<tr>

<td style="text-align:left;">

Log-Normal

</td>

<td style="text-align:left;">

`TMB`

</td>

<td style="text-align:right;">

3.105139

</td>

<td style="text-align:right;">

0.8271115

</td>

</tr>

<tr>

<td style="text-align:left;">

Log-Logistic

</td>

<td style="text-align:left;">

STATA

</td>

<td style="text-align:right;">

4.053462

</td>

<td style="text-align:right;">

0.7041011

</td>

</tr>

<tr>

<td style="text-align:left;">

Log-Logistic

</td>

<td style="text-align:left;">

`TMB`

</td>

<td style="text-align:right;">

4.039276

</td>

<td style="text-align:right;">

0.7037811

</td>

</tr>

<tr>

<td style="text-align:left;">

Weibull

</td>

<td style="text-align:left;">

`TMB`

</td>

<td style="text-align:right;">

4.179569

</td>

<td style="text-align:right;">

0.4611441

</td>

</tr>

</tbody>

</table>

  - \(\beta_1\)

<table class="table table-striped table-hover table-condensed" style="margin-left: auto; margin-right: auto;">

<thead>

<tr>

<th style="text-align:left;">

Distributions

</th>

<th style="text-align:left;">

Procedures

</th>

<th style="text-align:right;">

Estimate

</th>

<th style="text-align:right;">

Std.Error

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

Log-Normal

</td>

<td style="text-align:left;">

STATA

</td>

<td style="text-align:right;">

0.3332271

</td>

<td style="text-align:right;">

0.3823093

</td>

</tr>

<tr>

<td style="text-align:left;">

Log-Normal

</td>

<td style="text-align:left;">

`TMB`

</td>

<td style="text-align:right;">

0.1944089

</td>

<td style="text-align:right;">

0.3717275

</td>

</tr>

<tr>

<td style="text-align:left;">

Log-Logistic

</td>

<td style="text-align:left;">

STATA

</td>

<td style="text-align:right;">

0.2307253

</td>

<td style="text-align:right;">

0.2929081

</td>

</tr>

<tr>

<td style="text-align:left;">

Log-Logistic

</td>

<td style="text-align:left;">

`TMB`

</td>

<td style="text-align:right;">

0.2821410

</td>

<td style="text-align:right;">

0.2750079

</td>

</tr>

<tr>

<td style="text-align:left;">

Weibull

</td>

<td style="text-align:left;">

`TMB`

</td>

<td style="text-align:right;">

0.3386326

</td>

<td style="text-align:right;">

0.2286361

</td>

</tr>

</tbody>

</table>

  - \(\beta_2\)

<table class="table table-striped table-hover table-condensed" style="margin-left: auto; margin-right: auto;">

<thead>

<tr>

<th style="text-align:left;">

Distributions

</th>

<th style="text-align:left;">

Procedures

</th>

<th style="text-align:right;">

Estimate

</th>

<th style="text-align:right;">

Std.Error

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

Log-Normal

</td>

<td style="text-align:left;">

STATA

</td>

<td style="text-align:right;">

\-0.0345802

</td>

<td style="text-align:right;">

0.0157739

</td>

</tr>

<tr>

<td style="text-align:left;">

Log-Normal

</td>

<td style="text-align:left;">

`TMB`

</td>

<td style="text-align:right;">

\-0.0196087

</td>

<td style="text-align:right;">

0.0155103

</td>

</tr>

<tr>

<td style="text-align:left;">

Log-Logistic

</td>

<td style="text-align:left;">

STATA

</td>

<td style="text-align:right;">

\-0.0299774

</td>

<td style="text-align:right;">

0.0124366

</td>

</tr>

<tr>

<td style="text-align:left;">

Log-Logistic

</td>

<td style="text-align:left;">

`TMB`

</td>

<td style="text-align:right;">

\-0.0282645

</td>

<td style="text-align:right;">

0.0123644

</td>

</tr>

<tr>

<td style="text-align:left;">

Weibull

</td>

<td style="text-align:left;">

`TMB`

</td>

<td style="text-align:right;">

\-0.0245850

</td>

<td style="text-align:right;">

0.0088264

</td>

</tr>

</tbody>

</table>

  - \(\beta_3\)

<table class="table table-striped table-hover table-condensed" style="margin-left: auto; margin-right: auto;">

<thead>

<tr>

<th style="text-align:left;">

Distributions

</th>

<th style="text-align:left;">

Procedures

</th>

<th style="text-align:right;">

Estimate

</th>

<th style="text-align:right;">

Std.Error

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

Log-Normal

</td>

<td style="text-align:left;">

STATA

</td>

<td style="text-align:right;">

0.0105224

</td>

<td style="text-align:right;">

0.0055684

</td>

</tr>

<tr>

<td style="text-align:left;">

Log-Normal

</td>

<td style="text-align:left;">

`TMB`

</td>

<td style="text-align:right;">

0.0161059

</td>

<td style="text-align:right;">

0.0054747

</td>

</tr>

<tr>

<td style="text-align:left;">

Log-Logistic

</td>

<td style="text-align:left;">

STATA

</td>

<td style="text-align:right;">

0.0119030

</td>

<td style="text-align:right;">

0.0043183

</td>

</tr>

<tr>

<td style="text-align:left;">

Log-Logistic

</td>

<td style="text-align:left;">

`TMB`

</td>

<td style="text-align:right;">

0.0108971

</td>

<td style="text-align:right;">

0.0041369

</td>

</tr>

<tr>

<td style="text-align:left;">

Weibull

</td>

<td style="text-align:left;">

`TMB`

</td>

<td style="text-align:right;">

0.0089088

</td>

<td style="text-align:right;">

0.0034677

</td>

</tr>

</tbody>

</table>

### Variance Components

Values of the Estimates and S.E. are **similar values accross all
combinations of distributions and
procedures**.

  - \(\sigma^2_{\texttt{flirrtid}}\)

<table class="table table-striped table-hover table-condensed" style="margin-left: auto; margin-right: auto;">

<thead>

<tr>

<th style="text-align:left;">

Distributions

</th>

<th style="text-align:left;">

Procedures

</th>

<th style="text-align:right;">

Estimate

</th>

<th style="text-align:right;">

Std.Error

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

Log-Normal

</td>

<td style="text-align:left;">

STATA

</td>

<td style="text-align:right;">

0.3428102

</td>

<td style="text-align:right;">

0.1999956

</td>

</tr>

<tr>

<td style="text-align:left;">

Log-Normal

</td>

<td style="text-align:left;">

`TMB`

</td>

<td style="text-align:right;">

0.3139816

</td>

<td style="text-align:right;">

0.1960649

</td>

</tr>

<tr>

<td style="text-align:left;">

Log-Logistic

</td>

<td style="text-align:left;">

STATA

</td>

<td style="text-align:right;">

0.1654383

</td>

<td style="text-align:right;">

0.0995039

</td>

</tr>

<tr>

<td style="text-align:left;">

Log-Logistic

</td>

<td style="text-align:left;">

`TMB`

</td>

<td style="text-align:right;">

0.1250847

</td>

<td style="text-align:right;">

0.0891511

</td>

</tr>

<tr>

<td style="text-align:left;">

Weibull

</td>

<td style="text-align:left;">

`TMB`

</td>

<td style="text-align:right;">

0.2558837

</td>

<td style="text-align:right;">

0.0842125

</td>

</tr>

</tbody>

</table>

  - \(\log \sigma_0\)

<table class="table table-striped table-hover table-condensed" style="margin-left: auto; margin-right: auto;">

<thead>

<tr>

<th style="text-align:left;">

Distributions

</th>

<th style="text-align:left;">

Procedures

</th>

<th style="text-align:right;">

Estimate

</th>

<th style="text-align:right;">

Std.Error

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

Log-Normal

</td>

<td style="text-align:left;">

STATA

</td>

<td style="text-align:right;">

0.1892424

</td>

<td style="text-align:right;">

0.0673822

</td>

</tr>

<tr>

<td style="text-align:left;">

Log-Normal

</td>

<td style="text-align:left;">

`TMB`

</td>

<td style="text-align:right;">

0.1724522

</td>

<td style="text-align:right;">

0.0710459

</td>

</tr>

<tr>

<td style="text-align:left;">

Log-Logistic

</td>

<td style="text-align:left;">

STATA

</td>

<td style="text-align:right;">

\-0.4798616

</td>

<td style="text-align:right;">

0.0755740

</td>

</tr>

<tr>

<td style="text-align:left;">

Log-Logistic

</td>

<td style="text-align:left;">

`TMB`

</td>

<td style="text-align:right;">

\-0.5030141

</td>

<td style="text-align:right;">

0.0789163

</td>

</tr>

<tr>

<td style="text-align:left;">

Weibull

</td>

<td style="text-align:left;">

`TMB`

</td>

<td style="text-align:right;">

\-1.6614584

</td>

<td style="text-align:right;">

0.0280302

</td>

</tr>

</tbody>

</table>

## Two Way-Nested with Random Intercepts

Following on what Steph found, we have fit a Two-Way Nested Random
intercept. To verify which levels might be nested, we tabulate the
labels for each patient (`flirrtid`) vs. either the `site` or the
`side`. The tabulation of patients vs `site` is as
follows:

<table class="table table-striped table-hover table-condensed" style="margin-left: auto; margin-right: auto;">

<thead>

<tr>

<th style="text-align:right;">

1

</th>

<th style="text-align:right;">

2

</th>

<th style="text-align:right;">

3

</th>

<th style="text-align:right;">

4

</th>

<th style="text-align:right;">

5

</th>

<th style="text-align:right;">

6

</th>

<th style="text-align:right;">

7

</th>

<th style="text-align:right;">

8

</th>

<th style="text-align:right;">

9

</th>

<th style="text-align:right;">

10

</th>

<th style="text-align:right;">

11

</th>

<th style="text-align:right;">

12

</th>

<th style="text-align:right;">

13

</th>

<th style="text-align:right;">

14

</th>

<th style="text-align:right;">

15

</th>

<th style="text-align:right;">

16

</th>

<th style="text-align:right;">

17

</th>

<th style="text-align:right;">

18

</th>

<th style="text-align:right;">

19

</th>

<th style="text-align:right;">

20

</th>

<th style="text-align:right;">

21

</th>

<th style="text-align:right;">

22

</th>

<th style="text-align:right;">

23

</th>

<th style="text-align:right;">

24

</th>

<th style="text-align:right;">

25

</th>

<th style="text-align:right;">

26

</th>

<th style="text-align:right;">

27

</th>

<th style="text-align:right;">

28

</th>

<th style="text-align:right;">

29

</th>

<th style="text-align:right;">

30

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

2

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

2

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

11

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

7

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

14

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

2

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

2

</td>

<td style="text-align:right;">

13

</td>

</tr>

<tr>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

5

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

5

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

3

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

</tr>

<tr>

<td style="text-align:right;">

5

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

2

</td>

<td style="text-align:right;">

6

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

2

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

2

</td>

<td style="text-align:right;">

3

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

7

</td>

<td style="text-align:right;">

9

</td>

<td style="text-align:right;">

4

</td>

<td style="text-align:right;">

12

</td>

<td style="text-align:right;">

3

</td>

<td style="text-align:right;">

7

</td>

<td style="text-align:right;">

2

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

5

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

2

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

3

</td>

<td style="text-align:right;">

3

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

3

</td>

</tr>

<tr>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

3

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

53

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

</tr>

</tbody>

</table>

It transpires from this table that **some of the patients switched sites
a number of times**. For example, patient with label 11 is observed 2
times at site 1 and 3 times at site 3. Similarly, patient 18 is observed
11 times at site 1 and 12 at site 3. As a consequence, **we can’t
consider individuals as nested within sites**.

A more natural nesting structure is provided by the side of the
intubation. A tabulation of the labels informs us of the number of times
the different levels of the potential effects are
taken.

<table class="table table-striped table-hover table-condensed" style="margin-left: auto; margin-right: auto;">

<thead>

<tr>

<th style="text-align:left;">

</th>

<th style="text-align:right;">

1

</th>

<th style="text-align:right;">

2

</th>

<th style="text-align:right;">

3

</th>

<th style="text-align:right;">

4

</th>

<th style="text-align:right;">

5

</th>

<th style="text-align:right;">

6

</th>

<th style="text-align:right;">

7

</th>

<th style="text-align:right;">

8

</th>

<th style="text-align:right;">

9

</th>

<th style="text-align:right;">

10

</th>

<th style="text-align:right;">

11

</th>

<th style="text-align:right;">

12

</th>

<th style="text-align:right;">

13

</th>

<th style="text-align:right;">

14

</th>

<th style="text-align:right;">

15

</th>

<th style="text-align:right;">

16

</th>

<th style="text-align:right;">

17

</th>

<th style="text-align:right;">

18

</th>

<th style="text-align:right;">

19

</th>

<th style="text-align:right;">

20

</th>

<th style="text-align:right;">

21

</th>

<th style="text-align:right;">

22

</th>

<th style="text-align:right;">

23

</th>

<th style="text-align:right;">

24

</th>

<th style="text-align:right;">

25

</th>

<th style="text-align:right;">

26

</th>

<th style="text-align:right;">

27

</th>

<th style="text-align:right;">

28

</th>

<th style="text-align:right;">

29

</th>

<th style="text-align:right;">

30

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

L

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

2

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

5

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

2

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

3

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

5

</td>

<td style="text-align:right;">

7

</td>

<td style="text-align:right;">

3

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

3

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

5

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

7

</td>

</tr>

<tr>

<td style="text-align:left;">

R

</td>

<td style="text-align:right;">

5

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

3

</td>

<td style="text-align:right;">

6

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

2

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

2

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

2

</td>

<td style="text-align:right;">

4

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

4

</td>

<td style="text-align:right;">

62

</td>

<td style="text-align:right;">

4

</td>

<td style="text-align:right;">

11

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

14

</td>

<td style="text-align:right;">

2

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

5

</td>

<td style="text-align:right;">

14

</td>

<td style="text-align:right;">

2

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

3

</td>

<td style="text-align:right;">

3

</td>

<td style="text-align:right;">

9

</td>

</tr>

</tbody>

</table>

We can conclude from this tabulation that **the patient and side per
patient can be considered as nested**, however **the number of times the
couple side/individual is quite variable**, ranging from 1 to 62.

### Fixed Effect Estimates

Estimates and S.E. **look similar accross all combinations of
distributions and
procedures**.

  - \(\beta_0\)

<table class="table table-striped table-hover table-condensed" style="margin-left: auto; margin-right: auto;">

<thead>

<tr>

<th style="text-align:left;">

Distributions

</th>

<th style="text-align:left;">

Procedures

</th>

<th style="text-align:right;">

Estimate

</th>

<th style="text-align:right;">

Std.Error

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

Log-Normal

</td>

<td style="text-align:left;">

STATA

</td>

<td style="text-align:right;">

3.105303

</td>

<td style="text-align:right;">

0.8059647

</td>

</tr>

<tr>

<td style="text-align:left;">

Log-Normal

</td>

<td style="text-align:left;">

`TMB`

</td>

<td style="text-align:right;">

3.138969

</td>

<td style="text-align:right;">

0.8345070

</td>

</tr>

<tr>

<td style="text-align:left;">

Log-Logistic

</td>

<td style="text-align:left;">

STATA

</td>

<td style="text-align:right;">

4.066951

</td>

<td style="text-align:right;">

0.6786827

</td>

</tr>

<tr>

<td style="text-align:left;">

Log-Logistic

</td>

<td style="text-align:left;">

`TMB`

</td>

<td style="text-align:right;">

4.051810

</td>

<td style="text-align:right;">

0.7089018

</td>

</tr>

<tr>

<td style="text-align:left;">

Weibull

</td>

<td style="text-align:left;">

`TMB`

</td>

<td style="text-align:right;">

4.221373

</td>

<td style="text-align:right;">

0.4478470

</td>

</tr>

</tbody>

</table>

  - \(\beta_1\)

<table class="table table-striped table-hover table-condensed" style="margin-left: auto; margin-right: auto;">

<thead>

<tr>

<th style="text-align:left;">

Distributions

</th>

<th style="text-align:left;">

Procedures

</th>

<th style="text-align:right;">

Estimate

</th>

<th style="text-align:right;">

Std.Error

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

Log-Normal

</td>

<td style="text-align:left;">

STATA

</td>

<td style="text-align:right;">

0.2216968

</td>

<td style="text-align:right;">

0.3697748

</td>

</tr>

<tr>

<td style="text-align:left;">

Log-Normal

</td>

<td style="text-align:left;">

`TMB`

</td>

<td style="text-align:right;">

0.2626599

</td>

<td style="text-align:right;">

0.3712585

</td>

</tr>

<tr>

<td style="text-align:left;">

Log-Logistic

</td>

<td style="text-align:left;">

STATA

</td>

<td style="text-align:right;">

0.3552461

</td>

<td style="text-align:right;">

0.2709955

</td>

</tr>

<tr>

<td style="text-align:left;">

Log-Logistic

</td>

<td style="text-align:left;">

`TMB`

</td>

<td style="text-align:right;">

0.3712705

</td>

<td style="text-align:right;">

0.2735237

</td>

</tr>

<tr>

<td style="text-align:left;">

Weibull

</td>

<td style="text-align:left;">

`TMB`

</td>

<td style="text-align:right;">

0.3746148

</td>

<td style="text-align:right;">

0.2019821

</td>

</tr>

</tbody>

</table>

  - \(\beta_2\)

<table class="table table-striped table-hover table-condensed" style="margin-left: auto; margin-right: auto;">

<thead>

<tr>

<th style="text-align:left;">

Distributions

</th>

<th style="text-align:left;">

Procedures

</th>

<th style="text-align:right;">

Estimate

</th>

<th style="text-align:right;">

Std.Error

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

Log-Normal

</td>

<td style="text-align:left;">

STATA

</td>

<td style="text-align:right;">

\-0.0199041

</td>

<td style="text-align:right;">

0.0150271

</td>

</tr>

<tr>

<td style="text-align:left;">

Log-Normal

</td>

<td style="text-align:left;">

`TMB`

</td>

<td style="text-align:right;">

\-0.0206818

</td>

<td style="text-align:right;">

0.0155106

</td>

</tr>

<tr>

<td style="text-align:left;">

Log-Logistic

</td>

<td style="text-align:left;">

STATA

</td>

<td style="text-align:right;">

\-0.0295325

</td>

<td style="text-align:right;">

0.0118025

</td>

</tr>

<tr>

<td style="text-align:left;">

Log-Logistic

</td>

<td style="text-align:left;">

`TMB`

</td>

<td style="text-align:right;">

\-0.0296186

</td>

<td style="text-align:right;">

0.0124333

</td>

</tr>

<tr>

<td style="text-align:left;">

Weibull

</td>

<td style="text-align:left;">

`TMB`

</td>

<td style="text-align:right;">

\-0.0268564

</td>

<td style="text-align:right;">

0.0083165

</td>

</tr>

</tbody>

</table>

  - \(\beta_3\)

<table class="table table-striped table-hover table-condensed" style="margin-left: auto; margin-right: auto;">

<thead>

<tr>

<th style="text-align:left;">

Distributions

</th>

<th style="text-align:left;">

Procedures

</th>

<th style="text-align:right;">

Estimate

</th>

<th style="text-align:right;">

Std.Error

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

Log-Normal

</td>

<td style="text-align:left;">

STATA

</td>

<td style="text-align:right;">

0.0158904

</td>

<td style="text-align:right;">

0.0053860

</td>

</tr>

<tr>

<td style="text-align:left;">

Log-Normal

</td>

<td style="text-align:left;">

`TMB`

</td>

<td style="text-align:right;">

0.0159319

</td>

<td style="text-align:right;">

0.0053880

</td>

</tr>

<tr>

<td style="text-align:left;">

Log-Logistic

</td>

<td style="text-align:left;">

STATA

</td>

<td style="text-align:right;">

0.0107223

</td>

<td style="text-align:right;">

0.0040272

</td>

</tr>

<tr>

<td style="text-align:left;">

Log-Logistic

</td>

<td style="text-align:left;">

`TMB`

</td>

<td style="text-align:right;">

0.0110428

</td>

<td style="text-align:right;">

0.0040623

</td>

</tr>

<tr>

<td style="text-align:left;">

Weibull

</td>

<td style="text-align:left;">

`TMB`

</td>

<td style="text-align:right;">

0.0094559

</td>

<td style="text-align:right;">

0.0030264

</td>

</tr>

</tbody>

</table>

### Variance Components

Estimates and S.E. for \(\sigma^2_{\texttt{flirrtid}}\) and
\(\sigma^2_{\texttt{side}\text{ within }\texttt{flirrtid}}\) **seem very
different accross procedures**. Something very striking is the **very
low estimate and S.E. for \(\sigma^2_{\texttt{flirrtid}}\) under the
log-logistic distribution** (even after controlling for false
convergence and estimation errors).

A closer look makes me suspect that **the sense of the nesting is
somewhat reversed in STATA** (see the similarity betwwen the estimate of
\(\sigma^2_{\texttt{side}\text{ within }\texttt{flirrtid}}\) with `TMB`
and the \(\sigma^2_{\texttt{flirrtid}}\) for STATA under Log-Normal, and
conversely). I **don’t exclude a problem with how the template deals
with the nesting** even if it worked fine with the simulated example. To
address potential issues, please find the expressions I used to create
the likelihood and the template at the end of this document
(INCOMPLETE).

  - \(\sigma^2_{\texttt{flirrtid}}\)

<table class="table table-striped table-hover table-condensed" style="margin-left: auto; margin-right: auto;">

<thead>

<tr>

<th style="text-align:left;">

Distributions

</th>

<th style="text-align:left;">

Procedures

</th>

<th style="text-align:right;">

Estimate

</th>

<th style="text-align:right;">

Std.Error

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

Log-Normal

</td>

<td style="text-align:left;">

STATA

</td>

<td style="text-align:right;">

0.2243724

</td>

<td style="text-align:right;">

0.2496467

</td>

</tr>

<tr>

<td style="text-align:left;">

Log-Normal

</td>

<td style="text-align:left;">

`TMB`

</td>

<td style="text-align:right;">

0.1274766

</td>

<td style="text-align:right;">

0.3088715

</td>

</tr>

<tr>

<td style="text-align:left;">

Log-Logistic

</td>

<td style="text-align:left;">

STATA

</td>

<td style="text-align:right;">

0.0109174

</td>

<td style="text-align:right;">

0.1339572

</td>

</tr>

<tr>

<td style="text-align:left;">

Log-Logistic

</td>

<td style="text-align:left;">

`TMB`

</td>

<td style="text-align:right;">

0.0000000

</td>

<td style="text-align:right;">

0.0001136

</td>

</tr>

<tr>

<td style="text-align:left;">

Weibull

</td>

<td style="text-align:left;">

`TMB`

</td>

<td style="text-align:right;">

0.0000000

</td>

<td style="text-align:right;">

0.0000366

</td>

</tr>

</tbody>

</table>

  - \(\sigma^2_{\texttt{side}\text{ within }\texttt{flirrtid}}\)

<table class="table table-striped table-hover table-condensed" style="margin-left: auto; margin-right: auto;">

<thead>

<tr>

<th style="text-align:left;">

Distributions

</th>

<th style="text-align:left;">

Procedures

</th>

<th style="text-align:right;">

Estimate

</th>

<th style="text-align:right;">

Std.Error

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

Log-Normal

</td>

<td style="text-align:left;">

STATA

</td>

<td style="text-align:right;">

0.1211527

</td>

<td style="text-align:right;">

0.2107059

</td>

</tr>

<tr>

<td style="text-align:left;">

Log-Normal

</td>

<td style="text-align:left;">

`TMB`

</td>

<td style="text-align:right;">

0.2200352

</td>

<td style="text-align:right;">

0.2976401

</td>

</tr>

<tr>

<td style="text-align:left;">

Log-Logistic

</td>

<td style="text-align:left;">

STATA

</td>

<td style="text-align:right;">

0.1537091

</td>

<td style="text-align:right;">

0.1563250

</td>

</tr>

<tr>

<td style="text-align:left;">

Log-Logistic

</td>

<td style="text-align:left;">

`TMB`

</td>

<td style="text-align:right;">

0.1717159

</td>

<td style="text-align:right;">

0.0987778

</td>

</tr>

<tr>

<td style="text-align:left;">

Weibull

</td>

<td style="text-align:left;">

`TMB`

</td>

<td style="text-align:right;">

0.2541542

</td>

<td style="text-align:right;">

0.0733596

</td>

</tr>

</tbody>

</table>

  - \(\log \sigma_0\) shows similar values of estimates and S.E. No
    problem
there.

<table class="table table-striped table-hover table-condensed" style="margin-left: auto; margin-right: auto;">

<thead>

<tr>

<th style="text-align:left;">

Distributions

</th>

<th style="text-align:left;">

Procedures

</th>

<th style="text-align:right;">

Estimate

</th>

<th style="text-align:right;">

Std.Error

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

Log-Normal

</td>

<td style="text-align:left;">

STATA

</td>

<td style="text-align:right;">

0.1441952

</td>

<td style="text-align:right;">

0.0698290

</td>

</tr>

<tr>

<td style="text-align:left;">

Log-Normal

</td>

<td style="text-align:left;">

`TMB`

</td>

<td style="text-align:right;">

0.1606822

</td>

<td style="text-align:right;">

0.0714932

</td>

</tr>

<tr>

<td style="text-align:left;">

Log-Logistic

</td>

<td style="text-align:left;">

STATA

</td>

<td style="text-align:right;">

\-0.5447847

</td>

<td style="text-align:right;">

0.0786791

</td>

</tr>

<tr>

<td style="text-align:left;">

Log-Logistic

</td>

<td style="text-align:left;">

`TMB`

</td>

<td style="text-align:right;">

\-0.5316866

</td>

<td style="text-align:right;">

0.0803637

</td>

</tr>

<tr>

<td style="text-align:left;">

Weibull

</td>

<td style="text-align:left;">

`TMB`

</td>

<td style="text-align:right;">

\-1.7103497

</td>

<td style="text-align:right;">

0.0287613

</td>

</tr>

</tbody>

</table>

<!-- # Expressions for the Nested AFT (Incomplete) -->

<!--  - $i \in \{ 1, \dots I\}$ the "site" -->

<!--  - $j \in \{ 1, \dots J_i\}$ the "individual" in site $i$ -->

<!--  - $k \in \{ 1, \dots K_{ij}\}$ the "time" of observation taken from individual $j$ at site $i$ -->

<!-- $$ -->

<!-- \log T_{i(j(k))} = \mathbf{x}_{i(j(k))}^{T} \mathbf{\beta} + u_i+ u_{i(j)} + \sigma_0 \varepsilon_{i(j(k))}  -->

<!-- $$ -->

<!-- where $u_i \sim \mathcal{N}(0,\sigma_{1}^{2})$ and $u_{i(j)} \sim \mathcal{N}(0,\sigma_{2}^{2})$. For simplicity of notation, in what follows, we shall be eliminating the parentheses.  -->

<!-- By *stacking up* the different vectors of observations according to the different levels of nesting , we can define the following vectors: -->

<!-- \begin{equation} -->

<!-- \underbrace{\left[ -->

<!--   \begin{array}{c} -->

<!--     \log T_{ij1}\\ -->

<!--     \vdots\\ -->

<!--     \log T_{ijK_{ij}} -->

<!--   \end{array} -->

<!-- \right]}_{\log \mathbf{T}_{ij}} -->

<!-- = -->

<!-- \underbrace{\left[ -->

<!--   \begin{array}{c} -->

<!--     \mathbf{x}^{T}_{ij1}\\ -->

<!--     \vdots\\  -->

<!--     \mathbf{x}^{T}_{ijK_{ij}} -->

<!--   \end{array} -->

<!-- \right]}_{\mathbf{X}_{ij}} -->

<!-- \mathbf{\beta}  -->

<!-- +  -->

<!-- u_{i} -->

<!-- \underbrace{\left[ -->

<!--   \begin{array}{c} -->

<!--     1\\ -->

<!--     \vdots\\  -->

<!--     1 -->

<!--   \end{array} -->

<!-- \right] -->

<!-- }_{\mathbf{1}_{K_{ij}}}+ -->

<!-- u_{ij} -->

<!-- \underbrace{\left[ -->

<!--   \begin{array}{c} -->

<!--     1\\ -->

<!--     \vdots\\  -->

<!--     1 -->

<!--   \end{array} -->

<!-- \right]}_{\mathbf{1}_{K_{ij}}} -->

<!-- + -->

<!-- \sigma_0 -->

<!-- \underbrace{\left[ -->

<!--   \begin{array}{c} -->

<!--     \varepsilon_{ij1}\\ -->

<!--     \vdots\\  -->

<!--     \varepsilon_{ijK_{ij}} -->

<!--   \end{array} -->

<!-- \right]}_{\mathbf{\varepsilon}_{ij}} -->

<!-- \end{equation} -->

<!-- \begin{equation} -->

<!-- \left[ -->

<!--   \begin{array}{c} -->

<!--     \log \mathbf{T}_{i1}\\ -->

<!--     \vdots\\ -->

<!--     \log \mathbf{T}_{iJ_{i}} -->

<!--   \end{array} -->

<!-- \right] -->

<!-- = -->

<!-- \left[ -->

<!--   \begin{array}{c} -->

<!--     \mathbf{X}_{i1}\\ -->

<!--     \vdots\\  -->

<!--     \mathbf{X}_{iJ_{i}} -->

<!--   \end{array} -->

<!-- \right] -->

<!-- \mathbf{\beta}  -->

<!-- +  -->

<!-- u_{i} -->

<!-- \left[ -->

<!--   \begin{array}{c} -->

<!--     \mathbf{1}_{K_{i1}}\\ -->

<!--     \vdots\\  -->

<!--     \mathbf{1}_{K_{iJ_{i}}} -->

<!--   \end{array} -->

<!-- \right] -->

<!-- + -->

<!-- \left[ -->

<!--   \begin{array}{c} -->

<!--     u_{i1}\mathbf{1}_{K_{i1}}\\ -->

<!--     \vdots\\  -->

<!--     u_{iJ_{i}} \mathbf{1}_{K_{iJ_{i}}} -->

<!--   \end{array} -->

<!-- \right] -->

<!-- + -->

<!-- \sigma_0 -->

<!-- \left[ -->

<!--   \begin{array}{c} -->

<!--     \mathbf{\varepsilon}_{i1}\\ -->

<!--     \vdots\\  -->

<!--     \mathbf{\varepsilon}_{iJ_{i}} -->

<!--   \end{array} -->

<!-- \right] -->

<!-- \end{equation} -->

<!-- The likelihood for the model parameters $\mathbf{\theta} = [\mathbf{\beta}^T, \sigma_{1}^{2}\sigma_{2}^{2}, \sigma_{0}]$ is given by the marginal density, i.e.:  -->

<!-- \begin{align} -->

<!-- \mathcal{L(\mathbf{\theta})}  -->

<!-- &=  -->

<!-- \int f(T_{111}, \dots, T_{IJ_{I}K_{IJ_{I}}}, u_1, \dots ,u_{I}, u_{11}, \dots, u_{IJ_{I}}) \ d(u_1, \dots ,u_{I}, u_{11}, \dots, u_{IJ_{I}})\\ -->

<!-- &= \int f(T_{111}, \dots, T_{IJ_{I}K_{IJ_{I}}} \ \vert \ u_1, \dots ,u_{I}, u_{11}, \dots, u_{IJ_{I}}) -->

<!--  f(u_1, \dots ,u_{I}, u_{11}, \dots, u_{IJ_{I}}) \ d(u_1, \dots ,u_{I}, u_{11}, \dots, u_{IJ_{I}})\\ -->

<!-- &= -->

<!-- \int f(T_{111}, \dots, T_{IJ_{I}K_{IJ_{I}}}, u_1, \dots ,u_{I}, u_{11}, \dots, u_{IJ_{I}}) \ d(u_1, \dots ,u_{I}, u_{11}, \dots, u_{IJ_{I}})\\ -->

<!-- &=  -->

<!-- \int f(T_{111}, \dots, T_{IJ_{I}K_{IJ_{I}}} \ \vert \ u_1, \dots ,u_{I}, u_{11}, \dots, u_{IJ_{I}}) -->

<!--  f(u_1, \dots ,u_{I})f(u_{11}, \dots, u_{IJ_{I}}) \ d(u_1, \dots ,u_{I}, u_{11}, \dots, u_{IJ_{I}}) \\ -->

<!-- &= -->

<!-- \int -->

<!-- \left \{\prod_{i=1}^{I}\prod_{j=1}^{J_i} \prod_{k=1}^{K_{ij}} f(T_{ijk}\ \vert \  u_i, u_{i1}, \dots, u_{iJ_{i}})\right\} -->

<!-- \prod_{i=1}^{I} f(u_i) \prod_{j=1}^{J_i}f(u_{ij}) \ d(u_1, \dots ,u_{I}, u_{11}, \dots, u_{IJ_{I}})\\ -->

<!-- &=  -->

<!-- \int \exp\left\{\sum_{i=1}^{I}\sum_{j=1}^{J_i} \sum_{k=1}^{K_{ij}} \log f(T_{ijk}\ \vert \  u_i, u_{i1}, \dots, u_{iJ_{i}}) + \sum_{i=1}^{I} \log  f(u_i) + \sum_{j=1}^{J_i} \log f(u_{ij}) \right\} d(u_1, \dots ,u_{I}, u_{11}, \dots, u_{IJ_{I}}) -->

<!-- \end{align} -->

<!-- Final expression is approximated via Laplace. -->
