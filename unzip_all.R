zips = list.files(recursive = T,pattern = ".zip")
paths = dirname(zips)
for( i in 1:length(zips)){
       unzip(zips[i],exdir = paths[i])
}
