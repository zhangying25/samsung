## This function is to prepare tidy data that can be used for later analysis.
##
## Project: 
##    Human Activity Recognition Using Smartphones Dataset
##    http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 
## 
## Data:
##    https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
##
## 1. Merges the training and the test sets
## 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive variable names. 
## 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.
##
run_analysis <- function() {
    library(stringr)
    library(dplyr)
    
    ## read test data set
    test <- read.table("UCI HAR Dataset\\test\\X_test.txt",
        sep = "", header = FALSE)
    y_test <- read.table("UCI HAR Dataset\\test\\Y_test.txt",
        sep = "", header = FALSE, col.names = c("ID"))
    subject_test <- read.table("UCI HAR Dataset\\test\\subject_test.txt",
        sep = "", header = FALSE, col.names = c("ID"))    
    
    ## read train data set
    train <- read.table("UCI HAR Dataset\\train\\X_train.txt",
        sep = "", header = FALSE)
    y_train <- read.table("UCI HAR Dataset\\train\\Y_train.txt",
        sep = "", header = FALSE, col.names = c("ID"))
    subject_train <- read.table("UCI HAR Dataset\\train\\subject_train.txt",
        sep = "", header = FALSE, col.names = c("ID"))
    
    ## combine test and train data set
    all <- rbind(test, train)
    y_all <- rbind(y_test, y_train)
    subject_all <- rbind(subject_test, subject_train)
 
    ## read variable names
    feature <- read.table("UCI HAR Dataset\\features.txt",
        sep = "", header = FALSE, col.names = c("ID", "Feature"))
    ## create short name by removing "()", and replacing "-" with "_".
    ## () and - are not handled well when using in column name of data frame
    feature$ShortName <- str_replace_all(str_replace_all(feature$Feature, "[()]", ""), "[-]", "_")

    ## only select mean() and std() measures
    feature$MeanOrStd <- grepl("-mean()", feature$Feature, fixed = TRUE) | grepl("-std()", feature$Feature, fixed = TRUE)
    mean_std_ids <- feature[feature$MeanOrStd == TRUE, "ID"]
    mean_std <- all[, mean_std_ids]
    ## use descriptive variable names as column names
    mean_std_features <- feature[feature$MeanOrStd == TRUE, "ShortName"]
    colnames(mean_std) <- mean_std_features
    
    ## read activity labels
    activity <- read.table("UCI HAR Dataset\\activity_labels.txt",
        sep = "", header = FALSE, col.names = c("ID", "Activity"))
    ## use descriptive activity name
    mean_std$activity <- activity[y_all$ID, 2]
    ## add a column for subject ID
    mean_std$subject <- subject_all$ID
    
    ## create a new data frame that contains the mean of all measures grouped by activity and subject
    mean_by_activity_subject <- group_by(mean_std, activity, subject) %>% summarise_each(funs(mean))
    
    output <- "MeanByActivitySubject.txt"
    if (file.exists(output)) {
        file.remove(output)
    }
    write.table(mean_by_activity_subject, file = output, row.name = FALSE)
}