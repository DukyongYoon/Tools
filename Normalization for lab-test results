library(RODBC)

conn1<-odbcConnect("DB name", uid="user id", pwd="your password")
#use hospital 1 database information to connect

conn2<-odbcConnect("DB name", uid="user id", pwd="your password")
#use hospital 2 database information to connect

observation_concept_id<-"3023103" #'Potassium serum/plasma' as an example

hosp1<-sqlQuery(conn1, paste("select OBSERVATION_ID, VALUE_AS_NUMBER from OBSERVATION where observation_concept_id=",observation_concept_id))
#Result values from hospital 1

hosp2<-sqlQuery(conn2, paste("select OBSERVATION_ID, VALUE_AS_NUMBER from OBSERVATION where observation_concept_id=",observation_concept_id))
#Result values from hospital 2

Ma<- mean(hosp1[,2])
SDa<- sd(hosp1[,2])

Mb<-mean(hosp2[,2])
SDb<-sd(hosp2[,2])

standardization<-function(x, Ma, SDa, Mb, SDb) {
  ((x-Mb)/SDb)*SDa+Ma
}

shosp1<-hosp1
shosp2<-hosp2

shosp1$Standardization<-hosp1[,2]
shosp2$Standardization<-standardization(hosp2[,2],Ma, SDa, Mb, SDb) #insert normalized laboratory test result values

#you can replace existing results by normalized results using OBSERVATION_ID in each database
