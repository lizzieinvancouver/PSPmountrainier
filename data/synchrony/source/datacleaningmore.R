## Extracted from syncmodels.R ##
## on 27 Feb 2017 ##

#new changes to data (Oct 2016): No longer unique: Caterpillar 2a, 2b, 2c, 2d; Daphnia 3a, 3b; Paurs 2a, 2b caeruleus; Pyg. antarcticus a and b; Caterpillar4 now 4a and 4b
rawlong<-subset(rawlong, species!="asdf1" & species!="asdf2")
#asdf1= Diatom2b, asdf2= Thermocyclops oithonoides but first stage, in analysis now, last phenophase


#fix for Diatom4 spp. Dec 2016
sub<-subset(rawlong, species=="Diatom4 spp." & intid=="194");
sub[,c("species")]<-"Diatom4a spp."
rawlong<-rbind(rawlong, sub)
sub<-subset(rawlong, species=="Diatom4 spp." & intid=="195");
sub[,c("species")]<-"Diatom4b spp."
rawlong<-rbind(rawlong, sub)
sub<-subset(rawlong, species=="Diatom4 spp." & intid=="196");
sub[,c("species")]<-"Diatom4c spp."
rawlong<-rbind(rawlong, sub)
rawlong<-subset(rawlong, species!="Diatom4 spp.")




##
# figure out how many unique species
# and alter the data so each unique species shows up once
# watch out: if you leave in int_type you still get duplicated species...
# so it's not below until after duplicate species are removed!
specieschar.wdups <- aggregate(rawlong["phenovalue"],
    rawlong[c("studyid", "species", "spp")], FUN=length)
specieschar <- aggregate(specieschar.wdups["phenovalue"],
    specieschar.wdups[c("studyid", "species")], FUN=length)
#dupspp <- subset(specieschar, phenovalue>1)
#specieschar.wdups[which(specieschar.wdups$species %in% dupspp$species),] #there are some species with mult relationships
# delete duplicate species as spp1 (generally the shorter timeseries)
#rawlong.nodups <- rawlong[-(which(rawlong$species %in% dupspp$species &
   # rawlong$spp=="spp1")),]
# and order it!
rawlong.nodups<-rawlong
rawlong.nodups <- rawlong.nodups[with(rawlong.nodups, order(species, year)),]
#rawlong.nodups$newid<-with(rawlong.nodups, paste(intid,"_",species))
yy#rawlong.nodups <- rawlong.tot[with(rawlong.nodups, order(newid)),]
#specieschar.formodel <- aggregate(rawlong.nodups["phenovalue"],
  #  rawlong.nodups[c("studyid", "species", "intid", "terrestrial","spp")], FUN=length) 
 #specieschar.formodel <- specieschar.formodel[with(specieschar.formodel, order(species)),]   

#number of years per species
    
##

## Hinge models

##
# Heather's code to add in data formatted for hinge model
hinge <- subset(rawlong.nodups, intid=="170" | intid=="171" | intid=="177" |
    intid=="178" | intid=="179" | intid=="180" |intid=="181" | intid=="189" |
    intid=="191"|intid=="193" |intid=="194" | intid=="195" |intid=="196"|
    intid=="201" |intid=="207" |intid=="208")

hinge_non <- subset(rawlong.nodups, intid!="170" & intid!="171" & intid!="177"
     & intid!="178" & intid!="179" & intid!="180" & intid!="181" & intid!="189"
     & intid!="191" & intid!="193" & intid!="194" & intid!="195" & intid!="196"
     & intid!="201" & intid!="207" & intid!="208")

hinge_non$newyear<-hinge_non$year
hinge_pre<-subset(hinge, year<=1981); hinge_pre$newyear<-1981
hinge_post<-subset(hinge, year>1981); hinge_post$newyear<-hinge_post$year
hinges<-rbind(hinge_pre, hinge_post)
rawlong.tot<-rbind(hinge_non, hinges)


# prep the data to fit the model including:
# aggregate to get species level characteristics
# subset down to the phenovalues
# Run stan on unique species (n=88)
# (old) Run stan on 108 unique intid-species interactions (n=108) (NOT unique species (n=91))
rawlong.tot <- arrange(rawlong.tot, species)
rawlong.tot$yr1981 <- rawlong.tot$newyear-1981
rawlong.tot <- rawlong.tot[with(rawlong.tot, order(species)),]
#rawlong.tot$newid<-with(rawlong, paste(intid,"_",species)); 
#rawlong.tot <- rawlong.tot[with(rawlong.tot, order(species)),]
rawlong.tot2<-unique(rawlong.tot[,c("studyid","species","phenovalue","yr1981","year")]) #CLEAN UP so only unique values across repeating species within studoes
write.csv(rawlong.tot2, "output/rawlong.tot2.csv")
write.csv(rawlong.nodups, "output/rawlong.nodups.csv")



