#usda TNRS

library(tidyverse) #read in tidyverse package
library(TNRS) #read in TNRS package
library(readxl)

getwd() #check your working directory

#Read usda data
usda <- read.csv("data/usdaplants.csv")
#fix encoding 
#fix encoding
x <- "\xd7"
Encoding(x) <- "UTF-8"
usda$Scientific.Name <- iconv(usda$Scientific.Name, "UTF-8", "UTF-8",sub= 'x ')
#replace blanks with NA

usda[usda == ""] <- NA
#explore which have traits data
rowSums(!is.na(usda[usda$Characteristics.Data == "Yes",9:95]))
#lets resolve only those with characteristics data for now
usda <- usda %>% filter(Characteristics.Data == "Yes")

#resolve taxonomy of usda
#create a 2 column dataframe with a column of row ID numbers and the unique submitted names from ERA
usda_tnrs <- data.frame(c(1:length(unique(usda$Scientific.Name))), unique(usda$Scientific.Name))
#rename columns
names(usda_tnrs) <- c("ID", "submitted")
#Run TNRS - this step can be slow. Create a new object called "usda_resolved" for the results
usda_resolved <- TNRS(usda_tnrs, accuracy = 0.9)
#If accepted name was blank, or genus level or greater, replace with NA
usda_resolved$Accepted_name[usda_resolved$Accepted_name == "" | usda_resolved$Accepted_name_rank == "genus"] <- NA
#now, we are going to select only a few relevant columns from the TNRS output and join it to the usda based on the submitted name
#right join will have the same number of rows as the usda dataframe
usda <- usda_resolved %>% 
  select(Name_submitted, Accepted_name) %>%
  right_join(usda, by = join_by(Name_submitted == Scientific.Name)) #join_by says that these two columns should be used to match the datasets bc they are the same data

write.csv(usda, "data/resolved/usda_characteristics_resolved_3_3_26.csv")
