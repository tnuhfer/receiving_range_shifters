#noxious weed list resolution
library(tidyverse) #read in tidyverse package
library(TNRS) #read in TNRS package
library(readxl)

getwd() #check your working directory

#Read reg data
reg <- read.csv("data/regulatory_plants.csv")

#resolve taxonomy 
#create a 2 column dataframe with a column of row ID numbers and the unique submitted names from ERA
reg_tnrs <- data.frame(c(1:length(unique(reg$Clean.Scientific.Name))), unique(reg$Clean.Scientific.Name))
#rename columns
names(reg_tnrs) <- c("ID", "submitted")
#Run TNRS - this step can be slow. Create a new object called "reg_resolved" for the results
reg_resolved <- TNRS(reg_tnrs, accuracy = 0.9)
#If accepted name was blank, or genus level or greater, replace with NA
reg_resolved$Accepted_name[reg_resolved$Accepted_name == "" | reg_resolved$Accepted_name_rank == "genus"] <- NA
#now, we are going to select only a few relevant columns from the TNRS output and join it to the reg based on the submitted name
#right join will have the same number of rows as the reg dataframe
reg <- reg_resolved %>% 
  select(Name_submitted, Accepted_name) %>%
  right_join(reg, by = join_by(Name_submitted == Clean.Scientific.Name)) #join_by says that these two columns should be used to match the datasets bc they are the same data

#reduce list to those which are native somewhere in lower 48
reg_native <- reg[grepl("L48\\(N\\)", reg$Native.Status),]
write.csv(reg_native, "data/resolved/reg_native_resolved_4_8_26.csv")

#do same thing with Will's twenties data as source

#noxious weed list resolution
library(tidyverse) #read in tidyverse package
library(TNRS) #read in TNRS package
library(readxl)

getwd() #check your working directory

#Read reg data
gir <- read.csv("data/will_GIR.csv")
#rename name submitted column
names(gir)[1] <- "Submitted_name"
#resolve taxonomy 
#create a 2 column dataframe with a column of row ID numbers and the unique submitted names from ERA
gir_tnrs <- data.frame(c(1:length(unique(gir$Submitted_name))), unique(gir$Submitted_name))
#rename columns
names(gir_tnrs) <- c("ID", "submitted")
#Run TNRS - this step can be slow. Create a new object called "reg_resolved" for the results
gir_resolved <- TNRS(gir_tnrs, accuracy = 0.9)
#If accepted name was blank, or genus level or greater, replace with NA
gir_resolved$Accepted_name[gir_resolved$Accepted_name == "" | gir_resolved$Accepted_name_rank == "genus"] <- NA
#now, we are going to select only a few relevant columns from the TNRS output and join it to the reg based on the submitted name
#right join will have the same number of rows as the reg dataframe
gir <- gir_resolved %>% 
  select(Name_submitted, Accepted_name) %>%
  right_join(gir, by = join_by(Name_submitted == Submitted_name)) #join_by says that these two columns should be used to match the datasets bc they are the same data

#reduce list to those which are native somewhere in lower 48

uscodes <- c(73:78)
searchcode <- paste0(uscodes, collapse = "|")

gir_nuisance <- gir[grepl(searchcode, gir$Invasive_L2) & grepl(searchcode, gir$Native_L2),]

write.csv(gir_nuisance, "data/resolved/gir_nuisance_resolved_4_8_26.csv")


