

getwd()

library(plyr)
library(mice)
library(VIM)
library(ggplot2)
#read the  tr from the system
setwd("/Users/macuser/studioo")

tr<-read.csv("loan-prediction-dataset.csv" ,header = T)
head(tr)
summary(tr)
tr <- read.csv(file="loan-prediction-dataset.csv", na.strings=c("", "NA"), header=TRUE) # Convert blank fields to NA
#library(plyr)

sapply(tr, function(x) sum(is.na(x)))
# library(plyr)
# library(mice)
# library(VIM)
# library(ggplot2)
mice_plot <- aggr(tr, col=c('navyblue','red'),
                  numbers=TRUE, sortVars=TRUE,
                  labels=names(tr), cex.axis=.7,
                  gap=3, ylab=c("Missing data","Pattern"))


#Converting these data to factor
tr$Gender = factor(tr$Gender, levels = c('Female','Male'), labels = c(0,1))
tr$Married = factor(tr$Married, levels = c('Yes','No'), labels = c(0,1))
tr$Education = factor(tr$Education, levels = c('Graduate','Not Graduate'), labels = c(0,1))
tr$Self_Employed = factor(tr$Self_Employed, levels = c('No','Yes'), labels = c(0,1))
tr$Property_Area = factor(tr$Property_Area, levels = c('Rural','Semiurban', 'Urban'), labels = c(0,1,2))
tr$Dependents = factor(tr$Dependents, levels =  c('0','1','2','3+'), labels = c(0,1,2,3))
tr$Credit_History = factor(tr$Credit_History, levels = c("0","1"), labels = c(0,1))
tr$Loan_Status = factor(tr$Loan_Status, levels = c('N','Y'), labels = c(0,1))


par(mfrow=c(2,2))
hist(tr$LoanAmount, 
     main="Histogram for LoanAmount", 
     xlab="Loan Amount", 
     border="blue", 
     col="maroon",
     las=1, 
     breaks=20, prob = TRUE)
#lines(density(tr$LoanAmount), col='black', lwd=3)
boxplot(tr$LoanAmount, col='maroon',xlab = 'LoanAmount', main = 'Box Plot for Loan Amount')

hist(tr$ApplicantIncome, 
     main="Histogram for Applicant Income", 
     xlab="Income", 
     border="blue", 
     col="maroon",
     las=1, 
     breaks=50, prob = TRUE)
#lines(density(tr$ApplicantIncome), col='black', lwd=3)
boxplot(tr$ApplicantIncome, col='maroon',xlab = 'ApplicantIncome', main = 'Box Plot for Applicant Income')

library(ggplot2)
data(tr, package="lattice")
ggplot(data=tr, aes(x=LoanAmount, fill=Education)) +
  geom_density() +
  facet_grid(Education~.)


par(mfrow=c(2,3))
counts <- table(tr$Loan_Status, tr$Gender)
barplot(counts, main="Loan Status by Gender",
        xlab="Gender", col=c("darkgrey","maroon"),
        legend = rownames(counts))
counts2 <- table(tr$Loan_Status, tr$Education)
barplot(counts2, main="Loan Status by Education",
        xlab="Education", col=c("darkgrey","maroon"),
        legend = rownames(counts2))
counts3 <- table(tr$Loan_Status, tr$Married)
barplot(counts3, main="Loan Status by Married",
        xlab="Married", col=c("darkgrey","maroon"),
        legend = rownames(counts3))
counts4 <- table(tr$Loan_Status, tr$Self_Employed)
barplot(counts4, main="Loan Status by Self Employed",
        xlab="Self_Employed", col=c("darkgrey","maroon"),
        legend = rownames(counts4))
counts5 <- table(tr$Loan_Status, tr$Property_Area)
barplot(counts5, main="Loan Status by Property_Area",
        xlab="Property_Area", col=c("darkgrey","maroon"),
        legend = rownames(counts5))
counts6 <- table(tr$Loan_Status, tr$Credit_History)
barplot(counts6, main="Loan Status by Credit_History",
        xlab="Credit_History", col=c("darkgrey","maroon"),
        legend = rownames(counts5))

imputed_Data <- mice(tr, m=2, maxit = 2, method = 'cart', seed = 500)
tr <- complete(imputed_Data,2) #here I chose the second round of data imputation


sapply(tr, function(x) sum(is.na(x)))

tr$LogLoanAmount <- log(tr$LoanAmount)

par(mfrow=c(1,2))
hist(tr$LogLoanAmount, 
     main="Histogram for Loan Amount", 
     xlab="Loan Amount", 
     border="blue", 
     col="maroon",
     las=1, 
     breaks=20)
#lines(density(tr$LogLoanAmount), col='black', lwd=3)
boxplot(tr$LogLoanAmount, col='maroon',xlab = 'Income', main = 'Box Plot for Applicant Income')

tr$Income <- tr$ApplicantIncome + tr$CoapplicantIncome
tr$ApplicantIncome <- NULL
tr$CoapplicantIncome <- NULL

tr$LogIncome <- log(tr$Income)
par(mfrow=c(1,2))
hist(tr$LogIncome, 
     main="Histogram for Applicant Income", 
     xlab="Income", 
     border="blue", 
     col="maroon",
     las=1, 
     breaks=50, prob = TRUE)
lines(density(tr$LogIncome), col='black', lwd=3)
boxplot(tr$LogIncome, col='maroon',xlab = 'Income', main = 'Box Plot for Applicant Income')






set.seed(603)
sample <- sample.int(n = nrow(tr), size = floor(.70*nrow(tr)), replace = F)
#trainnew <- tr[sample, ]
#testnew  <- tr[-sample, ]



Mod1 <- glm (Loan_Status ~ Credit_History,data = trainnew, family = binomial)
summary(Mod1)

my_prediction_tr1 <- predict(logistic1, newdata = trainnew, type = "response")
table(trainnew$Loan_Status, my_prediction_tr1 > 0.5)

logistic_test1 <- glm (Loan_Status ~ Credit_History,data = testnew, family = binomial)
summary(logistic_test1)
my_prediction_te1 <- predict(logistic_test1, newdata = testnew, type = "response")
table(testnew$Loan_Status, my_prediction_te1 > 0.5)


##knc
logistic2 <- glm (Loan_Status ~ Credit_History+Education+Self_Employed+Property_Area+LogLoanAmount+
                    LogIncome,data = tr, family = binomial)
summary(logistic2)
my_prediction_tr2 <- predict(logistic2, newdata = trainnew, type = "response")
table(trainnew$Loan_Status, my_prediction_tr2 > 0.5)


logistic_test2 <- glm (Loan_Status ~ Credit_History+Education+Self_Employed+Property_Area+LogLoanAmount+
                         LogIncome,data = testnew, family = binomial)
  
summary(logistic_test2)


help(glm)
# 
# ###
# # grow tree
 library(rpart.plot)
 
 dtree <- rpart(Loan_Status ~ Credit_History+Education+Self_Employed+Property_Area+LogLoanAmount+
                  LogIncome,method="class", data=trainnew,parms=list(split="information"))
 dtree$cptable
 plotcp(dtree)
 dtree.pruned <- prune(dtree, cp=.02290076)
 prp(dtree.pruned, type = 2, extra = 104,
     fallen.leaves = TRUE, main="Decision Tree")
 dtree.pred <- predict(dtree.pruned, trainnew, type="class")
 dtree.perf <- table(trainnew$Loan_Status, dtree.pred,
                     dnn=c("Actual", "Predicted"))
 
 #accuracy
 dtree.perf

# 
# 
# 
# 
dtree_test <- rpart(Loan_Status ~ Credit_History+Education+Self_Employed+Property_Area+LogLoanAmount+
                       LogIncome,method="class", data=testnew,parms=list(split="information"))
 dtree_test$cptable
 plotcp(dtree_test)
 dtree_test.pruned <- prune(dtree_test, cp=.01639344)
 prp(dtree_test.pruned, type = 2, extra = 104,
   fallen.leaves = TRUE, main="Decision Tree")
dtree_test.pred <- predict(dtree_test.pruned, testnew, type="class")
 dtree_test.perf <- table(testnew$Loan_Status, dtree_test.pred,
                          dnn=c("Actual", "Predicted"))
 dtree_test.perf
# 
 summary(dtree_test)
# #forest
# rfNews()
# varImpPlot()
# library(randomForest) 
# set.seed(42) 
# fit.forest <- randomForest(Loan_Status ~ Credit_History+Education+Self_Employed+Property_Area+LogLoanAmount+
#                              LogIncome, data=trainnew,
#                            na.action=na.roughfix,
#                            importance=TRUE)
# fit.forest
# 
# importance(fit.forest, type=2)
# 
# forest.pred <- predict(fit.forest, testnew)
# forest.perf <- table(testnew$Loan_Status, forest.pred,
#                      dnn=c("Actual", "Predicted"))
# forest.perf
# 
# 
cor(tr)