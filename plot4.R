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


#Used for studying the data earlier
#unique(SCC$SCC.Level.One)
#unique(SCC$SCC.Level.Two)
#unique(SCC$SCC.Level.Three)[grepl("coal", unique(SCC$SCC.Level.Three), ignore.case=TRUE)]


# Sum only the Baltimore data for analysis
NEI_coal <- NEI[NEI$SCC %in% SCC[grepl("coal", SCC$SCC.Level.Three, ignore.case=TRUE),]$SCC, ]
NEI_coal_pivot <- ddply(NEI_coal, .(year), summarize, emission_thousand = sum(Emissions, na.rm=TRUE))
NEI_coal_pivot$emission_thousand <- NEI_coal_pivot$emission_thousand/1000.0



# Plot the result
png("plot4.png")
plot(NEI_coal_pivot, type="o", col="blue", xlab="year", ylab="PM2.5 Emissions (thousand tons)",main="US Coal-related PM2.5 Emissions by Year")
dev.off()



