# README
#### Getting and Cleaning Data: Course Project

The run_analysis.R script is designed to create and tidy the accelerometer data obtained from Samsung Galaxy S smartphones. The input is a subset of the text files contained in the zip file from:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

Before executing the script, download and unzip the file linked above. Make sure the files are in your current working directory.

### Step 1. Merge Data

The first step is to merge the test and training data. Here, we load in the the following files.

|File Name|Description|
|---------|-----------|
|X_train.txt|Training data
|y_train.txt|Training activity labels|
|subject_train.txt|Subject Labels|

We'll import them via the **read.table()** command. At the same time, we'll load the variable names for the training data.

```{r}
xtrain <- read.table("train/X_train.txt")
labs <- read.table("features.txt") # load variable names
names(xtrain) <- labs$V2 # Add variable names

ytrain <- read.table("train/y_train.txt")

trsubject <- read.table("train/subject_train.txt")
```

We loaded the variable names into the dataset right off the bat to prevent confusion. Then, we bind all the loaded variables together - xtrain, ytrain, and trsubject - into one dataset called "train". 

```{r} 
train <- cbind(trsubject, ytrain, xtrain) 
```

The process is repeated for the "test" dataset.

To combine the train and test data into one dataset, we use:

```{r}
alldata <- rbind(test, train)
```

### Step 2. Extract Measurements

The next step is to extract only the measurements with the mean and standard deviation of each variable. We use the **grepl()** command for this:

```{r}
mypattern <- c("std", "mean[^Freq]")
measurements <- alldata[ , grepl(paste(mypattern, 
                                 collapse = "|"), 
                                 names(alldata))]
```

We're collecting only the pure form of the mean by excluding *meanFreq* with **mean[^Freq]**. This is because the frequency of the mean is a different measurement than the mean, and for this project we're only capturing the pure mean.

This last command grabbed only the measured variables, so now we need to add the *subject* and *activity* columns back in. We're also going to rename these columns for easier reference later.

```{r}
measurements <- cbind(alldata[,1:2], measurements)
names(measurements)[1:2] <- c("subject", "activity") # clean up names
```

### Step 3. Apply Descriptive Activity Names

To convert the numeric levels of *activity* into descriptive character levels, we're going to **merge()** the "activity_labels.txt" table with our dataset "measurements".

```{r}
actlabs <- read.table("activity_labels.txt")
measurements <- merge(actlabs, measurements, 
                      by.y = "activity", by.x = "V1",
                      all.y = TRUE)
measurements <- measurements[, -1] # remove excess information
names(measurements)[1] <- "activity" # correcting the activity 
                                     # variable name again.
```

### Step 4. Use Descriptive Variable Labels

To get "descriptive labels", we need to meet the following requirements:
  + All lower case, when possible
  + Descriptive
  + Not duplicated
  + Not have underscores, dots, or spaces
*[From Editing Text Variables, Jeffery Leek, Powerpoint, slide 16]*

We'll do a couple of things here. First, we'll rename our current dataset to something less cumbersome.

```{r}
m <- measurements
```

Our first requirement is that all characters should be lowercase. We'll do this with **tolower()**.

```{r}
names(m) <- tolower(names(m))
```

Next, we'll make the names "descriptive" - we'll expand out all the abbreviations in each variable name using **sub()**. 

```{r}
names(m) <- sub("^t", "time", names(m))
names(m) <- sub("^f", "frequency", names(m))
names(m) <- sub("std", "standarddeviation", names(m))
names(m) <- sub("acc", "acceleration", names(m))
names(m) <- sub("mag", "magnitude", names(m))
names(m) <- sub("gyro", "gyroscope", names(m))
```

We think there are no duplicated names, but we can check with the following command:

```{r}
anyDuplicated(names(m))
```

Finally, we want to remove all the odd punctuation, which in this case is the *()* and the *-*.

```{r}
names(m) <- gsub("-", "", names(m))
names(m) <- sub("\\()", "", names(m))
```

### Step 5. Tidy the Data Set

To get a tidy data set that takes the mean of all our collected measured variables, for each activity and subject, we'll **melt()** and then **dcast()** our data. For the **melt()**, our id variables are subject and activity - all other variables are measured variables. Then, we'll **dcast()** the resulting dataset, using **mean** as the function.

```{r}
m <- melt(m, id.vars = c("subject", "activity"))
mtwo <- dcast(m, subject + activity ~ variable, mean)
```

Lastly, we'll write out the resulting tidy data set to a .txt file called "tidy.txt". Following the pillars of "tidy data" as outlined by Jeffery Leek in his presentation about Reshaping Data, this data set has:
1. **One variable per column.** We have no repeats, as we checked above.
2. **Each observation forms a row.** Each measurement mean of one activity per one subject is found in each row.
3. **Each table stores data about one kind of observation.** This is also true, as we are only tracking the measurements taken by the Galaxy S phone.

```{r}
write.table(mtwo, "tidy.txt", row.names = FALSE)
