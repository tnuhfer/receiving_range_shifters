#seed dispersal tnrs 

library(tidyverse) #read in tidyverse package
library(TNRS) #read in TNRS package
library(readxl)

getwd() #check your working directory

#Read seed data
seed <- read.csv("data/SeedData.csv")

#resolve taxonomy of seed
#first change column "accepted name" to "submitted name"
names(seed)[6]<- "Submitted_name"
#create a 2 column dataframe with a column of row ID numbers and the unique submitted names from ERA
seed_tnrs <- data.frame(c(1:length(unique(seed$Submitted_name))), unique(seed$Submitted_name))
#rename columns
names(seed_tnrs) <- c("ID", "submitted")
#Run TNRS - this step can be slow. Create a new object called "seed_resolved" for the results
seed_resolved <- TNRS(seed_tnrs, accuracy = 0.9)
#If accepted name was blank, or genus level or greater, replace with NA
seed_resolved$Accepted_name[seed_resolved$Accepted_name == "" | seed_resolved$Accepted_name_rank == "genus"] <- NA
#now, we are going to select only a few relevant columns from the TNRS output and join it to the seed based on the submitted name
#right join will have the same number of rows as the seed dataframe
seed <- seed_resolved %>% 
  select(Name_submitted, Accepted_name) %>%
  right_join(seed, by = join_by(Name_submitted == Submitted_name)) #join_by says that these two columns should be used to match the datasets bc they are the same data

#We will want to filter out non-native species but need to wait until we have processed USDA data

write.csv(seed, "data/resolved/seed_resolved_4_22_26.csv")
