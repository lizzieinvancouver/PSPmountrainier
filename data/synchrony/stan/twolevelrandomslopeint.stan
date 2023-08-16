// Two-level (1 hierarchical grouping) random slope model
// Partial pooling on intercepts and slopes 

data{
int<lower=0> N; 	//Level 1: Number of observations
int<lower=0> Nspp; 	//Level 2: Number of species (grouping factor)
int species[N]; 	//species identity, coded as int
//predictors
vector[N] year; 	//year of data point
//response
real y[N]; 		//DOY of pheno event 
}

parameters{
real mu_a;		//mean intercept across species (population)
real<lower=0> sigma_a;	//variation of intercept across species	
real mu_b;		//mean slope across species (population)
real<lower=0> sigma_b;	//variation of slope across species
real<lower=0> sigma_y; 	//measurement error, noise etc. (population standard deviation)
	
real a[Nspp]; 		//the intercept for each species
real b[Nspp]; 		//the slope for each species 

}

transformed parameters{
real ypred[N];
for (i in 1:N){
    ypred[i]=a[species[i]]+b[species[i]]*year[i];
}
	
}

model{	
b~normal(mu_b, sigma_b); // this creates the partial pooling on slopes
a~normal(mu_a, sigma_a); // this creates the partial pooling on intercepts

y~normal(ypred, sigma_y);
// Priors ...
mu_a~normal(100,30);
sigma_a~normal(0,20);
mu_b~normal(0,5);
sigma_b~normal(0,15);
sigma_y~normal(0,15);


}	
