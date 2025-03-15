##################
### Script to Explore how DBH growth varies with size & canopy status
### Exploration of data from PSP stands at Mount Rainier National Park

### Set working directory  ##NEED TO CHANGE###
setwd("C:/Users/jannekeh/Desktop/DBH Data/CanopyExploration")

### Read in Data
PSP <- read.csv("TV01002_v17.csv", header=TRUE)
head(PSP)

### Extract data for MORA stands south side old growth / mature
PSP_MORA <- PSP[PSP$STANDID=="TO04"|PSP$STANDID=="AG05"
                |PSP$STANDID=="AV06"|PSP$STANDID=="AM16"
                |PSP$STANDID=="AR07"|PSP$STANDID=="AE10",]

### Transform canopy data into yes / no canopy (D=1, C=1, I=0, S=0)
CANOPY <- rep(NA, length=dim(PSP_MORA)[1])
# Note - some other categories - U (known) will have an NA
CANOPY[PSP_MORA$CANOPY_CLASS=="S"] <- 0
CANOPY[PSP_MORA$CANOPY_CLASS=="I"] <- 0
CANOPY[PSP_MORA$CANOPY_CLASS=="D"] <- 1
CANOPY[PSP_MORA$CANOPY_CLASS=="C"] <- 1
PSP_MORA$CANOPY <- CANOPY

### Explore growth vs. canopy status last census
PSP_MORA_C <- PSP_MORA[is.na(PSP_MORA$CANOPY)==FALSE,] #Remove NA's
STNDTR <- paste(PSP_MORA_C$STANDID, PSP_MORA_C$TAG, sep="") #unique tree id
PSP_MORA_C$STNDTR <- STNDTR #add to data frame

### First data exploration - per tree explore growth~size, canopy status
trees <- unique(PSP_MORA_C$STNDTR) # unique trees
treedat <- c() #eventual data set

for(i in 1:length(trees)){ #for loop to extract per tree data
  treetmp <- PSP_MORA_C[PSP_MORA_C$STNDTR==trees[i],]
  treetmp <- treetmp[is.na(treetmp$DBH)==FALSE,] #remove NA's (mortality)
  if(length(unique(treetmp$SPECIES))!=1){next} # rm a case of trees w/ same tag in same stand
  if(dim(treetmp)[1]<2){next} #If only one observation, skip
  treeinfo <- treetmp[1,c(5,8,9)]
  treefirst <- treetmp[treetmp$YEAR==min(treetmp$YEAR),]
  treelast <- treetmp[treetmp$YEAR==max(treetmp$YEAR),]
  treedbhs <- c(treefirst$DBH[1], treelast$DBH[1]) #extract first, last dbh
  censustime <- treelast$YEAR[1]-treefirst$YEAR[1] #how long between measurements
  grwthinc <- 0.5*(treelast$DBH[1] - treefirst$DBH[1]) / censustime #increment
  ba1 <- pi*((0.5*treefirst$DBH[1])^2); ba2 <- pi*((0.5*treelast$DBH[1])^2)
  bainc <- (ba2 - ba1) / censustime #basal area increment
  treecanopies <- c(treefirst$CANOPY[1], treelast$CANOPY[1])
  treetmp2 <- c(treeinfo, censustime, treecanopies, 
                treedbhs, grwthinc, ba1, ba2, bainc)
  treedat <- rbind(treedat, treetmp2) #put all data into tree dat
}

dimnames(treedat)<-list(c(), c("STANDID","SPECIES","TAG",
                               "YEARS","CANOPY1","CANOPY2",
                               "DBH_1","DBH_2","RNGWDTH",
                               "BA_1","BA_2","BAINC"))
treedat <- data.frame(treedat)
for(j in 4:12){treedat[,j] <- as.numeric(treedat[,j])}

### Now graph tree specific data of size vs. growth, canopy, per species
spp <- c("THPL", "TSHE", "PSME", "ABAM", "CANO9", "TSME")
X11(8,6)
par(mfrow=c(2,3), omi=c(0,0,0,0), 
    mai=c(0.4,0.4,0.5,0.4), tck=-0.02,
    mgp=c(1.2,0.45,0))

for(i in 1:length(spp)){
  sppdat <- treedat[treedat$SPECIES==spp[i],]
  xmx <- max(sppdat$DBH_1)
  cls <- c("darkgreen","grey","yellow")
  canstat <- sppdat$CANOPY1+sppdat$CANOPY2 + 1
  ptcls <- cls[canstat]
  plot(sppdat$DBH_1,sppdat$RNGWDTH, xlim=c(0,xmx),
       pch=21, bg=ptcls,cex=2,
       xlab="Size(DBH)", ylab="Growth (radial - cm)")
  title(spp[i])
  if(i==4){legend(x="topleft", c("below","mixed","above"), 
                  pt.cex=2, pch=21, pt.bg=cls)}
}

### Plot basal area, basal area inc, canopy for 6 species
spp <- c("THPL", "TSHE", "PSME", "ABAM", "CANO9", "TSME")
X11(8,6)
par(mfrow=c(2,3), omi=c(0,0,0,0), 
    mai=c(0.4,0.4,0.5,0.4), tck=-0.02,
    mgp=c(1.2,0.45,0))

for(i in 1:length(spp)){
  sppdat <- treedat[treedat$SPECIES==spp[i],]
  xmx <- max(sppdat$BA_1)
  cls <- c("darkgreen","grey","yellow")
  canstat <- sppdat$CANOPY1+sppdat$CANOPY2 + 1
  ptcls <- cls[canstat]
  plot(sppdat$BA_1,sppdat$BAINC, xlim=c(0,xmx),
       pch=21, bg=ptcls,cex=2,
       xlab="Size(BA)", ylab="Growth (area - cm2)")
  title(spp[i])
  if(i==6){legend(x="topleft", c("below","mixed","above"), 
                  pt.cex=2, pch=21, pt.bg=cls)}
}


#######################
### Assess changes in growth when status changes for an individual tree
trees <- unique(PSP_MORA_C$STNDTR)
treedat_ind <- c() #eventual name of data array

## This for loop pulls out trees with > 4 censuses, start under canopy, end in canopy
## Would also extract trees that go back and forth.

for(i in 1:length(trees)){
  treetmp <- PSP_MORA_C[PSP_MORA_C$STNDTR==trees[i],] #extract tree specific info
  treeinfo <- treetmp[1,c(5,8,9,25)]
  treetmp <- treetmp[is.na(treetmp$DBH)==FALSE,] #remove na's
  if(dim(treetmp)[1]<5){next} #only for trees with 4 or more observations
  n0 <- length(treetmp$CANOPY[treetmp$CANOPY==0]) 
  n1 <- length(treetmp$CANOPY[treetmp$CANOPY==1]) 
  tot <- length(treetmp$CANOPY)
  if(n0<2){next}; if(n1<2){next} # must have at least 2 observations under and in
  stat1 <- treetmp$CANOPY[1]
  stat2 <- treetmp$CANOPY[length(treetmp$CANOPY)]
  if(stat1==1){next}; if(stat2==0){next} #has to start with 0, end with 1

  #determine growth under canopy
  CU <- treetmp[treetmp$CANOPY==0,] 
  CUdbh1 <- CU$DBH[CU$YEAR==min(CU$YEAR)]
  CUdbh2 <- CU$DBH[CU$YEAR==max(CU$YEAR)]
  CUyr1 <- CU$YEAR[CU$YEAR==min(CU$YEAR)]
  CUyr2 <- CU$YEAR[CU$YEAR==max(CU$YEAR)]
  CURL <- 0.5*(CUdbh2 - CUdbh1) / (CUyr2 - CUyr1) #radial increment
  # basal area increment
  CUBinc <- (pi*((0.5*CUdbh2)^2) - pi*((0.5*CUdbh1)^2)) / (CUyr2 - CUyr1)
  
  #determine growth in canopy
  CI <- treetmp[treetmp$CANOPY==1,] 
  CIdbh1 <- CI$DBH[CI$YEAR==min(CI$YEAR)]
  CIdbh2 <- CI$DBH[CI$YEAR==max(CI$YEAR)]
  CIyr1 <- CI$YEAR[CI$YEAR==min(CI$YEAR)]
  CIyr2 <- CI$YEAR[CI$YEAR==max(CI$YEAR)] 
  CIRL <- 0.5*(CIdbh2 - CIdbh1) / (CIyr2 - CIyr1) #radial increment
  # basal area increment
  CIBinc <- (pi*((0.5*CIdbh2)^2) - pi*((0.5*CIdbh1)^2)) / (CIyr2 - CIyr1)
  # bind it all together into treedat_ind 
  treetmp2 <- c(treeinfo, CUdbh1, CURL, CUBinc, CIRL, CIBinc)
  treedat_ind <- rbind(treedat_ind, treetmp2)
}

# Reconfigure as data frame
dimnames(treedat_ind)<-list(c(), c("STANDID","SPECIES","TAG","TREEID",
                                   "DBH1", "RL_GRWTH_U", "BA_GRWTH_U",
                                   "RL_GRWTH_C", "BA_GRWTH_C"))
treedat_ind <- data.frame(treedat_ind)
treedat_ind$TREEID <- as.factor(as.character(treedat_ind$TREEID))
treedat_ind$SPECIES <- as.factor(as.character(treedat_ind$SPECIES))
treedat_ind$DBH1 <- as.numeric(treedat_ind$DBH1)
treedat_ind$RL_GRWTH_U <- as.numeric(treedat_ind$RL_GRWTH_U)
treedat_ind$RL_GRWTH_C <- as.numeric(treedat_ind$RL_GRWTH_C)
treedat_ind$BA_GRWTH_U <- as.numeric(treedat_ind$BA_GRWTH_U)
treedat_ind$BA_GRWTH_C <- as.numeric(treedat_ind$BA_GRWTH_C)

### Now plot growth rates pre and post change in canopy, increment, size
spp <- c("ABAM", "TSHE") #two species with the most data
X11(width=6,height=6)
par(mfrow=c(2,2), omi=c(0,0,0,0), 
    mai=c(0.4,0.4,0.5,0.4), tck=-0.02,
    mgp=c(1.1,0.25,0), xpd=NA)

## for loop for plotting
for(i in 1:length(spp)){
  sppdat <- treedat_ind[treedat_ind$SPECIES==spp[i],]
  sz <- c("smaller","larger")
  
  for(j in 1:2){
    if(j==1){sppdat2 <- sppdat[sppdat$DBH1<=30,]}
    if(j==2){sppdat2 <- sppdat[sppdat$DBH1>30,]}
  
    #make base plot
    ymn <- 0.95*min(c(sppdat2$RL_GRWTH_U, sppdat2$RL_GRWTH_C))
    ymx <- 1.05*max(c(sppdat2$RL_GRWTH_U, sppdat2$RL_GRWTH_C))
    plot(c(1,2), c(mean(sppdat2$RL_GRWTH_U), mean(sppdat2$RL_GRWTH_U)),
         ylim=c(ymn,ymx), xlim=c(0.5,2.5), type="n", xaxt="n", 
         xlab="CANOPY STATUS", ylab="GROWTH (INCREMENT)")
    text(1,ymn-0.02, "under"); text(2,ymn-0.02, "within")
  
    # plot individual trees
    trees <- unique(sppdat2$TREEID)
    for(k in 1:length(trees)){
      indat <- sppdat2[sppdat2$TREEID==trees[k],]
      grths <- c(indat$RL_GRWTH_U, indat$RL_GRWTH_C)
      lines(c(1,2),grths)
      points(c(1,2),grths, pch=21, bg=c("darkgreen","yellowgreen"))
    }
    title(paste(spp[i],sz[j],sep="-"))
  }
}


### Plot BA increment
spp <- c("ABAM", "TSHE") #two species with the most data
X11(width=6,height=6)
par(mfrow=c(2,2), omi=c(0,0,0,0), 
    mai=c(0.4,0.4,0.5,0.4), tck=-0.02,
    mgp=c(1.1,0.25,0), xpd=NA)

## for loop for plotting
for(i in 1:length(spp)){
  sppdat <- treedat_ind[treedat_ind$SPECIES==spp[i],]
  sz <- c("smaller","larger")
  
  for(j in 1:2){
    if(j==1){sppdat2 <- sppdat[sppdat$DBH1<=30,]}
    if(j==2){sppdat2 <- sppdat[sppdat$DBH1>30,]}
    
    #make base plot
    ymn <- 0.95*min(c(sppdat2$BA_GRWTH_U, sppdat2$BA_GRWTH_C))
    ymx <- 1.05*max(c(sppdat2$BA_GRWTH_U, sppdat2$BA_GRWTH_C))
    plot(c(1,2), c(mean(sppdat2$BA_GRWTH_U), mean(sppdat2$BA_GRWTH_U)),
         ylim=c(ymn,ymx), xlim=c(0.5,2.5), type="n", xaxt="n", 
         xlab="CANOPY STATUS", ylab="GROWTH (AREA)")
    mtext("under", side=1, adj=0.25, line=0.1)
    mtext("within", side=1, adj=0.75, line=0.1)
    
    # plot individual trees
    trees <- unique(sppdat2$TREEID)
    for(k in 1:length(trees)){
      indat <- sppdat2[sppdat2$TREEID==trees[k],]
      grths <- c(indat$BA_GRWTH_U, indat$BA_GRWTH_C)
      lines(c(1,2),grths)
      points(c(1,2),grths, pch=21, bg=c("darkgreen","yellowgreen"))
    }
    title(paste(spp[i],sz[j],sep="-"))
  }
}
