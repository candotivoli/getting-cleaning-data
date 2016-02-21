
# Submission for Assignment: Getting and Cleaning Data Course Project
#
# From a style perspective I am going with the naming both variables and functions using lowerCamelCase
#
# main function is runAnalysis() which will return the tidy data set
#
library(dplyr)

runAnalysis <- function() {

    # download the zip file from the URL provided in the assignment and extract 
    dataUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(dataUrl, "dataset.zip", "curl")
    unzip("dataset.zip")
    
    # zip extract will create the below sub directory with all files in a file system beneath
    dataDir <- "UCI HAR Dataset"
    
    # Set up file paths relative to root directory
    
    xTestFile <- paste(dataDir, "/test/X_test.txt", sep="")
    xTrainFile <- paste(dataDir, "/train/X_train.txt", sep="")
    yTestFile <- paste(dataDir, "/test/Y_test.txt", sep="")
    yTrainFile <- paste(dataDir, "/train/Y_train.txt", sep="")
    subjectTrainFile <- paste(dataDir, "/train/subject_train.txt", sep="")
    subjectTestFile <- paste(dataDir, "/test/subject_test.txt", sep="")
    featureFile <- paste(dataDir, "/features.txt", sep="")
    activityFile <- paste(dataDir, "/activity_labels.txt", sep="")
    
    # load in x training and test set and concatenate using rbind. 
    # for all 3 data sets the test file is first and training second
    xTest <- read.table(xTestFile)
    xTrain <- read.table(xTrainFile)
    xAll <- rbind(xTest, xTrain)
    
    # load in y training and test set and concatenate using rbind and give friendly column name
    yTest <- read.table(yTestFile)
    yTrain <- read.table(yTrainFile)
    yAll <- rbind(yTest, yTrain)
    colnames(yAll) <- "activity"
    
    # load in subject training and test set and concatenate using rbind and give friendly column name
    subjectTest <- read.table(subjectTestFile)
    subjectTrain <- read.table(subjectTrainFile)
    subjectAll <- rbind(subjectTest, subjectTrain)
    colnames(subjectAll) <- "subject"
    
    # load feature list to get names of features and get indices of columns
    # containing mean() or std() using grep
    featureList <- read.table(featureFile)
    meanStdCols <- grep("(mean|std)\\(\\)", featureList[,2])
    
    # update column names of xAll to have full list and then filter down
    # based on the column indices found by grep above
    colnames(xAll) <- featureList[,2]
    xMeanStd <- xAll[,meanStdCols]
    
    # read activity mapping file
    activities <- read.table(activityFile)
    
    # define a function that, given an index will return the text version. Remove
    # underscores but leave in Caps (I think this is ok)
    # return as a factor
    getActivity <- function(x) { as.factor(sub("_", " ", as.character(activities[x,2]))) }
    
    # change yAll$activity to be the cleaned up text version rather than the numeric
    yAll <- mutate(yAll, activity = getActivity(yAll$activity))
    
    # bind 3 datasets (y, subjects, X relevant cols) to get full dataset
    dataSet <- cbind(yAll, subjectAll, xMeanStd)
    
    
    # Fucntion to tidy up the names of the columns to make more readable. 
    # 
    # tBodyAcc-std()-Y will convert to TimeBodyAccStdDevY
    # fBodyBodyGyroJerkMag-mean() will convert to FourierBodyGyroJerkMagMean
    #
    # Using following transformations:
    #
    # > At the start of the word "t" goes to "Time" and "f" goes to "Fourier"
    # > "mean()" goes to "Mean" and "std()" goes to "StdDev"
    # > "BodyBody" goes to "Body" (this seems to be a bug with original feature file)
    
    tidyFeatureName <- function (s) {
        
        s1 <- sub("^f", "Fourier",s)
        s2 <- sub("^t", "Time", s1)
        s3 <- sub("BodyBody", "Body", s2)
        s4 <- sub("-mean\\(\\)", "Mean", s3)
        s5 <- sub("-std\\(\\)", "StdDev", s4)
        s6 <- sub("-", "", s5)
        s6
        
    }
    
    # update dataSet with tidy versions of the name
    colnames(dataSet) <- sapply(colnames(dataSet), tidyFeatureName)
    
    grouped <- group_by(dataSet, activity, subject)
    
    tidy <- summarize_each(grouped, funs(mean))
    
    tidy
}



