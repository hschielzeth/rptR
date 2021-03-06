#' GLMM-based Repeatability Using PQL Estimation for Binomial Data
#' 
#' Calculates repeatability from a generalised linear mixed-effects models fitted
#' by PQL (penalized-quasi likelihood) estimation for binary and proportion data.
#' 
#' @param y If a data.frame is given to the data argument: String specifying response (binary) or vector with two strings for proportion data 
#'       (the first specifying the variable for number of successes and the second the variable for number of trials)
#'        Alternative: Vector of a response values (for binary data) or a two-column
#'        matrix, array or data.frame with colums code{m, n-m}, where \code{m} is the number of successes and n the 
#'        number of trials.
#' @param groups String indicating group variable or Vector of group identities.
#' @param data Data frame containing respnse and groups variable.
#' @param link Link function, \code{log} and \code{sqrt} are allowed, defaults 
#'        to \code{log}.  
#' @param CI Width of the confidence interval (defaults to 0.95).
#' @param nboot Number of parametric bootstraps for interval estimation
#'        (defaults to 1000). Larger numbers of permutations give a better
#'        asymtotic CI, but may be very time-consuming.
#' @param npermut Number of permutations for significance testing 
#'        (defaults to 1000). Larger numbers of permutations give better
#'        asymtotic \emph{P} values, but may be very time-consuming.      
#' @param parallel If TRUE, bootstraps will be distributed. 
#' @param ncores Specify number of cores to use for parallelization. On default,
#'        all cores are used.  
#'       
#' @details Models are fitted using the \link{glmmPQL} function in \pkg{MASS} 
#'          with the \code{quasibinomial} family (proportion data) or the
#'          \code{binomial} family (binary data). }\note{ Confidence intervals 
#'          and standard errors are inappropriate at high repeatabilities 
#'          (\emph{omega} < 1), because parametric bootstrapping allows only
#'           \emph{omega} greater than or equal to 1.
#'   
#' 
#' @return Returns an object of class rpt that is a a list with the following elements: 
#' \item{datatype}{Type of response (here: "binomial").}
#' \item{method}{Method used to calculate repeatability (here: "PQL").}
#' \item{link}{Link function used (here: "logit" or "probit").}
#' \item{CI}{Width of the confidence interval.}
#' \item{R.link}{Point estimate for repeatability on the link scale.}
#' \item{se.link}{Standard error  (\emph{se}) for repeatability on the link 
#'       scale, i.e. the standard deviation of the parametric bootstrap runs. 
#'       Note that the distribution might not be symmetrical, in which case 
#'       the \emph{se} is less informative.}
#' \item{CI.link}{Confidence interval for repeatability on the link scale based
#'       on parametric-boostrapping of \emph{R}.}
#' \item{P.link}{Approximate \emph{P} value from a significance test for the 
#'       link scale repeatability based on randomisation.}
#' \item{R.org}{Point estimate for repeatability \emph{R} on the original scale.}
#' \item{se.org}{Standard error  (\emph{se}) for repeatability on the original
#'       scale, i.e. the standard deviation of the parametric bootstrap runs.
#'       Note that the distribution might not be symmetrical, in which case
#'        \emph{se} is less informative.}
#' \item{CI.org}{Confidence interval for repeatability on the link scale based
#'       on parametric-boostrapping of \emph{R}.}
#' \item{P.org}{Approximate \emph{P} value from a a significance test for the
#'       original scale repeatability based on randomisation. }
#' \item{omega}{Multiplicative overdispersion parameter.}
#' \item{R.boot}{Named list of parametric bootstap samples for \emph{R}.
#'       \code{R.link} gives the samples for the link scale repeatability,
#'       \code{R.org} gives the samples for the original scale repeatability.} 
#' \item{R.permut}{Named list of permutation samples for \emph{R}. \code{R.link}
#'       gives the samples for the link scale repeatability, \code{R.org} gives
#'       the samples for the original scale repeatability.} 
#' \item{ngroups}{Number of groups.}
#' \item{nobs}{Number of observations.}
#'
#' @references 
#' Browne, W. J., Subramanian, S. V., et al. (2005). \emph{Variance partitioning in multilevel logistic models that exhibit overdispersion}. Journal of the Royal Statistical Society A 168: 599-613. \cr
#' 
#' Goldstein, H., Browne, W., et al. (2002). \emph{Partitioning variation in multilevel models}. Understanding Statistics 1: 223-231. \cr
#' 
#' Nakagawa, S. and Schielzeth, H. (2010) \emph{Repeatability for Gaussian and non-Gaussian data: a practical guide for biologists}. Biological Reviews 85: 935-956
#' 
#' @author Holger Schielzeth  (holger.schielzeth@@ebc.uu.se) & 
#'         Shinichi Nakagawa (shinichi.nakagawa@@otago.ac.nz) &
#'         Martin Stoffel (martin.adam.stoffel@@gmail.com)
#'         
#' @seealso \link{rpt.binomGLMM.add}, \link{rpt}, \link{print.rpt}
#' 
#' @examples  
#' 
#' # repeatability estimations for egg dumping (binary data)
#'      data(BroodParasitism)
#'      EggDump <- subset(BroodParasitism, OwnClutchesBothSeasons == 1, select = c(HostYN, FemaleID))
#'      (rpt.Host <- rpt.binomGLMM.multi("HostYN", "FemaleID", data = EggDump,  nboot=10, npermut=10))  
#'      # low number of nboot and npermut to speed up error checking
#'      (rpt.BroodPar <- rpt.binomGLMM.multi("cbpYN", "FemaleID", data = BroodParasitism, nboot=10, npermut=10))
#'      # low number of nboot and npermut to speed up error checking
#'      
#' # repeatability estimations for egg dumping (proportion data)
#'      data(BroodParasitism)
#'      ParasitisedOR <- subset(BroodParasitism,  select= c(HostClutches, OwnClutches, FemaleID))
#'      ParasitisedOR$parasitised <-  ParasitisedOR$OwnClutches - ParasitisedOR$HostClutches 
#'      (rpt.Host <- rpt.binomGLMM.multi(c("HostClutches", "parasitised"), "FemaleID", 
#'                                      data = ParasitisedOR[BroodParasitism$OwnClutchesBothSeasons == 1, ], 
#'                                      nboot=10, npermut=10))
#'                                       # reduced number of npermut iterations
#'                                       
#'      ParasitismOR <- subset(BroodParasitism,  select= c(cbpEggs, nEggs, FemaleID))
#'      ParasitismOR$parasitised <-  ParasitismOR$nEggs  - ParasitismOR$cbpEggs
#'      zz = which(ParasitismOR[,1]==0 & ParasitismOR[,2]==0) # some rows have entries 0,0 and need to be removed
#'      (rpt.BroodPar <- rpt.binomGLMM.multi(c("cbpEggs", "parasitised"), "FemaleID", 
#'                                              data = ParasitismOR[-zz, ], nboot=10, npermut=10))   
#' 
#' 
#' @keywords models
#' 
#' @export
#' 
# @importFrom MASS glmmPQL
#' @importFrom VGAM probit rbetabinom

rpt.binomGLMM.multi <- function(y, groups, data, link=c("logit", "probit"), CI=0.95, nboot=1000, npermut=1000, parallel = FALSE, ncores = 0) {
        
        # data argument check
        if  (is.character(y) & ((length(y) == 1) || (length(y) == 2)) & is.character(groups) & (length(groups) == 1)) {
                # y gets vector is one column, stays df if two columns
                ifelse(is.data.frame(data[, y]),  y <- as.matrix(data[, y]), y <- data[, y])
                # y <- as.matrix(data[, y])
                groups <- data[, groups]
        }
        
        # initial checks
	if (is.null(dim(y))) 
		y <- cbind(y, 1-y)
	if (nrow(y) != length(groups)) 
		stop("y and group have to be of equal length")
	if(nboot < 0) 	nboot <- 0
	if(npermut < 1) npermut <- 1
	if(length(link) > 1)
		link   <- link[1]
	if(link != "logit" & link != "probit") 
		stop("inappropriate link (has to be 'logit' or 'probit')")
	if(any(is.na(y))) {
		warning("missing values in y are removed")
		groups <- groups[-rowSums(is.na(y)) > 0]
		y      <- y[-rowSums(is.na(y)) > 0,]
	}
	# preparation
	groups <- factor(groups)
	n <- rowSums(y)
	N <- nrow(y)
	k <- length(levels(groups))
	# functions
	pqlglmm.binom.model <- function(y, groups, n, link, returnR=TRUE) {
		if(all(n==1)) mod <- MASS::glmmPQL(y ~ 1, random=~1|groups,  family=binomial(link=eval(link)), verbose=FALSE)
		else          mod <- MASS::glmmPQL(y ~ 1, random=~1|groups,  family=quasibinomial(link=eval(link)), verbose=FALSE)	
		VarComp  <- lme4::VarCorr(mod)
		beta0    <- as.numeric(mod$coefficients$fixed)
		if(all(n==1)) omega <- 1
			else      omega <- (as.numeric(VarComp[2,1]))
		var.a  <- (as.numeric(VarComp[1,1]))
		if (link=="logit") {
			R.link  <- var.a / (var.a+omega*pi^2 /3)
			P 		<- exp(beta0) / (1+ exp(beta0))
			R.org   <- (var.a * P*P / (1+exp(beta0))^2 ) / (var.a * P*P / (1+exp(beta0))^2 + omega * P*(1-P)) 
		}
		if (link=="probit") {
			R.link  <- var.a / (var.a+omega)
			R.org   <- NA 
		}
		if(returnR) return(list(R.link=R.link, R.org=R.org))
		else return(list(beta0=beta0, omega=omega, var.a=var.a)) 
	}
	# point estimate
	R <- pqlglmm.binom.model(y, groups, n, link)
	# confidence interval by parametric bootstrapping
        # nboot is not used in function, but necessary to run parSapply over vector in parallelization
	bootstr <- function(nboot, y, groups, k, N, n, beta0, var.a, omega, link) {
		groupMeans <- rnorm(k, 0, sqrt(var.a))
		p.link     <- beta0 + groupMeans[groups]
		if(link=="logit") p <- exp(p.link)/(1+exp(p.link))
		if(link=="probit") p <- probit(p.link, inverse=TRUE) # VGAM::probit(p.link, inverse=TRUE)
		if(all(n==1))
			m <- rbinom(N, 1, p)   # binomial model
		else {
			rho <- (omega-1)/(n-1)
			rho[rho<=0] <-0				# underdispersion is ignored
			rho[rho>=1] <- 9e-10      # strong overdispersion is forced to have rho ~ 1
#			if(rho==0)
#				m <- rbinom(N,n,p)
#			else {
				m <- rbetabinom(N,n,p,rho)    # or p * rho, VGAM::rbetabinom(N,n,p,rho)
#			}
		}
		pqlglmm.binom.model(cbind(m, n-m), groups, n, link) 
	}
        if(nboot > 0 & parallel == TRUE){ 
                mod.ests <- pqlglmm.binom.model(y, groups, n, link, returnR=FALSE)
                if (ncores == 0) {
                ncores <- parallel::detectCores()
                warning("No core number specified: detectCores() is used to detect the number of 
                        cores on the local machine")
                } 
                # start cluster
                cl <- parallel::makeCluster(ncores)
                parallel::clusterExport(cl, c("pqlglmm.binom.model", "probit", "rbetabinom"), envir=environment())
                # parallel::clusterEvalQ(cl,library(VGAM)) ## problematic!
                # parallel computing
                R.boot <- (parallel::parSapply(cl, 1:nboot, bootstr, y = y, groups = groups, k = k, N = N,
                                               n = n, beta0 = mod.ests$beta0, var.a = mod.ests$var.a, 
                                               omega = mod.ests$omega, link = link))
                # transform to list
                R.boot <- lapply(data.frame(t(R.boot)), unlist)
                parallel::stopCluster(cl)
	} else if (nboot > 0 & parallel == FALSE) {
		mod.ests <- pqlglmm.binom.model(y, groups, n, link, returnR=FALSE)
		R.boot   <- replicate(nboot, bootstr(y = y, groups = groups, k = k, N = N,
		                                     n = n, beta0 = mod.ests$beta0, var.a = mod.ests$var.a, 
		                                     omega = mod.ests$omega, link = link), simplify=TRUE)
		R.boot   <- list(R.link = as.numeric(unlist(R.boot["R.link",])), R.org = as.numeric(unlist(R.boot["R.org",])))  
	} else {
		R.boot   <- list(R.link = NA, R.org = NA)
	}
	CI.link  <- quantile(R.boot$R.link, c((1-CI)/2,1-(1-CI)/2), na.rm=TRUE)
	CI.org   <- quantile(R.boot$R.org, c((1-CI)/2,1-(1-CI)/2), na.rm=TRUE)
	se.link  <- sd(R.boot$R.link,na.rm=TRUE)
	se.org   <- sd(R.boot$R.org,na.rm=TRUE)
	# significance test by randomization
	permut   <- function(y, groups, N, link) {
		samp <- sample(1:N, N)
		pqlglmm.binom.model(y, groups[samp], n, link) 
	}
	if(npermut > 1) { 
		R.permut <- replicate(npermut-1, permut(y, groups, N, link), simplify=TRUE)
		R.permut <- list(R.link = c(R$R.link, unlist(R.permut["R.link",])), R.org = c(R$R.org, unlist(R.permut["R.org",])))
		P.link   <- sum(R.permut$R.link >= R$R.link) / npermut
		P.org    <- sum(R.permut$R.org >= R$R.org) / npermut
	} else {
		R.permut <- R
		P.link   <- NA
		P.org    <- NA
	}
	# return of results
	if(mod.ests$omega<1) warning("omega < 1, therefore CI are unreliable")
	res <- list(call=match.call(), 
				datatype="binomial", method="PQL", link=link, CI=CI, 
				R.link=R$R.link, se.link=se.link, CI.link=CI.link, P.link=P.link,
				R.org=R$R.org, se.org=se.org, CI.org=CI.org, P.org=P.org, 
				omega=mod.ests$omega,
				R.boot = list(R.link=R.boot$R.link, R.org=R.boot$R.org),
				R.permut = list(R.link=R.permut$R.link, R.org=R.permut$R.org),
				ngroups = length(unique(groups)), nobs = length(y)) 
	class(res) <- "rpt"
	return(res) 
}			
