# install R packages (with dependency) from a local folder
# by wwang010, this version: 27 May 2022

#Pls change lines 5 & 6 & 8 
zip_path= "C:/Users/XXX/Documents/R4zip"               # place all R package binary zip files into this folder
libpath = "C:/Users/XXX/Documents/R/win-library/4.1"   # R library location

pack_basic =list.files("C:/Program Files/R/R-4.1.0/library" )


# Function to select the latest version of the package
final_package_ver <- function(package_name) {
  final_package_ver=list.files(zip_path,pattern=paste0('^',package_name,'_'))
  if (length(final_package_ver)>1 ) {
    temp= sub("^.*_", "", final_package_ver)
    temp= sub( "*.zip","", temp)
    tt=temp[1]
    for (j in 2:length(temp)){
      if (compareVersion(tt, temp[j])==-1){
        tt=temp[j]
      } 
    }
  final_package_ver =paste0(package_name, '_', tt, ".zip")
  }    
  return(final_package_ver) 
}

# Function to check dep
dep_check = function(package_name){
  if (package_name %in% setdiff(installed.packages()[,1], pack_basic)){
    temp=readRDS(paste0(libpath, "/", package_name, "/Meta/package.rds"))
    dep = c(names(temp[["Imports"]] ),names(temp[["Depends"]] ), names(temp[["LinkingTo"]] ) )
  } else{
    dep=character()
  }
  return(dep)
}


# Function to identify dependency packages needed
pack_dep= function(package_name){
  temp = dep_check(package_name)
  dep = setdiff(temp,installed.packages()[,1])
  return(dep)
}

pack_multi_dep =function(vec_pack){
  temp= unique(unlist(lapply(vec_pack, pack_dep )))
  return(temp)
}


# Function to install packages
install_sg_pack = function(package_name){
  print(noquote(paste0("Installing ", package_name)))
  final_package_ver =final_package_ver(package_name)
  if(length(final_package_ver)>0 ){
  package_path = paste0(zip_path,"/",final_package_ver)
  install.packages(package_path, repos = NULL, type = "win.binary",lib=libpath)
  } else{
  print(noquote(paste0("No binary zip file for \"", package_name, "\", pls check \"zip_path\" and the CRAN website for its compatibility with this R version.")))
  }
}

install_multi_pack= function(vec_pack){
  for (pack in vec_pack){
    install_sg_pack(pack)
  }
}

# Final function to install the package and dependency 
install_packages=function(package_name){
  if (package_name %in% installed.packages()[,1]){
    print(noquote(paste0("\"", package_name, "\" was already installed.")))
  }else{
    install_sg_pack(package_name)
  }
  
  # install dep
  temp= pack_dep(package_name) 
  while (length(temp)> 0 ){
    print(noquote("Installing dependency."))
    if(length(temp) == 1 ){ 
      install_sg_pack(temp)
      temp = pack_dep(temp)
    } else{
      install_multi_pack(temp)
      temp= pack_multi_dep(temp)
    }
  }
}
print(noquote( "pls add \" \" to the package name when using install_packages(). "))
      