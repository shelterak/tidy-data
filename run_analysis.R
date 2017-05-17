# Data Science Specialization
# Getting & Cleaning Data
# Week 4 Programming Assignment

# Create a script to do the following:
        # 1. Merges the training and the test sets to create one data set.
        # 2. Extracts only the measurements on the mean and standard deviation 
        #    for each measurement.
        # 3. Uses descriptive activity names in the data set.
        # 4. Appropriately labels the data set with descriptive variable names.
        # 5. From the data set in step 4, create a second, independent tidy data 
        #    set with the average of each variable for each activity and each subject.

### 1. Merge data sets

# Piece together training data set
xtrain <- read.table("train/X_train.txt")
labs <- read.table("features.txt") # load variable names
names(xtrain) <- labs$V2 # Add variable names
ytrain <- read.table("train/y_train.txt")
trsubject <- read.table("train/subject_train.txt")
train <- cbind(trsubject, ytrain, xtrain)

# Piece together test data set
xtest <- read.table("test/X_test.txt") 
names(xtest) <- labs$V2 # Add variable names
ytest <- read.table("test/y_test.txt")
tssubject <- read.table("test/subject_test.txt")
test <- cbind(tssubject, ytest, xtest)

# "Merge"
alldata <- rbind(test, train)


### 2. Extract measurements
mypattern <- c("std", "mean[^Freq]")
measurements <- alldata[ , grepl(paste(mypattern, collapse = "|"), 
                                 names(alldata))]
measurements <- cbind(alldata[,1:2], measurements)
names(measurements)[1:2] <- c("subject", "activity") # clean up names


### 3. Apply descriptive activity names
actlabs <- read.table("activity_labels.txt")
measurements <- merge(actlabs, measurements, by.y = "activity", by.x = "V1", 
                      all.y = TRUE)
measurements <- measurements[, -1]
names(measurements)[1] <- "activity"


### 4. Use descriptive variable labels
m <- measurements
names(m) <- tolower(names(m))
names(m) <- sub("^t", "time", names(m))
names(m) <- sub("^f", "frequency", names(m))
names(m) <- sub("std", "standarddeviation", names(m))
names(m) <- sub("acc", "acceleration", names(m))
names(m) <- sub("mag", "magnitude", names(m))
names(m) <- sub("gyro", "gyroscope", names(m))
names(m) <- gsub("-", "", names(m))
names(m) <- sub("\\()", "", names(m))

## 5. Tidy data, with average for each variable, person, and activity
m <- melt(m, id.vars = c("subject", "activity"))
mtwo <- dcast(m, subject + activity ~ variable, mean)

# write out tidy data set
write.table(mtwo, "tidy.txt", row.names = FALSE)
