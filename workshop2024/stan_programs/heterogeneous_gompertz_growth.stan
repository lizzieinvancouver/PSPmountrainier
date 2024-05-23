functions {
  real gompertz(real t, real d_max, real beta, real delta_t_half) {
    return d_max * exp(-log2() * exp( -   (2 / log2()) 
                                        * (beta / d_max) 
                                        * (t - (2000 + delta_t_half))));
  }
}

data {
  int<lower=1> N;
  int<lower=1> N_trees;
  int<lower=1> tree_N_obs[N_trees];
  int<lower=1, upper=N> tree_start_idxs[N_trees];
  int<lower=1, upper=N> tree_end_idxs[N_trees];
  vector[N] tree_years;
  vector[N] tree_dbhs;
  
  int<lower=1> N_year_grid;
  vector[N_year_grid] year_grid;
}

parameters {
  real<lower=0> d0[N_trees];      // Minimum DBH (cm)
  real<lower=0> delta_d[N_trees]; // Difference between minimum and maximum DBH (cm)
  real<lower=0> beta[N_trees];    // Intermediate linear growth rate (cm / year)
  real delta_t_half[N_trees];     // Time to half maximum DBH (years relative to 2000)
  real<lower=0> sigma;            // Measurement variability (cm)
}

model {
  d0 ~ normal(0, 150 / 2.57);          // 99% prior mass between 0 and 50 cm
  delta_d ~ normal(0, 30 / 2.57);      // 99% prior mass between 0 and 30 cm
  beta ~ normal(0, 2 / 2.57);          // 99% prior mass between 0 and 2 cm / year
  delta_t_half ~ normal(0, 50 / 2.32); // 99% prior mass between +/- 50 years
  sigma ~ normal(0, 0.25 / 2.57);      // 99% prior mass between 0 and 0.25 cm 
  
  for (t in 1:N_trees) {
    int start_idx = tree_start_idxs[t];
    int end_idx = tree_end_idxs[t];
    vector[tree_N_obs[t]] years = tree_years[start_idx:end_idx];
    vector[tree_N_obs[t]] dbhs = tree_dbhs[start_idx:end_idx];
    
    for (n in 1:tree_N_obs[t]) {
      real mu =  gompertz(years[n], delta_d[t], beta[t], delta_t_half[t]) 
               + d0[t];
      dbhs[n] ~ normal(mu, sigma);
    }
  }
}

generated quantities {
  real dbh_grid[N_trees, N_year_grid];
  real dbh_grid_pred[N_trees, N_year_grid];
  for (t in 1:N_trees) {
    for (n in 1:N_year_grid) {
      dbh_grid[t, n] = gompertz(year_grid[n], delta_d[t], 
                       beta[t], delta_t_half[t]) + d0[t];
      dbh_grid_pred[t, n] = normal_rng(dbh_grid[t, n], sigma);
    }
  }
}
