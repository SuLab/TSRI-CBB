#Notes and Script for R-Users Group: A Continuation of Mapping
  #Natalya Gallo
  #May 6, 2020

#clear workspace
rm(list = ls())

#Helpful resources
  #GIS in R
      #https://www.jessesadler.com/post/gis-with-r-intro/
      #https://www.jessesadler.com/post/simple-feature-objects/
      #https://www.r-spatial.org//r/2018/10/25/ggplot2-sf.html
  #sf package 
      #https://r-spatial.github.io/sf/
      #sf cheatsheet:https://github.com/rstudio/cheatsheets/blob/master/sf.pdf
  #1-Day Data Wrangling and Spatial Analysis R Course
      #http://www.seascapemodels.org/rstats/2019/02/23/new-r-course-posted-online.html
  #Leaflet for interactive maps
      #https://rstudio.github.io/leaflet/
      #http://leaflet-extras.github.io/leaflet-providers/preview/index.html
  #Importing bathymetry and coastline data
      #https://www.r-bloggers.com/importing-bathymetry-and-coastline-data-in-r/
  #marmap package: awesome package for plotting bathymetric data
        #https://www.molecularecologist.com/2015/07/marmap/
        #http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0073051 (check out the Supplementary code)
        #https://cran.r-project.org/web/packages/marmap/vignettes/marmap.pdf

#Goals for today:
  #Make a map of CalCOFI stations and look at how they overlap with marine conservation
    #areas in the region (using the sf package)
  #Make an interactive map of all historic CalCOFI stations and colorcode by 
    #sampling frequency (using the leaflet package)
  #Add bathymetry and coastline data (using the marmap package) 
    #(probably won't get to this)

library(sf)
library(sp)
library(ggplot2)
library(rnaturalearth)
library(ggspatial)
library(tidyverse)
library(marmap)
library(leaflet)
library(maps)
library(RColorBrewer)

#to follow along and create all maps, this Rdata file should have all input included
load(file="Maps_RUsers_Gallo.RData")

#Caveat about sf. Installing sf may prove to be a bit tricky depending 
#on your OSX. sf depends on lots of other packages including rgdal and rgdal is 
#famous for issues with installation. So see how you go. If sf won’t install, 
#then just follow along on our screen for now and figure that out later 
#(with lots of googling).

# Plotting CalCOFI Grid Stations
#Note, coordinates are in a signed degrees format (DDD.dddd) (decimal degrees) 
CalCOFI_Stations = read.csv("CalCOFIStaPosNDepth113.csv", header=TRUE)
head(CalCOFI_Stations)

CalCOFI_Stations$Dlongitude = CalCOFI_Stations$Dlongitude*-1
summary(CalCOFI_Stations)
str(CalCOFI_Stations)

#In order to convert our data frame to an sf object assign a known CRS to 
#spatial data:
#WGS84 (EPSG: 4326) is the CRS commonly used by organizations that provide 
#GIS data for the entire globe or many countries. CRS used by Google Earth. 
#So, if you have lat/long GPS data, WGS84 is the right CPS to use. 

#Convert our dataframe into an sf object and assign CRS
CalCOFI_sdf <- st_as_sf(CalCOFI_Stations, coords = c("Dlongitude", "Station.Dlatitude"), crs = "+init=epsg:4326")
st_crs(CalCOFI_sdf) #check that CRS was properly assigned

#Plot data
ggplot() +
  geom_sf(data = CalCOFI_sdf) +
  ggtitle("CalCOFI Stations")

#Now transform from one CRS to another to project coordinates. 
#California Teale Albers (NAD83 California Albers) EPSG:3310 
#This CRS gives you distances in m and works for CA. Recommended by Kevin
#Stierhoff to use for US West Coast
#To look up different CRS options, look here: https://spatialreference.org/
CalCOFI_sdf_tf <- st_transform(CalCOFI_sdf, crs = "+init=epsg:3310")
st_crs(CalCOFI_sdf_tf) #check that reprojection worked

#Plot stations to check that reprojection worked
ggplot() +
  geom_sf(data = CalCOFI_sdf_tf) +
  ggtitle("CalCOFI Stations")

#Import shapefiles to build into figure
#To import a shapefile using sf, you need to use st_read() and use the 
#file path to the shapefile

#Plotting US EEZ
US_EEZ_sf = st_read("/Users/natalyagallo/Desktop/CalCOFI_Fig/useez/useez.shp")
#downloaded from https://coastalmap.marine.usgs.gov/GISdata/basemaps/boundaries/eez/NOAA/useez_noaa.htm
#Reproject to match CalCOFI station CRS
US_EEZ_sf_tf <- st_transform(US_EEZ_sf, crs = "+init=epsg:3310")
st_crs(US_EEZ_sf_tf) #check that reprojection worked

#Plot stations to check that reprojection worked
ggplot() +
  geom_sf(data = US_EEZ_sf_tf) +
  ggtitle("US EEZ")

#CA State Waters (shapefile provided by Kevin Stierhoff)
State_Waters_sf = st_read("/Users/natalyagallo/Desktop/CalCOFI_Fig/Natalya_shapefiles/MAN_CA_StateWater.shp")
#Reproject to match CalCOFI station CRS
State_Waters_sf_tf <- st_transform(State_Waters_sf, crs = "+init=epsg:3310")
st_crs(State_Waters_sf_tf) #check that reprojection worked

#Plot stations to check that reprojection worked
ggplot() +
  geom_sf(data = State_Waters_sf_tf) +
  ggtitle("CA State Waters")

#Determine overlap between CalCOFI Stations and CA State Waters with this file
CalCOFI_in_State <-  sf::st_intersection(CalCOFI_sdf_tf, State_Waters_sf_tf) 
summary(CalCOFI_in_State)
print(CalCOFI_in_State, n = 20) #16 stations

ggplot() +
  geom_sf(data = State_Waters_sf_tf) +
  geom_sf(data = CalCOFI_in_State) + 
  ggtitle("CalCOFI in CA State Waters")

# Get country world maps as Spatial objects using rnaturalearth
countries_sp <- ne_countries(scale = "medium")
#transform to same CRS
countries_sp_tf <- spTransform(countries_sp, CRS("+init=epsg:3310")) 
proj4string(countries_sp_tf) #check that reprojection worked
countries_sf_tf = st_as_sf(countries_sp_tf)

#Plot stations to check that reprojection worked
ggplot() +
  geom_sf(data = countries_sf_tf) +
  ggtitle("Countries data")

#Plotting State Boundaries
State_bound_sf = st_read("/Users/natalyagallo/Desktop/CalCOFI_Fig/cb_2017_us_state_500k/cb_2017_us_state_500k.shp")
#downloaded from https://www.census.gov/geo/maps-data/data/cbf/cbf_state.html
#Reproject to match CalCOFI station CRS
State_bound_sf_tf <- st_transform(State_bound_sf, crs = "+init=epsg:3310")
st_crs(State_bound_sf_tf) #check that reprojection worked

#Plot stations to check that reprojection worked
ggplot() +
  geom_sf(data = State_bound_sf_tf) +
  ggtitle("State Boundaries")

#Figure 1a - plot of Extended CalCOFI grid with stations colorcoded by 
#jurisdiction
CalCOFI_sdf_tf #used bbox info to set x and y limits
Fig1a = ggplot() +
  geom_sf(data = US_EEZ_sf_tf) +
  geom_sf(data = countries_sf_tf, fill = "antique white") +
  geom_sf(data = State_Waters_sf_tf) +
  geom_sf(data = State_bound_sf_tf, fill = "antique white") +
  geom_sf(data = CalCOFI_sdf_tf, aes(color = Jurisdiction, shape = Core)) +
  scale_color_manual(values = c("#0072B2", "gray0", "#D55E00")) +
  scale_shape_manual(values = c(15, 8, 19)) +
  coord_sf(xlim = c(-621392.1, 325195.7), ylim = c(-995904.5, -10328.39)) +
  annotation_scale(location = "bl", width_hint = 0.5) +
  ggtitle("CalCOFI Stations") +
  theme(legend.position="none") +
  theme(panel.grid.major = element_line(color = gray(.5), 
  linetype = "dashed", size = 0.5), 
  panel.background = element_rect(fill = "aliceblue"))
Fig1a

#But what if you want to add labels?

#Messy way to put station and line labels into figures
#Save x-y coordinates from sf object for CalCOFI stations
For_Labels <- CalCOFI_sdf_tf$geometry
For_Labels
#Convert sfc_POINT object to x,y columns: https://github.com/r-spatial/sf/issues/231
For_Labels_2 <- do.call(rbind, st_geometry(For_Labels)) %>% 
  as_tibble() %>% setNames(c("lat", "lon")) %>% as.data.frame()
For_Labels_2

#Add lable information
For_Labels_2$Label_1 <- CalCOFI_Stations$Label_1
For_Labels_2$Label_2 <- CalCOFI_Stations$Label_2
For_Labels_2$Label_3 <- CalCOFI_Stations$Label_3
For_Labels_2$Label_4 <- CalCOFI_Stations$Label_4
For_Labels_2$Label_5 <- CalCOFI_Stations$Label_5
For_Labels_2$Label_6 <- CalCOFI_Stations$Label_6
For_Labels_2$Label_7 <- CalCOFI_Stations$Label_7
For_Labels = For_Labels_2
str(For_Labels)

#Adding labels
Fig1a + 
  geom_text(data = For_Labels, aes(x = lat, y = lon, label=Label_1), size = 3, hjust=1.7, vjust=0.25, angle = 30) +
  geom_text(data = For_Labels, aes(x = lat, y = lon, label=Label_2), size = 3, hjust=2.6, vjust=0.25, angle = 30) +
  geom_text(data = For_Labels, aes(x = lat, y = lon, label=Label_3), size = 3, hjust=0.5, vjust=2.5, angle = 30, check_overlap = TRUE) +
  #geom_text(data = For_Labels, aes(x = lat, y = lon, label=Label_4), size = 3, hjust=-0.20, vjust = 0.25, angle = 30, colour = "red") +
  geom_text(data = For_Labels, aes(x = lat, y = lon, label=Label_5), size = 3, hjust=0.5, vjust=-1.5, angle = 30, check_overlap = TRUE) +
  theme(axis.title.x = element_blank(), axis.title.y = element_blank())  
ggsave("Figure1a.pdf")

## What if you want to know how many CalCOFI stations fall within marine conservation
  # areas? CA MPAs, Cowcod Conservation Area, National Marine Sanctuaries

CAMPAs_sf = st_read("/Users/natalyagallo/Desktop/CalCOFI_Fig/CAMPAs/ds582.shp")
#downloaded from: https://map.dfg.ca.gov/metadata/ds0582.html
#Reproject to match CalCOFI station CRS
CAMPAs_sf_tf <- st_transform(CAMPAs_sf, crs = "+init=epsg:3310")
st_crs(CAMPAs_sf_tf) #check that reprojection worked

#Plot stations to check that reprojection worked
ggplot() +
  geom_sf(data = CAMPAs_sf_tf) +
  ggtitle("CA MPAs")

#Determine overlap between sampling and MPAs
CalCOFI_in_MPA <-  sf::st_intersection(CalCOFI_sdf_tf, CAMPAs_sf_tf) 
summary(CalCOFI_in_MPA)
CalCOFI_in_MPA

ggplot() +
  geom_sf(data = CalCOFI_in_MPA) +
  geom_sf(data = CAMPAs_sf_tf)
ggtitle("CalCOFI in MPAs")

#Plotting Cowcod Conservation Area
CCA_sf = st_read("/Users/natalyagallo/Desktop/CalCOFI_Fig/CCA/MAN_SCSR_Cowcod_ConsArea.shp")
#downloaded from https://earthworks.stanford.edu/catalog/stanford-kv299cy7357
#Reproject to match CalCOFI station CRS
CCA_sf_tf <- st_transform(CCA_sf, crs = "+init=epsg:3310")
st_crs(CCA_sf_tf) #check that reprojection worked

#Plot stations to check that reprojection worked
ggplot() +
  geom_sf(data = CCA_sf_tf) +
  ggtitle("Cowcod Conservation Area")

#Determine overlap between sampling and MPAs
CalCOFI_in_CCA <-  sf::st_intersection(CalCOFI_sdf_tf, CCA_sf_tf) 
summary(CalCOFI_in_CCA)
CalCOFI_in_CCA

ggplot() +
  geom_sf(data = CCA_sf_tf) +
  geom_sf(data = CalCOFI_in_CCA) + 
  ggtitle("CalCOFI in CCA")

#Look at overlap between CalCOFI Stations and National Marine Sanctuaries
#Get Shapefiles for National Marine Sanctuaries
#Grand Farallones
GF_NMS_sf = st_read("/Users/natalyagallo/Desktop/CalCOFI_Fig/gfnms_py2/GFNMS_py.shp")
#Reproject to match CalCOFI station CRS
GF_NMS_sf_tf <- st_transform(GF_NMS_sf, crs = "+init=epsg:3310")
st_crs(GF_NMS_sf_tf)

#Cordell Bank
CB_NMS_sf = st_read("/Users/natalyagallo/Desktop/CalCOFI_Fig/cbnms_py2/CBNMS_py.shp")
#Reproject to match CalCOFI station CRS
CB_NMS_sf_tf <- st_transform(CB_NMS_sf, crs = "+init=epsg:3310")
st_crs(CB_NMS_sf_tf)

#CINMS
CI_NMS_sf = st_read("/Users/natalyagallo/Desktop/CalCOFI_Fig/cinms_py2/cinms_py.shp")
#Reproject to match CalCOFI station CRS
CI_NMS_sf_tf <- st_transform(CI_NMS_sf, crs = "+init=epsg:3310")
st_crs(CI_NMS_sf_tf)

#MBNMS
MB_NMS_sf = st_read("/Users/natalyagallo/Desktop/CalCOFI_Fig/mbnms_py2/mbnms_py.shp")
#Reproject to match CalCOFI station CRS
MB_NMS_sf_tf <- st_transform(MB_NMS_sf, crs = "+init=epsg:3310")
st_crs(MB_NMS_sf_tf)

#Determine overlap between CalCOFI Stations and NMS with this file
CalCOFI_in_GF_NMS <-  sf::st_intersection(CalCOFI_sdf_tf, GF_NMS_sf_tf) 
summary(CalCOFI_in_GF_NMS) #1 station

CalCOFI_in_CB_NMS <-  sf::st_intersection(CalCOFI_sdf_tf, CB_NMS_sf_tf) 
summary(CalCOFI_in_CB_NMS) #0 stations

CalCOFI_in_CI_NMS <-  sf::st_intersection(CalCOFI_sdf_tf, CI_NMS_sf_tf) 
summary(CalCOFI_in_CI_NMS) #1 station

CalCOFI_in_MB_NMS <-  sf::st_intersection(CalCOFI_sdf_tf, MB_NMS_sf_tf) 
summary(CalCOFI_in_MB_NMS) #7 stations

#Figure 1b - plot of CalCOFI stations within MPAs with stations colorcoded by 
#jurisdiction
CalCOFI_in_MPA #used bbox info to set x and y limits

Fig1b = ggplot() +
  geom_sf(data = State_bound_sf_tf, fill = "antique white") +
  geom_sf(data = CalCOFI_sdf_tf, aes(color = Jurisdiction, shape = Core)) +
  scale_color_manual(values = c("#0072B2", "gray0", "#D55E00")) +
  scale_shape_manual(values = c(15, 8, 19)) +
  geom_sf(data = CAMPAs_sf_tf) + 
  geom_sf(data = CalCOFI_in_MPA) +
  coord_sf(xlim = c(-43124.25, 209416.9), ylim = c(-551191.5, -376106.9)) +
  annotation_scale(location = "bl", width_hint = 0.5) +
  ggtitle("CalCOFI Stations in MPAs") +
  theme(legend.position="none") +
  theme(panel.grid.major = element_line(color = gray(.5), 
  linetype = "dashed", size = 0.5), 
  panel.background = element_rect(fill = "aliceblue"))
Fig1b
ggsave("Figure1b.pdf")

#Figure 1c - plot of CalCOFI stations within CCA with stations colorcoded by 
#jurisdiction

CCA_sf_tf #used bbox info to set x and y limits
#xmin: 10608.86 ymin: -630772 xmax: 203346.9 ymax: -464041.6

Fig1c = ggplot() +
  geom_sf(data = US_EEZ_sf_tf) +
  geom_sf(data = State_bound_sf_tf, fill = "antique white") +
  geom_sf(data = CalCOFI_sdf_tf, aes(color = Jurisdiction, shape = Core)) +
  scale_color_manual(values = c("#0072B2", "gray0", "#D55E00")) +
  scale_shape_manual(values = c(15, 8, 19)) +
  geom_sf(data = CCA_sf_tf) + 
  geom_sf(data = CalCOFI_in_CCA) +
  coord_sf(xlim = c(8508.86, 253346.9), ylim = c(-640772, -464041.6)) +
  annotation_scale(location = "bl", width_hint = 0.5) +
  ggtitle("CalCOFI Stations in CCA") +
  theme(legend.position="none") +
  theme(panel.grid.major = element_line(color = gray(.5), 
  linetype = "dashed", size = 0.5), 
  panel.background = element_rect(fill = "aliceblue"))
Fig1c
ggsave("Figure1c.pdf")

#Figure with National Marine Sanctuaries
GF_NMS_sf_tf

Fig1d = ggplot() +
  #geom_sf(data = US_EEZ_sf_tf) +
  geom_sf(data = countries_sf_tf, fill = "antique white") +
  geom_sf(data = State_bound_sf_tf, fill = "antique white") +
  geom_sf(data = CalCOFI_sdf_tf, aes(color = Jurisdiction, shape = Core)) +
  scale_color_manual(values = c("#0072B2", "gray0", "#D55E00")) +
  scale_shape_manual(values = c(15, 8, 19)) +
  #geom_sf(data = State_Waters_sf_tf) +
  geom_sf(data = GF_NMS_sf_tf, fill=alpha('blue', 0.4)) +
  geom_sf(data = CB_NMS_sf_tf, fill=alpha('#3182bd', 0.4)) +
  geom_sf(data = CI_NMS_sf_tf, fill=alpha('#ae017e', 0.4)) +
  geom_sf(data = MB_NMS_sf_tf, fill=alpha('#08306b', 0.4)) + 
  geom_sf(data = CalCOFI_in_GF_NMS, pch = 15) + 
  geom_sf(data = CalCOFI_in_CB_NMS, pch = 15) +
  geom_sf(data = CalCOFI_in_CI_NMS, pch = 19) +
  geom_sf(data = CalCOFI_in_MB_NMS, pch = 15) +
  coord_sf(xlim = c(-431392.1, 135195.7), ylim = c(-508904.5, 117907.2)) +
  annotation_scale(location = "bl", width_hint = 0.5) +
  ggtitle("CalCOFI Stations in NMS") +
  theme(legend.position="none") +
  theme(panel.grid.major = element_line(color = gray(.5), 
  linetype = "dashed", size = 0.5), 
  panel.background = element_rect(fill = "aliceblue"))
Fig1d
ggsave("Figure1d.pdf")

#mapping tip!
#drawExtent() which enters R into an interactive mode. In the interactive 
#mode we can click two points on the graph and R will tell us their grid 
#coordinates. Another option to using bbox.
plot(rsst)
drawExtent()

### PART 2: What if you want to make an interactive map for people to access?
  #Leaflet package

#Leaflet makes use of a Javascript (this is the language that dynamic web pages 
#tend to use) package for mapping. It builds maps of your data ontop a range 
#of freely available map layers. Check out this guide to leaflet in R for more 
#examples: https://rstudio.github.io/leaflet/
#Leaflet uses javascript, so it is code that runs in a user’s browser. This means
#anyone looking at the map on the web has to download all the data before they 
#can render the map. So you should keep your spatial datasets small if you want 
#to use leaflet - imagine your collegues trying to download your 100mb spatial 
#data layer on their mobile data plan.
#To make the map, we first specify the dataframe to use with leaflet. 
#Then we add tiles, which is the base layer. Then we add markers at the 
#coordinates of our copepod sites.
#Note: these notes were copied from: http://www.seascapemodels.org/data/data-wrangling-spatial-course.html

#Second part of the tutorial
#Introduction to mapping and spatial analysis in R
setwd("/Users/natalyagallo/Desktop/data_for_course")
cope <- read.csv("spatial-data/copepods_standardised.csv")
head(cope)

#first use maps package to map your data
map(database = 'world')
points(cope$longitude, cope$latitude)
range(cope$longitude)
range(cope$latitude)

map(database = 'world', xlim = c(100, 160), ylim = c(-67, -10), col = 'grey', 
    fill = T, border = NA)
points(cope$longitude, cope$latitude, cex = 0.5, col = 'grey20')
axis(2, las = 1, ylim = c(-65, -10), cex.axis = 0.7)
ylabel <- expression(paste("latitude (" ^o, "N)"))
text(85, -35, ylabel, xpd = NA, srt = 90, cex = 0.8)
#Check out ?axis if you want to make further modifications to this axis. 

#Adding SST
#We have provided you with two files MeanAVHRRSST.gri and MeanAVHRRSST.grd which 
#contain gridded maps of annual mean sea surface temperature from the Hadley 
#dataset. Gridded data, also known as raster data, can be read and manipulated
#with the raster package.
rsst <- raster('spatial-data/MeanAVHRRSST')
plot(rsst)

#to recreate the plot in ggplot, we need to turn the raster into a dataframe
dat_grid <- data.frame(xyFromCell(rsst, 1:ncell(rsst)), vals = rsst[])
head(dat_grid)
ggplot(dat_grid, aes(x = x, y = y, fill = vals)) + geom_tile() 

#With RColorBrewer use scale_fill_brewer (for discrete colours) and 
#scale_fill_distiller (for continuous colours)
ggplot(dat_grid, aes(x = x, y = y, fill = vals)) + geom_tile() + 
  scale_fill_distiller(type = "seq", palette = "RdPu", direction = 1) +
  theme_dark()

#Add sample points
ggplot(dat_grid, aes(x = x, y = y, fill = vals)) + geom_tile() +
  scale_fill_distiller(type = "seq", palette = "RdPu", direction = 1) +
  geom_point(data = cope, aes(x = longitude, y = latitude), fill = grey(0.8, 0.5), size = 0.5)+
  theme_dark()

#simplify the raster by aggregating it
rsst_blocky <- aggregate(rsst, 5)
dat_block <- data.frame(xyFromCell(rsst_blocky, 1:ncell(rsst_blocky)),
                        vals = rsst_blocky[])

#change the map projection to an orthagonal projection
ggplot(dat_block, aes(x = x, y = y, fill = vals)) + geom_tile() +
  scale_fill_distiller(type = "seq", palette = "RdPu", direction = 1) +
  geom_point(data = cope, aes(x = longitude, y = latitude), fill = grey(0.8, 0.5), size = 0.5) +
  theme_dark() + coord_map("ortho", orientation = c(-40, 135, 0))

#We won’t cover transforming projections here, except to say that for rasters 
#you can transform the projection using projectRaster() and for point (or 
#polygon, or line) data you will want to use spTransform() from the sp package 
#or st_transform() from the sf package (newer and better).

#Plot some land over our raster using shapefiles
#Geocomputation in R is a good resource for learning about spatial analysis in 
#R: https://geocompr.robinlovelace.net/
aus <- st_read(dsn = "spatial-data", "Aussie")
ggplot() +
  geom_sf(data = aus) 

ggplot() +
  geom_tile(data = dat_block, aes(x = x, y = y, fill = vals)) +
  scale_fill_distiller(type = "seq", palette = "RdPu", direction = 1) +
  geom_point(data = cope, aes(x = longitude, y = latitude), fill = grey(0.8, 0.5), size = 0.5) +
  geom_sf(data = aus)  +
  theme_dark() 

#Extract SSTs at the sampling sites
pts <- cbind(cope$longitude, cope$latitude)
#This matrix gives the coordinates we want to extract SST for. Now we just use 
#the extract function in the raster package to obtain SST at each site. We can 
#assign the outcome of extract directly back into our dataframe for copepods 
#too. 
cope$sst <- raster::extract(rsst, pts)

subset(cope, is.na(sst)) #3 datapoints with no SST, remove these
cope <- subset(cope, !is.na(sst)) 
#The ! just means ‘NOT’, so we are asking for the rows that are not NA (missing).

head(cope)
#Now create an interactive map with leaflet

cope_gridded <- cope %>%
  mutate(lat = round(latitude), lon = round(longitude)) %>%
  group_by(lat, lon) %>%
  summarize(richness = mean(richness), sst = mean(sst))

head(cope_gridded)

print(object.size(cope), units = "Kb") #check size
print(object.size(cope_gridded), units = "Kb") #check size

leaflet(cope_gridded) %>%
  addTiles() %>%
  addCircleMarkers(lng = ~lon, lat = ~lat, radius = 0.5)

#We can do a bit more with leaflet maps than this. One option is to change the 
#tiles. See a full list of options here: http://leaflet-extras.github.io/leaflet-providers/preview/index.html
#We can also colour the markers by thespecies richness.
#To build a colour palette, we can use some utility functions provided in the 
#leaflet package

copedomain <- range(cope_gridded$richness)
oranges <- colorNumeric("YlOrRd", domain = copedomain)
#Which creates a function that will generate a Yellow-Orange-Red palette from 
#RColorBrewer. The domain argument ensures that our colour scale will grade 
#from the minimum to maximum copepod richness.

leaflet(cope_gridded) %>%
  addProviderTiles("Esri.OceanBasemap") %>%
  addCircleMarkers(lng = ~lon, lat = ~lat, radius = 3,
                   color = 'grey80', weight = 1, fill = TRUE,
                   fillOpacity = 0.7, fillColor = ~oranges(richness)) %>%
  addLegend("topright", pal = oranges, values = copedomain,
            title = "Number of copepod species", opacity = 1) 
#leaflet provider tiles: http://leaflet-extras.github.io/leaflet-providers/preview/index.html

#To save this as a webpage click the ‘Export’ button above the figure window 
#in RStudio. 

setwd("/Users/natalyagallo/Desktop/CalCOFI_Fig/CalCOFI_Stations_Plotting")

# Plotting CalCOFI Grid Stations (All) and colorcoding by sampling frequency
# Locations obtained from Jim Wilkinson

#Note, coordinates are in a signed degrees format (DDD.dddd) (decimal degrees) 
CalCOFI_Stations_All = read.csv("Station_ID.csv", header=TRUE)
head(CalCOFI_Stations_All)
summary(CalCOFI_Stations_All$DLon_Dec) #For some reason, some are positive and
#some are negative, which is no good, so use absolute value to correct
CalCOFI_Stations_All$DLon_Dec = abs(CalCOFI_Stations_All$DLon_Dec) 
summary(CalCOFI_Stations_All$DLon_Dec) 
str(CalCOFI_Stations_All$DLon_Dec)
hist(CalCOFI_Stations_All$DLon_Dec)
#now change to negative to represent western hemisphere
CalCOFI_Stations_All$DLon_Dec = CalCOFI_Stations_All$DLon_Dec*-1
summary(CalCOFI_Stations_All$DLon_Dec)
hist(CalCOFI_Stations_All$DLon_Dec)

CalCOFI_Stations_All$Spatial_Op2 = NULL
CalCOFI_Stations_All$Spatial_Op4 = NULL
head(CalCOFI_Stations_All)

#Currently 18 stations don't have all of the location data, so need to remove
#these as missing values in coordinates are not allowed for next section
CalCOFI_Stations_All_mod = CalCOFI_Stations_All %>% 
  drop_na(DLon_Dec, DLat_Dec) %>%
  as.data.frame()

#Now bring in datasheet that shows sampling frequency for all unique stations
Station_MD = read.csv("Station_MD.csv", header=TRUE)
head(Station_MD)

#Now merge these two datasheets so you have unique_sampling dates for all stations
Stations_Sampled_Metadata = merge(CalCOFI_Stations_All_mod, Station_MD, "Sta_ID")
head(Stations_Sampled_Metadata)
summary(Stations_Sampled_Metadata$unique_dates)

#Stations >1
CalCOFI_Stations_Morethan1 = Stations_Sampled_Metadata %>% 
  filter(unique_dates > 1) %>% as.data.frame()
head(CalCOFI_Stations_Morethan1)

CalCOFI_gridded <- CalCOFI_Stations_Morethan1 %>%
  mutate(lat = DLat_Dec, lon = DLon_Dec) %>%
  group_by(lat, lon) %>%
  summarize(sample.no = mean(unique_dates))
head(CalCOFI_gridded)

leaflet(CalCOFI_gridded) %>%
  addTiles() %>%
  addCircleMarkers(lng = ~lon, lat = ~lat, radius = 0.5)

head(CalCOFI_gridded)
samplefreq <- range(CalCOFI_gridded$sample.no)
oranges <- colorNumeric("YlOrRd", domain = samplefreq)
#Which creates a function that will generate a Yellow-Orange-Red palette from 
#RColorBrewer. The domain argument ensures that our colour scale will grade 
#from the minimum to maximum sampling frequency. 

leaflet(CalCOFI_gridded) %>%
  addProviderTiles("Esri.OceanBasemap") %>%
  addCircleMarkers(lng = ~lon, lat = ~lat, radius = 3,
                   color = 'grey80', weight = 1, fill = TRUE,
                   fillOpacity = 0.7, fillColor = ~oranges(sample.no)) %>%
  addLegend("topright", pal = oranges, values = samplefreq,
            title = "CalCOFI Stations Sampling Frequency", opacity = 1) 

#Quick Look at Marmap
#https://www.molecularecologist.com/2015/07/marmap/

# Get bathymetric data
CalCOFI_map_near = getNOAA.bathy(-122, -117, 38, 32, res=4, keep=TRUE)

#set plotting window and margins
par(mfrow=c(1,1))
par(mar=c(4.2,4.2,2,2))

#plot grid
plot(CalCOFI_map_near, land=FALSE, n=50, lwd=0.03)
map("worldHires", res=0, add=TRUE)

# Add -200m and -1000m isobath
plot(CalCOFI_map_near, deep=-100, shallow=-100, step=0, lwd=0.5, drawlabel=TRUE, add=TRUE)
plot(CalCOFI_map_near, deep=-500, shallow=-500, step=0, lwd=0.5, drawlabel=TRUE, add=TRUE)
plot(CalCOFI_map_near, deep=-1500, shallow=-1500, step=0, lwd=0.3, drawlabel=TRUE, add=TRUE)
plot(CalCOFI_map_near, deep=-3000, shallow=-3000, step=0, lwd=0.3, drawlabel=TRUE, add=TRUE)
plot(CalCOFI_map_near, deep=-4000, shallow=-4000, step=0, lwd=0.3, drawlabel=TRUE, add=TRUE)

save.image(file="Maps_RUsers_Gallo.RData")