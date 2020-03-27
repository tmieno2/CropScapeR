#' Request for images of the CDL raster data
#'
#' A function that makes HTTP GET requests for the CDL raster data for an area of interests in a given crop year.
#' This function implements the GetCDLImage service provided by the CropScape \url{https://nassgeodata.gmu.edu/CropScape}.
#'
#' @param aoi Area of interest. Could be a 5-digit FIPS code of a county, three coordinates that defines a triangle,
#' or four corner points that defines a rectangle (or a box), or a single coordinate. The default coordinate system used by CDL is a projected
#' coordinate system called Albers projection (or Albers equal-area conic projection). Users could specify coordinates based on a
#' different coordinate system (defined by the \code{crs} argument), including the geographic coordinate system such as latitude-longitude.
#' @param year  Crop year of data to request. Should be a 4-digit numerical value.
#' @param type Type of AOI. 'f' for county, 'ps' for triangle with multiple coordinates, 'b' for box with four corner points, 'p' for a single coordinate.
#' @param format Format of the image file. Can be png or kml.
#' @param crs Coordinate system. NULL if use the default coordinate system (e.g., Albers projection); Use '+init=epsg:4326' for longitude/latitude.
#' @param destfile A character string (or vector, see \code{url}) with the name where the downloaded file is saved. If not specified, the function will creater a temporary folder to save the image file.
#' @param verbose TRUE/FALSE. Display the directory saving the file or not.
#'
#' @return
#' The function downloads an image file in png or kml format to users' computer. This function is different to \code{GetCDLData} that returns a raster TIF file.
#'
#' @export
#'
GetCDLImage <- function(aoi = NULL, year = NULL, type = NULL, format = 'png', crs = NULL, destfile = NULL, verbose = TRUE){
  targetCRS <- "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"

  if(!type %in% c('f', 'ps', 'b', 'p')) stop('The type value is wrong.')

  if(type == 'f'){
    GetCDLImageF(fips = aoi, year = year, format = format, verbose = verbose, destfile = destfile)
  }

  if(type == 'ps'){
    if(length(aoi) < 6) stop('For points, at least 6 values (3 coordinate points) have to be provided for aoi.')
    if(!is.null(crs)){
      numps <- length(aoi) # Number of points
      oldpoints <- sp::SpatialPoints(cbind(aoi[seq(1, numps, by = 2)], aoi[seq(2, numps, by = 2)]), sp::CRS(crs))
      newpoints <- sp::spTransform(oldpoints, targetCRS)
      aoi <- paste0(as.vector(t(newpoints@coords)), collapse = ',')
    }
    GetCDLImagePs(points = aoi, year = year, format = format, verbose = verbose, destfile = destfile)
  }

  if(type == 'b'){
    if(length(aoi) != 4) stop('For box, 4 values (2 coordinate points) have to be provided for aoi.')
    if(!is.null(crs)){
      numps <- length(aoi) # Number of points
      oldpoints <- sp::SpatialPoints(cbind(aoi[seq(1, numps, by = 2)], aoi[seq(2, numps, by = 2)]), sp::CRS(crs))
      newpoints <- sp::spTransform(oldpoints, targetCRS)
      aoi <- paste0(as.vector(t(newpoints@coords)), collapse = ',')
    }
    GetCDLImageB(box = aoi, year = year, format = format, verbose = verbose, destfile = destfile)
  }
}

?download.file()