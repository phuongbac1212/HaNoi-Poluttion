my_packages = c("raster", "rgdal", "ggplot2", "dplyr", "gstat", "sf", "sp")

install_if_missing = function(p) {
  if (p %in% rownames(installed.packages()) == FALSE) {
    install.packages(p)
  }
}

invisible(sapply(my_packages, install_if_missing))