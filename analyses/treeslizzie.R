## Started 11 Oct 2023 ##
## Looking at DBH data from Rainier with Mike ##
## Totally unchecked etc. ##

## Updated 12 Feb 2024: To count trees in Janneke's plot

d <- read.csv("~/Documents/git/teaching/stan/bayesian2024ubc/bayesian2024ubc_git/data/treestands/trees/TV01003_v17.csv")
d2 <- read.csv("~/Documents/git/teaching/stan/bayesian2024ubc/bayesian2024ubc_git/data/treestands/trees/TV01002_v17.csv")


## Counting trees
# Need to check these exist
jhrltrees  <- c("TO04", "AG05", "AV06", "AM16", "AE10", "PARA", "TA01", "SUNR", "AB08")
dsites  <- d2[which(d2$STANDID %in% jhrltrees),]
sort(unique(dsites$STANDID))
dsitesrecent <- subset(dsites, YEAR>2000)

justtreeIDsall <- subset(dsites, select=c("STANDID", "PLOTNUMBER", "TREEID"))
justtreeIDs <- justtreeIDsall[!duplicated(justtreeIDsall), ]

treesperplot <- aggregate(justtreeIDs[c("TREEID")], justtreeIDs[c("STANDID", "PLOTNUMBER")], FUN=length)
table(justtreeIDs$STANDID, justtreeIDs$PLOTNUMBER)
quantile(treesperplot$TREEID)
hist(treesperplot$TREEID)
table(justtreeIDs$STANDID)

## end of counting trees




# Where is the old data? Not Mount Rainier
olddata <- subset(d, YEAR<1940)
mrrsold <- subset(olddata, PSP_STUDYID=="MRRS")
unique(mrrsold$STANDID)
mrrsold
mrrs <- subset(d, PSP_STUDYID=="MRRS")
min(mrrs$YEAR, na.rm=TRUE)
max(mrrs$YEAR, na.rm=TRUE)

smtree <- subset(mrrs, DBH<10)
bigtree <- subset(mrrs, DBH>20)

changingtreeID <- unique(smtree$TREEID)[which(unique(smtree$TREEID) %in% unique(bigtree$TREEID))]
changingtrees <- d[which(d$TREEID %in% changingtreeID),]

library(ggplot2)
ggplot(changingtrees, aes(y=DBH, x=YEAR, group=TREEID))+
	geom_point() + 
	facet_wrap(TREEID~.)


# One high elevation site
ae10 <- subset(d, STANDID=="AE10")
onetree <- subset(d, TREEID=="AE10000100001")
anothertree <- subset(d, TREEID=="AE10001600003")

if(FALSE){
ggplot(ae10, aes(y=DBH, x=YEAR, group=TREEID))+
	geom_point() + 
	facet_wrap(TREEID~.)
}