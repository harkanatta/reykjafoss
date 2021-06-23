Packages <- c("magrittr", "magick", "here", "exifr", "sf", "tidyverse")
pacman::p_load(Packages, character.only = TRUE)


herepath <- here()
pathnew <- paste(herepath,"minnimyndir",sep = "/")
dir.create(pathnew)
myndir <- list.files(herepath,pattern = "JPEG|JPG", recursive = T,full.names = T)

defines <- c("png:compression-filter" = "1", "png:compression-level" = "0")

for (i in myndir) {
mynd <- image_read(i) %>%
  image_resize("800x800")
print(paste(gsub(".*[/]([^.]+)[.].*", "\\1", i)))
  image_set_defines(mynd, defines)
  image_write(mynd, path = paste(pathnew,paste(gsub(".*[/]([^.]+)[.].*", "\\1", i),"JPEG",sep = "."),sep = "/"))
}

#ATH! þurfti að gera: remotes::install_github("r-spatial/leafem") ### vesen með eina mynd fyrir hvern punkt, þær komu alltaf allar í alla punktana

###Ná í slóðirnar að myndunum eftir að þær eru komnar í möppuna minnimyndir
library(httr)
req <- GET("https://api.github.com/repos/harkanatta/reykjafoss/git/trees/main?recursive=1")
stop_for_status(req)
filelist <- unlist(lapply(content(req)$tree, "[", "path"), use.names = F)
myndalisti <- grep("minnimyndir", filelist, value = TRUE, fixed = TRUE)
myndaurl <- list()
for (i in 1:length(myndalisti)) {
myndaurl[i] <-  paste0("https://raw.githubusercontent.com/harkanatta/reykjafoss/main/",myndalisti[i],sep = "")
}
unname(unlist(myndaurl))

image_files <- list.files(pathnew, full.names = TRUE,recursive = T)
svaka <- read_exif(image_files,tags = "GPSPosition")
rass <- separate(svaka, GPSPosition, into = c("lat", "lon"), sep = "\\s") %>% mutate(lat=as.numeric(lat), lon=as.numeric(lon))
rass <- rass[!is.na(rass$lat) & !is.na(rass$lon),]
ress <- st_as_sf(rass, coords = c("lon", "lat"), crs = 'WGS84')
ress$myndir <- unname(unlist(myndaurl))[grepl("JPEG|JPG|PNG",unname(unlist(myndaurl)))]
img <- "https://github.com/harkanatta/ssnv_trident/blob/master/graphs/tvologo.jpg?raw=true"
map <- mapview(nvumd,col.regions="#cb5600",map.types="Stamen.TerrainBackground", legend = FALSE) +
  mapview(ress,legend=F,popup = leafpop::popupImage(ress$myndir))

map %>% 
  leafem::addLogo(img, width = '20%', height = '25%',offset.y = 20,offset.x = 80,alpha = 0.7) %>% 
  leaflet.extras::addFullscreenControl(pseudoFullscreen = T)


library(leaflet)

m <- leaflet() %>%
  addTiles() %>% 
  addProviderTiles(providers$OpenStreetMap) %>%
  addScaleBar() %>% 
  addCircleMarkers(data = ress,
                   popup = popupImage(ress$myndir)) %>% 
  leafem::addLogo(img, width = '20%', height = '25%',offset.y = 20,offset.x = 80,alpha = 0.7) %>% 
  leaflet.extras::addFullscreenControl(pseudoFullscreen = T)

library(htmlwidgets)
saveWidget(m, file="m.html")
