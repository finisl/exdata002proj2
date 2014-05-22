## 1) script requirements
# * The script & both files are stored in the same directory: summarySCC_PM25.rds & Source_Classification_Code.rds
# * Following libraries are assumed to be installed already:
#   - ggplot2
#   - grid
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
library(ggplot2)
library(grid)
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
NEI_fips24510 <- NEI[NEI$fips=="24510",]
NEI_fips24510_pivot <- ddply(NEI_fips24510, .(type, year), summarize, emission_thousand = sum(Emissions, na.rm=TRUE))
NEI_fips24510_pivot$emission_thousand <- NEI_fips24510_pivot$emission_thousand/1000.0



# Plot the result
png("plot3.png")
ggplot(NEI_fips24510_pivot, aes(x=year, y=emission_thousand, )) + 
    geom_line(aes(color=type, linetype=type), show_guide=TRUE, size=1.5) + 
    #facet_grid(type~.) +
    #scale_color_manual(values=c("red", "blue", "green", "purple")) +
    scale_linetype_manual(values=c("solid", "dotdash", "dotted", "longdash")) +
    #theme(legend.position="bottom") +
    theme(legend.position=c(0.86,0.89), legend.key.width = unit(1.5, "cm"), legend.key.height = unit(0.5, "cm")) +
    theme(plot.title=element_text(face="bold",size="14")) +
    ggtitle("Baltimore PM2.5 Emissions by Year") +
    xlab("Year") + ylab("PM2.5 Emissions (thousand tons)")
dev.off()




