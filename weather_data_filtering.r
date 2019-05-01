#dplyr and data.table need to be installed.
weatherdata <- data.table::fread("C:/Users/GCHAU069/Documents/CSI4142/WeatherData.csv")
test <- weatherdata[Year>=2014]
data.table::fwrite(test,"weatherdata2014plus.csv")
#run up to this point and stop if you don't have a lot of ram
#if you do skip the next line
data.table::fread("C:/Users/GCHAU069/Documents/weatherdata2014plus.csv")
test2 = dplyr::filter(test, grepl("OTTAWA",X.U.FEFF..Station.Name.))
data.table::fwrite(test2,"weatherdata2014plusonlyottawa.csv")