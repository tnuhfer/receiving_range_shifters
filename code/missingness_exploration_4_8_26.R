library(tidyverse)
data <- read.csv("data/joined_data_4_22_with_dispersal.csv")

data$weedy_proxy <- FALSE
data$weedy_proxy[data$reg_native == TRUE | data$gir_nuisance == TRUE] <- TRUE

#possible response variables = weedy_proxy or gpi_inv_else

data<- data[,-1] 


#data[-is.na(data$ResolvedName ),]
#calculate row and column sums - removing nine as the number of columns with 100% completion for ease of viewing
#data$row_sums <- rowSums(!is.na(data)) - 9

#hist(data$row_sums)
#(table(data$row_sums))

#colSums(!is.na(data)) %>% data.frame() 

library(naniar)

#vis_miss(data)

#test out removing some variables
#data$complete <- complete.cases(data %>% select(-c(genus, ResolvedName, csr_c, csr_r, 
#                   gpi_inv_cong, gpi_inv_else, reg_native, 
#                   gir_nuisance, gpi_inv_nat, weedy_proxy,  row_sums,
#                   will_rangesize, will_preciprange, will_phrange)))

#complete <- data %>% filter(complete == TRUE) 

#table(complete$gpi_inv_else)
#sum(complete)

#table(data$weedy_proxy)
#table(data$gpi_inv_else)    


#could we expand this with european species?


#modeling ideas -
#keep everything but will's data and CSR
#turn invasive elsewhere/invasive locally into a factor - 0,1,2
#use clm rather than simmulated annealing?

#do some more exploration prior to modeling

#create ordinal response variable
data$response <- 0
data$response[data$gpi_inv_else == TRUE] <- 1
data$response[data$weedy_proxy == TRUE] <- 2

#re-arrange habit variable to only list primary habit
data <- data %>% separate_wider_delim(usda_habit, ",", names = c("usda_habit"), too_many = "drop", cols_remove = TRUE)
#make ordinal factors out of other variables
data$usda_nitro <- factor(data$usda_nitro, levels = c("None", "Low", "Medium", "High"))
data$usda_toxic <- factor(data$usda_toxic, levels = c("None", "Slight", "Moderate", "Severe"))
data$usda_lifespan <- factor(data$usda_lifespan, levels = c("Short", "Moderate", "Long"))


table(temp$response)
