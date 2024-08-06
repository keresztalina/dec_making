data {
  int<lower=1> nConditions;
  int<lower=1> nTrials;
  array[nConditions, nTrials] int<lower=1,upper=2> choice;     
  array[nConditions, nTrials] real<lower=-4, upper=4> reward; 
}

transformed data {
  vector[2] initV;  // initial values for V
  initV = rep_vector(0.0, 2);
}

parameters {
  // subject-level parameters
  real alpha_sub_raw; 
  real tau_sub_raw;
  real<lower=0> alpha_sd_raw;
  real<lower=0> tau_sd_raw;
  
  // condition-level raw parameters
  vector[nConditions] alpha_raw;
  vector[nConditions] tau_raw;
}

transformed parameters {
  real<lower=0,upper=1> alpha_sub; 
  real<lower=0,upper=10> tau_sub;
  vector<lower=0,upper=1>[nConditions] alpha;
  vector<lower=0,upper=10>[nConditions] tau;
  
  alpha_sub  = Phi_approx(alpha_sub_raw);
  tau_sub = Phi_approx(tau_sub_raw);
  alpha  = Phi_approx(alpha_sub_raw  + alpha_sd_raw * alpha_raw);
  tau = Phi_approx(tau_sub_raw + tau_sd_raw * tau_raw) * 10;
}

model {
  // group-level priors
  alpha_sub_raw  ~ normal(0,1);
  tau_sub_raw ~ normal(0,1);
  alpha_sd_raw  ~ normal(0,0.3);
  tau_sd_raw ~ normal(0,0.3);
  
  // individual-level priors
  alpha_raw ~ normal(0,1);
  tau_raw ~ normal(0,1);
  
  for (s in 1:nConditions) {
    vector[2] v; 
    real pe;    
    v = initV;

    for (t in 1:nTrials) {        
      choice[s,t] ~ categorical_logit( tau[s] * v );
      
      pe = reward[s,t] - v[choice[s,t]]; // prediction error
      v[choice[s,t]] = v[choice[s,t]] + alpha[s] * pe; // value update
    }
  }    
}

generated quantities {
  real alpha_sub_raw_prior;
  real tau_sub_raw_prior;
  real alpha_sd_raw_prior;
  real tau_sd_raw_prior;
  vector[nConditions] alpha_raw_prior;
  vector[nConditions] tau_raw_prior;
  
  real alpha_sub_prior;
  real tau_sub_prior;
  vector[nConditions] alpha_prior;
  vector[nConditions] tau_prior;
  
  array[nConditions, nTrials] int y_pred_prior;
  array[nConditions, nTrials] int y_pred_posterior;
  
  alpha_sub_raw_prior = normal_rng(0,1);
  tau_sub_raw_prior = normal_rng(0,1);
  alpha_sd_raw_prior = normal_rng(0,0.3);
  tau_sd_raw_prior = normal_rng(0,0.3);
  for (i in 1:nConditions) {
    alpha_raw_prior[i] = normal_rng(0,1);
  }
  for (i in 1:nConditions) {
    tau_raw_prior[i] = normal_rng(0,1);
  }

  alpha_sub_prior = Phi_approx(alpha_sub_raw_prior);
  tau_sub_prior = Phi_approx(tau_sub_raw_prior);
  alpha_prior  = Phi_approx(alpha_sub_raw_prior + alpha_sd_raw_prior * alpha_raw_prior);
  tau_prior = Phi_approx(tau_sub_raw_prior + tau_sd_raw_prior * tau_raw_prior) * 10;
  
  y_pred_prior = rep_array(-999,nConditions,nTrials);
  y_pred_posterior = rep_array(-999,nConditions,nTrials);
  
  {for (s in 1:nConditions) {
        vector[2] v_prior; 
        real pe;    
        v_prior = initV;
        
        for (t in 1:nTrials) {
          y_pred_prior[s,t] = categorical_logit_rng( tau_prior[s] * v_prior );
          pe = reward[s,t] - v_prior[choice[s,t]];
          v_prior[choice[s,t]] = v_prior[choice[s,t]] + alpha_prior[s] * pe; 
        }
    }    
  }
  
  {for (s in 1:nConditions) {
        vector[2] v_posterior; 
        real pe;    
        v_posterior = initV;
        
        for (t in 1:nTrials) {
          y_pred_posterior[s,t] = categorical_logit_rng( tau[s] * v_posterior );
          pe = reward[s,t] - v_posterior[choice[s,t]];
          v_posterior[choice[s,t]] = v_posterior[choice[s,t]] + alpha[s] * pe; 
        }
    }    
  }  
}
