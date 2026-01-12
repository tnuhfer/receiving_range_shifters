library(tidyverse) #read in tidyverse package
library(TNRS) #read in TNRS package
library(readxl)

getwd() #check your working directory

#Read gpi data
gpi <- read.csv("data/gpi/GPI_database.csv")

#resolve taxonomy of gpi
#create a 2 column dataframe with a column of row ID numbers and the unique submitted names from ERA
gpi_tnrs <- data.frame(c(1:length(unique(gpi$GPI_name))), unique(gpi$GPI_name))
#rename columns
names(gpi_tnrs) <- c("ID", "submitted")
#Run TNRS - this step can be slow. Create a new object called "gpi_resolved" for the results
gpi_resolved <- TNRS(gpi_tnrs, accuracy = 0.9)
#If accepted name was blank, or genus level or greater, replace with NA
gpi_resolved$Accepted_name[gpi_resolved$Accepted_name == "" | gpi_resolved$Accepted_name_rank == "genus"] <- NA
#now, we are going to select only a few relevant columns from the TNRS output and join it to the gpi based on the submitted name
#right join will have the same number of rows as the gpi dataframe
gpi <- gpi_resolved %>% 
  select(Name_submitted, Accepted_name) %>%
  right_join(gpi, by = join_by(Name_submitted == GPI_name)) #join_by says that these two columns should be used to match the datasets bc they are the same data

#We will want to filter out non-native species but need to wait until we have processed USDA data

write.csv(gpi, "data/resolved/gpi_resolved_1_12_26.csv")
