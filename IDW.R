library(raster)
library(rgdal)
library(ggplot2)
library(dplyr)
library(gstat)
library(sf)
library(sp)

hanoi = readOGR(dsn = "shp", layer = "HN_huyen")

hanoi = spTransform(hanoi, CRS("+proj=longlat +datum=WGS84"))
hn.df = fortify(hanoi)

work_path = "./FairKit/"

idw_func <- function(type, date, hour, polutants)
{
  if (type == "Ngày") {
    data_path = paste(work_path, substr(date, 1, 4), "/day/", sep = "")
    file.list <- list.files(path = data_path)
    file.name = paste(data_path, date, ".csv", sep = "")
  } else if (type == "Giờ") {
    data_path = paste(work_path, substr(date, 1, 4), "/hour/", sep = "")
    file.list <- list.files(path = data_path)
    file.name = paste(data_path, date, "_", hour, ".csv", sep = "")
  }
  
  aqi.dat = read.csv(file.name)
  aqi.df = as.data.frame(aqi.dat)
  
  polutants.aqi = c("AQI.PM2.5", "AQI.PM10", "AQI.CO")
  names(polutants.aqi) = c("PM2.5", "PM10", "CO")
  switch(
    polutants.aqi[polutants],
    "AQI.PM2.5" = {
      sub.aqi.df = dplyr::filter(aqi.df, !is.na(AQI.PM2.5))
      na.aqi.df = dplyr::filter(aqi.df, is.na(AQI.PM2.5))
    },
    "AQI.CO" = {
      sub.aqi.df = dplyr::filter(aqi.df, !is.na(AQI.CO))
      na.aqi.df = dplyr::filter(aqi.df, is.na(AQI.CO))
    },
    "AQI.PM10" = {
      sub.aqi.df = dplyr::filter(aqi.df, !is.na(AQI.PM10))
      na.aqi.df = dplyr::filter(aqi.df, is.na(AQI.PM10))
    }
  )
  #if (nrow(sub.aqi.df) < 10) {
  #  print(paste("has", nrow(sub.aqi.df), "available | too many NA values"))
  #  next
  #}
  r <- raster(ncol = 1000, nrow = 1000)
  extent(r) <- extent(hanoi)
  grid = as(r, "SpatialPixels")
  grddf = as.data.frame(grid)
  
  pts = sub.aqi.df
  coordinates(pts) = ~ longitude + latitude
  proj4string(pts) = proj4string(grid)
  
  # make a ring buffer around available points
  corodinate_aqi = cbind(sub.aqi.df$longitude, sub.aqi.df$latitude)
  c_pts = st_multipoint(corodinate_aqi, dim = "XY")
  st.buffer = st_buffer(c_pts, dist = 8.5 / 111)
  st = as(st.buffer, 'Spatial')
  
  switch(
    polutants.aqi[polutants],
    "AQI.PM2.5" = {
      idw = idw(formula = AQI.PM2.5 ~ 1 ,
                location = pts,
                newdata = grid)
    },
    "AQI.CO" = {
      idw = idw(formula = AQI.CO ~ 1 ,
                location = pts,
                newdata = grid)
    },
    "AQI.PM10" = {
      idw = idw(formula = AQI.PM10 ~ 1 ,
                location = pts,
                newdata = grid)
    }
  )
  idw = crop(idw, st)
  idw.df = as.data.frame(idw)
  
  #  krig = krige(formula = AQI.PM2.5~1 , location = pts, newdata = grid)
  #  krig.df = as.data.frame(krig)
  
  
  # export solution
  plot1 = ggplot() +
    scale_fill_gradientn(
      name = "AQI value",
      limits = c(0, 500),
      label = c('50', '100', '150', '200', '300', '500'),
      colors = c(
        '#00E400',
        '#FFFF00',
        '#FF7E00',
        '#FF0000',
        '#8F3F97',
        '#7E0023'
      )
    ) +
    geom_tile(data = idw.df, aes(x = x, y = y, fill = var1.pred)) +
    geom_polygon(
      data = hn.df,
      aes(x = long, y = lat, group = group),
      color = "black",
      fill = NA
    ) +
    geom_label(
      data = sub.aqi.df,
      aes(x = longitude, y = latitude),
      label = sub.aqi.df$KIT.ID ,
      nudge_x = 0,
      nudge_y = 0
    ) +
    geom_point(data = sub.aqi.df,
               aes(x = longitude, y = latitude),
               color = "#2EB98B") +
    geom_point(data = na.aqi.df,
               aes(x = longitude, y = latitude),
               color = "red") +
    labs(
      x = "Longtitude",
      y = "Lattitude",
      title = "Ha Noi Air Quality Index (PM2.5)",
      subtitle = paste("Iterpolation of PM2.5 AQI in Hanoi in timestamp: ", date[1])
    ) +
    #geom_sf(data = st.buffer,
    #        color = "blue",
    #        fill = NA) +
    coord_sf(xlim = c(105.65, 106), ylim =  c(20.85, 21.2))
  return(list(plot1, aqi.df))
}


