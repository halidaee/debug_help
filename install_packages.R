package_list <- c("caret", "Rcpp", "future", "furrr", "rdist", "devtools")
install.packages(package_list, dependencies = TRUE)
devtools::install_github("mpleung/ARD/R/nuclear_ard")
