// Synchrony model with trend, partial pooling by species on intercepts and slopes
// from file called synchrony1_notype_MK.stan in gelmanhill/synchrony repo

data {
  int N;                                // # data points
  int J;                                // # species
  vector[N] y;                          // DOY of pheno event
  int species[N];                       // species identity, coded as int
  vector[N] year;                       // year of data point
}

parameters {
  vector[J] a;                          // the intercept for each species
  vector[J] b;                          // the slope for each species
  real<lower=0> sigma_y;                // measurement error, noise, etc.

  // hyperparameters
  real mu_a;                            // mean intercept across species
  real<lower=0> sigma_a;                // variation of intercept among species
  real mu_b;                            // mean slope across species
  real<lower=0> sigma_b;                // variation of slope among species
}

model {
  real ypred[N];
  for (i in 1:N){
    ypred[i] = a[species[i]] + b[species[i]] * year[i];
  }
  y ~ normal(ypred, sigma_y);
  a ~ normal(mu_a, sigma_a);
  b ~ normal(mu_b, sigma_b);
   // This model is missing the rest of the priors (poor form, this is some of Lizzie's early code!)
} 
