// Regression model with random slope and intercept.
  #include <TMB.hpp>
  template<class Type>
  Type objective_function<Type>::operator() ()
  {
  DATA_FACTOR(group);         // grouping factor
  DATA_VECTOR(t);             // response
  DATA_MATRIX(X);             // covariates
  DATA_VECTOR(d);              // censoring indicator
  DATA_VECTOR(w);              // random weights
  PARAMETER_VECTOR(u);        // random intercept for given individual
  PARAMETER_VECTOR(beta);     // 'fixed' effect parameters
  PARAMETER(log_sigma1);       // for the random intercept
  PARAMETER(log_sigma0);      // for the log-normal distribution
  
  int nobs=t.size();
  int ngroups=u.size();
  int j;
  Type res(0.0);
  
  Type sigma1(exp(log_sigma1));
  Type sigma0(exp(log_sigma0));  
  Type sigmasq1(exp(2*log_sigma1));
  Type sigmasq0(exp(2*log_sigma0));  
  
  ADREPORT(sigma1);
  ADREPORT(sigma0);
  ADREPORT(sigmasq1);
  ADREPORT(sigmasq0);
  
  vector<Type> mu = X*beta;
  vector<Type> log_t  = log(t);
  vector<Type> e  = log_t;
  
  /* Random Effects: intercept~N(0,sigma1) */
  for(int j=0;j<ngroups;j++){
  res-= w[j]*dnorm(u[j], Type(0) , exp(log_sigma1), 1);
  }
  
  /* Observations: T|u ~ logNormal(e,sigma1) */
  for(int i=0;i<nobs;i++){
  j=group[i];
  e[i] =(log_t[i]-mu[i]-u[j])/exp(log_sigma0);
  res-= w[j]*(d[i]*(-log_t[i]-log_sigma0 + dnorm(e[i], Type(0), Type(1), 1) - log(pnorm(-e[i], Type(0), Type(1)))) + log(1 - pnorm(e[i],Type(0), Type(1))));
  }
  return res;
  }
