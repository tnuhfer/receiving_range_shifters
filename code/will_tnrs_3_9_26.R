#resolve will's data and bethany's data

library(tidyverse) #read in tidyverse package
library(TNRS) #read in TNRS package
library(readxl)

getwd() #check your working directory

#Read data
will <- read.csv("data/will_breadth.csv")

#select relevant variables based on his paper - interested in native range size and precipitation range only
#maybe also soil ph - let's try it

will <- will %>% select(Accepted.Symbol, Scientific.Name, Range_Size, Precip, pH, Status) %>% filter(Status == "native")



#resolve taxonomy 
#create a 2 column dataframe with a column of row ID numbers and the unique submitted names from ERA
will_tnrs <- data.frame(c(1:length(unique(will$Scientific.Name))), unique(will$Scientific.Name))
#rename columns
names(will_tnrs) <- c("ID", "submitted")
#Run TNRS - this step can be slow. Create a new object called "will_resolved" for the results
will_resolved <- TNRS(will_tnrs, accuracy = 0.9)
#If accepted name was blank, or genus level or greater, replace with NA
will_resolved$Accepted_name[will_resolved$Accepted_name == "" | will_resolved$Accepted_name_rank == "genus"] <- NA
#now, we are going to select only a few relevant columns from the TNRS output and join it to the will based on the submitted name
#right join will have the same number of rows as the will dataframe
will <- will_resolved %>% 
  select(Name_submitted, Accepted_name) %>%
  right_join(will, by = join_by(Name_submitted == Scientific.Name)) #join_by says that these two columns should be used to match the datasets bc they are the same data

write.csv(will, "data/resolved/will_characteristics_resolved_3_3_26.csv")

#for abundance, maybe use spcis? deal with later

