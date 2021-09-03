###### Creating an interactive map for the canyons and my deployment sites. #######
########## Ashley Nicoll 5/7/2020 #########

# Very helpful info page about leaflet
## https://rstudio.github.io/leaflet/

# Load required libraries
library(tidyverse)
library(maps)
library(mapproj)
library(raster)
library(leaflet)
library(RColorBrewer)
library(mgcv)
library(tidyr)
library(sf)
library(rgeos)

# Load CanyonLeafletAN.Rdata file 

# Subset canyons. The Canyons shapefile is very large. This will make the map 
# take a long time to load. So we want to trim down all the shapefiles. 
Canyons_sf$Ocean <- as.character(Canyons_sf$Ocean)
Canyons_sub <- Canyons_sf$Ocean == "North Pacific Ocean"
Canyons.f <- Canyons_sf[Canyons_sub, ]


# Make Everything smaller. 
  # All my shapefiles came with data that is helpful however unnecessary for making 
  # the maps. I removed all the columns and only left feature name, area, and geometry columns.

  # Canyons.f
  Canyons.f$type <- NULL
  Canyons.f$Ocean <- NULL
  Canyons.f$Geomorphic <- NULL  
  Canyons.f$area_km2 <- NULL
  Canyons.f$Delta_D <- NULL
  Canyons.f$Length <- NULL
  Canyons.f$Width <- NULL
  #CAMPA
  CAMPA$OBJECTID <- NULL
  CAMPA$CCR <- NULL
  CAMPA$Study_Regi <- NULL
  CAMPA$FULLNAME <- NULL
  CAMPA$Type <- NULL
  CAMPA$DFG_URL <- NULL
  CAMPA$CCR_Int <- NULL
  CAMPA$SHORTNAME <- NULL
  CAMPA$Acres <- NULL
  CAMPA$Hectares <- NULL
  # CCA
  CCA$objectid_2 <- NULL
  #NMS
  CB_NMS$SANCTUARY <- NULL
  CB_NMS$DATUM <- NULL
  CB_NMS$ACRES <- NULL
  CB_NMS$AREA_SM <- NULL
  CB_NMS$AREA_NAME <- NULL
  CB_NMS$AREA_NM <- NULL
  CB_NMS$Area_SQMI <- NULL
  
  CI_NMS$SANCTUARY <- NULL
  CI_NMS$DATUM <- NULL
  
  GF_NMS$SHAPE_Leng <- NULL
  
  MB_NMS$SANCTUARY <- NULL
  MB_NMS$DATUM <- NULL
  MB_NMS$AREA_SM <- NULL
  MB_NMS$AREA_NM <- NULL
  MB_NMS$AREA_ACRES <- NULL
  MB_NMS$Area2013Mi <- NULL
  
  
# Have to transform them. I used the ESRI.OceanBaseMap. This map has 
  # projection = +proj=longlat +datum=WGS84 so we have to change the projection 
  # of all of our shapefiles to match. 
  
  # If you shapefiles are not transformed, you will get an error when you try to map
  # it telling you that you need to adjust your projection. 
Canyons.f <- st_transform(Canyons.f, crs = "+proj=longlat +datum=WGS84")
CAMPA <- st_transform(CAMPA, crs = "+proj=longlat +datum=WGS84")
CCA <- st_transform(CCA, crs = "+proj=longlat +datum=WGS84")
CB_NMS <- st_transform(CB_NMS, crs = "+proj=longlat +datum=WGS84")
CI_NMS <- st_transform(CI_NMS, crs = "+proj=longlat +datum=WGS84")
GF_NMS <- st_transform(GF_NMS, crs = "+proj=longlat +datum=WGS84")
MB_NMS <- st_transform(MB_NMS, crs = "+proj=longlat +datum=WGS84")

# I had to add a name column to the National Marine Sanctuaries df because I 
# wanted the names to pop-up when the mouse goes over them but the df only had 
# their abreviations. 
# Add names to the NMS
MB_NMS$NAME <- "Monterey Bay"
GF_NMS$NAME <- "Greater Farallones"
CI_NMS$NAME <- "Channel Islands"
CB_NMS$NAME <- "Cordell Bank"

# In order to have labels pop up when the mouse goes over you have to make a list 
# of the names. 

# The column that you use to make the labels must be a character vectore. If it's not
# you will get an error saying: "'fmt' is not a character vector". 
CAMPA$NAME <- as.character(CAMPA$NAME)
# This is the line of code that you use to assign the names for your labels. 
  # In my shapefiles each row is different polygon. By using this line of code, it will take the
  # info from the name column for each row. It allows you to have different names for polygons that 
  # are in the same layer. 
labelsMPA <- sprintf(CAMPA$NAME) %>% lapply(htmltools::HTML)
labelsMB_NMS <- sprintf(MB_NMS$NAME) %>% lapply(htmltools::HTML)
labelsGF_NMS <- sprintf(GF_NMS$NAME) %>% lapply(htmltools::HTML)
labelsCI_NMS <- sprintf(CI_NMS$NAME) %>% lapply(htmltools::HTML)
labelsCB_NMS <- sprintf(CB_NMS$NAME) %>% lapply(htmltools::HTML)


# Color code the canyons based on mean depth
  # Find the range of canyons depths. 
canyondomain <- range(Canyons.f$Mean_Depth)
  # Assign a color palette to the range. 
oranges <- colorNumeric("YlOrRd", domain = canyondomain) 

# Making the leaflet -- Assembling the leaflet works similar to ggplot in that the 
# layers are added in the order they appear. 

  # Also similar to ggplot you connect the different layers using "%>%" this is called a pipe. In
  # this setting is functions the same as the "+" in ggplot. 

  # You can use pipes in other applications. They take the output of one function and funnel it 
  # into the first argument of the next function. 

map <- leaflet(Canyons.f) %>%
  # Define what part of the word you want to see when the map opens. 
  fitBounds(lng1  = -127, lng2 = -114,
            lat1 = 43, lat2 = 32) %>%
  # This adds the basemap that I want. Leaflet has a bunch of "Provider Tiles" which are like
  # different default tiles they have available. You can google them. 
  addProviderTiles("Esri.OceanBasemap") %>%
  # Adds the MPA polygons. I assigned all the different protection agencies to their own group. 
  # This will allow them to be turned on and off by the user later. 
  addPolygons(data = CAMPA, 
              group = "Marine Protected Areas", 
              color = "Purple", weight = 1, 
              opacity = 1, 
              fillOpacity = 0.7, 
              fillColor = "Purple", 
              # This next option is how to get them to popout and highlight when the mouse 
              # goes over them. 
              highlightOptions = highlightOptions(
                color = "white", 
                weight = 2,
                bringToFront = TRUE),
              # Here's the labels we made previously. 
              label = labelsMPA, 
              labelOptions = labelOptions(
                style = list("font-weight" = "normal", padding = "3px 8px"),
                textsize = "15px",
                direction = "auto")) %>%
  # Rinse and repeat for all my different protection areas. 
  addPolygons(data = CCA, 
              group = "Cow-Cod Conservation Areas", 
              color = "Green", weight = 1, 
              opacity = 1, 
              fillOpacity = 0.7, 
              fillColor = "Green", 
              highlightOptions = highlightOptions(
                color = "white", 
                weight = 2,
                bringToFront = TRUE),
              label = "CCA", 
              labelOptions = labelOptions(
                style = list("font-weight" = "normal", padding = "3px 8px"),
                textsize = "15px",
                direction = "auto")) %>%
  # I had individual shapefiles for all the different NMS's so they have to be added individually. 
  addPolygons(data = CB_NMS, 
              group = "National Marine Sanctuaries", 
              color = "Blue", weight = 1, 
              opacity = 1, 
              fillOpacity = 0.7, 
              fillColor = "Blue", 
              highlightOptions = highlightOptions(
                color = "white", 
                weight = 2,
                bringToFront = TRUE),
              label = labelsCB_NMS, 
              labelOptions = labelOptions(
                style = list("font-weight" = "normal", padding = "3px 8px"),
                textsize = "15px",
                direction = "auto")) %>%
  addPolygons(data = CI_NMS, 
              group = "National Marine Sanctuaries", 
              color = "Blue", weight = 1, 
              opacity = 1, 
              fillOpacity = 0.7, 
              fillColor = "Blue", 
              highlightOptions = highlightOptions(
                color = "white", 
                weight = 2,
                bringToFront = TRUE),
              label = labelsCI_NMS, 
              labelOptions = labelOptions(
                style = list("font-weight" = "normal", padding = "3px 8px"),
                textsize = "15px",
                direction = "auto")) %>%
  addPolygons(data = GF_NMS, 
              group = "National Marine Sanctuaries", 
              color = "Blue", weight = 1, 
              opacity = 1, 
              fillOpacity = 0.7, 
              fillColor = "Blue", 
              highlightOptions = highlightOptions(
                color = "white", 
                weight = 2,
                bringToFront = TRUE),
              label = labelsGF_NMS, 
              labelOptions = labelOptions(
                style = list("font-weight" = "normal", padding = "3px 8px"),
                textsize = "15px",
                direction = "auto")) %>%
  addPolygons(data = MB_NMS, 
              group = "National Marine Sanctuaries", 
              color = "Blue", weight = 1, 
              opacity = 1, 
              fillOpacity = 0.7, 
              fillColor = "Blue", 
              highlightOptions = highlightOptions(
                color = "white", 
                weight = 2,
                bringToFront = TRUE),
              label = labelsMB_NMS, 
              labelOptions = labelOptions(
                style = list("font-weight" = "normal", padding = "3px 8px"),
                textsize = "15px",
                direction = "auto")) %>%
  # I added the canyons last because I want them to be on top of everything else. 
  addPolygons(data = Canyons.f,
              color = "Gray80", weight = 1, 
              smoothFactor = 0.5,
              opacity = 1.0, 
              fillOpacity = 0.8,
              # This is where I filled in the color gradient we made before. 
              fillColor = ~colorQuantile("YlOrRd", Mean_Depth)(Mean_Depth))%>%
  # This adds the legend for the color gradient. 
  addLegend("topright", pal = oranges, 
            values = canyondomain, 
            title = "Mean Canyon Depth", 
            opacity = 1) %>%
  # This adds the control so the user can turn on and off the different protection layers. 
  addLayersControl(
    overlayGroups = c("Marine Protected Areas", "Cow-Cod Conservation Areas", "National Marine Sanctuaries"), 
    options = layersControlOptions(collapsed = TRUE)
  )
map



# Use this for the government prodected areas. Makes them pop out and highlight. 
highlightOptions = highlightOptions(color = "white", weight = 2,
                                    bringToFront = TRUE))
# use this to make a the names of the protected areas appear when moused over. 
labels <- sprintf(CAMPA$NAME) %>% lapply(htmltools::HTML)

  
# Clean up the R Environment. 
  rm(list = c("IMECOCAL", "NWFSC_GTS_NE_sdf", "NWFSC_GTS_SE_sdf_tf"))


save.image(file="CanyonLeafletAN.RData"))

