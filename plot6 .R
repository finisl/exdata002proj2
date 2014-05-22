## 1) script requirements
# * The script & both files are stored in the same directory: summarySCC_PM25.rds & Source_Classification_Code.rds
# * Following libraries are assumed to be installed already:
#   - plyr

## 2) summarySCC_PM25.rds data fields are:
# * fips      : A five-digit number (represented as a string) indicating the U.S. county
# * SCC       : The name of the source as indicated by a digit string (see source code classification table)
# * Pollutant : A string indicating the pollutant
# * Emissions : Amount of PM2.5 emitted, in tons
# * type      : The type of source (point, non-point, on-road, or non-road)
# * year      : The year of emissions recorded

## 3) Source_Classification_Code.rds data:
# This table provides a mapping from the SCC digit strings int he Emissions table to the actual name of 
# the PM2.5 source. The sources are categorized in a few different ways from more general to more specific.

## __________________________________________________________________________________________
## 4) The processing script



# load the libraries
library(plyr)



# Load the RDSsummarySCC_PM25.rds; check existence before re-loading again; easier for development
flagLoad <- 0
if (exists("NEI")==FALSE) { 
    flagLoad <- 1
} else if (nrow(NEI)!=6497651) {
    flagLoad <- 1
} else if(ncol(NEI)!=6) {
    flagLoad <- 1
}
if (flagLoad==1) {
    NEI <- readRDS("summarySCC_PM25.rds")
}
# Load the Source_Classification_Code.rds; it's quick. Just load
SCC <- readRDS("Source_Classification_Code.rds")



# Sum only the Baltimore data for analysis
NEI_2city <- NEI[NEI$fips %in% c("24510", "06037") & NEI$type=="ON-ROAD",]
NEI_2city_pivot <- ddply(NEI_2city, .(fips, year), summarize, emission = sum(Emissions, na.rm=TRUE))
NEI_2city_pivot[NEI_2city_pivot$fips=="24510", "fips"] <- "Baltimore"
NEI_2city_pivot[NEI_2city_pivot$fips=="06037", "fips"] <- "Los Angeles"
names(NEI_2city_pivot)[1] <- "city"



# Plot the result
png("plot6.png")
ggplot(NEI_2city_pivot, aes(x=year, y=emission, )) + 
    geom_line(aes(color=city, linetype=city), show_guide=TRUE, size=1.5) + 
    #facet_grid(type~.) +
    #scale_color_manual(values=c("red", "blue", "green", "purple")) +
    scale_linetype_manual(values=c("solid", "dotdash")) +
    #theme(legend.position="bottom") +
    theme(legend.position=c(0.86,0.6), legend.key.width = unit(1.5, "cm"), legend.key.height = unit(0.5, "cm")) +
    theme(plot.title=element_text(face="bold",size="14")) +
    ggtitle("Baltimore & Los Angeles motor-vehicle Emission by Year") +
    xlab("Year") + ylab("PM2.5 Emissions (tons)")
dev.off()




