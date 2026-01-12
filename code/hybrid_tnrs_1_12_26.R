library(tidyverse) #read in tidyverse package
library(TNRS) #read in TNRS package
library(readxl)

getwd() #check your working directory

#Read hybrid data
hybrid <- read.csv("data/hybrid.csv")

#resolve taxonomy of hybrid
#create a 2 column dataframe with a column of row ID numbers and the unique submitted names from ERA
hybrid_tnrs <- data.frame(c(1:length(unique(hybrid$Genus))), unique(hybrid$Genus))
#rename columns
names(hybrid_tnrs) <- c("ID", "submitted")
#Run TNRS - this step can be slow. Create a new object called "hybrid_resolved" for the results
hybrid_resolved <- TNRS(hybrid_tnrs, accuracy = 0.9)
#If accepted name was blank, replace with NA
hybrid_resolved$Accepted_name[hybrid_resolved$Accepted_name == ""] <- NA
#now, we are going to select only a few relevant columns from the TNRS output and join it to the hybrid based on the submitted name
#right join will have the same number of rows as the hybrid dataframe
hybrid <- hybrid_resolved %>% 
  select(Name_submitted, Accepted_name) %>%
  right_join(hybrid, by = join_by(Name_submitted == `Genus`)) #join_by says that these two columns should be used to match the datasets bc they are the same data

#We will want to filter out non-native species but need to wait until we have processed USDA data

write.csv(hybrid, "data/resolved/hybrid_resolved_1_12_25.csv")
