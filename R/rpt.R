#' Repeatability Calculation for Gaussian and Non-Gaussian Data
#' 
#' A wrapper function for repeatability calculations. Calls specialised functions 
#' depending of the choice of datatype and method.
#' 
#' @param y Vector of measurements (or two-column matrix or dataframe in case of 
#'        proprotion data, see \link{rpt.binomGLMM.add} and
#'         \link{rpt.binomGLMM.multi} for details.
#' @param groups Vector of group identitities (will be converted to a factor).
#' @param datatype Character string specifying the data type
#'       ("Gaussian", "binomial", "proportion", "count"). "binomial" and 
#'       "proportion" are interchangable and call the same functions.
#' @param method character string specifying the method of calculation. 
#'        Defaults to "REML" for Gaussian data and to "GLMM.multi" for binomial
#'        and count data.
#' @param link Character string specifying the link function. Ignored for "Gaussian" 
#'        datatype and for the "GLMM.add" method.
#' @param CI Width of the confidence interval between 0 and 1 (defaults to 0.95).
#' @param nboot Number of bootstrapping runs used when calculating the asymtotic 
#'        confidence interval (defaults to 1000). Ignored for the "GLMM.add",
#'        "corr" and "ANOVA" methods.
#' @param npermut Number of permutations used when calculating asymtotic
#'        \emph{P} values (defaults to 1000). Ignored for the "GLMM.add" method.
#' 
#' @details For \code{datatype="Gaussian"} calls function \link{rpt.corr}, \link{rpt.aov}, 
#'          \link{rpt.remlLMM} or \link{rpt.mcmcLMM} (methods "corr", "ANOVA", 
#'          "REML" and "MCMC", respectively).
#'          
#'          For \code{datatype="binomial"} or \code{datatype="proportion"} calls function
#'          \link{rpt.binomGLMM.multi} or \link{rpt.binomGLMM.add} (methods "GLMM.multi" 
#'          and "GLMM.add", respectively).
#'          
#'          For \code{datatype="count"} calls function \link{rpt.poisGLMM.multi} 
#'          or \link{rpt.poisGLMM.add} (methods "GLMM.multi" and "GLMM.add", respectively). 
#' 
#' @return Returns an object of class rpt. See details for specific functions.
#' \item{datatype}{Type of repsonse ("Gaussian", "binomial" or "count").}
#' \item{method}{Method used to calculate repeatability ("REML", "MCMC", "ANOVA", 
#'      "corr", "GLMM.add" or "GLMM.multi").}
#' \item{link}{Link functions used (GLMMs only).}
#' \item{CI}{Width of the confidence interval or Bayesian credibility interval.}
#' \item{R}{Point estimate for repeatability.}
#' \item{R.link}{Point estimate for repeatability on link scale (GLMM only).}
#' \item{R.org}{Point estimate for repeatability on original scale (GLMM only).}
#' \item{se}{Standard error (\emph{se}) for repeatability. Note that the 
#'       distribution might not be symmetrical, in which case the se is less
#'       informative.}
#' \item{se.link}{Standard error (\emph{se}) for repeatability on link scale
#'       (GLMM only).}
#' \item{se.org}{Standard error (\emph{se}) for repeatability on original scale
#'       (GLMM only).}
#' \item{CI.R}{Confidence interval or Bayesian credibility interval for the
#'       repeatability.}
#' \item{CI.link}{Confidence interval or Bayesian credibility interval for
#'       repeatability on link scale (GLMM only).}
#' \item{CI.org}{Confidence interval or Bayesian credibility interval for
#'       repeatability on original scale (GLMM only).}
#' \item{P}{Significace test, returned as \emph{NA} for the Bayesian approach
#'       conflicts with the null hypothesis testing.}
#' \item{P.link}{Significace test for repeatability on link scale, returned as
#'       \emph{NA} for the Bayesian approach conflicts with the null hypothesis
#'       testing.}
#' \item{P.org}{Significace test for repeatability on original scale, returned 
#'      as \emph{NA} for the Bayesian approach conflicts with the null hypothesis
#'      testing.}
#' \item{R.post}{MCMC samples form the posterior distributions of \emph{R}.} 
#' \item{R.boot}{Parametric bootstrap samples for \emph{R}.}
#' \item{R.permut}{Permutation samples for \emph{R}.}
#'
#' @references 
#' Nakagawa, S. and Schielzeth, H. (2010) \emph{Repeatability for Gaussian and 
#'              non-Gaussian data: a practical guide for biologists}. Biological Reviews 85: 935-956
#' 
#' @author Holger Schielzeth  (holger.schielzeth@@ebc.uu.se) & 
#'      Shinichi Nakagawa (shinichi.nakagawa@@otago.ac.nz)
#'      
#' @seealso \link{rpt.adj}, \link{rpt.corr}, \link{rpt.aov}, \link{rpt.remlLMM}, \link{rpt.mcmcLMM},
#'          \link{rpt.binomGLMM.add}, \link{rpt.binomGLMM.multi}, \link{rpt.poisGLMM.add}, 
#'          \link{rpt.poisGLMM.multi} 
#' 
#' @examples  
#' 
#'        # all examples use a reduced number of npermut and nboot iterations!
#'        
#'        # for Gaussian data - correlation-based repeatability
#'        # repeatability for male breeding success on a transformed scale
#'          data(Fledglings)
#'          Fledglings$sqrtFledge <- sqrt(Fledglings$Fledge)
#'         (rpt.Fledge <- rpt("sqrtFledge", "MaleID", data = Fledglings, datatype="Gaussian", 
#'                             method="corr", nboot=10, npermut=10))  # reduced number of iterations
#'   
#'        
#'        # for Gaussian data - ANOVA-based and LMM-based repeatabilities
#'        # repeatability estimation for tarsus length - a very high R
#'        data(BodySize)
#'        # ANOVA based
#'        (rpt.BS <- rpt("Tarsus", "BirdID", data = BodySize, datatype="Gaussian", method="ANOVA", npermut=10)) 
#'        # LMM based
#'        (rpt.Weight <- rpt("Weight", "BirdID", data = BodySize, datatype="Gaussian", method="REML", nboot=10, npermut=10)) 
#'        # LMM based with MCMC
#'        (rpt.Weight <- rpt("Weight", "BirdID", data = BodySize, datatype="Gaussian", method="MCMC"))
#'        
#'        # for Binary data - additive and multiplicative overdispersion models
#'        # repeatability estimations for egg dumping (binary data)
#'        data(BroodParasitism)
#'        attach(BroodParasitism)
#'        (rpt.BroodPar <- rpt(cbpYN, FemaleID, datatype="binomial", method="GLMM.multi", link="logit", 
#'                             nboot=10, npermut=10))
#'        (rpt.BroodPar <- rpt(cbpYN, FemaleID, datatype="binomial", method="GLMM.multi", link="probit", 
#'                             nboot=10, npermut=10))
#'        (rpt.BroodPar <- rpt(cbpYN, FemaleID, datatype="binomial", method="GLMM.add"))
#'        detach(BroodParasitism)
#'        
#'        # for proportion data - additive and multiplicative overdispersion models
#'        # repeatability estimations for egg dumping (proportion data)
#'        data(BroodParasitism)
#'        attach(BroodParasitism)
#'        ParasitisedOR <- cbind(HostClutches, OwnClutches-HostClutches)   
#'        (rpt.Host <- rpt(ParasitisedOR[OwnClutchesBothSeasons==1,], FemaleID[OwnClutchesBothSeasons==1], 
#'                         datatype="proportion", method="GLMM.multi", nboot=10, npermut=10))
#'        (rpt.Host <- rpt(ParasitisedOR[OwnClutchesBothSeasons==1,], FemaleID[OwnClutchesBothSeasons==1], 
#'                         datatype="proportion", method="GLMM.add"))
#'        detach(BroodParasitism)
#'        
#'        # for count data - additive and multiplicative overdispersion models
#'        # repeatability for male fledgling success
#'        data(Fledglings)
#'        attach(Fledglings)
#'        (rpt.Fledge <- rpt(Fledge, MaleID, datatype="count", method="GLMM.multi", nboot=10, npermut=10))
#'        (rpt.Fledge <- rpt(Fledge, MaleID, datatype="count", method="GLMM.add"))
#'        detach(Fledglings)
#'
#'
#' @keywords models
#' 
#' @export
#' 
rpt <- function(y, groups, data, 
			   datatype=c("Gaussian", "binomial", "proportion", "count"),  
			   method=c("corr", "ANOVA", "REML", "MCMC", "GLMM.add", "GLMM.multi"),  
			   link=c("logit", "probit", "log", "sqrt"),
			   CI=0.95, nboot=1000, npermut=1000) {
	if(datatype=="Gaussian") {
		if(length(method)>1) {
			warning("Linear mixed model fitted by REML used by default. Change using argument 'method', if required ('corr', 'ANOVA', 'REML' and 'MCMC' allowed for Gaussian data).")
			method<-"REML" 
		}
		if (method=="REML")  return(rpt.remlLMM(y, groups, data, CI=CI, nboot=nboot, npermut=npermut))
		if (method=="MCMC")  return(rpt.mcmcLMM(y, groups, data, CI=CI))
		if (method=="ANOVA") return(rpt.aov(y, groups, data, CI=CI, npermut=npermut))	
		if (method=="corr")  return(rpt.corr(y, groups, data, CI=CI, nboot=nboot, npermut=npermut)) 
	}
	if(datatype=="binomial" | datatype=="proportion") {
		if(length(method)>1) {
			warning("Generalised linear mixed model with multiplicative overdispersion fitted by PQL used by default. Change using argument 'method', if required ('GLMM.add' and 'GLMM.multi' allowed for Binomial data).")
			method<-"GLMM.multi" 
		}
		if (method=="GLMM.multi") return(rpt.binomGLMM.multi(y, groups, data, link, CI=CI, nboot=nboot, npermut=npermut))
		if (method=="GLMM.add") return(rpt.binomGLMM.add(y, groups, data, CI=CI))
	}
	if(datatype=="count") {
		if(length(method)>1) {
			warning("Generalised linear mixed model with multiplicative overdispersion fitted by PQL used by default. Change using argument 'method', if required ('GLMM.add' and 'GLMM.multi' allowed for count data).")
			method<-"GLMM.multi"
		}
		if(length(link)>1) {
			link="log"
			warning("Log link will be used.")
		}
		if (method=="GLMM.multi") return(rpt.poisGLMM.multi(y, groups, data, link, CI=CI, nboot=nboot, npermut=npermut)) 
		if (method=="GLMM.add")   return(rpt.poisGLMM.add(y, groups, data, CI=CI)) 
	} 
}