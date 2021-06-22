library(magrittr)
library(magick)
library(here)
herepath <- here()
pathnew <- paste(herepath,"nytt",sep = "/")
dir.create(pathnew)
myndir <- list.files(herepath,pattern = "JPEG", recursive = T,full.names = T)

defines <- c("png:compression-filter" = "1", "png:compression-level" = "0")

for (i in myndir) {
mynd <- image_read(i) %>%
  image_resize("800x800")
print(paste(gsub(".*[/]([^.]+)[.].*", "\\1", i)))
  image_set_defines(mynd, defines)
  image_write(mynd, path = paste(pathnew,paste(gsub(".*[/]([^.]+)[.].*", "\\1", i),"JPEG",sep = "."),sep = "/"))
}
