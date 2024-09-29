# This function computes the dates of astronomical events (equinoxes, solstices,
# and full moons) for a given year in a given latitude.
#
# Installation:
# It can loaded using `source("https://raw.githubusercontent.com/RealityBending/scripts/main/astronomical_dates.R")`
# It requires the 'chillR' and the 'lunar' packages to be installed.
#
# Author: Dominique Makowski
#
# Usage:
# > events <- astronomical_dates(year=2023, latitude = 50.8229)  # Latitude in Brighton, UK
# > events["Equinox_Spring"]
astronomical_dates <- function(year=2023, latitude = 50.8229){
  dates <- seq(ISOdate(year, 1, 1), ISOdate(year, 12, 31), by='day')
  days <- chillR::make_JDay(data.frame(Year=format(dates, "%Y"),Month=format(dates, "%m"),Day=format(dates, "%d")))
  daylength <- chillR::daylength(latitude = latitude, days$JDay)$Daylength

  # Solstice ---------------------------------------------------------------
  solstice_winter <- as.Date(dates[which(daylength==min(daylength))])
  solstice_summer <- as.Date(dates[which(daylength==max(daylength))])

  # Equinox ---------------------------------------------------------------
  # Method 1: Where the daylength is closest to 12 hours
  equinox_spring <- as.Date(dates[which(abs(daylength[1:150] - 12) == min(abs(daylength[1:150] - 12)))])
  equinox_autumn <- as.Date(dates[which(abs(daylength[151:300] - 12) == min(abs(daylength[151:300] - 12)))+150])

  # Method 2: Where the rate of changes is minimum
  # equinox_spring <- as.Date(dates[which(diff(daylength)==max(diff(daylength)))+1])
  # equinox_autumn <- as.Date(dates[which(diff(daylength)==min(diff(daylength)))+1])

  # Method 3: Where there is an inversion in the rate of change
  # d <- diff(diff(daylength))
  # equinox_spring <- as.Date(dates[which(d > 0 & c(d[-1], 0) < 0)+2])
  # equinox_autumn <- as.Date(dates[which(d < 0 & c(d[-1], 0) > 0)+2])

  # Full moons
  phase <- lunar::lunar.illumination(dates)
  moon <- data.frame(dates = as.Date(dates),
                     phase = phase,
                     newmoon = FALSE,
                     fullmoon = FALSE)
  moon[which(diff(sign(diff(phase)))==-2)+1, "fullmoon"] <- TRUE
  moon[which(diff(sign(diff(phase)))==2)+2, "newmoon"] <- TRUE

  list("Solstice_Summer"=solstice_summer,
       "Solstice_Winter"=solstice_winter,
       "Equinox_Autumn"=equinox_autumn,
       "Equinox_Spring"=equinox_spring,
       "Moon_Full"=moon[moon$fullmoon==TRUE, "dates"],
       "Moon_New"=moon[moon$newmoon==TRUE, "dates"],
       "Dates"=dates)
}
