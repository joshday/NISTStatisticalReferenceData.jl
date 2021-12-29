using Downloads: download

depspath(args...) = joinpath(@__DIR__, args...)

for path in ["anova", "regression", "mcmc", "nonlinear", "univariate"]
    rm(depspath(path), force=true, recursive=true)
    mkpath(depspath(path))
end

anova = ["SiRstv", "SmLs01", "SmLs02", "SmLs03", "AtmWtAg", "SmLs04", "SmLs05", "SmLs06", 
         "SmLs07", "SmLs08", "SmLs09"]

lls = ["Norris", "Pontius", "NoInt1", "NoInt2", "Filip", "Longley", "Wampler1",
       "Wampler2", "Wampler3", "Wampler4", "Wampler5"]

mcmc = ["mcmc01", "mcmc02", "mcmc03", "mcmc04", "mcmc05", "mcmc06"]

nls = ["Misra1a", "Chwirut2", "Chwirut1", "Lanczos3", "Gauss1", "Gauss2", "DanWood", 
        "Misra1b", "Kirby2", "Hahn1", "Nelson", "MGH17", "Lanczos1", "Lanczos2", "Gauss3", 
        "Misra1c", "Misra1d", "Roszman1", "ENSO", "MGH09", "Thurber", "BoxBOD", "Rat42", "MGH10", 
        "Eckerle4", "Rat43", "Bennett5"]

univ = ["PiDigitsved", "Lottery", "Lew", "Mavro", "Michelsoved", "NumAcc1", "NumAcc2", 
        "NumAcc3", "NumAcc4"]



for file in map(x -> x * ".dat", anova)
    download("https://www.itl.nist.gov/div898/strd/anova/$file", depspath("anova", file))
end
for file in map(x -> x * ".dat", lls)
    download("https://www.itl.nist.gov/div898/strd/lls/data/LINKS/DATA/$file", depspath("regression", file))
end
for file in map(x -> x * ".dat", mcmc)
    download("https://www.itl.nist.gov/div898/strd/mcmc/$file", depspath("mcmc", file))
end
for file in map(x -> x * ".dat", nls)
    download("https://www.itl.nist.gov/div898/strd/nls/data/LINKS/DATA/$file", depspath("nonlinear", file))
end
for file in map(x -> x * ".dat", univ) 
    download("https://www.itl.nist.gov/div898/strd/univ/data/$file", depspath("univariate", file))
end
