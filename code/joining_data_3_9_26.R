#put together cohesive dataset

#commercially available plants
calscape <- read.csv("C:/Users/lnuhfer/OneDrive - University of Massachusetts/receiving_range_shifters/data/resolved/calscape_resolved_3_4_26.csv", comment.char="#")
era <- read.csv("C:/Users/lnuhfer/OneDrive - University of Massachusetts/receiving_range_shifters/data/resolved/era_resolved_1_17_26.csv")
m_orn <- read.csv("C:/Users/lnuhfer/OneDrive - University of Massachusetts/receiving_range_shifters/data/resolved/modern_orn_resolved_1_17_26(in).csv")

#additional traits sources
csr <- read.csv("C:/Users/lnuhfer/OneDrive - University of Massachusetts/receiving_range_shifters/data/resolved/csr_resolved_1_12_26.csv")
gpi <- read.csv("C:/Users/lnuhfer/OneDrive - University of Massachusetts/receiving_range_shifters/data/resolved/gpi_resolved_1_12_26.csv")
hybrid <- read.csv("C:/Users/lnuhfer/OneDrive - University of Massachusetts/receiving_range_shifters/data/resolved/hybrid_resolved_1_12_26.csv")
usda_plants <- read.csv("C:/Users/lnuhfer/OneDrive - University of Massachusetts/receiving_range_shifters/data/resolved/usda_characteristics_resolved_3_3_26.csv")
will <- read.csv("C:/Users/lnuhfer/OneDrive - University of Massachusetts/receiving_range_shifters/data/resolved/will_characteristics_resolved_3_3_26.csv")

#create core list
#filter calscape to commercially available
calscape_avail <- calscape %>% filter(Nursery.Availability != "Never or Almost Never Available" & Nursery.Availability != "Rarely Available")
spp_list <- as.data.frame(unique(c(calscape_avail$Accepted_name, era$Accepted_name[era$Commercially.Available != "Unlikely"], 
                                   m_orn$Accepted_name, usda_plants$Accepted_name[usda_plants$Commercial.Availability %in% c("Routinely Available", "Contracting Only")]))) 
names(spp_list) <- "ResolvedName"
spp_list <- spp_list %>% filter(!is.na(ResolvedName))
#join join join! 

#select columns carefully and label them
spp_list <- spp_list %>% left_join(select(csr, Accepted_name, `C....`,`R....`), join_by(ResolvedName == Accepted_name))
names(spp_list) <- c("ResolvedName", "csr_c", "csr_r")
spp_list <- spp_list %>% left_join(select(usda_plants, Accepted_name, Growth.Habit, Growth.Rate, Known.Allelopath, Lifespan, Nitrogen.Fixation, Toxicity), 
                       join_by(ResolvedName == Accepted_name))

names(spp_list) <- c("ResolvedName", "csr_c", "csr_r", "usda_habit", "usda_growth", "usda_allelo", "usda_lifespan", "usda_nitro", "usda_toxic")

#make a genus column to use for hybrid, invaSive congener
spp_list <- spp_list %>% separate_wider_delim(ResolvedName, delim = " ", names = c("genus", "delete"), 
                                              too_many = "drop", cols_remove =  FALSE) %>%
  select(-delete)

spp_list <- spp_list %>% left_join(select(hybrid, Accepted_name, HybProp, Hyb_Ratio), join_by(genus == Accepted_name)) 

names(spp_list)[11:12] <- c("hyb_prop", "hyb_ratio")

spp_list$gpi_inv_cong <- FALSE
gpi <- gpi %>% separate_wider_delim(Accepted_name, delim = " ", names = c("genus", "delete"), 
                                                 too_many = "drop", cols_remove =  FALSE) %>%
  select(-delete)

spp_list$gpi_inv_cong[spp_list$genus %in% gpi$genus] <- TRUE
table(spp_list$gpi_inv_cong)

spp_list$gpi_inv_else <- FALSE
spp_list$gpi_inv_else[spp_list$ResolvedName %in% gpi$Accepted_name] <- TRUE

spp_list <- spp_list %>% left_join(select(will, Accepted_name, Range_Size, Precip, pH), join_by(ResolvedName == Accepted_name)) 

names(spp_list)[15:17] <- c("will_rangesize", "will_preciprange", "will_phrange")      

spp_list %>% write.csv("data/joined_data_3_9_26.csv")


