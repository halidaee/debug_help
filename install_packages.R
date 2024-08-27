package_list <- c("caret", "Rcpp", "future", "furrr", "rdist", "devtools")

# Install packages not yet installed
installed_packages <- package_list %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
    install.packages(package_list[!installed_packages])
}

if (!"nuclearARD" %in% installed.packages()) {
    devtools::install_github("mpleung/ARD/R/nuclear_ard")
}
