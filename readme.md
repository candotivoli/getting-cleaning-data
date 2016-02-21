
# Tidy Data for Assignment: Getting and Cleaning Data Course Project

The function `runAnalysis()` in the script `run_analysis.R` will download the zip file below and process it to return the required tidy dataset.

 
    source("run_analysis.R")
    tidy <- runAnalysis()
    write.table(tidy, "tidy.txt")
    
    # read tidy dataset using below
    tidy2 <- read.table("tidy.txt", header=TRUE)

### Getting the raw data

The first part of the function downloads the zip file [https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip) 

* It extracts the zip file and loads the X, Y and student test and training sets. 
* It merges the test and training sets for each of X, Y and student using `rbind`.

### Taking just the right columns from X

The script reads the list of feature names from **features.txt** and uses grep to take just those features that include **_mean()_** or **_std()_**. By assigning the feature names to the variables in the X data set and then using the output of `grep` we get a subset of X with just the right columns

### Tidying the activities for Y

This script reads the list of activity labels from the **activity_label.txt** file. The function `getActivity()` uses this data to provide a mapping from number to tidy text value. Underscores are removed from the labels. The output is a factor.

### Merging X, Y and subject

The 3 datasets are merged together using `cbind`

### Wide form

I'm taking the view that each row in the original X dataset constitutes a single observation and there is no need to transform into a narrow form.

### Tidying the column names

Going with the suggestions for variable names form the course lecture names of variables should be:

* All lower case where possible
* Descriptive - Diagnosis vs Dx
* Not duplicated
* Not have underscores or dots or whitespaces
    
If I adopted the lower case guideline then the variable name: `tBodyAcc-std()-Y` would convert to `timebodyaccmeany` which is not readable. Therefore I am going with capitals for these column names. So `tBodyAcc-std()-Y` will convert to `TimeBodyAccStdDevY`. Also there seems to be a bug where certain features are "BodyBody" so will clean this up.

* `f` will go to `Fourier` and `t` will go to `Time`
* `BodyBody` will go to `Body`
* `mean()` will go to `Mean`
* `std()` will go to `StdDev`
* The `-` will be removed

### Group and Summarize

Finally the dataset is grouped by the `activity` and `subject` using `group_by` and then the mean of each value column is computed using `summarize_each`. The resultant dataset is returned.

### Testing
To test run the following:

    source("run_analysis.R")
    tidy <- runAnalysis()
    write.table(tidy, "tidy.txt")
    
    # read tidy dataset using below
    tidy2 <- read.table("tidy.txt", header=TRUE)


