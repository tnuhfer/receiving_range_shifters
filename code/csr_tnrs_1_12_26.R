library(tidyverse) #read in tidyverse package
library(TNRS) #read in TNRS package
library(readxl)

getwd() #check your working directory

#Read CSR data
csr <- read_excel("data/csr.xlsx")
csr <- csr %>% select(-37) #remove extra 37 column

#resolve taxonomy of CSR
#create a 2 column dataframe with a column of row ID numbers and the unique submitted names from ERA
csr_tnrs <- data.frame(c(1:length(unique(csr$`Correct name with authors`))), unique(csr$`Correct name with authors`))
#rename columns
names(csr_tnrs) <- c("ID", "submitted")
#Run TNRS - this step can be slow. Create a new object called "csr_resolved" for the results
csr_resolved <- TNRS(csr_tnrs, accuracy = 0.9)
#If accepted name was blank, or genus level or greater, replace with NA
csr_resolved$Accepted_name[csr_resolved$Accepted_name == "" | csr_resolved$Accepted_name_rank == "genus"] <- NA
#now, we are going to select only a few relevant columns from the TNRS output and join it to the csr based on the submitted name
#right join will have the same number of rows as the csr dataframe
csr <- csr_resolved %>% 
  select(Name_submitted, Accepted_name) %>%
  right_join(csr, by = join_by(Name_submitted == `Correct name with authors`)) #join_by says that these two columns should be used to match the datasets bc they are the same data

#We will want to filter out non-native species but need to wait until we have processed USDA data

write.csv(csr, "data/resolved/csr_resolved_1_12_25.csv")
