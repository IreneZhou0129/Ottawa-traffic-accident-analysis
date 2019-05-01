library(stringr)
collisiondata <- data.table::fread("C:/Users/GCHAU069/Documents/CSI4142/CollisionData.csv")

#pretreat location here
test = gsub("T & T SC","tnt",collisiondata$Location) 
test = gsub("@","\t",test)
test = gsub("TO BE DETERMINED","",test)
test = gsub("34B & 42A-3","34B n 42A-3",test) 
test = gsub("35 & 36","35 n 36",test) 
test = gsub("NO NAME","",test) 
test = gsub("(OTTAWA)","",test) 
test = gsub("Grand","GRAND",test) 
test = gsub("&","\t",test)
test = gsub("btwn","\t",test)
test = gsub(" and ","\t",test)
test = gsub("tnt","T & T SC",test) 
test = gsub("34B n 42A-3","34B & 42A-3",test) 
test = gsub("35 n 36","35 & 36",test)
for(i in 1:length(test)){
  test[i] = ifelse(str_count(test[i],"/") == 1 && str_count(test[i],"\t") < 2, gsub("/","\t",test[i]), test[i])
}
#add the commas for the ones that don't have enough.


collisiondata$Location = test

collisiondata$Location = ifelse(str_count(collisiondata$Location,"\t") < 2, paste(collisiondata$Location,"\t",sep=""),collisiondata$Location)
collisiondata$Location = ifelse(str_count(collisiondata$Location,"\t") < 2, paste(collisiondata$Location,"\t",sep=""),collisiondata$Location)

collisiondata$Hour = str_replace_all(substr(collisiondata$Time,1,2),":","")
collisiondata$Month = ifelse(collisiondata$Year == 2017, substr(collisiondata$Date,4,5) ,substr(collisiondata$Date,6,7))
collisiondata$Day = ifelse(collisiondata$Year == 2017, substr(collisiondata$Date,1,2) , substr(collisiondata$Date,9,10))

for (i in 1:nrow(collisiondata)){
  #because data is only from ottawa, we know that longitude is - something. so if it aint that means they reversed it.

  if (collisiondata[i]$Longitude > 0){
      
      tempvar = collisiondata[i]$Longitude
      collisiondata[i]$Longitude = collisiondata[i]$Latitude
      collisiondata[i]$Latitude = tempvar
    }
    
}


collisiondata2 <- data.table::data.table(collisiondata$Location,collisiondata$Longitude,collisiondata$Latitude,collisiondata$Year,collisiondata$Month,collisiondata$Day,collisiondata$Time,collisiondata$Hour,collisiondata$Environment,collisiondata$Road_Surface,collisiondata$Traffic_Control,collisiondata$Collision_Location,collisiondata$Light,collisiondata$Collision_Classification,collisiondata$Impact_type)

data.table::fwrite(collisiondata2,"C:/Users/GCHAU069/Documents/CSI4142/CollisionData2.csv",col.names = FALSE, quote = FALSE, sep = "\t")


stationdata <- data.table::fread("C:/Users/GCHAU069/Documents/CSI4142/Station Inventory EN.csv")
stationdatatest = dplyr::filter(stationdata, grepl("OTTAWA",Name))



stationdata2 = data.table::data.table(stationdatatest$Name,stationdatatest$`Latitude (Decimal Degrees)`,stationdatatest$`Longitude (Decimal Degrees)`)
write.csv(stationdata2,file = "C:/Users/GCHAU069/Documents/CSI4142/stationData.csv",col.names = FALSE, quote = FALSE, sep = "\t")




