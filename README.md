# NISTStatisticalReferenceData

This package provides utilities for working with the datasets and certified values provided by
[NIST's Statistical Reference Datasets (StRD)](https://www.itl.nist.gov/div898/strd/).

Taken directly from the NIST StRD website:

> The purpose of this project is to improve the accuracy of statistical software 
> by providing reference datasets with certified computational results that enable 
> the objective evaluation of statistical software.

## Which statistical analyses can be tested with this package?

NIST StRD provides example datasets and certified statistical results for:

- One-Way ANOVA
- MCMC
- Nonlinear Regression
- Linear Regression
- Univariate Statistics

To list the available datasets, use the `datasets()` function:

```julia
julia> NISTStatisticalReferenceData.datasets()
OrderedCollections.OrderedDict{String, Vector{String}} with 5 entries:
  "anova"      => ["AtmWtAg", "SiRstv", "SmLs01", "SmLs02", "SmLs03", "SmLs04", "SmLs05", "SmLs06", "SmLs07", "SmLs08", "SmLs09"]
  "mcmc"       => ["mcmc01", "mcmc02", "mcmc03", "mcmc04", "mcmc05", "mcmc06"]
  "nonlinear"  => ["Bennett5", "BoxBOD", "Chwirut1", "Chwirut2", "DanWood", "ENSO", "Eckerle4", "Gauss1", "Gauss2", "Gauss3",  …] 
  "regression" => ["Filip", "Longley", "NoInt1", "NoInt2", "Norris", "Pontius", "Wampler1", "Wampler2", "Wampler3", "Wampler4", "Wampler5"]
  "univariate" => ["Lew", "Lottery", "Mavro", "Michelsoved", "NumAcc1", "NumAcc2", "NumAcc3", "NumAcc4", "PiDigitsved"]
```

## Loading data

Use `TestCase(dataset)` to load the dataset, its metadata, and the certified values.

```julia
julia> NISTStatisticalReferenceData.TestCase("Lottery")
Test Case
    LocalFile: /Users/joshday/.julia/dev/NISTStatisticalReferenceData/deps/univariate/Lottery.dat
    URL      : https://www.itl.nist.gov/div898/strd/univ/data/Lottery.dat
    Procedure: Univariate
    Data Description: 
        "Real World"
        1    Response          : y = 3-digit random number
        0    Predictors
        218  Observations
    Model: 
        Lower Level of Difficulty
        2    Parameters        : mu, sigma
        1    Response Variable : y
        0    Predictor Variables
    Data: 
        219×1 DataFrame
    Certified Values:
        UnivariateStats: m=518.95871559633, s=291.699727470969, a=-0.120948622967393, n=218 | exact=false
```

## How this package works 

- All the NIST StRD's `.dat` files are downloaded in this package's `deps/build.jl` script.
- The values of `TestCase(dataset)` are populated from the `.dat` files.
  - For example, here is the `AtmWtAg.dat` file (for ANOVA):

```
NIST/ITL StRD 
Dataset Name:   AtmWtAg   (AtmWtAg.dat)


File Format:    ASCII
                Certified Values   (lines 41 to 47)
                Data               (lines 61 to 108) 


Procedure:      Analysis of Variance


Reference:      Powell, L.J., Murphy, T.J. and Gramlich, J.W. (1982).
                "The Absolute Isotopic Abundance & Atomic Weight
                of a Reference Sample of Silver".
                NBS Journal of Research, 87, pp. 9-19.


Data:           1 Factor
                2 Treatments
                24 Replicates/Cell
                48 Observations
                7 Constant Leading Digits
                Average Level of Difficulty
                Observed Data


Model:          3 Parameters (mu, tau_1, tau_2)
                y_{ij} = mu + tau_i + epsilon_{ij}






Certified Values:

Source of                  Sums of               Mean               
Variation          df      Squares              Squares             F Statistic


Between Instrument  1 3.63834187500000E-09 3.63834187500000E-09 1.59467335677930E+01
Within Instrument  46 1.04951729166667E-08 2.28155932971014E-10

                   Certified R-Squared 2.57426544538321E-01

                   Certified Residual
                   Standard Deviation  1.51048314446410E-05











Data:  Instrument           AgWt
           1            107.8681568
           1            107.8681465
           1            107.8681572
           1            107.8681785
           1            107.8681446
           1            107.8681903
           1            107.8681526
           1            107.8681494
           1            107.8681616
           1            107.8681587
           1            107.8681519
           1            107.8681486
           1            107.8681419
           1            107.8681569
           1            107.8681508
           1            107.8681672
           1            107.8681385
           1            107.8681518
           1            107.8681662
           1            107.8681424
           1            107.8681360
           1            107.8681333
           1            107.8681610
           1            107.8681477
           2            107.8681079
           2            107.8681344
           2            107.8681513
           2            107.8681197
           2            107.8681604
           2            107.8681385
           2            107.8681642
           2            107.8681365
           2            107.8681151
           2            107.8681082
           2            107.8681517
           2            107.8681448
           2            107.8681198
           2            107.8681482
           2            107.8681334
           2            107.8681609
           2            107.8681101
           2            107.8681512
           2            107.8681469
           2            107.8681360
           2            107.8681254
           2            107.8681261
           2            107.8681450
           2            107.8681368
```
