#run_analysis.R
#Max B. , 10.04.2020

#Getting packages install.packeges(data.table) & install.packeges(dplyr)
#load packages

library(data.table)
library(dplyr)

#Setting working directory
setwd("C:/Users/mb/Desktop/Training")

URL<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
destFile<-"CDataset.zip"

if(!file.exists(destFile)){
  download.file(URL,destfile=destFile,mode="wb")
}

#Unzip the existing File


date_Download<-date()

#Focus on Reading function
setwd("./UCI HAR Dataset")

#Store feature files

FeaturesTrain<-read.table("./train/X_train.txt", header = F)
FeaturesTest<-read.table("./test/X_test.txt", header = F)

#Store Activity files

ActivityTrain<-read.table("./train/y_train.txt", header = F)
ActivityTest<-read.table("./test/y_test.txt", header = F)

#Read Subject files

SubjectTrain<-read.table("./train/subject_train.txt", header = F)
SubjectTest<-read.table("./test/subject_test.txt", header = F)

#Activity Labels

ActivityLabels<-read.table("./activity_labels.txt", header = F)

#Feature Names
FeaturesNames<-read.table("./features.txt", header = F)

#Binding Tables together (Features/Activity/Subject test&train)

SubjectData<-rbind(SubjectTest,SubjectTrain)
ActivityData<-rbind(ActivityTest,ActivityTrain)
FeaturesData<-rbind(FeaturesTest,FeaturesTrain)

##New names for colums ActivityData & ActivityLabels
names(ActivityData)<-"ActivityN"
names(ActivityLabels)<-c("ActivityN","Activity")


Activity <- left_join(ActivityData, ActivityLabels, "ActivityN")[, 2]

##Renaming colum Subject and Feature

names(SubjectData)<-"Subject"
names(FeaturesData)<-FeaturesNames$V2

#Creating Dataset with Subject,Features,Activity

DataSet<-cbind(SubjectData,Activity)
DataSet<-cbind(DataSet,FeaturesData)

##New Dataset with only the mean and standard deviation for the measures

subFeaturesNames<-FeaturesNames$V2[grep("mean\\(\\)|std\\(\\)",FeaturesNames$V2)]
DataNames<- c("Subject","Activity",as.character(subFeaturesNames))
DataSet<-subset(DataSet,select=DataNames)

#Rename the colums with clear names
names(DataSet)<-gsub("^t","time",names(DataSet))
names(DataSet)<-gsub("^f","frequency",names(DataSet))
names(DataSet)<-gsub("Acc","Accelerometer",names(DataSet))
names(DataSet)<-gsub("Gyro","Gyroscope",names(DataSet))
names(DataSet)<-gsub("Mag","Magnitude",names(DataSet))
names(DataSet)<-gsub("BodyBody","Body",names(DataSet))


SecondDataSet<-aggregate(. ~Subject + Activity , DataSet,mean)
SecondDataSet<-SecondDataSet[order(SecondDataSet$Subject,SecondDataSet$Activity),]

write.table(SecondDataSet,file="tidydata.txt",row.names = F)