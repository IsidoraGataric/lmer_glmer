# Loading the packages.
require(rms)
require(lme4)
require(languageR)
require(multcomp)
require(lsmeans)
require(multcompView)
require(pbkrtest)
require(lmerTest)
require(randomForest)
require(party)
require(MASS)
require(ggplot2)
library(car)
require(mgcv)

# Loading dataset.
dat=read.table("vld_final.txt",T)

# Dimensions of dataset (number of rows [data], number of columns [variables]).
dim(dat)
#[1] 2023   16

# Column names.
colnames(dat)

# [1] "Subject"            "TrialOrder"         "Group"             
# [4] "CorrectResponse"    "TrialNumber"        "Suffix"            
# [7] "SuffixLength"       "Response"           "Accuracy"          
# [10] "RT"                 "SuffixAmbiguity"    "Noun"              
# [13] "LemmaFrequency"     "NounLength"         "SuffixFrequency"   
# [16] "SuffixProductivity"

# ------------------
# -------------------------------- PREPARING DATA FOR STATISTICAL ANALYSIS!
# ------------------

# Sorting the participants according to the accuracy of the answers they gave. 
sort(tapply(dat$Accuracy, dat$Subject, sum)/44)

#      s28       s31       s40       s22       s33       s29       s32       s39 
#0.7954545 0.7954545 0.7954545 0.8181818 0.8181818 0.8409091 0.8409091 0.8409091 
#      s41       s42        s5        s6       s23       s26       s37       s11 
#0.8409091 0.8409091 0.8409091 0.8409091 0.8636364 0.8636364 0.8636364 0.8863636 
#      s12       s16       s17       s18       s35       s36        s4       s46 
#0.8863636 0.8863636 0.8863636 0.8863636 0.8863636 0.8863636 0.8863636 0.8863636 
#       s7        s1       s19       s27       s44        s3       s30       s43 
#0.8863636 0.9090909 0.9090909 0.9090909 0.9090909 0.9318182 0.9318182 0.9318182 
#      s45        s8       s10       s13       s14       s15        s2       s21 
#0.9318182 0.9318182 0.9545455 0.9545455 0.9545455 0.9545455 0.9545455 0.9545455 
#      s24       s25       s34       s38       s20        s9 
#0.9545455 0.9545455 0.9545455 0.9545455 0.9772727 0.9772727

# Sorting the stimuli according to the accuracy of the answers participants gave on it. 
sort(tapply(dat$Accuracy, dat$TrialNumber, sum)/23)

#      100       109        17       126        37        23        98       115 
#0.1304348 0.1739130 0.3913043 0.4347826 0.4782609 0.5652174 0.6521739 0.6521739 
#       27       117       124       129        96       130        25        35 
#0.6956522 0.6956522 0.6956522 0.6956522 0.7391304 0.7391304 0.7826087 0.7826087 
#       38       103       105       119        10       116         6        91 
#0.7826087 0.7826087 0.7826087 0.7826087 0.8260870 0.8260870 0.8695652 0.8695652 
#       93        19        94        99       106       112       113       114 
#0.8695652 0.9130435 0.9130435 0.9130435 0.9130435 0.9130435 0.9130435 0.9130435 
#      122       123       128       131         2         7        21        89 
#0.9130435 0.9130435 0.9130435 0.9130435 0.9565217 0.9565217 0.9565217 0.9565217 
#       90        92        95        97       101       102       104       107 
#0.9565217 0.9565217 0.9565217 0.9565217 0.9565217 0.9565217 0.9565217 0.9565217 
#      108       110       111       118       120       121       125       127 
#0.9565217 0.9565217 0.9565217 0.9565217 0.9565217 0.9565217 0.9565217 0.9565217 
#      132         1         5         9        13        24        30        31 
#0.9565217 1.0000000 1.0000000 1.0000000 1.0000000 1.0000000 1.0000000 1.0000000 
#       34        40        44         3         4         8        11        12 
#1.0000000 1.0000000 1.0000000 1.0434783 1.0434783 1.0434783 1.0434783 1.0434783 
#       14        15        16        18        20        22        26        28 
#1.0434783 1.0434783 1.0434783 1.0434783 1.0434783 1.0434783 1.0434783 1.0434783 
#       29        32        33        36        39        41        42        43 
#1.0434783 1.0434783 1.0434783 1.0434783 1.0434783 1.0434783 1.0434783 1.0434783 

# Note: Now I need to throw out the participants and stimuli with above 25% error-rate! All participants have less than 25% error-rate!

# Deletion of stimuli (25% of the error)!
dat=dat[dat$TrialNumber!="100",]
dat=dat[dat$TrialNumber!="109",]
dat=dat[dat$TrialNumber!="17",]
dat=dat[dat$TrialNumber!="126",]
dat=dat[dat$TrialNumber!="37",]
dat=dat[dat$TrialNumber!="23",]
dat=dat[dat$TrialNumber!="98",]
dat=dat[dat$TrialNumber!="115",]
dat=dat[dat$TrialNumber!="27",]
dat=dat[dat$TrialNumber!="117",]
dat=dat[dat$TrialNumber!="124",]
dat=dat[dat$TrialNumber!="129",]
dat=dat[dat$TrialNumber!="96",]
dat=dat[dat$TrialNumber!="130",]

# Dimensions of dataset (number of rows [data], number of columns [variables]).
dim(dat)
#[1] 1707   16

# Calculating the percentage of deleted data.
(2023-1707)/2023
#[1] 0.1562037

# -----------------------------------------

# I have to examine in which covariates the ambiguous and unambiguous suffixes differ (e.g. Are ambiguous suffixes longer, or more frequent [stat.sign.]?!). I will create subset with 
# data of two participants from different experimental groups (because it would be too long to look at the whole sample, and also it is useless).

datx=dat[dat$Subject=="s9" | dat$Subject=="s38",]

# Dimensions of subest.
dim(datx)
#74 16

# ----------------------
##################### Noun length (in letters)
# ----------------------

aov.datx= aov(NounLength~SuffixAmbiguity, data=datx)
summary (aov.datx)
print(model.tables(aov.datx, "means"),digits=3)
boxplot(NounLength~SuffixAmbiguity, data=datx)

#                Df Sum Sq Mean Sq F value Pr(>F)  
#SuffixAmbiguity  1   8.56   8.564   4.088 0.0469 *
#Residuals       72 150.84   2.095                 
        
#    ambiguous unambiguous
#         7.07        7.76
#        41.00       33.00

# Note: This effect is marginally statistically significant (p = 0.04). This results suggest that unambiguous suffixes are in general longer than ambiguous.

# -------------------------
##################### Lemma Frequency (taken from the corpus srWac)
# -------------------------

aov.datx= aov(LemmaFrequency~SuffixAmbiguity, data=datx)
summary (aov.datx)
print(model.tables(aov.datx, "means"),digits=3)
boxplot(LemmaFrequency~SuffixAmbiguity, data=datx)

#                Df    Sum Sq   Mean Sq F value Pr(>F)  
#SuffixAmbiguity  1 7.865e+08 786503093   3.235 0.0763 
#Residuals       72 1.750e+10 243114598 

#     ambiguous unambiguous
#         10934        4375
# rep        41          33

# Note: This effect is not statistically significant, which means that nouns with ambiguous and unambiguous suffixes do not differ in the frequency of lemmas.

# -------------------------
##################### Suffix frequency (taken from the database created by me and my colleagues)
# -------------------------

aov.datx= aov(SuffixFrequency~SuffixAmbiguity, data=datx)
summary (aov.datx)
print(model.tables(aov.datx, "means"),digits=3)
boxplot(SuffixFrequency~SuffixAmbiguity, data=datx)

#                Df    Sum Sq  Mean Sq F value Pr(>F)
#SuffixAmbiguity  1 7.809e+06  7808535   0.288  0.593
#Residuals       72 1.950e+09 27089474

#    ambiguous unambiguous
#         4578        3925
#rep        41          33

# Note: This effect is not statistically significant, which means that nouns with ambiguous and unambiguous suffixes do not differ in the suffix frequency.

# -------------------------
##################### Suffix length (in letters)
# -------------------------

aov.datx= aov(SuffixLength~SuffixAmbiguity, data=datx)
summary (aov.datx)
print(model.tables(aov.datx, "means"),digits=3)
boxplot(SuffixLength~SuffixAmbiguity, data=datx)

#                Df Sum Sq Mean Sq F value Pr(>F)
#SuffixAmbiguity  1   1.04  1.0356   1.461  0.231
#Residuals       72  51.02  0.7086   

#    ambiguous unambiguous
#         2.73        2.97
#rep     41.00       33.00

# Note: This effect is not statistically significant, which means that nouns with ambiguous and unambiguous suffixes do not differ in the suffix length.

# -------------------------
##################### Suffix Productivity (taken from the database created by me and my colleagues)
# -------------------------

aov.datx= aov(SuffixProductivity~SuffixAmbiguity, data=datx)
summary (aov.datx)
print(model.tables(aov.datx, "means"),digits=3)
boxplot(SuffixProductivity~SuffixAmbiguity, data=datx)

#            Df   Sum Sq Mean Sq F value Pr(>F)  
#NV           1   593524  593524   2.905 0.0926
#Residuals   72 14708156  204280

#    jedno vise
#      377  197
#      33   41

# Note: This effect is not statistically significant, which means that nouns with ambiguous and unambiguous suffixes do not differ in the suffix productivity.
# ______
# _______________________________________
# __________________________________________________________

# I need to throw out the RTs that are errors.
dat=dat[dat$Accuracy>0,]

# Dimension of the data set (number of rows [data], number of columns [variables]).
dim(dat)
#[1] 1633   16

# Calculating the percentage of deleted data.
(2023-1633)/2023
#[1] 0.192783

# Visual inspection of data (RTs).
par(mfrow=c(2,2))
plot(sort(dat$RT))
plot(density(dat$RT))
qqnorm(dat$RT)
par(mfrow=c(1,1))

# I have to examine RTs with powerTransform() to see which transformation I have to use (distribution of RTs is not normal). So, if the value is close to zero
# the best transformation is log tranformation, if the value is close to one, than we need inverse transformation of raw RTs. 
powerTransform(dat$RT)
#Estimated transformation parameters 
#   dat$RT 
#-1.314563 

# Note: the results suggest inverse transformation of RTs.

# Following previous studies, I will use log transformation to transform the raw values of LemmaFrequency, SuffixFrequency, SuffixLength, NounLength, and SuffixProductivity.
dat$flem=log(dat$LemmaFrequency)
dat$nlen=log(dat$NounLength)
dat$fsuf=log(dat$SuffixFrequency)
dat$slen=log(dat$SuffixLength)
dat$sprod=log(dat$SuffixProductivity)

# Inverse transformation of RTs. 
dat$RT=-1000/dat$RT

# Visual inspection of data (RTs), after transformation.
par(mfrow=c(2,2))
plot(sort(dat$RT))
plot(density(dat$RT))
qqnorm(dat$RT)
par(mfrow=c(1,1))

# Note: this distribution is closer to normal.

# ------- Shapiro-Wilk & Kolmogorov-Smirnov after transformation of RTs (this step has been skipped earlier, because on the basis of VIP1 graphics I saw that distribution deviates exceptionally from normal [before transformation]).

# I will use K-S test to test normality of transformed RTs distribution.
ks.test(jitter(dat$RT),"pnorm",mean(dat$RT),sd(dat$RT))
#        One-sample Kolmogorov-Smirnov test
#
#data:  jitter(dat$RT)
#D = 0.041749, p-value = 0.006742
#alternative hypothesis: two-sided

# Note: This test is statistically significant, and this suggest that our sample distribution is different than reference probability distribution [distribution is not normal].

# I continue to deal with the distribution, and it's normality. I will use S-W test, and this test is more powerful than K-S test. If S-W test is significant (p-value), than distribution is not normal. 
shapiro.test(dat$RT)
#        Shapiro-Wilk normality test
#
#data:  dat$RT
#W = 0.99274, p-value = 3.377e-07

# Note: It is significant, distribution is not normal, even after the transformation. In psycholinguistics studies, this is very often the case.

# Normalization of continuous precitors, to be comparable on the same scale.
dat$trial.z = scale(dat$TrialOrder)
dat$flem.z = scale(dat$flem)
dat$nlen.z = scale(dat$nlen)
dat$fsuf.z = scale(dat$fsuf)
dat$slen.z = scale(dat$slen)
dat$sprod.z = scale(dat$sprod)

# Factor as factor (SuffixAmbiguity).
as.factor(as.character(dat$SuffixAmbiguity))
levels(dat$SuffixAmbiguity)
table(dat$SuffixAmbiguity)

#  ambiguous unambiguous 
#        911         722

# Factor as factor (Subject).
as.factor(as.character(dat$Subject))
levels(dat$Subject)
table(dat$Subject)

# Factor as factor (TrialNumber).
as.factor(as.character(dat$TrialNumber))
levels(dat$TrialNumber)
table(dat$TrialNumber)

# __________________________________________________________
# ________________________________________________________________

# Visualization of continuous predictors.

# -------------------------
##################### Trial order
# -------------------------

par(mfrow=c(2,2))
plot(sort(dat$TrialOrder))
plot(density(dat$TrialOrder))
qqnorm(dat$TrialOrder)
par(mfrow=c(1,1))

# -------------------------
##################### Noun length
# -------------------------

par(mfrow=c(2,2))
plot(sort(dat$nlen))
plot(density(dat$nlen))
qqnorm(dat$nlen)
par(mfrow=c(1,1))

# -------------------------
##################### Lemma frequency
# -------------------------

par(mfrow=c(2,2))
plot(sort(dat$flem))
plot(density(dat$flem))
qqnorm(dat$flem)
par(mfrow=c(1,1))

# -------------------------
##################### Suffix frequency
# -------------------------

par(mfrow=c(2,2))
plot(sort(dat$fsuf))
plot(density(dat$fsuf))
qqnorm(dat$fsuf)
par(mfrow=c(1,1))

# -------------------------
##################### Suffix length
# -------------------------

par(mfrow=c(2,2))
plot(sort(dat$slen))
plot(density(dat$slen))
qqnorm(dat$slen)
par(mfrow=c(1,1))

# -------------------------
##################### Suffix productivity
# -------------------------

par(mfrow=c(2,2))
plot(sort(dat$sprod))
plot(density(dat$sprod))
qqnorm(dat$sprod)
par(mfrow=c(1,1))

# __________________________________________________________
# ____________________________________________________________

# Visual inspection of random effects.

qqmath(~RT|Subject,data=dat)
qqmath(~RT|TrialNumber,data=dat)
xylowess.fnc (RT~TrialOrder | Subject, data=dat, ylab= "RT")

# ____________________________________________________________
# ____________________________________________________________

# Examine the data for Suffix frequency, we have one outlier (-nje) with frequency = 23567.
table(dat$SuffixFrequency)

#   46    73    81    88    91   170   424   464   537   868   913  2140  2280 
#   21    41    21    23    24    38    43    24    46   217    24    92    68 
# 3001  3200  3764  3765  5345  6155  6585 23567 
#  181    40    91    24   173   129   224    89

# _________________________________________________________
# ________________________________________________________________

# Colinearity between predictors.
C=cov(dat[,c("flem","nlen","fsuf","slen","sprod")], y = NULL, use = "everything", method = c("pearson", "kendall", "spearman"))
Cor=cov2cor(C)
Cor

#             flem        nlen       fsuf        slen       sprod
#flem   1.00000000 -0.02192262  0.4623827  0.01930949  0.34034109
#nlen  -0.02192262  1.00000000 -0.1175926  0.62876318 -0.02878838
#fsuf   0.46238265 -0.11759259  1.0000000 -0.27074274  0.91055550
#slen   0.01930949  0.62876318 -0.2707427  1.00000000 -0.20600849
#sprod  0.34034109 -0.02878838  0.9105555 -0.20600849  1.00000000

collin.fnc(dat[,c("flem","nlen","fsuf","slen","sprod")])$cnumber

# This value is too big!
#48.82148

# Reduced, but still too big! This suggest that GAMMs might be more appropriate analysis for this data.
collin.fnc(dat[,c("flem","nlen","sprod")])$cnumber
#29.71396

# Note: I exscluded SuffixFrequency and SuffixLength.

# Visualization of multicolinearity (3 predictors).
postscript("isidora.pairscor1.ps", width=16, height=16,paper="special",horizontal=FALSE,onefile=FALSE)
png("isidora.pairscor1.png", width=800, height=800)
pairscor.fnc(dat[,c("flem","nlen","sprod")], hist=TRUE, smooth=TRUE, cex.point=1, col.points="darkgrey")
dev.off()

# Visualization of multicolinearity (5 predictors).
postscript("isidora1.pairscor1.ps", width=16, height=16,paper="special",horizontal=FALSE,onefile=FALSE)
png("isidora1.pairscor1.png", width=800, height=800)
pairscor.fnc(dat[,c("flem","nlen","fsuf","slen","sprod")], hist=TRUE, smooth=TRUE, cex.point=1, col.points="darkgrey")
dev.off()

# ______________________________
# _____________________________________________
# ____________________________________________________________

# ------------------
# -------------------------------- LMER ANALYSIS!
# ------------------

# ________________________
# _____________________________________________
# ____________________________________________________________

################################################################# LMER: Linear Mixed-Effect Regression!

########## Random effects!
lmer0 <- lmer(RT ~ 1 + (1|Subject) + (1|TrialNumber),	data=dat)
ranefItem <- lmer(RT ~ 1 + (1|Subject),	data=dat)
ranefSubj <- lmer(RT ~ 1 + (1|TrialNumber), data=dat)

anova(ranefItem, lmer0)

#object: RT ~ 1 + (1 | Subject)
#..1: RT ~ 1 + (1 | Subject) + (1 | TrialNumber)
#       Df    AIC    BIC  logLik deviance  Chisq Chi Df Pr(>Chisq)    
#object  3 730.20 746.39 -362.10   724.20                             
#..1     4 502.38 523.98 -247.19   494.38 229.81      1  < 2.2e-16 ***

# Note: The second model is better (AIC and BIC is smaller, LogLik is bigger).

anova(ranefSubj, lmer0)

#object: RT ~ 1 + (1 | TrialNumber)
#..1: RT ~ 1 + (1 | Subject) + (1 | TrialNumber)
#       Df     AIC     BIC  logLik deviance  Chisq Chi Df Pr(>Chisq)    
#object  3 1043.87 1060.06 -518.93  1037.87                             
#..1     4  502.38  523.98 -247.19   494.38 543.48      1  < 2.2e-16 ***

# Note: The second model is better (AIC and BIC is smaller, LogLik is bigger).

# __________________________________________________________
# ________________________________________________________________

############# TRIAL ORDER 

lmer.dat <- lmer(RT ~ trial.z + (1|Subject) + (1|TrialNumber),	data=dat)
summary (lmer.dat)

#Fixed effects:
#              Estimate Std. Error         df t value Pr(>|t|)    
#(Intercept) -1.411e+00  3.303e-02  6.970e+01 -42.712   <2e-16 ***
#trial.z     -2.744e-03  6.509e-03  1.528e+03  -0.422    0.673 

# Note: not significant.

lmer.dat1 <- lmer(RT ~ poly(TrialOrder, 2) + (1|Subject) + (1|TrialNumber), data=dat)
summary (lmer.dat1)

#Fixed effects:
#                       Estimate Std. Error         df t value Pr(>|t|)    
#(Intercept)            -1.41090    0.03312   69.50000 -42.602  < 2e-16 ***
#poly(TrialOrder, 2)1   -0.11370    0.26238 1526.80000  -0.433  0.66482    
#poly(TrialOrder, 2)2    0.72977    0.26288 1528.40000   2.776  0.00557 ** 

# I set REML = FALSE, because the models differ in fixed effects.
lmer.dat.a=update(lmer.dat, REML=FALSE)
lmer.dat1.a=update(lmer.dat1, REML=FALSE)

anova(lmer.dat.a,lmer.dat1.a)

#lmer.dat.a: RT ~ trial.z + (1 | Subject) + (1 | TrialNumber)
#lmer.dat1.a: RT ~ poly(TrialOrder, 2) + (1 | Subject) + (1 | TrialNumber)
#            Df    AIC    BIC  logLik deviance  Chisq Chi Df Pr(>Chisq)   
#lmer.dat.a   5 504.21 531.20 -247.10   494.21                            
#lmer.dat1.a  6 498.52 530.91 -243.26   486.52 7.6902      1   0.005552 **

# Note: the second model is better, the one with POLY function of TrialOrder.

# ------------------------
################ Embbeding of other predictors in LMER model.

lmer.dat2 <- lmer(RT ~ poly(TrialOrder,2) + SuffixAmbiguity + (1|Subject) +(1|TrialNumber), data=dat)
summary (lmer.dat2)

lmer.dat3 <- lmer(RT ~ poly(TrialOrder,2) + nlen.z + SuffixAmbiguity + (1|Subject) +(1|TrialNumber), data=dat)
summary (lmer.dat3)

lmer.dat4 <- lmer(RT ~ poly(TrialOrder,2) + nlen.z + flem.z + SuffixAmbiguity + (1|Subject) +(1|TrialNumber), data=dat)
summary (lmer.dat4)

lmer.dat5 <- lmer(RT ~ poly(TrialOrder,2) + nlen.z + sprod.z + flem.z + SuffixAmbiguity + (1|Subject) + (1|TrialNumber), data=dat)
summary (lmer.dat5)

# I will check the interactions between predictors.
lmer.dat6 <- lmer(RT ~ poly(TrialOrder,2) + nlen.z + flem.z + sprod.z*SuffixAmbiguity + (1|Subject) + (1|TrialNumber), data=dat)
summary (lmer.dat6)

#Fixed effects:
#                                     Estimate Std. Error         df t value
#(Intercept)                        -1.411e+00  3.384e-02  7.320e+01 -41.685
#poly(TrialOrder, 2)1               -1.524e-01  2.619e-01  1.537e+03  -0.582
#poly(TrialOrder, 2)2                7.280e-01  2.622e-01  1.541e+03   2.776
#nlen.z                              4.218e-02  1.229e-02  6.640e+01   3.432
#flem.z                             -9.830e-02  1.342e-02  6.680e+01  -7.326
#sprod.z                            -2.225e-03  4.576e-02  6.400e+01  -0.049
#SuffixAmbiguityunambiguous         -4.932e-03  2.737e-02  6.530e+01  -0.180
#sprod.z:SuffixAmbiguityunambiguous  1.354e-02  4.781e-02  6.400e+01   0.283
#                                   Pr(>|t|)    
#(Intercept)                         < 2e-16 ***
#poly(TrialOrder, 2)1                0.56066    
#poly(TrialOrder, 2)2                0.00557 ** 
#nlen.z                              0.00104 ** 
#flem.z                             3.99e-10 ***
#sprod.z                             0.96137    
#SuffixAmbiguityunambiguous          0.85757    
#sprod.z:SuffixAmbiguityunambiguous  0.77792

lmer.dat5.a=update(lmer.dat5, REML=FALSE)
lmer.dat6.a=update(lmer.dat6, REML=FALSE)

anova(lmer.dat5.a,lmer.dat6.a)

#lmer.dat5.a: RT ~ poly(TrialOrder, 2) + nlen.z + sprod.z + flem.z + SuffixAmbiguity + 
#lmer.dat5.a:     (1 | Subject) + (1 | TrialNumber)
#lmer.dat6.a: RT ~ poly(TrialOrder, 2) + nlen.z + flem.z + sprod.z * SuffixAmbiguity + 
#lmer.dat6.a:     (1 | Subject) + (1 | TrialNumber)
#            Df    AIC    BIC  logLik deviance  Chisq Chi Df Pr(>Chisq)
#lmer.dat5.a 10 451.12 505.11 -215.56   431.12                         
#lmer.dat6.a 11 453.04 512.42 -215.52   431.04 0.0877      1     0.7672

# Note: the first model is better.

# ------
# I will check the interactions between some other predictors.
lmer.dat6 <- lmer(RT ~ poly(TrialOrder,2) + nlen.z + sprod.z + flem.z*SuffixAmbiguity + (1|Subject) + (1|TrialNumber), data=dat)
summary (lmer.dat6)

#Fixed effects:
#                                    Estimate Std. Error         df t value
#(Intercept)                       -1.408e+00  3.329e-02  7.000e+01 -42.299
#poly(TrialOrder, 2)1              -1.563e-01  2.619e-01  1.537e+03  -0.597
#poly(TrialOrder, 2)2               7.292e-01  2.622e-01  1.542e+03   2.781
#nlen.z                             4.079e-02  1.226e-02  6.630e+01   3.328
#sprod.z                            6.449e-03  1.331e-02  6.520e+01   0.484
#flem.z                            -1.118e-01  1.955e-02  6.810e+01  -5.720
#SuffixAmbiguityunambiguous        -2.591e-03  2.634e-02  6.560e+01  -0.098
#flem.z:SuffixAmbiguityunambiguous  2.624e-02  2.700e-02  6.710e+01   0.972
#                                  Pr(>|t|)    
#(Intercept)                        < 2e-16 ***
#poly(TrialOrder, 2)1               0.55059    
#poly(TrialOrder, 2)2               0.00548 ** 
#nlen.z                             0.00143 ** 
#sprod.z                            0.62966    
#flem.z                            2.59e-07 ***
#SuffixAmbiguityunambiguous         0.92196    
#flem.z:SuffixAmbiguityunambiguous  0.33462 

lmer.dat5.a=update(lmer.dat5, REML=FALSE)
lmer.dat6.a=update(lmer.dat6, REML=FALSE)

anova(lmer.dat5.a,lmer.dat6.a)

#lmer.dat5.a: RT ~ poly(TrialOrder, 2) + nlen.z + sprod.z + flem.z + SuffixAmbiguity + 
#lmer.dat5.a:     (1 | Subject) + (1 | TrialNumber)
#lmer.dat6.a: RT ~ poly(TrialOrder, 2) + nlen.z + sprod.z + flem.z * SuffixAmbiguity + 
#lmer.dat6.a:     (1 | Subject) + (1 | TrialNumber)
#            Df    AIC    BIC  logLik deviance  Chisq Chi Df Pr(>Chisq)
#lmer.dat5.a 10 451.12 505.11 -215.56   431.12                         
#lmer.dat6.a 11 452.11 511.49 -215.06   430.11 1.0101      1     0.3149

# Note: the first model is better, again.

# ------
# I will check the interactions between some other predictors, again.
lmer.dat6 <- lmer(RT ~ poly(TrialOrder,2) + sprod.z + flem.z + nlen.z*SuffixAmbiguity + (1|Subject) + (1|TrialNumber), data=dat)
summary (lmer.dat6)

#Fixed effects:
#                                    Estimate Std. Error         df t value
#(Intercept)                       -1.415e+00  3.306e-02  6.870e+01 -42.791
#poly(TrialOrder, 2)1              -1.463e-01  2.619e-01  1.536e+03  -0.559
#poly(TrialOrder, 2)2               7.273e-01  2.622e-01  1.541e+03   2.774
#sprod.z                            9.886e-03  1.277e-02  6.550e+01   0.774
#flem.z                            -9.927e-02  1.337e-02  6.700e+01  -7.423
#nlen.z                             2.940e-02  1.978e-02  6.510e+01   1.486
#SuffixAmbiguityunambiguous        -3.578e-03  2.641e-02  6.570e+01  -0.136
#nlen.z:SuffixAmbiguityunambiguous  2.138e-02  2.525e-02  6.600e+01   0.847
#                                  Pr(>|t|)    
#(Intercept)                        < 2e-16 ***
#poly(TrialOrder, 2)1               0.57654    
#poly(TrialOrder, 2)2               0.00561 ** 
#sprod.z                            0.44151    
#flem.z                            2.64e-10 ***
#nlen.z                             0.14205    
#SuffixAmbiguityunambiguous         0.89262    
#nlen.z:SuffixAmbiguityunambiguous  0.40018 

lmer.dat5.a=update(lmer.dat5, REML=FALSE)
lmer.dat6.a=update(lmer.dat6, REML=FALSE)

anova(lmer.dat5.a,lmer.dat6.a)

#lmer.dat5.a: RT ~ poly(TrialOrder, 2) + nlen.z + sprod.z + flem.z + SuffixAmbiguity + 
#lmer.dat5.a:     (1 | Subject) + (1 | TrialNumber)
#lmer.dat6.a: RT ~ poly(TrialOrder, 2) + sprod.z + flem.z + nlen.z * SuffixAmbiguity + 
#lmer.dat6.a:     (1 | Subject) + (1 | TrialNumber)
#            Df    AIC    BIC  logLik deviance  Chisq Chi Df Pr(>Chisq)
#lmer.dat5.a 10 451.12 505.11 -215.56   431.12                         
#lmer.dat6.a 11 452.36 511.74 -215.18   430.36 0.7659      1     0.3815

# Note: the first model is better, again.

# ------
# And again ...
lmer.dat6 <- lmer(RT ~ poly(TrialOrder,2) + nlen.z*sprod.z + flem.z + SuffixAmbiguity + (1|Subject) + (1|TrialNumber), data=dat)
summary (lmer.dat6)

#Fixed effects:
#                             Estimate Std. Error         df t value Pr(>|t|)
#(Intercept)                -1.419e+00  3.315e-02  6.930e+01 -42.794  < 2e-16
#poly(TrialOrder, 2)1       -1.469e-01  2.618e-01  1.537e+03  -0.561  0.57495
#poly(TrialOrder, 2)2        7.281e-01  2.622e-01  1.542e+03   2.777  0.00555
#nlen.z                      3.637e-02  1.277e-02  6.590e+01   2.847  0.00588
#sprod.z                     3.431e-02  2.087e-02  6.540e+01   1.644  0.10493
#flem.z                     -1.026e-01  1.355e-02  6.750e+01  -7.574 1.36e-10
#SuffixAmbiguityunambiguous  8.599e-03  2.733e-02  6.550e+01   0.315  0.75406
#nlen.z:sprod.z             -2.677e-02  1.844e-02  6.520e+01  -1.452  0.15140
#                              
#(Intercept)                ***
#poly(TrialOrder, 2)1          
#poly(TrialOrder, 2)2       ** 
#nlen.z                     ** 
#sprod.z                       
#flem.z                     ***
#SuffixAmbiguityunambiguous    
#nlen.z:sprod.z              

lmer.dat5.a=update(lmer.dat5, REML=FALSE)
lmer.dat6.a=update(lmer.dat6, REML=FALSE)

anova(lmer.dat5.a,lmer.dat6.a)

#lmer.dat5.a: RT ~ poly(TrialOrder, 2) + nlen.z + sprod.z + flem.z + SuffixAmbiguity + 
#lmer.dat5.a:     (1 | Subject) + (1 | TrialNumber)
#lmer.dat6.a: RT ~ poly(TrialOrder, 2) + nlen.z * sprod.z + flem.z + SuffixAmbiguity + 
#lmer.dat6.a:     (1 | Subject) + (1 | TrialNumber)
#            Df    AIC    BIC  logLik deviance  Chisq Chi Df Pr(>Chisq)
#lmer.dat5.a 10 451.12 505.11 -215.56   431.12                         
#lmer.dat6.a 11 450.89 510.27 -214.45   428.89 2.2315      1     0.1352

# Note: the second model is a bit better, but having in mind that this interaction is not stat.sig. we will continue with model 5. 

# ------
# I will check the interactions between some other predictors.
lmer.dat7 <- lmer(RT ~ poly(TrialOrder,2) + nlen.z*flem.z + sprod.z + SuffixAmbiguity + (1|Subject) + (1|TrialNumber), data=dat)
summary (lmer.dat7)

#Fixed effects:
#                             Estimate Std. Error         df t value Pr(>|t|)
#(Intercept)                -1.414e+00  3.310e-02  6.890e+01 -42.718  < 2e-16
#poly(TrialOrder, 2)1       -1.491e-01  2.619e-01  1.536e+03  -0.569  0.56927
#poly(TrialOrder, 2)2        7.286e-01  2.622e-01  1.541e+03   2.779  0.00553
#nlen.z                      4.032e-02  1.301e-02  6.500e+01   3.100  0.00286
#flem.z                     -9.859e-02  1.339e-02  6.690e+01  -7.365 3.37e-10
#sprod.z                     1.101e-02  1.290e-02  6.530e+01   0.854  0.39644
#SuffixAmbiguityunambiguous -5.816e-04  2.691e-02  6.550e+01  -0.022  0.98282
#nlen.z:flem.z              -6.775e-03  1.346e-02  6.760e+01  -0.503  0.61649
#                              
#(Intercept)                ***
#poly(TrialOrder, 2)1          
#poly(TrialOrder, 2)2       ** 
#nlen.z                     ** 
#flem.z                     ***
#sprod.z                       
#SuffixAmbiguityunambiguous    
#nlen.z:flem.z          

lmer.dat5.a=update(lmer.dat5, REML=FALSE)
lmer.dat7.a=update(lmer.dat7, REML=FALSE)

anova(lmer.dat5.a,lmer.dat7.a)

#lmer.dat5.a: RT ~ poly(TrialOrder, 2) + nlen.z + sprod.z + flem.z + SuffixAmbiguity + 
#lmer.dat5.a:     (1 | Subject) + (1 | TrialNumber)
#lmer.dat7.a: RT ~ poly(TrialOrder, 2) + nlen.z * flem.z + sprod.z + SuffixAmbiguity + 
#lmer.dat7.a:     (1 | Subject) + (1 | TrialNumber)
#            Df    AIC    BIC  logLik deviance  Chisq Chi Df Pr(>Chisq)
#lmer.dat5.a 10 451.12 505.11 -215.56   431.12                         
#lmer.dat7.a 11 452.85 512.23 -215.43   430.85 0.2735      1      0.601

# Note: the first model is better. 

# Final note: lmer5 is the best model so far, but we will name it lmer6.

# ----

lmer.dat6 <- lmer(RT ~ poly(TrialOrder,2) + nlen.z + sprod.z + flem.z + SuffixAmbiguity + (1|Subject) + (1|TrialNumber), data=dat)
summary (lmer.dat6)

#Random effects:
# Groups      Name        Variance Std.Dev.
# TrialNumber (Intercept) 0.007438 0.08624 
# Subject     (Intercept) 0.037281 0.19308 
# Residual                0.066547 0.25797 
#Number of obs: 1633, groups:  TrialNumber, 74; Subject, 46
#
#Fixed effects:
#                             Estimate Std. Error         df t value Pr(>|t|)
#(Intercept)                -1.413e+00  3.296e-02  6.810e+01 -42.858  < 2e-16
#poly(TrialOrder, 2)1       -1.520e-01  2.618e-01  1.538e+03  -0.581 0.561644
#poly(TrialOrder, 2)2        7.289e-01  2.622e-01  1.542e+03   2.780 0.005507
#nlen.z                      4.263e-02  1.211e-02  6.720e+01   3.521 0.000776
#sprod.z                     1.021e-02  1.273e-02  6.640e+01   0.802 0.425323
#flem.z                     -9.784e-02  1.323e-02  6.790e+01  -7.393 2.79e-10
#SuffixAmbiguityunambiguous -2.994e-03  2.633e-02  6.660e+01  -0.114 0.909798
#                              
#(Intercept)                ***
#poly(TrialOrder, 2)1          
#poly(TrialOrder, 2)2       ** 
#nlen.z                     ***
#sprod.z                       
#flem.z                     ***
#SuffixAmbiguityunambiguous    

# -------------------------------------------------
############################# Is it better with POLY function?

lmer.dat7 <- lmer(RT ~ poly(TrialOrder,2) + poly(nlen, 2)+ sprod.z + flem.z + SuffixAmbiguity + (1|Subject) +(1|TrialNumber), data=dat)
summary (lmer.dat7)

lmer.dat6.a=update(lmer.dat6, REML=FALSE)
lmer.dat7.a=update(lmer.dat7, REML=FALSE)

anova(lmer.dat6.a,lmer.dat7.a)

# Better without poly.

lmer.dat7 <- lmer(RT ~ poly(TrialOrder,2) + nlen.z + poly(sprod, 2) + flem.z + SuffixAmbiguity + (1|Subject) +(1|TrialNumber), data=dat)
summary (lmer.dat7)

lmer.dat6.a=update(lmer.dat6, REML=FALSE)
lmer.dat7.a=update(lmer.dat7, REML=FALSE)

anova(lmer.dat6.a,lmer.dat7.a)

# Better without poly.

lmer.dat7 <- lmer(RT ~ poly(TrialOrder,2) + nlen.z + sprod.z + poly(flem, 2) + SuffixAmbiguity + (1|Subject) +(1|TrialNumber), data=dat)
summary (lmer.dat7)

lmer.dat6.a=update(lmer.dat6, REML=FALSE)
lmer.dat7.a=update(lmer.dat7, REML=FALSE)

anova(lmer.dat6.a,lmer.dat7.a)

# Parameters are not consistent, so we will continue without poly, because we know that we have outlier value in LemmaFrequency, which deviate destiribution.

# -----------------------------------------------
# ---------------------------
################## Best LMER model so far (with -nje suffix)!

lmer.dat6 <- lmer(RT ~ poly(TrialOrder,2) + nlen.z + sprod.z + flem.z + SuffixAmbiguity + (1|Subject) + (1|TrialNumber), data=dat)
summary (lmer.dat6)

#Random effects:
# Groups      Name        Variance Std.Dev.
# TrialNumber (Intercept) 0.007438 0.08624 
# Subject     (Intercept) 0.037281 0.19308 
# Residual                0.066547 0.25797 
#Number of obs: 1633, groups:  TrialNumber, 74; Subject, 46
#
#Fixed effects:
#                             Estimate Std. Error         df t value Pr(>|t|)
#(Intercept)                -1.413e+00  3.296e-02  6.810e+01 -42.858  < 2e-16
#poly(TrialOrder, 2)1       -1.520e-01  2.618e-01  1.538e+03  -0.581 0.561644
#poly(TrialOrder, 2)2        7.289e-01  2.622e-01  1.542e+03   2.780 0.005507
#nlen.z                      4.263e-02  1.211e-02  6.720e+01   3.521 0.000776
#sprod.z                     1.021e-02  1.273e-02  6.640e+01   0.802 0.425323
#flem.z                     -9.784e-02  1.323e-02  6.790e+01  -7.393 2.79e-10
#SuffixAmbiguityunambiguous -2.994e-03  2.633e-02  6.660e+01  -0.114 0.909798
#                              
#(Intercept)                ***
#poly(TrialOrder, 2)1          
#poly(TrialOrder, 2)2       ** 
#nlen.z                     ***
#sprod.z                       
#flem.z                     ***
#SuffixAmbiguityunambiguous 
  
#--------------------------

#################### By-participant random slope adjustments.

lmer.dat8 <- lmer(RT ~ poly(TrialOrder,2) + nlen.z + sprod.z + flem.z + SuffixAmbiguity + (1|Subject) + (0+poly(TrialOrder, 2)|Subject) + (1|TrialNumber), data=dat)
summary (lmer.dat8)

lmer.dat6.a=update(lmer.dat6, REML=FALSE)
lmer.dat8.a=update(lmer.dat8, REML=FALSE)

anova(lmer.dat6.a,lmer.dat8.a)

# Better with.

# --------------------------

lmer.dat8 <- lmer(RT ~ poly(TrialOrder,2) + nlen.z + sprod.z + flem.z + SuffixAmbiguity + (1|Subject) + (0+nlen.z|Subject) + (1|TrialNumber), data=dat)
summary (lmer.dat8)

lmer.dat6.a=update(lmer.dat6, REML=FALSE)
lmer.dat8.a=update(lmer.dat8, REML=FALSE)

anova(lmer.dat6.a,lmer.dat8.a)

# Better with.

# --------------------------

lmer.dat8 <- lmer(RT ~ poly(TrialOrder,2) + nlen.z + sprod.z + flem.z + SuffixAmbiguity + (1|Subject) + (0+nlen.z+poly(TrialOrder, 2)|Subject) + (1|TrialNumber), data=dat)
summary (lmer.dat8)

lmer.dat6.a=update(lmer.dat6, REML=FALSE)
lmer.dat8.a=update(lmer.dat8, REML=FALSE)

anova(lmer.dat6.a,lmer.dat8.a)

# Definitely, better with this two slope adjustments.

# ------------------------

lmer.dat8 <- lmer(RT ~ poly(TrialOrder,2) + nlen.z + sprod.z + flem.z + SuffixAmbiguity + (1|Subject) + (0+sprod.z|Subject) + (1|TrialNumber), data=dat)
summary (lmer.dat8)

lmer.dat6.a=update(lmer.dat6, REML=FALSE)
lmer.dat8.a=update(lmer.dat8, REML=FALSE)

anova(lmer.dat6.a,lmer.dat8.a)

# Better without.

# ------------------------

lmer.dat8 <- lmer(RT ~ poly(TrialOrder,2) + nlen.z + sprod.z + flem.z + SuffixAmbiguity + (1|Subject) + (0+flem.z|Subject) + (1|TrialNumber), data=dat)
summary (lmer.dat8)

lmer.dat6.a=update(lmer.dat6, REML=FALSE)
lmer.dat8.a=update(lmer.dat8, REML=FALSE)

anova(lmer.dat6.a,lmer.dat8.a)

# Better without.

# ----------------------------
# ---------------------------------------------
# ---------------------------------------------------------

#################### By-stimulus random slope adjustments.

lmer.dat8 <- lmer(RT ~ poly(TrialOrder,2) + nlen.z + sprod.z + flem.z + SuffixAmbiguity + (1|Subject) + (0+poly(TrialOrder, 2)|TrialNumber) + (1|TrialNumber), data=dat)
summary (lmer.dat8)

lmer.dat6.a=update(lmer.dat6, REML=FALSE)
lmer.dat8.a=update(lmer.dat8, REML=FALSE)

anova(lmer.dat6.a,lmer.dat8.a)

# Better without.

# --------------------------

lmer.dat8 <- lmer(RT ~ poly(TrialOrder,2) + nlen.z + sprod.z + flem.z + SuffixAmbiguity + (1|Subject) + (0+nlen.z|TrialNumber) + (1|TrialNumber), data=dat)
summary (lmer.dat8)

lmer.dat6.a=update(lmer.dat6, REML=FALSE)
lmer.dat8.a=update(lmer.dat8, REML=FALSE)

anova(lmer.dat6.a,lmer.dat8.a)

# Better without.

# ------------------------

lmer.dat8 <- lmer(RT ~ poly(TrialOrder,2) + nlen.z + sprod.z + flem.z + SuffixAmbiguity + (1|Subject) + (0+sprod.z|TrialNumber) + (1|TrialNumber), data=dat)
summary (lmer.dat8)

lmer.dat6.a=update(lmer.dat6, REML=FALSE)
lmer.dat8.a=update(lmer.dat8, REML=FALSE)

anova(lmer.dat6.a,lmer.dat8.a)

# Better without.

# ------------------------

lmer.dat8 <- lmer(RT ~ poly(TrialOrder,2) + nlen.z + sprod.z + flem.z + SuffixAmbiguity + (1|Subject) + (0+flem.z|TrialNumber) + (1|TrialNumber), data=dat)
summary (lmer.dat8)

lmer.dat6.a=update(lmer.dat6, REML=FALSE)
lmer.dat8.a=update(lmer.dat8, REML=FALSE)

anova(lmer.dat6.a,lmer.dat8.a)

# Better without.

---------

########################## LMER MODEL #######
################### WITH -NJE #################

lmer.dat8 <- lmer(RT ~ poly(TrialOrder,2) + nlen.z + sprod.z + flem.z + SuffixAmbiguity + (1|Subject) + (0+nlen.z+poly(TrialOrder, 2)|Subject) + (1|TrialNumber), data=dat)
summary (lmer.dat8)

# ----------------------------

#Random effects:
# Groups      Name                 Variance Std.Dev. Corr       
# TrialNumber (Intercept)          0.007532 0.08679             
# Subject     nlen.z               0.001500 0.03873             
#             poly(TrialOrder, 2)1 2.508114 1.58370  -0.31      
#             poly(TrialOrder, 2)2 1.245162 1.11587   0.17  0.18
# Subject.1   (Intercept)          0.037734 0.19425             
# Residual                         0.062686 0.25037             
#Number of obs: 1633, groups:  TrialNumber, 74; Subject, 46
#
#Fixed effects:
#                            Estimate Std. Error        df t value Pr(>|t|)    
#(Intercept)                -1.412100   0.033092 67.990000 -42.672  < 2e-16 ***
#poly(TrialOrder, 2)1       -0.214347   0.347102 42.830000  -0.618  0.54015    
#poly(TrialOrder, 2)2        0.724928   0.305401 42.500000   2.374  0.02220 *  
#nlen.z                      0.043223   0.013377 73.090000   3.231  0.00185 ** 
#sprod.z                     0.010498   0.012721 66.210000   0.825  0.41220    
#flem.z                     -0.096995   0.013230 67.770000  -7.332 3.63e-10 ***
#SuffixAmbiguityunambiguous -0.002594   0.026301 66.290000  -0.099  0.92174    

# ---------------------
# ---------------------------

# I will check interaction between the random segment and random slope adjustments of the predictors NounLength and TrialOrder for different Subjects.
lmer.dat9 <- lmer(RT ~ poly(TrialOrder,2) + nlen.z + sprod.z + flem.z + SuffixAmbiguity + (1|Subject) + (1+nlen.z+poly(TrialOrder, 2)|Subject) + (1|TrialNumber), data=dat)
summary (lmer.dat9)

#Random effects:
# Groups      Name                 Variance Std.Dev. Corr             
# TrialNumber (Intercept)          0.007529 0.08677                   
# Subject     (Intercept)          0.028441 0.16864                   
#             nlen.z               0.001519 0.03897   0.55            
#             poly(TrialOrder, 2)1 2.489876 1.57793  -0.07 -0.28      
#             poly(TrialOrder, 2)2 1.208605 1.09937  -0.59  0.21  0.20
# Subject.1   (Intercept)          0.008881 0.09424                   
# Residual                         0.062733 0.25047                   
#Number of obs: 1633, groups:  TrialNumber, 74; Subject, 46
#
#Fixed effects:
#                            Estimate Std. Error        df t value Pr(>|t|)    
#(Intercept)                -1.412369   0.032954 68.210000 -42.859  < 2e-16 ***
#poly(TrialOrder, 2)1       -0.214985   0.346210 42.820000  -0.621  0.53791    
#poly(TrialOrder, 2)2        0.714080   0.303623 42.590000   2.352  0.02338 *  
#nlen.z                      0.042685   0.013388 73.130000   3.188  0.00211 ** 
#sprod.z                     0.010277   0.012718 66.190000   0.808  0.42196    
#flem.z                     -0.096673   0.013224 67.750000  -7.311 3.97e-10 ***
#SuffixAmbiguityunambiguous -0.003022   0.026289 66.290000  -0.115  0.90883 

lmer.dat8.a=update(lmer.dat8, REML=FALSE)
lmer.dat9.a=update(lmer.dat9, REML=FALSE)

anova(lmer.dat8.a,lmer.dat9.a)

# The first model is better, and it is much more interpretable.

-------

# How much does any individual (in this model) differ from the population?
ranef(lmer.dat8)$Subject

#          nlen.z poly(TrialOrder, 2)1 poly(TrialOrder, 2)2  (Intercept)
#s1  -0.008349068          -1.23931557          -0.90258524 -0.147470518
#s10 -0.020349698           2.28228447          -0.26370428  0.060334962
#s11  0.051095135          -1.60692862          -0.65208873  0.239389342
#s12  0.009089373          -0.02992297           0.36758901 -0.024107158
#s13 -0.014194896           0.96871251          -0.01668803  0.019248008
#s14  0.028832337           0.50299200           1.22375735 -0.156918601
#s15  0.009620936           0.12254840           1.16235388 -0.126590599
#s16  0.001663126           0.86161905           0.12303673  0.376986435
#s17 -0.008026025          -0.35866503          -1.09372812  0.225534193
#s18  0.030058739          -2.27399266          -0.17143983 -0.051613427
#s19  0.006535470           0.46548866           0.27432788 -0.074039630
#s2  -0.020469050           1.32831998           0.64156340 -0.171476532
#s20 -0.002431822           0.20461328           0.15644970 -0.114955506
#s21  0.022102737          -0.22836611           0.51421749  0.240151320
#s22  0.015189017           0.82737807           0.92260458  0.042669350
#s23  0.025960903           0.83058538          -0.33854686  0.197506919
#s24 -0.036348129           1.07401891          -0.21847953 -0.077526740
#s25  0.003153644          -0.64925902          -1.29872639  0.289691440
#s26 -0.030599501           0.37208887           0.16343146 -0.063659393
#s27 -0.037279726          -0.93925331          -0.71454536  0.033994274
#s28 -0.025204563           0.30665836          -0.24542593 -0.058498645
#s29 -0.015023860           0.27499463           0.22962442 -0.194522922
#s3  -0.037485295           1.78089932          -0.39638672 -0.161117213
#s30 -0.051898168           1.88552891          -0.93475105 -0.146275083
#s31  0.015869008           0.20426361          -0.42038631  0.112943448
#s32  0.037643354          -1.57871154          -0.54936440 -0.233372395
#s33 -0.008675279           1.32213880           0.14228867 -0.112345136
#s34  0.014617764          -1.16239076          -0.37646228  0.121908128
#s35  0.020842935          -0.04570168           0.22736035 -0.005005022
#s36  0.009945865           0.03496979          -0.17536166  0.161319575
#s37  0.016604860          -0.73938313           0.37680924  0.124764767
#s38  0.001094978           0.39655545           0.42180335 -0.115741109
#s39  0.012278878           0.80089000           0.70629314  0.227059546
#s4  -0.008940779           0.80650942          -0.46353036 -0.071929332
#s40  0.056775094          -3.17476351          -0.38057783  0.376615391
#s41  0.043231916           0.79051548           0.86952913 -0.052889443
#s42 -0.042525312           0.26397311          -0.39624815  0.278707520
#s43  0.004615099          -0.39469356           0.71103777 -0.098868856
#s44 -0.027864993           0.19377330           0.25608210 -0.241775781
#s45  0.040427580          -0.39268803           0.98753803 -0.230457139
#s46 -0.011000911           0.04225556           0.45560768  0.456689321
#s5  -0.002307634          -1.17091401          -0.98767032 -0.211727097
#s6  -0.052531088          -0.79786216           0.01008009 -0.292924276
#s7   0.008268662          -0.50862942          -0.22309294  0.038790724
#s8  -0.015074557          -1.44447005          -0.51003287 -0.178027452
#s9  -0.008937057          -0.20866416           0.78643776 -0.210469661

# -------------
# -----------------------

# I will call this "fake bootstrapping", because I have a small amount of data, and it is not posible to do a real bootstrapping.
confint(lmer.dat8)

                                 2.5 %      97.5 %
#.sig01                      0.06531539  0.10517880
#.sig02                      0.02027102  0.05727791
#.sig03                     -0.84718371  0.33720160
#.sig04                     -0.81620329  0.91135121
#.sig05                      0.79258022  2.33471692
#.sig06                     -0.80653218  0.91637197
#.sig07                      0.18815835  1.87360413
#.sig08                      0.15682282  0.24157824
#.sigma                      0.24134678  0.26006784
#(Intercept)                -1.47698406 -1.34736731
#poly(TrialOrder, 2)1       -0.90741507  0.46993381
#poly(TrialOrder, 2)2        0.11876219  1.33118558
#nlen.z                      0.01733496  0.06910789
#sprod.z                    -0.01404910  0.03507818
#flem.z                     -0.12260852 -0.07149050
#SuffixAmbiguityunambiguous -0.05341506  0.04817037

par(mfrow=c(2,3))
plot(fitted(lmer.dat8),residuals(lmer.dat8))
plot(fitted(lmer.dat8),scale(residuals(lmer.dat8)))
qqnorm(residuals(lmer.dat8), main=" ")
qqline(residuals(lmer.dat8))
par(mfrow=c(1,1))

b1=bootMer(lmer.dat8, FUN = function(x) as.numeric(logLik(x)), nsim = 100)

head(as.data.frame(b1))

#        V1
#1 -228.4669
#2 -243.8528
#3 -230.7973
#4 -253.1006
#5 -216.7248
#6 -219.8914

plot(b1$t)

# -------------
# ------------------------

# Model criticism (Baayen & Milin, 2010; Baayen, 2008).

dat$SuffixAmbiguity <- relevel(dat$SuffixAmbiguity, ref = "unambiguous")

lmer.dat8 <- lmer(RT ~ poly(TrialOrder,2) + nlen.z + sprod.z + flem.z + SuffixAmbiguity + (1|Subject) + (0+nlen.z+poly(TrialOrder, 2)|Subject) + (1|TrialNumber), data=dat)
summary (lmer.dat8)

lmer.dat8.a <- lmer(RT ~ poly(TrialOrder,2) + nlen.z + sprod.z + flem.z + SuffixAmbiguity + (1|Subject) + (0+nlen.z+poly(TrialOrder, 2)|Subject) + (1|TrialNumber), data=dat, subset=abs(scale(resid(lmer.dat8)))<2.5)
summary (lmer.dat8.a)

#Random effects:
# Groups      Name                 Variance Std.Dev. Corr       
# TrialNumber (Intercept)          0.008013 0.08951             
# Subject     nlen.z               0.001966 0.04434             
#             poly(TrialOrder, 2)1 2.683477 1.63813  -0.38      
#             poly(TrialOrder, 2)2 0.990665 0.99532   0.25  0.18
# Subject.1   (Intercept)          0.037935 0.19477             
# Residual                         0.056044 0.23674             
#Number of obs: 1614, groups:  TrialNumber, 74; Subject, 46
#
#Fixed effects:
#                          Estimate Std. Error        df t value Pr(>|t|)    
#(Intercept)              -1.419178   0.034501 76.390000 -41.134  < 2e-16 ***
#poly(TrialOrder, 2)1     -0.326458   0.344602 43.680000  -0.947  0.34867    
#poly(TrialOrder, 2)2      0.565406   0.286635 42.960000   1.973  0.05500 .  
#nlen.z                    0.043252   0.013845 77.810000   3.124  0.00251 ** 
#sprod.z                   0.004897   0.012859 66.330000   0.381  0.70456    
#flem.z                   -0.098061   0.013347 67.380000  -7.347 3.51e-10 ***
#SuffixAmbiguityambiguous  0.003385   0.026560 66.130000   0.127  0.89897    

# ------------------
# ------------------------------------
################# Same model, but without -nje suffix (outlier) #######################

dat1=dat[dat$SuffixFrequency<10000,]

dat1$SuffixAmbiguity <- relevel(dat1$SuffixAmbiguity, ref = "unambiguous")

lmer.dat8 <- lmer(RT ~ poly(TrialOrder,2) + nlen.z + sprod.z + flem.z + SuffixAmbiguity + (1|Subject) + (0+nlen.z+poly(TrialOrder, 2)|Subject) + (1|TrialNumber), data=dat)
summary (lmer.dat8)

lmer.dat8.a <- lmer(RT ~ poly(TrialOrder,2) + nlen.z + sprod.z + flem.z + SuffixAmbiguity + (1|Subject) + (0+nlen.z+poly(TrialOrder, 2)|Subject) + (1|TrialNumber), data=dat, subset=abs(scale(resid(lmer.dat8)))<2.5)
summary (lmer.dat8.a)

#Random effects:
# Groups      Name                 Variance Std.Dev. Corr       
# TrialNumber (Intercept)          0.008013 0.08951             
# Subject     nlen.z               0.001966 0.04434             
#             poly(TrialOrder, 2)1 2.683477 1.63813  -0.38      
#             poly(TrialOrder, 2)2 0.990665 0.99532   0.25  0.18
# Subject.1   (Intercept)          0.037935 0.19477             
# Residual                         0.056044 0.23674             
#Number of obs: 1614, groups:  TrialNumber, 74; Subject, 46
#
#Fixed effects:
#                          Estimate Std. Error        df t value Pr(>|t|)    
#(Intercept)              -1.419178   0.034501 76.390000 -41.134  < 2e-16 ***
#poly(TrialOrder, 2)1     -0.326458   0.344602 43.680000  -0.947  0.34867    
#poly(TrialOrder, 2)2      0.565406   0.286635 42.960000   1.973  0.05500 .  
#nlen.z                    0.043252   0.013845 77.810000   3.124  0.00251 ** 
#sprod.z                   0.004897   0.012859 66.330000   0.381  0.70456    
#flem.z                   -0.098061   0.013347 67.380000  -7.347 3.51e-10 ***
#SuffixAmbiguityambiguous  0.003385   0.026560 66.130000   0.127  0.89897 

# ------------------
# -------------------------------- VIZUALIZATION OF FINAL RESULTS!
# ------------------

g1<-ggplot(data=dat, aes(x=SuffixAmbiguity, y=RT)) + 
    geom_bar(stat="identity", fill="darkred", colour="darkred")
g1
           
# ------------
           
g2<-ggplot(data=dat, aes(x=nlen.z, y=RT)) + 
  geom_point(shape=18, color="gray")+
  geom_smooth(method=lm,  linetype="solid",
             color="darkred", fill="gray")
g2
           
# ------------
           
g3<-ggplot(data=dat, aes(x=flem.z, y=RT)) + 
  geom_point(shape=18, color="gray")+
  geom_smooth(method=lm,  linetype="solid",
             color="darkred", fill="gray")
g3
           
# ------------
           
g4<-ggplot(data=dat, aes(x=sprod.z, y=RT)) + 
  geom_point(shape=18, color="gray")+
  geom_smooth(method=lm,  linetype="solid",
             color="darkred", fill="gray")
g4

################## The end!
