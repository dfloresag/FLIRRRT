// Regression model with random slope and intercept.
  #include <TMB.hpp>

  template<class Type>
  Type objective_function<Type>::operator() ()
  {
  DATA_FACTOR(group);         
  DATA_VECTOR(t);             
  DATA_MATRIX(X);             
  DATA_VECTOR(d);             
  DATA_VECTOR(w);             
  PARAMETER_VECTOR(u);        
  PARAMETER_VECTOR(beta);     
  PARAMETER(log_sigma1);      
  PARAMETER(log_sigma0);      
  PARAMETER(log_lambda);      
  
  int nobs=t.size();
  int ngroups=u.size();
  int j;
  Type res(0.0);
  
  Type sigma1(exp(log_sigma1));
  Type sigma0(exp(log_sigma0));  
  Type lambda(exp(log_lambda));
  
  Type sigmasq1(exp(2*log_sigma1));
  Type sigmasq0(exp(2*log_sigma0));  
  
  ADREPORT(sigma1);
  ADREPORT(sigma0);
  ADREPORT(sigmasq1);
  ADREPORT(sigmasq0);
  ADREPORT(lambda);
  
  vector<Type> mu = X*beta;
  vector<Type> log_t  = log(t);
  vector<Type> trans_t  = exp((lambda/sigma0)*log_t);
  
  vector<Type> e = trans_t;
  
  /* Random Effects: intercept~N(0,sigma1) */
  for(int j=0;j<ngroups;j++){
    res-= w[j]*dnorm(u[j], Type(0) , exp(log_sigma1), 1);
  }
  
  /* Observations: T|u ~ Gamma(e,sigma_0, lambda) */
  for(int i=0;i<nobs;i++){
    j=group[i];
    e[i] =(log_t[i]-mu[i]-u[j])/exp(log_sigma0);
    res-= w[j]*(d[i]*(log_lambda-log_sigma0-log_t[i]-lgamma(exp(-2*log_lambda))+exp(-2*log_lambda)*(-2*log_lambda-(exp(log_lambda))*e[i]- exp(-exp(log_lambda)*e[i])))+(1-d[i])*log(1-pgamma(exp(-2*log_lambda - exp(log_lambda)*e[i]), Type(exp(-2*log_lambda)), Type(1))));
  }
  return res;
  }
