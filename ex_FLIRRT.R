rm(list=ls())
setwd("~/Dropbox/[Uni] MONASH/[Codes]/Examples/FLIRRT")

library(TMB)
library(plyr)

compile("aft_ln.cpp")
compile("aft_ll.cpp")
compile("aft_wb.cpp")
compile("aft_gg_pos.cpp")
compile("aft_gg_neg.cpp")

dyn.load(dynlib("aft_ln"))
dyn.load(dynlib("aft_ll"))
dyn.load(dynlib("aft_wb"))
dyn.load(dynlib("aft_gg_pos"))
dyn.load(dynlib("aft_gg_neg"))

flirrt_data <- read.csv("FLIRRT_data_for_analysis.csv", na.strings = "")

dim(flirrt_data)

flirrt_data<-flirrt_data[order(flirrt_data$flirrtid),]
flirrt_data<-na.omit(flirrt_data)

dim(flirrt_data)

flirrt_data$side

head(flirrt_data)

table(flirrt_data$flirrtid)
table(flirrt_data$site)

xtabs(~site+flirrtid, data = flirrt_data)
xtabs(~flirrtid+side, data = flirrt_data)

flirrt_data$flirrtid_fac <- factor(flirrt_data$flirrtid)
flirrt_data$site_fac <- factor(flirrt_data$site)

###########

m <- 1 

time.start <-Sys.time()

err_ml = cnv_ml  = cnv_vc <- 0

est_ml <- FALSE

n_obsr <- nrow(flirrt_data)
n_site <- length(levels(flirrt_data$site_fac))
n_subj <- length(levels(flirrt_data$flirrtid_fac))
n_ssub <- unname(rowSums(1*(table(flirrt_data$flirrtid_fac,flirrt_data$side)>0)))

# n_ssub <- unname(colSums(1*(table(cgd_mod$id, cgd_mod$center_num)>0))) 

t   <- flirrt_data$life
cn  <- flirrt_data$censor

X   <- cbind(rep(1, n_obsr),
             ifelse(flirrt_data$group_ITT=="H", 0, 1),
             flirrt_data$age,
             flirrt_data$apache)

# site <- cgd_mod$center_num
# subj <- as.factor(cgd_mod$id)

site <- flirrt_data$site_fac
subj <- flirrt_data$flirrtid_fac
subj_lab <- unique(subj)

MaxIt <- 1000

bs_ln_stt <- c(4.675779, 0.3332271, -.0345802, 0.0105224)
ss_ln_stt <- c(exp(1/2*log(0.3428102)) , exp(0.1892424))
ls_ln_stt <- c(0.3428102 , 0.1892424)

bs_ll_stt <- c(4.053462, 0.2307253, -.0299774, 0.011903)
ss_ll_stt <- c(exp(1/2*log(0.1654383)) , exp(-.4798616))
ls_ll_stt <- c(0.1654383 , -0.4798616)

se_bs_ln_stt <- c(0.8448544, 0.3823093, 0.0157739, 0.0055684)
se_ss_ln_stt <- c(NA, NA)
se_ls_ln_stt <- c(0.1999956, 0.0673822)

se_bs_ll_stt <- c(0.7041011, 0.2929081, 0.0124366, 0.0043183)
se_ss_ll_stt <- c(NA, NA)
se_ls_ll_stt <- c(0.0995039, 0.075574)

while(!est_ml & m <= MaxIt){
  
  # ML estimation of all parameters ####
  
  dta   <- list(group=subj, 
                X=X,
                w = rep(1, times = n_subj),
                t=t, 
                d=cn)
  
  par     <- list(u          = rep(0, times = n_subj),
                  beta       = c(4.675779, 0.3332271, -.0345802, 0.0105224), 
                  log_sigma1 = 1/2*log(.1314843),
                  log_sigma0 = 0.1892424
                  )
  
  par_gg     <- list(u          = rep(0, times = n_subj),
                  beta       = c(4.675779, 0.3332271, -.0345802, 0.0105224), 
                  log_sigma1 = 1/2*log(.1314843),
                  log_sigma0 = 0.1892424,
                  log_lambda = 0.5
  )

  obj_ln    <- MakeADFun(data=dta,
                         parameters=par,
                         random="u",
                         type = c("ADFun", "ADGrad" , "Fun"),
                         DLL= "aft_ln",
                         silent = TRUE,
                         hessian = FALSE, 
                         method = "CG",
                         inner.control = list(maxit = 10000),
                         control = list(maxit =1000)
  )
  
  obj_ll    <- MakeADFun(data=dta,
                         parameters=par,
                         random="u",
                         type = c("ADFun", "ADGrad" , "Fun"),
                         DLL= "aft_ll",
                         silent = TRUE,
                         hessian = FALSE, 
                         method = "CG",
                         inner.control = list(maxit = 10000),
                         control = list(maxit =1000)
  )
  
  obj_wb    <- MakeADFun(data=dta,
                         parameters=par,
                         random="u",
                         type = c("ADFun", "ADGrad" , "Fun"),
                         DLL= "aft_wb",
                         silent = TRUE,
                         hessian = FALSE, 
                         method = "CG",
                         inner.control = list(maxit = 10000),
                         control = list(maxit =1000)
  )
  
  obj_gg_pos    <- MakeADFun(data=dta,
                         parameters=par_gg,
                         random="u",
                         type = c("ADFun", "ADGrad" , "Fun"),
                         DLL= "aft_gg_pos",
                         silent = TRUE,
                         hessian = FALSE, 
                         method = "CG",
                         inner.control = list(maxit = 10000),
                         control = list(eval.max = 1000, iter.max =1000)
  )
  
  
  obj_gg_neg    <- MakeADFun(data=dta,
                             parameters=par_gg,
                             random="u",
                             type = c("ADFun", "ADGrad" , "Fun"),
                             DLL= "aft_gg_neg",
                             silent = TRUE,
                             hessian = FALSE,
                             method = "CG",
                             inner.control = list(maxit = 10000),
                             control = list(eval.max = 10000, iter.max =10000)
  )
  
  o_ln <- try(
    nlminb(obj_ln$par, obj_ln$fn, obj_ln$gr), silent = TRUE
  )
  
  o_ll <- try(
    nlminb(obj_ll$par, obj_ll$fn, obj_ll$gr), silent = TRUE
  )

  o_wb <- try(
    nlminb(obj_wb$par, obj_wb$fn, obj_wb$gr), silent = TRUE
  )
  
  o_gg_pos <- try(
    nlminb(obj_gg_pos$par, obj_gg_pos$fn, obj_gg_pos$gr, control = obj_gg_pos$control), silent = FALSE
  )
  
  o_gg_neg <- try(
    nlminb(obj_gg_neg$par, obj_gg_neg$fn, obj_gg_neg$gr, control = obj_gg_neg$control), silent = FALSE
  )

  # Error Control #### 
  
  if(inherits(o_ln, "try-error") | inherits(o_ll, "try-error") | inherits(o_wb, "try-error")) {
    
    est_ml <- FALSE
    err_ml <- err_ml+1
    
  } else if (o_ln$convergence==1 | o_ll$convergence==1 | o_wb$convergence==1){
    
    est_ml <- FALSE
    cnv_ml <- cnv_ml+1
    
  } else {
    
    se_bs_ln_tmp <- try((summary(sdreport(obj = obj_ln), 
                                 select = "fixed")), silent = TRUE)
    se_bs_ll_tmp <- try((summary(sdreport(obj = obj_ll), 
                                 select = "fixed")), silent = TRUE)
    se_bs_wb_tmp <- try((summary(sdreport(obj = obj_wb), 
                                 select = "fixed")), silent = TRUE)
    se_bs_gg_pos_tmp <- try((summary(sdreport(obj = obj_gg_pos), 
                                 select = "fixed")), silent = TRUE)
    se_bs_gg_neg_tmp <- try((summary(sdreport(obj = obj_gg_neg),
                                     select = "fixed")), silent = TRUE)
 
    
    se_ss_ln_tmp <- try((summary(sdreport(obj = obj_ln), 
                                 select = "report")), silent = TRUE)
    se_ss_ll_tmp <- try((summary(sdreport(obj = obj_ll), 
                                 select = "report")), silent = TRUE)
    se_ss_wb_tmp <- try((summary(sdreport(obj = obj_wb), 
                                 select = "report")), silent = TRUE)
    se_ss_gg_pos_tmp <- try((summary(sdreport(obj = obj_gg_pos), 
                                 select = "report")), silent = TRUE)
    se_ss_gg_neg_tmp <- try((summary(sdreport(obj = obj_gg_neg), 
                                     select = "report")), silent = TRUE)
    
    if(inherits(se_bs_ln_tmp,"try-error") | inherits(se_bs_ll_tmp,"try-error") | inherits(se_ss_ln_tmp,"try-error") | inherits(se_ss_ll_tmp,"try-error")){
      
      est_ml <- FALSE
      cnv_vc <- cnv_vc+1
      
    } else {
      
      est_ml <- TRUE
      
      bs_ln_tmb    <- unname(se_bs_ln_tmp[1:ncol(X), "Estimate"])
      ss_ln_tmb    <- unname(se_ss_ln_tmp[1:2, "Estimate"])
      ls_ln_tmb    <- unname(c(se_ss_ln_tmp[3, "Estimate"], se_bs_ln_tmp[6, "Estimate"]))
      
      se_bs_ln_tmb <- unname(se_bs_ln_tmp[1:ncol(X), "Std. Error"])
      se_ss_ln_tmb <- unname(se_ss_ln_tmp[1:2, "Std. Error"])
      se_ls_ln_tmb <- unname(c(se_ss_ln_tmp[3, "Std. Error"], se_bs_ln_tmp[6, "Std. Error"]))
      
      bs_ll_tmb    <- unname(se_bs_ll_tmp[1:ncol(X), "Estimate"])
      ss_ll_tmb    <- unname(se_ss_ll_tmp[1:2, "Estimate"])
      ls_ll_tmb    <- unname(c(se_ss_ll_tmp[3, "Estimate"], se_bs_ll_tmp[6, "Estimate"]))
      
      se_bs_ll_tmb <- unname(se_bs_ll_tmp[1:ncol(X), "Std. Error"])
      se_ss_ll_tmb <- unname(se_ss_ll_tmp[1:2, "Std. Error"])
      se_ls_ll_tmb <- unname(c(se_ss_ll_tmp[3, "Std. Error"], se_bs_ll_tmp[6, "Std. Error"]))
      
      bs_wb_tmb    <- unname(se_bs_wb_tmp[1:ncol(X), "Estimate"])
      ss_wb_tmb    <- unname(se_ss_wb_tmp[1:2, "Estimate"])
      ls_wb_tmb    <- unname(c(se_ss_wb_tmp[3, "Estimate"], se_bs_wb_tmp[6, "Estimate"]))
      
      se_bs_wb_tmb <- unname(se_bs_wb_tmp[1:ncol(X), "Std. Error"])
      se_ss_wb_tmb <- unname(se_ss_wb_tmp[1:2, "Std. Error"])
      se_ls_wb_tmb <- unname(c(se_ss_wb_tmp[3, "Std. Error"], se_bs_wb_tmp[6, "Std. Error"]))
      
    }
  }
  m <- m+1
}


######

bs_0_est<- cbind(
  c(bs_ln_stt[1], bs_ln_tmb[1], bs_ll_stt[1], bs_ll_tmb[1], bs_wb_tmb[1]),
  c(se_bs_ln_stt[1], se_bs_ln_tmb[1], se_bs_ll_stt[1], se_bs_ll_tmb[1], se_bs_wb_tmb[1])
)

bs_1_est<- cbind(
  c(bs_ln_stt[2], bs_ln_tmb[2], bs_ll_stt[2], bs_ll_tmb[2], bs_wb_tmb[2]),
  c(se_bs_ln_stt[2], se_bs_ln_tmb[2], se_bs_ll_stt[2], se_bs_ll_tmb[2], se_bs_wb_tmb[2])
)

bs_2_est<- cbind(
  c(bs_ln_stt[3], bs_ln_tmb[3],bs_ll_stt[3], bs_ll_tmb[3], bs_wb_tmb[3]),
  c(se_bs_ln_stt[3], se_bs_ln_tmb[3], se_bs_ll_stt[3], se_bs_ll_tmb[3], se_bs_wb_tmb[3])
)

bs_3_est<- cbind(
  c(bs_ln_stt[4], bs_ln_tmb[4],bs_ll_stt[4],  bs_ll_tmb[4],  bs_wb_tmb[4]),
  c(se_bs_ln_stt[4], se_bs_ln_tmb[4],se_bs_ll_stt[4], se_bs_ll_tmb[4], se_bs_wb_tmb[4])
)

ls_1_est<- cbind(
  c(ls_ln_stt[1], ls_ln_tmb[1],  ls_ll_stt[1], ls_ll_tmb[1], ls_wb_tmb[1]),
  c(se_ls_ln_stt[1], se_ls_ln_tmb[1],  se_ls_ll_stt[1], se_ls_ll_tmb[1], se_ls_wb_tmb[1])
)

ls_0_est<- cbind(
  c(ls_ln_stt[2], ls_ln_tmb[2],  ls_ll_stt[2], ls_ll_tmb[2], ls_wb_tmb[2]),
  c(se_ls_ln_stt[2], se_ls_ln_tmb[2],  se_ls_ll_stt[2], se_ls_ll_tmb[2], se_ls_wb_tmb[2])
)

colnames(bs_0_est) =
  colnames(bs_1_est) =
  colnames(bs_2_est) =
  colnames(bs_3_est) =
  colnames(ls_1_est) =
  colnames(ls_0_est) <- c("Estimate", "Std.Error")

Procedures    <- c('STATA', '`TMB`', "STATA", "`TMB`", "`TMB`")
Distributions <- c("Log-Normal", "Log-Normal", "Log-Logistic", "Log-Logistic", "Weibull")

bs_0.df   <- data.frame(Distributions, Procedures, bs_0_est, Parameter = "beta_0", Model = "OW_RI")
bs_1.df   <- data.frame(Distributions, Procedures, bs_1_est, Parameter = "beta_1", Model = "OW_RI")
bs_2.df   <- data.frame(Distributions, Procedures, bs_2_est, Parameter = "beta_2", Model = "OW_RI")
bs_3.df   <- data.frame(Distributions, Procedures, bs_3_est, Parameter = "beta_3", Model = "OW_RI")
ls_1.df   <- data.frame(Distributions, Procedures, ls_1_est, Parameter = "sigma2_subj", Model = "OW_RI")
ls_0.df   <- data.frame(Distributions, Procedures, ls_0_est, Parameter = "log_sigma_0", Model = "OW_RI")

est <- join_all(dfs = list(bs_0.df,bs_1.df,bs_2.df,bs_3.df,ls_1.df,ls_0.df), type = "full")

write.table(est,file = "~/Dropbox/[Uni] MONASH/[AFT-Documents]/[Reports]/Datasets/ex_FLIRRT_OW_RI.txt", row.names = FALSE)

