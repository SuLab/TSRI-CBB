#Kayla Blincow

# #TidyTuesday Beer data for R Users Meeting 4/8


#load my libraries
library(tidyverse)
library(scatterpie) #to put pie charts on my map
library(patchwork)

#Code from GitHub to get the data for the week
# Get the Data

brewing_materials <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-03-31/brewing_materials.csv')
beer_taxed <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-03-31/beer_taxed.csv')
brewer_size <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-03-31/brewer_size.csv')
beer_states <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-03-31/beer_states.csv')


#Let's start by taking a look at the data..
head(brewing_materials)
summary(brewing_materials)
unique(brewing_materials$type)

#hmmm... I wonder how are usage of "sugar and syrups" has changed through time..

head(beer_taxed)
summary(beer_taxed)
unique(beer_taxed$type)

#meh going to ignore this data for now..

head(brewer_size)
summary(brewer_size)

#meh going to ignore this data for now also..

head(beer_states)
summary(beer_states)

#How do different regions in the US vary in the production quantity?

#Now I have some direction! Let's start with the first question...
#How has the usage of sugar and syrups changed through time?

#Remove extraneous columns from the data frame
b_mat <- brewing_materials %>% 
  select(year, month, type, month_current) %>% 
  #plus we only want to look at sugar/syrup material
  filter(type == "Sugar and syrups")

#looks like the brewing materials data is by month
#let's combine the year and month columns into one date column
b_mat$date <- paste(b_mat$year, b_mat$month, "01")
b_mat$date <- as.Date(b_mat$date, format = "%Y %m %d")


#let's start with a really basic plot
plot(b_mat$date, b_mat$month_current, type = "l")
#looks like it might be kind of seasonal, also, drops off like crazy in 2016..

#I don't really care at the seasonality of the material usage, so I am going to
#combine the data by year and look at that time series
b_mat2 <- b_mat %>% 
  group_by(year) %>% 
  summarize(year_tot = sum(month_current))

#basic plot
plot(b_mat2$year, b_mat2$year_tot, type = "l")

#let's make this plot look prettier

sugar <- ggplot(b_mat2) +
  geom_line(aes(x = year, y = year_tot), size = 1.5) +
  xlab("Year") + ylab("Pounds of Sugar and Syrups") + 
  ggtitle("Sugar and Syrups Used in US Beer Production") +
  scale_x_continuous(breaks = c(2008, 2009, 2010, 2011, 2012, 2013, 2014, 2015,
                               2016, 2017)) +
  theme_classic()

#I'm intrigued by the drop off.. I want to know if the ratio of all materials used
#across the years reflects a reduction in sugars..

all_mat <- brewing_materials %>% 
  group_by(year, type) %>% 
  summarize(year_tot = sum(month_current))

#make a stacked percent bar plot
ggplot(all_mat, aes(fill = type, y = year_tot, x = year)) + 
  geom_bar(position = "fill", stat = "identity")

#ew... need a new color scheme and it looks like we need to remove some categories
dontneed <- unique(all_mat$type)[9:11]
all_mat2 <- all_mat %>% 
  filter(!type %in% dontneed)

materials <- ggplot(all_mat2, aes(
  fill = factor(type, levels = c("Barley and barley products",
                                 "Corn and corn products",
                                 "Wheat and wheat products",
                                 "Malt and malt products",
                                 "Rice and rice products",
                                 "Hops (dry)", 
                                 "Hops (used as extracts)",
                                 "Sugar and syrups",
                                 "Other")), 
  y = year_tot, x = as.factor(year))) + 
  geom_bar(position = "fill", stat = "identity") +
  scale_fill_brewer(name = "Product Type", palette = "Paired") +
  xlab("Year") + ylab("Percent of Product Type") +
  ggtitle("Relative Proportions of Brewing Materials") +
  theme_classic()

#Onto the next question we had!
#How do different regions in the US vary in the production quantity?

#reminder
head(beer_states)
summary(beer_states)
unique(beer_states$type)

#first we need to decide our regions..
south <- c("TX", "OK", "AR", "LA", 
           "MS", "AL", "TN", "KY", 
           "WV", "MD", "DE", "DC", 
           "VA", "NC", "SC", "GA", "FL")
noreast <- c("ME", "VT", "NH", "MA", 
             "CT", "RI", "NJ", "PA", "NY")
midwest <- c("ND", "SD", "NE", "KS", 
             "MN", "IA", "MO", "WI", 
             "IL", "IN", "MI", "OH")
west <- c("WA", "OR", "CA", "NV", 
          "ID", "MT", "WY", "UT", 
          "CO", "AZ", "NM")
ncont <- c("AK", "HI")

region <- c(rep("South", 17), rep("East Coast", 9), rep("MidWest", 12),
            rep("West", 11), rep("Non-Contiguous", 2))
region <- as.data.frame(cbind(region, c(south, noreast, midwest, west, ncont)))
names(region) <- c("region", "state")
  
#join our region dataframe with the beer_states data frame
beer_region <- right_join(beer_states, region, by = "state")
beer_region[is.na(beer_region)] <- 0

beer_region2 <- beer_region %>% 
  group_by(year, region, type) %>% 
  summarize(total_barr = sum(barrels))



#let's plot it!
ggplot(data = beer_region2) +
  geom_line(aes(x = year, y = total_barr, color = region, linetype = type))

#hmmm not that cool... let's spice things up with a map of the totals of each 
#type of beer sold in the last year of the time series in the region
#we are also going to remove the non-contiguous states..
type_region <- beer_region2 %>% 
  filter(year == 2019) %>% 
  filter(region != "Non-Contiguous")

type_region$lat <- NA
type_region$long <- NA

for(i in 1:length(type_region$region)){
  if(type_region$region[i] == "South"){
    type_region$lat[i] <- 34
    type_region$long[i] <- -90
  } else {
    if(type_region$region[i] == "East Coast"){
      type_region$lat[i] <- 42.5
      type_region$long[i] <- -75
    } else {
      if(type_region$region[i] == "MidWest"){
        type_region$lat[i] <- 44
        type_region$long[i] <- -95
      } else {
        if(type_region$region[i] == "West"){
          type_region$lat[i] <- 40
          type_region$long[i] <- -115
        } 
      }
    }
  }
}

#need to convert to wide format
region_wide <- spread(type_region, type, total_barr)
colnames(region_wide) <- c("year", "region", "lat", "long", 
                           "Bottles and Cans", "Kegs and Barrels", 
                           "On Premises")
region_wide <- as.data.frame(region_wide)
region_wide <- region_wide[,-2]
region_wide$radius <- region_wide[,5]/1000000

#get the base map
usa <- map_data("state")

#make a fancy map
beermap <- ggplot(usa) +
  geom_map(data = usa, map = usa, 
           aes(long, lat, map_id = region),
           fill = "grey40", color = "black") +
  geom_scatterpie(data = region_wide, 
                  aes(long, lat, r = radius),
                  cols = c("Bottles and Cans",
                           "Kegs and Barrels", 
                           "On Premises")) +
  scale_fill_brewer(palette = "Dark2") +
  coord_fixed() +
  labs(title = "Beer Production by Region", 
       subtitle = "Size of pie denotes relative amount of production",
       fill = "Type of Use") +
  theme(panel.grid = element_blank(),
        panel.border = element_blank(),
        axis.title = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank())


#Now just for the heck of it let's play with that mythical gpplot combo package
#PATCHWORK
(sugar + materials) / beermap
sugar + materials - beermap + plot_layout(ncol = 1, 
                                          widths = c(8, 8, 16))
sugar + materials + beermap + plot_layout(ncol = 1)
sugar + materials + beermap + plot_layout(ncol = 1, widths = c(4,4,4))
