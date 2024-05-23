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
  real<lower=0> d0[N_trees]; // Diameter at year of first observation (cm)
  real beta;                 // Linear growth rate (cm / year)
  real<lower=0> sigma;       // Measurement variability (cm)
}

model {
  d0 ~ normal(0, 150 / 2.57);     // 99% prior mass between 0 and 150 cm
  beta ~ normal(0, 2 / 2.32);     // 99% prior mass between +/- 2 cm / year
  sigma ~ normal(0, 0.25 / 2.57); // 99% prior mass between 0 and 0.25 cm 
  
  for (t in 1:N_trees) {
    int start_idx = tree_start_idxs[t];
    int end_idx = tree_end_idxs[t];
    vector[tree_N_obs[t]] years = tree_years[start_idx:end_idx];
    vector[tree_N_obs[t]] dbhs = tree_dbhs[start_idx:end_idx];
    
    dbhs ~ normal(d0[t] + beta * (years - years[1]), sigma);
  }
}

generated quantities {
  real dbh_grid_pred[N_trees, N_year_grid];
  for (t in 1:N_trees) {
    real y0 = tree_years[tree_start_idxs[t]];
    for (n in 1:N_year_grid) {
      real mu = d0[t] + beta * (year_grid[n] - y0);
      dbh_grid_pred[t, n] = normal_rng(mu, sigma);
    }
  }
}
