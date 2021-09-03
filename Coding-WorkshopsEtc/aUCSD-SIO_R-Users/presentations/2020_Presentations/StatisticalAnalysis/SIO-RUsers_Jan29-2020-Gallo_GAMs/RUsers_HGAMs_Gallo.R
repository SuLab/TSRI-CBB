#Natalya Gallo's Code for January 29, 2020 R Users Meeting
#From Pedersen et al. (2019) HGAMs paper in PeerJ

library("datasets")
library("ggplot2")
library("cowplot")
library("gratia")
library("mgcv")
library("viridis")
library("tidyverse")

#The `CO2` dataset, available in R via the **datasets** package

#The default CO2 plant variable is ordered;
#This recodes it to an unordered factor (see main text for why).
CO2 <- transform(CO2, Plant_uo=factor(Plant, ordered=FALSE))

#Data generated from a hypothetical study of bird movement along a 
#migration corridor, sampled throughout the year (see supplemental code).

#Loading simulated bird movement data
#This data is in the Github repository that accompanies the paper (Pedersen et al. 2019)
getwd()
setwd("/Users/natalyagallo/Desktop/Data Analysis References/HGAMS/data")
bird_move <- read.csv("bird_move.csv")

#Plot datasets
CO2_vis_plot <- ggplot(CO2, aes(x=conc, y=uptake, group=Plant,
  color=Plant, lty=Plant)) +
  geom_point() + geom_line() +
  scale_color_manual(values = rep(c("red","blue","black"), times =4))+
  scale_linetype_manual(values = rep(1:4, each=3))+
  guides(color="none",linetype="none")+
  labs(x=expression(CO[2] ~ concentration ~ (mL ~ L^{-1})), 
       y=expression(CO[2] ~ uptake ~ (mu*mol ~ m^{-2})))
CO2_vis_plot

bird_vis_plot <- ggplot(dplyr::filter(bird_move, count > 0),
  aes(x=week, y=latitude, size=count))+
  facet_wrap(~ species) +
  geom_point() +
  scale_size(name = "Count", range = c(0.2, 3)) +
  labs(x = "Week", y = "Latitude") +
  theme(legend.position = "bottom")
bird_vis_plot

plot_grid(CO2_vis_plot, bird_vis_plot, nrow=1, labels=c("A","B"),
          align = "hv", axis = "lrtb")

# Model G: a single common smoother for all observations

CO2_modG <- gam(log(uptake) ~ s(log(conc), k=5, bs="tp") +
                  s(Plant_uo, k=12, bs="re"),
                data=CO2, method="REML", family="gaussian")
draw(CO2_modG)

# setup prediction data
CO2_modG_pred <- with(CO2, expand.grid(conc=seq(min(conc), max(conc), 
        length=100), Plant_uo=levels(Plant_uo)))

# make the prediction, add this and a column of standard errors to the prediction
# data.frame. Predictions are on the log scale.
CO2_modG_pred <- cbind(CO2_modG_pred,predict(CO2_modG, CO2_modG_pred, 
        se.fit=TRUE, type="response"))

# make the plot. Note here the use of the exp() function to back-transform the
# predictions (which are for log-uptake) to the original scale
ggplot(data=CO2, aes(x=conc, y=uptake, group=Plant_uo)) +
  facet_wrap(~Plant_uo) +
  geom_ribbon(aes(ymin=exp(fit - 2*se.fit), ymax=exp(fit + 2*se.fit), x=conc),
              data=CO2_modG_pred, 
              alpha=0.3, 
              inherit.aes=FALSE) +
  geom_line(aes(y=exp(fit)), data=CO2_modG_pred) +
  geom_point() +
  labs(x=expression(CO[2] ~ concentration ~ (mL ~ L^{-1})),
       y=expression(CO[2] ~ uptake ~ (mu*mol ~ m^{-2})))

##Examining these plots, we see that while functional responses among plants are 
#similar, some patterns are not captured by this model.  For instance, for plant 
#Qc2 the model clearly underestimates CO2 uptake. A model including individual 
#differences in functional responses may better explain variation.

##Now test the Bird example using Model G (single common smoother for all observations) 
bird_modG <- gam(count ~ te(week, latitude, bs=c("cc", "tp"), k=c(10, 10)),
                 data=bird_move, method="REML", family="poisson",
                 knots=list(week=c(0, 52)))

draw(bird_modG)

#add the predicted values from the model to bird_move
bird_move <- transform(bird_move, modG = predict(bird_modG, type="response"))

ggplot(bird_move, aes(x=modG, y=count)) +
  facet_wrap(~species) +
  geom_point(alpha=0.1) +
  geom_abline() +
  labs(x="Predicted count", y="Observed count")

# Model GS: A global smoother plus group-level smoothers that have the same
  #wiggliness (i.e. global smoother with individual effects that have a 
  #shared penalty)

CO2_modGS <- gam(log(uptake) ~ s(log(conc), k=5, m=2) + 
      s(log(conc), Plant_uo, k=5,  bs="fs", m=2),
      data=CO2, method="REML")

#bs = "fs" : a factor-smoother

draw(CO2_modGS)

# setup prediction data
CO2_modGS_pred <- predict(CO2_modGS, se.fit=TRUE)
CO2 <- transform(CO2, 
                 modGS = CO2_modGS_pred$fit, 
                 modGS_se = CO2_modGS_pred$se.fit)

ggplot(data=CO2, aes(x=conc, y=uptake, group=Plant_uo)) +
  facet_wrap(~Plant_uo) +
  geom_ribbon(aes(ymin=exp(modGS-2*modGS_se),
                  ymax=exp(modGS+2*modGS_se)), alpha=0.25) +
  geom_line(aes(y=exp(modGS))) +
  geom_point() +
  labs(x=expression(CO[2] ~ concentration ~ (mL ~ L^{-1})),
       y=expression(CO[2] ~ uptake ~ (mu*mol ~ m^{-2})))

#Model_GS with the bird data
bird_modGS <- gam(count ~ te(week, latitude, bs=c("cc", "tp"),
      k=c(10, 10), m=2) +
      t2(week, latitude, species, bs=c("cc", "tp", "re"),
      k=c(10, 10, 6), m=2, full=TRUE),
      data=bird_move, method="REML", family="poisson", 
      knots=list(week=c(0, 52)))

draw(bird_modGS)

bird_move <- transform(bird_move, modGS = predict(bird_modGS, type="response"))
bird_modGS_indiv <- ggplot(data=bird_move, 
  aes(x=week, y=latitude, fill=modGS,color=modGS)) +
  geom_tile(size=0.25) +
  facet_wrap(~ species, ncol=6) +
  scale_fill_viridis("Count") +
  scale_color_viridis("Count") +
  scale_x_continuous(expand=c(0, 0), breaks=c(1, 26, 52)) +
  scale_y_continuous(expand=c(0, 0), breaks=c(0, 30, 60)) +
  labs(x = "Week", y = "Latitude") +
  theme(legend.position="right")

bird_modGS_indiv_fit <- ggplot(data=bird_move, aes(x=modGS, y=count)) +
  facet_wrap(~ species, ncol=6) +
  geom_point(alpha=0.1) +
  geom_abline() +
  labs(x="Predicted count (model *GS*)", y= "Observed count")

plot_grid(bird_modGS_indiv, bird_modGS_indiv_fit, 
          ncol=1, 
          align="vh", 
          axis = "lrtb",
          labels=c("A","B"), 
          rel_heights= c(1,1))

#Model GI: A global smoother with group-level smoothers with differing 
  #wiggliness (i.e. global smoother with individual effects with individual
  #penalties) Useful if different groups differ substantially in how wiggly
  #they are

CO2_modGI <- gam(log(uptake) ~ s(log(conc), k=5, m=2, bs="tp") +
                   s(log(conc), by=Plant_uo, k=5, m=1, bs="tp") +
                   s(Plant_uo, bs="re", k=12),
                 data=CO2, method="REML")

#Fitting CO2_modGI 
CO2_modGI <- gam(log(uptake) ~ s(log(conc), k=5, m=2, bs="tp") +
                   s(log(conc), by= Plant_uo, k=5, m=1, bs="tp") +
                   s(Plant_uo, bs="re", k=12),
                 data=CO2, method="REML")

#plotting CO2_modGI 
draw(CO2_modGI, select = c(1,14,8,2,11,5), scales = "fixed")

#Model GI for the bird data
bird_modGI <- gam(count ~ species +
            te(week, latitude, bs=c("cc", "tp"), k=c(10, 10), m=2) +
            te(week, latitude, by=species, bs= c("cc", "tp"),
            k=c(10, 10), m=1),
            data=bird_move, method="REML", family="poisson",
            knots=list(week=c(0, 52)))

## Model S: Group-specific smoothers without a global smoother but all smoothers
  #have similar wiggliness

CO2_modS <- gam(log(uptake) ~ s(log(conc), Plant_uo, k=5, bs="fs", m=2),
                data=CO2, method="REML")

bird_modS <- gam(count ~ t2(week, latitude, species, bs=c("cc", "tp", "re"),
                            k=c(10, 10, 6), m=2, full=TRUE),
                 data=bird_move, method="REML", family="poisson",
                 knots=list(week=c(0, 52)))

## Model I: Group-specific smoothers without a global smoother but with 
  #different wiggliness

CO2_modI <- gam(log(uptake) ~ s(log(conc), by=Plant_uo, k=5, bs="tp", m=2) +
            s(Plant_uo, bs="re", k=12),
            data=CO2, method="REML")

bird_modI <- gam(count ~ species + te(week, latitude, by=species,
            bs=c("cc", "tp"), k=c(10, 10), m=2),
            data=bird_move, method="REML", family="poisson",
            knots=list(week=c(0, 52)))

## Compare models with AIC:

AIC_table <- AIC(CO2_modG,CO2_modGS, CO2_modGI, CO2_modS, CO2_modI,
                 bird_modG, bird_modGS, bird_modGI, bird_modS, bird_modI)%>%
  rownames_to_column(var= "Model")%>%
  mutate(data_source = rep(c("CO2","bird_data"), each =5))%>%
  group_by(data_source)%>%
  mutate(deltaAIC = AIC - min(AIC))%>%
  ungroup()%>%
  dplyr::select(-data_source)%>%
  mutate_at(.vars = vars(df,AIC, deltaAIC), 
            .funs = funs(round,.args = list(digits=0)))
