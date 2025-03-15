##Files in this folder
##Exploration by JHRL March 15, 2025

1. R script (Canopy&SizeExploration.R). Script that takes in PSP data (TV01002_v17.csv) and assesses how size and canopy status influence growth. Definitely not definitive (made many executive decisions about stands / trees to include, etc).

2. Four figures exploring the relationship between size and growth (ring width and basal area) and canopy status. The first two explore how size and growth (ring width and basal area separately) are related for 6 species in South- side stands, color coding points (each representing a tree) by whether they are under the canopy, above / in the canopy, or their status changed during the many censuses. The second set of figures explore how growth of trees that change status (go from under canopy to in/above canopy) varies.
- Fig_BAvsBAinc.pdf
- Fig_DBHvsRL.pdf
- Fig_indtrees_canopy_BA.pdf
- Fig_indtrees_canopy_RL.pdf

3. Some tidbits / conclusions (JHRL)
- As expected, smaller trees tend to be under the canopy and larger trees in the canopy (this makes sense!). Trees that change status tend to be at a size right in the middle, but not entirely (suggesting that some changes in canopy status occur because of local dynamics - e.g. large nearby tree falling down).
- There does seem to be size-dependent growth visible in the data (smaller trees grow less), which is really only visible in basal area increment vs. basal area patterns. It is extremely noisy (lots of tree to tree variability), and saturation occurs at relatively small size (probably smaller than most of the trees we cored); except maybe for PSME.
- For trees that change status, growth does not seem to increase, lots of tree to tree variability, and for many trees indeed growth decreases when canopy status changes (!!!) - especially when exploring these patterns in RL.   
- There are a lot of U's (unknown canopy status, or not assessed), and this seems to be not entirely independent of census date - suggesting maybe this stopped being a priority recently?


My conclusion: First, I am now skeptical that we can include canopy status as a meaningful covariate in any models of growth using PSP data. It's correlated with size, and there are a lot of unknowns in the data. It's also the case that we don't have many of the very smallest trees (<15 cm dbh) where we might affect size constraints on growth to be the greatest??? We might want to include size, with all the caveats / issues that occur due to geometry (ring width vs basal area). For tree ring analyses - I am also less convinced we should add some sort of size specific covariate, since we are primiarly working with larger trees with lots of other trends. Letting the tree-specific GP processes take out any trends (whether due to size or other processes) seems a reasonable way to model this.