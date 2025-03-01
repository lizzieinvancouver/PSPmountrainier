Started 3 October 2023
By Lizzie so far

** PLEASE see below for: Citation for data ** 
Data available at: https://pnwpsp.forestry.oregonstate.edu/data
Most relevant for us for tree data: https://andlter.forestry.oregonstate.edu/data/abstract.aspx?dbcode=TV010

Also add data citation: Franklin, J.F., D. Bell, S.M. Remillard, and M. Powers. 2023. Long-term growth, mortality and regeneration of trees in permanent vegetation plots in the Pacific Northwest, 1910 to present ver 24. Environmental Data Initiative. https://doi.org/10.6073/pasta/5835a1fadb7fd65842f90256edae999c (Accessed 2023-09-23).

Sections are:

Overview
Tree data files (\trees)
Climate data files (\climate)
Citation for tree data
Misc notes (including ideas of what we could look at) 
trees2024/ folder

<><><><><><><>
<> Overview <>
<><><><><><><>

My goal was to track down tree stand data (ideally for Mount Rainier, where we have some local knowledge) where we could model something about tree growth. The first hurdle was that most data reported is NOT the raw data. It's often Basal Area (BA) per m squared, or volume or such. But I found the raw data, with some help from the data providers. I explain the basics of those two files below.

I am trying not to repeat metadata elsewhere, but (from TVO10.Metadata.pdf): 

Plots [of forest trees in forests] are censused every 5 or 6 years. Attributes measured or assessed at each census include tree diameter, tree vigor, and the condition of the crown and stem. The same attributes are recorded for trees (ingrowth) that have exceeded the minimum diameter since the previous census. In many plots tree locations are surveyed to provide a plot-specific x-y location. A mortality assessment is done for trees that have died since the previous census. The assessment characterizes rooting, stem, and crown condition, obvious signs of distress or disturbance, and the apparent predisposing and proximate causes of tree death.


<><><><><><><><><><><>
<> Tree data files <>
<><><><><><><><><><><>

** TV01001_v2.csv - Very rough categories for size-y things and healthy ratings (sort of) for each tree.

Initial tree conditions with spatial coordinates (Oct 1 1910 - Apr 1 2010); basically gives you a sense of how many 'boles' (trunks) the tree has and the status of its crowns and root. 

More info at: https://andlter.forestry.oregonstate.edu/data/attributes.aspx?dbcode=TV010&entnum=1

** TV01002_v17.csv - is the data they collect on each tree every 5-6 years. 

Individual tree remeasurement (Feb 1 1910 - Aug 17 2022): Table containing periodic remeasurement data of individual trees within reference stands

More info at: https://andlter.forestry.oregonstate.edu/data/attributes.aspx?dbcode=TV010&entnum=2, (and TVO10.Metadata.pdf) but some relevant columns:

PSP_STUDYID: Big dividers between where they have 'stands' -- we are invested in MRRS (Mount Rainier)

STANDID: This is the most relevant spatial unit to me with PLOT nested within it. Stand ID is usually a unique elevation or forest type or such. 

TREEID: Tree identification code represented as STANDID+PLOTID+00000, where 00000 represents a unique tree number for that stand and plot

SPECIES: What species? 4 letter code

YEAR: Year of establishment, remeasurement, or mortality

TREE_STATUS: 1 means the tree is living, other codes are in TV010.Metadata

DBH -- diameter at breast height (take a tape measure, wrap around tree usually but see DBH_CODE for times they did it slightly differently)

I have also included:

** TV01003_v17.csv - Individual tree mortality (Feb 1 1910 - Aug 17 2022): Table recording individual tree mortality year and contributing conditions and causes of mortality

More info at: https://andlter.forestry.oregonstate.edu/data/attributes.aspx?dbcode=TV010&entnum=3

** TV01004.csv - Tree heights (Feb 1 1910 - Aug 1 2004): Height data of selected trees.

More info at: https://andlter.forestry.oregonstate.edu/data/attributes.aspx?dbcode=TV010&entnum=4

I also have info on plot establishment and description, but cannot post online. 

<><><><><><><><><><><><><><>
<> Climate data <>
<><><><><><><><><><><><><><>

I went to: https://climexp.knmi.nl/

And pulled GHCN min and max temperature, precipitation and snowfall and snow depth data for (info below for min temp):

RAINIER_PARADISE_RS,_WA (United States)
coordinates: 46.79N, -121.74E, 1654.0m
GHCN-D station code: USC00456898

Could also pair with LONGMIRE (two separate datasets: 1909-1978 and 1978-2023)

<><><><><><><><><><><><><><>
<> Citation for tree data <>
<><><><><><><><><><><><><><>

Updated here: https://andrewsforest.oregonstate.edu/acknowledgements

As of 3 October 2023 they ask that for these TWO things, and please also do the third:
(1) You include a citations (with DOI) to the datasets you're using (Please include a data citation (including DOI) in your references. A data citation is provided on web pages for each of our datasets)  
(2) Either the short or long acknowledgement:

SHORT: "This material is based upon work supported by the H.J. Andrews Experimental Forest and Long Term Ecological Research (LTER) program under the NSF grant LTER8 DEB-2025755."

LONG: "Data [and/or facilities] were provided by the H.J. Andrews Experimental Forest and Long Term Ecological Research (LTER) program, administered cooperatively by Oregon State University, the USDA Forest Service Pacific Northwest Research Station, and the Willamette National Forest. This material is based upon work supported by the National Science Foundation under the grant LTER8 DEB-2025755."

(3) Please send a PDF or full citation of your Andrews Forest related publications to HJApubs@lists.oregonstate.edu. We keep track of all Andrews Forest publications. Thank you!

(4) Also add reference to data citation: 
Franklin, J.F., D. Bell, S.M. Remillard, and M. Powers. 2023. Long-term growth, mortality and regeneration of trees in permanent vegetation plots in the Pacific Northwest, 1910 to present ver 24. Environmental Data Initiative. https://doi.org/10.6073/pasta/5835a1fadb7fd65842f90256edae999c (Accessed 2023-09-23).

<><><><><><><>
<> Misc notes <>
<><><><><><><>

Could look at tree growth for one species (or more) over time in one STAND. Stands to consider:
	- AE10 is high elevation site — climate data from Paradise (fairly close) and is fairly species poor
	- AV06 - Lower in elevation (more species) is Longmire climate data (Ranger station) but climate data may not be as good

Could look at elevational trends in tree growth. 

Chatted with Ailene Ettinger on 4 Oct 2023:

She mentioned two papers on these data:
https://cdnsciencepub.com/doi/abs/10.1139/X10-149 (The tree mortality regime in temperate old-growth coniferous forests: the role of physical damage)
https://www.science.org/doi/abs/10.1126/science.1165000 (Widespread Increase of Tree Mortality Rates in the Western United States)

She also said she is not sure if plot is relevant; standID is the unit she has used.

She would not be surprised if height is not always sampled.

Notes -- she shew WtchBrm is a Witch's Broom, a likely sign of disease.

She said the climate data sounded right.


><><><><><><><><><><><>
<> trees2024/ folder <>
><><><><><><><><><><><>
These data were received from Andy Bluhm on 28 February 2025 (to Lizzie).
They are data we requested for our 2025 BIRS (Banff) workshop -- the 2024 collected data in advance of it being fully processed. Here's the email that came with the files:

Lizzie,
Attached is the (non QAQC'd) data from the PSP Mt. Rainier stands collected in 2024.
Our data collection app spits out three files. Then through the PSP/USFS database management system, we clean and merge the data into something like what you use (TV001002). But that process, unfortunately, won't be started for a long time. In the meantime, here's what I have for you.

standdoc_MRRS_2024: notes about the stands/sites
mortality_MRRS_2024: dead tree measurements
trees_MRRS_2024: live tree measurements

It shouldn't be too onerous to reformat/merge/append to what you've been working with. The variables are all pretty much the same as what you've been using. 

Note: The other "type" of data we collect are tree locations (mainly used for mapping and creating stem maps). You have these maps. However, last summer I noticed that there were a significant number of sites that had a significant number of mismapped or unmapped trees. So if you're using the stem maps you already have for any type of spatial analysis, please be aware of that. The "trees_MRRS_2024" file has mapping data for both mis-mapped and previously unmapped trees. It's on my list to update these stem maps, but I won't be getting to that anytime soon.

If you have any questions about something please let me know.

Andy