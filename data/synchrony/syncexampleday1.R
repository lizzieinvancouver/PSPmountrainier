## Started 11 Jan 2022 ##
## By Lizzie ##

# Simulate test data (data to test our model) on consumer-resources phenology over time
# Fit the model and check a few diagnostics

set.seed(167)

setwd("/Users/lizzie/Documents/git/projects/misc/miscmisc/bayesianflows/examples/synchrony")

####################
## Build test data ##
####################

# Create the species-level parameters
J <- 50
type <- rep(c(1,2), c(25,25))
level <- c(125, 125)
sigma_level <- c(25, 25)
species_level <- rnorm(J, 0, 1)
trend <- c(-0.1, -0.2)
sigma_trend <- c(0.2, 0.2)
species_trend <- rnorm(J, 0, 1)

# Create the data
year_0 <- 1976
sigma_y <- 5
n_data_per_species <- round(runif(J, 5, 40))
species <- rep(1:J, n_data_per_species)
N <- length(species)
year <- rep(NA, N)

for (j in 1:J){
  year[species==j] <- rev(2009 - 1:(n_data_per_species[j])) - year_0
}

ypred <- length(N)

for (n in 1:N){
  s <- species[n]
  t <- type[s]
  ypred[n] <- level[t] + sigma_level[t]*species_level[s] +
    (trend[t] + sigma_trend[t]*species_trend[s])*year[n] 
}

y <- rnorm(N, ypred, sigma_y)

# Plot the data

pdf("raw1.pdf", height=4, width=6)
colors=c("blue", "red")
par(mar=c(3,3,1,1), mgp=c(1.5,.5,0), tck=-.01)
plot(range(year), range(y), type="n", xlab="Year", ylab="Day of year",
     bty="l", main="Raw data (types 1 and 2 are blue and red)")
for (j in 1:J)
  lines(year[species==j], y[species==j], col=colors[type[j]])
dev.off()

####################
## Model fitting ##
####################

library("rstan")
options(mc.cores = 4) # set to how many cores you want to run (for 4, you need 4 cores on your machine)

# Fit a simple model (intercept only)
fit_simple <- stan("stan/synchrony_interceptonly.stan", data=c("N","y","J","species","year","type"), iter=1000, chains=4)
print(fit_simple)

# Look at the results
library("shinystan")
launch_shinystan(fit_simple)

# Fit a model with a trend line (this model is the same as how we generated the data)
fit1 <- stan("stan/synchrony1_notype.stan", data=c("N","y","J","species","year","type"), iter=1000, chains=4)
print(fit1)
launch_shinystan(fit1)


#################################################
## Some plots to show what mixed modeling does ##
#################################################

n_data_per_species
df <- data.frame(species=species, year=year, y=y)
par(mfrow=c(1,2))

# One species with less data
plot(y~year, data=subset(df, species==34), ylab="Day of year", pch=16)
abline(lm(y~year, data=subset(df, species==34)))

summ <- summary(fit1)$summary
mixed34 <- summ[grep("34", rownames(summ)),] 

abline(a=mixed34[1,1], b=mixed34[2,1], col="dodgerblue")

# One species with more data and a trend
plot(y~year, data=subset(df, species==49), ylab="Day of year", pch=16)
abline(lm(y~year, data=subset(df, species==49)))

summ <- summary(fit1)$summary
mixed49 <- summ[grep("49", rownames(summ)),] 

abline(a=mixed49[1,1], b=mixed49[2,1], col="dodgerblue")
