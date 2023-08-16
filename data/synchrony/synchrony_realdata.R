## Started 25 February 2022 ##
## By Lizzie ##

## Synchrony code using real data for Bayes class ##
# Makes one predictive check, then a few more
# Show lm fits versus other two models

## Still working on ...
# Showing estimates from rstanarm using Bayesplot (Alina's code)

## housekeeping
rm(list=ls()) 
options(stringsAsFactors = FALSE)

## set working directory if you need to
setwd("/Users/lizzie/Documents/git/projects/misc/miscmisc/bayesianflows/examples/synchrony")

## flags
# You must set to true and RUN the models once for setting this to FALSE to work
runmodels <- FALSE

## libraries
library(rstan)
library(rstanarm)
library(dplyr)
library(shinystan)

# saving one step and writing out semi-cleaned data for class
if(FALSE){
rawlong <- read.csv("input/rawlong2.csv")
source("source/datacleaningmore.R")
}

rawlong.tot2 <- read.csv("output/rawlong.tot2.csv")
rawlong.nodups <- read.csv("output/rawlong.nodups.csv")

# Formatting for R stan (several ways to do this, this is one)
Nreal <- nrow(rawlong.tot2)
yreal <- rawlong.tot2$phenovalue
Nspp <- length(unique(rawlong.tot2$species)) #newid is character !
species <- as.numeric(as.factor(rawlong.tot2$species))
year <- rawlong.tot2$yr1981

if(runmodels){
# See the stan code on this model for notes on what it does
syncmodel <- stan("stan/twolevelrandomslope.stan", data=c("Nreal","Nspp","yreal","species","year"),
                   iter=4000, warmup=3000, chains=4, cores=4)
save(syncmodel, file="output/syncmodel.Rdata")

# See the stan code on this model for notes on what it does
syncmodel2 <- stan("stan/twolevelrandomslopeint.stan", data=c("Nreal","Nspp","yreal","species","year"),
                   iter=4000, warmup=3000, chains=4, cores=4)
save(syncmodel2, file="output/syncmodel2.Rdata")

# Partial pooling (random effects) of species on intercept and slope
syncharm <- stan_lmer(phenovalue~(yr1981|species), data=rawlong.tot2, cores=4)
save(syncharm, file="output/syncharm.Rdata")

# Partial pooling (random effects) of species on intercept only
syncharmint <- stan_lmer(phenovalue~yr1981 + (1|species), data=rawlong.tot2, cores=4)
save(syncharmint, file="output/syncharmint.Rdata")
}

# launch_shinystan(syncharm)

if(!runmodels){
load("output/syncmodel.Rdata")
load("output/syncmodel2.Rdata")
}

if(FALSE){
print(syncmodel, pars = c("mu_b", "sigma_y", "a", "b"))
print(syncmodel2, pars = c("mu_b", "sigma_y", "a", "b"))
}


################################
## Posterior predictive checks ##
################################


# First, plot the real data used in the model
pdf("graphs/realdata_formodel.pdf", height=4, width=6)
par(mar=c(3,3,1,1), mgp=c(1.5,.5,0), tck=-.01)
plot(range(year), range(yreal), type="n", xlab="Year",
     ylab="Day of year", bty="l", main="Raw real data")
for (j in 1:Nspp){
  lines(year[species==j], yreal[species==j])
}
hist(yreal, xlab="Day of year", main="Real data")
dev.off()

# What does a similar plot look like using the model output?
syncmodel2post <- extract(syncmodel2) 
# hist(syncmodel2post$mu_b, xlab="Change per year")

# extract means for now (other ways to extract the mean)
sigma_y <- mean(syncmodel2post$sigma_y) 
sigma_a <- mean(syncmodel2post$sigma_a) 
sigma_b <- mean(syncmodel2post$sigma_b) 
mu_b <- mean(syncmodel2post$mu_b) 
mu_a <- mean(syncmodel2post$mu_a) 

a <- rnorm(Nspp, mean=mu_a, sd=sigma_a)
b <- rnorm(Nspp, mean=mu_b, sd=sigma_b)

N <- Nreal

ypred <- length(N) 
for (n in 1:N){
    s <- species[n]
    ypred[n] <- a[s] + b[s]*year[n]
}
y <- rnorm(N, ypred, sigma_y)

pdf("graphs/onepredictivecheck.pdf", height=4, width=6)
par(mar=c(3,3,1,1), mgp=c(1.5,.5,0), tck=-.01)
plot(range(year), range(y), type="n", xlab="Year", ylab="Day of year",
    bty="l", main="Data from posterior means")
for (j in 1:Nspp)
  lines(year[species==j], y[species==j])
hist(y, xlab="Day of year", main="Data from posterior means")
dev.off()


pdf("graphs/rawvsonepredictivecheck.pdf", height=8, width=6)
par(mfrow=c(2,1))
par(mar=c(3,3,1,1), mgp=c(1.5,.5,0), tck=-.01)
plot(range(year), range(yreal), type="n", xlab="Year",
      ylab="Day of year (empirical data)", bty="l", main="")
for (j in 1:Nspp){
  lines(year[species==j], yreal[species==j])
 }
plot(range(year), range(y), type="n", xlab="Year", ylab="Day of year (simulated from posterior means)",
     bty="l", main="")
for (j in 1:Nspp)
   lines(year[species==j], y[species==j])
dev.off()

# Okay, but that's just one new draw ... PPCs should be done with many draws...
# But then you need to decide on what summary statistics matter because you cannot just look at each plot
# Below I do: SD of y (using the means, I should also consider using other draws of the posterior)

# Create the data using new a and b for each of the species, simshere times
simshere <- 1000
y.sd100 <- matrix(0, ncol=simshere, nrow=Nspp)
for (i in 1:simshere){
    for (n in 1:N){
        s <- species[n]
        ypred[n] <- a[s] + b[s]*year[n] 
    }
  y <- rnorm(N, ypred, sigma_y)
  y.df <- as.data.frame(cbind(y, species))
  y.sd <- aggregate(y.df["y"], y.df["species"], FUN=sd)
  y.sd100[,i] <- y.sd[,2] 
}

# ... and here's the real data, includes studyid -- which we discussed adding to model
# real.sd <- aggregate(rawlong.nodups["phenovalue"], rawlong.nodups[c("studyid", "spp")], FUN=sd)
real.sd <- aggregate(rawlong.tot2["phenovalue"], rawlong.tot2[c("studyid", "species")],
    FUN=sd)

pdf("graphs/retroSDsync.pdf", height=7, width=6)
hist(colMeans(y.sd100), col=rgb(1,0,0,0.5), xlim=c(10,14), 
    main="",
    xlab="Mean(SD of y) from 1000 sim. datasets (pink) versus empirical data (blue)")
abline(v = mean(real.sd$phenovalue), col = "blue", lwd = 2)
dev.off()

# Okay, let's look at other aspects of the model
comppool <- lm(phenovalue~yr1981, data=rawlong.tot2)

# no pooling
uniquespp <- unique(rawlong.tot2$species)
slopefits <- rep(NA< length(uniquespp))
varfits <- rep(NA< length(uniquespp))
intfits <- rep(NA< length(uniquespp))
for(eachsp in 1:length(uniquespp)){
	lmhere <- lm(phenovalue~yr1981, data=subset(rawlong.tot2, species==uniquespp[eachsp]))
	slopefits[eachsp] <- coef(lmhere)[2]
	varfits[eachsp] <- (summary(lmhere)$sigma)**2
	intfits[eachsp] <- coef(lmhere)[1]
}
dr <- data.frame(cbind(uniquespp, slopefits, varfits, intfits))
dr$slopefits <- as.numeric(dr$slopefits)
dr$intfits <- as.numeric(dr$intfits)
dr$varfits <- as.numeric(dr$varfits)

# get 'new' species intercepts and slopes
# this is one way to create fake data from the Stan output to use in the PP check
a <- rnorm(Nspp, mean=mu_a, sd=sigma_a)
b <- rnorm(Nspp, mean=mu_b, sd=sigma_b) 

# compare a few things on this single new dataset
par(mfrow=c(1,2))
hist(b, main="slopes (b) from the stan model with mean from the raw data in blue")
abline(v = mean(dr$slopefits), col = "blue", lwd = 2) # less negative, slopes are generally pooled towards center which makes sense
hist(dr$varfits, main="sigma y (b) from the raw data with sigma_y from the model in blue")
abline(v=sigma_y, col = "blue", lwd = 2) 

par(mfrow=c(1,2))

hist(dr$intfits, breaks=20, main="No pool intercepts", xlab="intercept")
hist(a, breaks=20, main="Partial pool intercepts")


# Random slopes only model:
syncmodelpost <- extract(syncmodel)
sigma_brsmodel <- mean(syncmodelpost$sigma_b) 
mu_brsmodel <- mean(syncmodelpost$mu_b) 

arsmodel <- colMeans(syncmodelpost$a) 
brsmodel <- rnorm(Nspp, mean=mu_brsmodel, sd=sigma_brsmodel)

par(mfrow=c(1,3))
hist(dr$intfits, breaks=20, main="No pool intercepts", xlab="intercept")
hist(a, breaks=20, main="Partial pool intercepts")
hist(arsmodel, breaks=20, main="No pool intercepts (with PP slopes)")

par(mfrow=c(1,3))
hist(dr$slopefits, breaks=20, main="No pool slopes", xlab="change over time")
hist(b, breaks=20, main="Partial pool slopes (and intercepts)")
hist(brsmodel, breaks=20, main="PP slopes (w/ no pool intercepts)")

#####################
## Plot the models ##
#####################

library(viridis)
my.pal <- viridis_pal(option="viridis")(length(unique(rawlong.tot2$species)))

plot(phenovalue~yr1981, data=rawlong.tot2, ylab="day of year (of event)", xlim=c(0,35), ylim=c(0,220), pch=16)
abline(lm(y~year), lwd=2)
abline(syncmodel2post$mu_a, syncmodel2post$mu_b, col="dodgerblue", lwd=2)
abline(mean(arsmodel), syncmodelpost$mu_b, col="firebrick", lwd=2)

par(mfrow=c(1,2))

plot(phenovalue~yr1981, data=rawlong.tot2, main="No pooling", 
     ylab="day of year (of event)", xlab="year adjusted", xlim=c(0,35), ylim=c(0,220), pch=16, type="n")

for(i in c(1:length(unique(rawlong.tot2$species)))){
    subby <- subset(rawlong.tot2, species==unique(rawlong.tot2$species)[i])
    points(phenovalue~yr1981, data=subby, pch=16, col=my.pal[i])
    abline(dr$intfits[i], dr$slopefits[i], col=my.pal[i])
    }

plot(phenovalue~yr1981, data=rawlong.tot2, main="Partial pooling", 
     ylab="day of year (of event)", xlab="year adjusted",  xlim=c(0,35), ylim=c(0,220), pch=16, type="n")

syncmodel2sum <- summary(syncmodel2)$summary
synmodel2as <- syncmodel2sum[grep("a\\[", rownames(syncmodel2sum)), "mean"]
synmodel2bs <- syncmodel2sum[grep("b\\[", rownames(syncmodel2sum)), "mean"]

for(i in c(1:length(unique(rawlong.tot2$species)))){
    subby <- subset(rawlong.tot2, species==unique(rawlong.tot2$species)[i])
    points(phenovalue~yr1981, data=subby, pch=16, col=my.pal[i])
    abline(synmodel2as[i], synmodel2bs[i], col=my.pal[i])
    }








if(FALSE){ ## From local adaptation code
plot(spring_event~lat_prov, data=d, type="n")
points(spring_event~lat_prov, data=subset(d, prov_continent=="Europe"))
points(spring_event~lat_prov, data=subset(d, prov_continent=="North America"), col="dodgerblue")

abline(fit2_latsum["(Intercept)", "mean"], fit2_latsum["lat_prov", "mean"]) # line for Europe
abline((fit2_latsum["(Intercept)", "mean"]+fit2_latsum["prov_continentNorth America", "mean"]),
    (fit2_latsum["lat_prov", "mean"] + fit2_latsum["lat_prov:prov_continentNorth America", "mean"]), col="dodgerblue") # line for N America

# We're initially most interested in these 'across garden and species' effects shown above ... so following...
# https://mc-stan.org/bayesplot/
posterior <- as.matrix(fit2_lat)

mcmc_areas(posterior,
           pars = c("lat_prov", "lat_prov:prov_continentNorth America"),
           prob = 0.8)
}
