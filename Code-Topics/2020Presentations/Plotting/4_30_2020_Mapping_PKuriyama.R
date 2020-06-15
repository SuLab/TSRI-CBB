#----------------------------------------------------------------------
#R users map making

#Mostly pulled from:
# https://urldefense.com/v3/__https://eriqande.github.io/rep-res-web/lectures/making-maps-with-R.html__;!!Mih3wA!XQD7_YmEF-cldVwWscURQI9Q9ESGFBHwWwjO1LoOamVEJUmSTxvkVepjjdo2ziFq$ 

#----------------------------------------------------------------------
#Install/load packages

library(tidyverse)
install.packages("ggmap")
library(ggmap)
library(maps)
library(mapdata)

#----------------------------------------------------------------------
#Look at USA example map data
usa <- map_data('usa')
italy <- map_data('italy')

head(usa)
unique(usa$region)
unique(usa$subregion)

###Plot the values using regular ggplot
#geom_point
ggplot(usa, aes(x = long, y = lat)) + geom_point()

#geom_line
ggplot(usa, aes(x = long, y = lat)) + geom_line()

#geom_polygon
ggplot() + geom_polygon(data = usa, aes(x = long, y = lat,
                                        group = group)) +
  coord_fixed(1.3)

#Play with dimensions
ggplot() + geom_polygon(data = usa, aes(x = long, y = lat,
                                        group = group)) +
  coord_fixed(.9)

ggplot() + geom_polygon(data = usa, aes(x = long, y = lat,
                                        group = group)) +
  coord_fixed(2)


###coord_fixed of 1.3 means that every 1 unit in lat is 1.3x longer than
###1 unit in long
###Can just eyeball until the proportions look ok

ggplot() + 
  geom_polygon(data = usa, aes(x=long, y = lat), fill = "violet", color = "blue") + 
  coord_fixed(1.3)

#geom_map
ggplot() + geom_map(data = usa, map = usa, 
                    aes(x = long, y = lat, map_id = region), fill = 'gray')

#----------------------------------------------------------------------
#Modify the colors 
ggplot() + geom_map(data = usa, map = usa, aes(x = long, 
  y = lat, map_id = region), fill = 'violet', color = 'blue')

our_map <- ggplot() + geom_map(data = usa, map = usa, 
                    aes(x = long, y = lat, 
                        map_id = region), fill = 'white', color = 'black')
our_map

#Add points
labs <- tibble(
  long = c(-117.27, -122.306417),
  lat = c(32.8328, 47.644855),
  names = c("SWFSC", "NWFSC"),
  stringsAsFactors = FALSE
)  

our_map + geom_point(data = labs, aes(x = long,
                                      y = lat), color = 'black',
                     size = 5)

our_map + geom_point(data = labs, aes(x = long,
                                      y = lat), color = 'red',
                     size = 2)

#----------------------------------------------------------------------
#1. Make map of New Zealand
temp <- map_data('nz')

ggplot() + geom_map(data = temp, map = temp, aes(x = long, y = lat,
                                                   map_id = region)) +
  xlim(170, 175) + ylim(-44, -40) + coord_fixed(1.3) 


#2. Make a map of the West Coast
ggplot() + geom_map(data = usa, map = usa, aes(x = long, y = lat,
                                                 map_id = region)) +
  xlim(-125, -110) + ylim(25, 50) + coord_fixed(1.3)

states <- map_data("state")
unique(states$region)

temp <- states %>% filter(region %in% c("california", "oregon", 
                                "washington", "idaho", "nevada")) 

ggplot() + geom_map(data = temp, map = temp, aes(x = long, y = lat,
                                               map_id = region)) +
  coord_fixed(1.3)
    


#----------------------------------------------------------------------
#google maps satellite images

#Search for NCEAS ggmap cheatsheet
my_loc <- c(lon = -117.27, lat = 32.8328)

#Need to register an API key with google
?register_google

mykey <- "321jf90ds-ajfdsapcdjskalcpjs" #This will be your API key when you register
#with google. This one is made up and won't run
register_google(key = mykey)
#After running the get_map function should work

#Get map
myMap <- get_map(location = my_loc, 
  source = "google", maptype = "satellite", crop = FALSE) 


ggmap(myMap) + geom_point(aes(x = -117.27, y = 32.8328), 
                          colour = "red", size = 2) 

+ xlim(-117.5, -117.25) + 
  ylim(32.6, 32.8)

#Lose resolution
ggmap(myMap) + geom_point(aes(x = -117.27, y = 32.8328), 
                                    colour = "red", size = 2) +
  scale_x_continuous(limits = c(-117.3, -117.1)) +
  scale_y_continuous(limits = c(32.7, 32.9))

#Zoom in on map
zoom_map <- get_map(location = my_loc, source = 'google',
                    maptype = 'satellite', zoom = 20)

#Try to find where this map is
ggmap(zoom_map)

#----------------------------------------------------------------------
#Bin data
#Sample longitudes and latitudes
set.seed(300) #Set seed to make sure we sample the same "random values"

#Generate data for one year
samp_dat1 <- tibble(lon = runif(1000, min = -117.75, max = -116.75),
                   lat = runif(1000, min = 32.5, max = 33.2), weight = rlnorm(1000)) %>%
  as.data.frame
samp_dat1$year <- 1

#Year 2
samp_dat2 <- tibble(lon = runif(1000, min = -117.75, max = -116.75),
                    lat = runif(1000, min = 32.5, max = 33.2), weight = rlnorm(1000)) %>%
  as.data.frame
samp_dat2$year <- 2

#Year 3
samp_dat3 <- tibble(lon = runif(1000, min = -117.75, max = -116.75),
                    lat = runif(1000, min = 32.5, max = 33.2), weight = rlnorm(1000)) %>%
  as.data.frame
samp_dat3$year <- 3

samp_dat <- rbind(samp_dat1, samp_dat2, samp_dat3)

#Go back to simplified map
states <- map_data("state")
ca_dat <- states %>% filter(region %in% c("california")) 
ca_map <- ggplot() + geom_map(data = ca_dat, map = ca_dat, aes(x = long,
  y = lat, map_id = region), fill = 'white', colour = 'black') + xlim(-118, -116) + 
  ylim(32.5, 33.5) + coord_fixed(1.3)  

#We want to count the number of points within some square
#Plot the points over each year
#alpha makes the points more transparent because they're so bunched up
ca_map + geom_point(data = samp_dat, aes(x = lon, y = lat), alpha = .5) + 
  facet_wrap(~ year)
#Hard to see patterns in the raw data
#Will be easier to track the changes in tiles over time
#Use stat_bin2d to assign each of the points to a tile

#This shows the tiles for all three years of data
bins <- ggplot(samp_dat, aes(x = lon, y = lat)) +
  stat_bin2d(binwidth = c(.05, .05))

#Because we're interested in changes over time, add group = year 
bins <- ggplot(samp_dat, aes(x = lon, y = lat, group = year)) +
  stat_bin2d(binwidth = c(.05, .05)) + facet_wrap(~ year)

#Internally ggplot records the numbers within each tile
#Below is a way to get the tile assignments
binned <- ggplot_build(bins)$data[[1]]
#See binned$group is each of the individual years
unique(binned$group)

#Assign each tile a unique value
tile_id <- binned %>% distinct(x, y) %>% mutate(tile_id = 1:length(x))

#Add this back into the binned data frame
binned <- binned %>% left_join(tile_id, by = c("x", "y"))

#Check that this is working
binned %>% filter(tile_id == 1)
#SO for tile 1, the number of observations went 3 to 6 to 2
#Just to see, which tile had the greatest range within these three years?
binned %>% group_by(tile_id) %>% summarize(min_count = min(count),
                                           max_count = max(count), 
                                           change_count = max_count - min_count) %>%
  arrange(desc(change_count))

#Tile 152 and 208 had changes of 10 animals; Double check this
binned %>% filter(tile_id == 152)
binned %>% filter(tile_id == 208)

#Now add in the tile_id to samp_dat
#this will involve filtering the data by xmin/xmax and ymin/ymax values in binned
#First get the distinct min/max values
tile_min_max <- binned %>% distinct(xmin, xmax, ymin, ymax, tile_id, x, y)

#Steps are filter the samp_dat based on the min/max values
#Add the tile_id column to the filtered data
samp_dat$tile_id <- 999 #add placeholder value 
samp_dat$tile_x <- 999 #add placeholder value 
samp_dat$tile_y <- 999 #add placeholder value 

#Add the x and y values to samp_dat to plot these without
#having to call bin_2d again

#Loop through each of the rows of tile_min_max
for(ii in 1:nrow(tile_min_max)){
  temp_tile <- tile_min_max[ii, ]
  
  #Find the values in samp_dat that are between min/max values
  #One thing to check is the boundary conditions (in terms of < and >=).
  #I'm not exactly sure which one ggplot uses but something to be aware of
    indices <- which(samp_dat$lon > temp_tile$xmin &
        samp_dat$lon <= temp_tile$xmax &
        samp_dat$lat > temp_tile$ymin &
        samp_dat$lat <= temp_tile$ymax)
  samp_dat[indices, 'tile_id'] <- temp_tile$tile_id
  samp_dat[indices, 'tile_y'] <- temp_tile$y
  samp_dat[indices, 'tile_x'] <- temp_tile$x
}

#Check that there are no 999 in samp_dat
sum(samp_dat$tile_id == 999)

#Now we can look at changes in weight over time in particular tiles
#Specify whatever summary statistic you want within the summarize() call
summarized_samp_dat <- samp_dat %>% group_by(tile_id, year, tile_x, tile_y) %>% 
  summarize(avg_weight = mean(weight), sd_weight = sd(weight))

#Plot the avg_weight through year and space
ggplot(summarized_samp_dat) + geom_tile(aes(x = tile_x, y = tile_y,
                                 fill = avg_weight)) + facet_wrap(~ year)

#Change the colors
ggplot(summarized_samp_dat) + geom_tile(aes(x = tile_x, y = tile_y,
                                 fill = avg_weight)) + facet_wrap(~ year) +
  scale_fill_gradient(low = 'white', high = 'red')

#Plot the sd in weight
ggplot(summarized_samp_dat) + geom_tile(aes(x = tile_x, y = tile_y,
                                 fill = sd_weight)) + facet_wrap(~ year) +
  scale_fill_gradient(low = 'white', high = 'red')
#Grey values where there was only 1 observation I bet

#The grid resolution was c(.05, .05); Change the values in line 217 to change tile size

