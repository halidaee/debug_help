unlink(".RData")


Sys.getenv("MKL_THREADING_LAYER")

sessionInfo()


# Change this line.
top_directory <- Sys.getenv("LAB_DIR")
adj_directory <- paste0(top_directory, "debug_help/")

library(caret)
library(Rcpp)
library(tidyverse)
library(nuclearARD)
library(parallel)
library(future)
library(furrr)
library(purrr)
library(broom)
library(rdist)

omp_num_threads <- as.integer(Sys.getenv("OMP_NUM_THREADS"))
print(paste0("Thread count:", omp_num_threads))
plan(multicore, workers = omp_num_threads)

Adj_Matrix_Construction <- function(P_mat) {
    diag(P_mat) <- 0
    U <- matrix(runif(N * N), nrow = N, ncol = N)
    U <- t(U) / 2 + U / 2
    A_mat <- (U < P_mat) * 1.0
    return(list(P_mat = P_mat, A_mat = A_mat))
}


matrix_MSE <- function(A, B) {
    A <- as.matrix(A)
    B <- as.matrix(B)
    MSE <- mean((A - B)^2)
    return(MSE)
}

vector_MSE <- function(A, B) {
    A <- as.vector(A)
    B <- as.vector(B)
    MSE <- mean((A - B)^2)
    return(MSE)
}

MSE_tibble_func <- function(x, y) {
    x$MSE[lambda_ind] <- y
    return(x)
}

N_vals <- c(60, 100, 200, 300)
K_vals <- c(7, 10, 14, 17)
# N_vals <- c(100, 200, 300)
# K_vals <- c(10, 14, 17)

number_vals <- length(N_vals)

job_array_index <- as.numeric(Sys.getenv("ARRAY_ID"))
print(job_array_index)
print(Sys.getenv("ARRAY_ID"))
partition <- ceiling(job_array_index %/% number_vals)
print(partition)
NK_ind <- 1 + (job_array_index %% number_vals)

set.seed(125 + partition)
options <- furrr_options(seed = 125 + partition)



N_val <- N_vals[NK_ind]
K_val <- K_vals[NK_ind]


N <- N_val
K <- K_val



lambda_grid <- seq(0.1, 50, 0.1)
# k_folds <- 5
lambda_length <- length(lambda_grid)


MSE_simulation <- function(sim_number) {
    print(sim_number)
    print(Sys.time())

    # Create empty lists that we will add elements to.
    P_true <- list() # List of true probability matrices, one per random graph model
    A_true <- list() # List of true adjacency matrices, one per random graph model
    ARD_mats <- list() # List ARD data matrices
    P_hat <- list() # List of probability matrices estimated from ARD data
    y <- list() # List of 'outcome' variable values, one for each model, to be used in regression.
    nuclr_mats <- list() # List of nuclear adjacency matrices

    model_types <- c("LSM", "RDP", "SBM")

    # First, we conduct the simulation for the latent space model.
    alpha <- rnorm(N) # Generate intercept term.
    positions <- matrix(rexp(N * 2), nrow = N, ncol = 2) # Generate locations.
    latent_index <- alpha + t(replicate(N, alpha)) - pdist(positions) # Compute latent index.
    P_LSM <- exp(latent_index) / (1 + exp(latent_index)) # Compute log odds ratio.
    LSM_mats <- Adj_Matrix_Construction(P_LSM)
    P_true[["LSM"]] <- LSM_mats$P_mat
    A_true[["LSM"]] <- LSM_mats$A_mat


    # Next, conduct simulation for random dot product graph.
    positions <- sqrt(runif(N))
    P_RDP <- positions * t(replicate(N, positions))
    RDP_mats <- Adj_Matrix_Construction(P_RDP)
    P_true[["RDP"]] <- RDP_mats$P_mat
    A_true[["RDP"]] <- RDP_mats$A_mat


    # Third, the stochastic block model simulation.
    P_SBM <- matrix(rep(0.3, N * N), nrow = N, ncol = N)
    groups <- 5
    bs <- floor(N / 5)
    for (g in 0:(groups - 1)) {
        P_SBM[(g * bs + 1):((g + 1) * bs), (g * bs + 1):((g + 1) * bs)] <- 0.7
    }
    SBM_mats <- Adj_Matrix_Construction(P_SBM)
    P_true[["SBM"]] <- SBM_mats$P_mat
    A_true[["SBM"]] <- SBM_mats$A_mat

    # Generate ARDs[]
    types <- lapply(model_types, function(x) matrix(rbinom(K * N, 1, 0.5), nrow = K, ncol = N))
    types <- setNames(types, model_types)

    ARD_mats <- lapply(model_types, function(x) t(types[[x]] %*% A_true[[x]]))
    ARD_mats <- setNames(ARD_mats, model_types)

    MSE_tibbles <- list()

    for (model in model_types) {
        char_mat <- types[[model]]
        ARD_mat <- ARD_mats[[model]]


        P_hat <- map(lambda_grid, function(lambda) accel_nuclear_gradient(as.matrix(char_mat), t(as.matrix(ARD_mat)), lambda = lambda))
        MSE_vector <- map_dbl(P_hat, function(x) matrix_MSE(x, P_true[[model]]))
        MSE_tibbles[[model]] <- tibble(lambda = lambda_grid, MSE = MSE_vector)
    }



    A_frame <- enframe(A_true)
    ARD_frame <- enframe(ARD_mats)
    types_frame <- enframe(types)
    MSE_frame <- enframe(MSE_tibbles)
    full.tibble <- enframe(P_true) %>%
        rename(P_true = value) %>%
        left_join(A_frame, by = "name") %>%
        rename(A_true = value) %>%
        left_join(MSE_frame, by = "name") %>%
        rename(MSE_table = value) %>%
        left_join(ARD_frame, by = "name") %>%
        rename(ARD_mat = value) %>%
        left_join(types_frame, by = "name") %>%
        rename(net_type = name, types_mat = value) %>%
        mutate(sim_number = sim_number)

    return(full.tibble)
}

num_sims <- 25

full_df <- future_map(1:num_sims, MSE_simulation, .options = options) %>%
    # full_df <- map(1:num_sims, MSE_simulation) %>%
    bind_rows() %>%
    mutate(partition = partition) %>%
    mutate(N = N_val) %>%
    mutate(K = K_val)

reduced_df <- full_df %>%
    select(sim_number, partition, net_type, N, K, MSE_table)

## Create string for name of csv file this will be exported to.
cv_directory <- paste0(top_directory, "debug_help/")
full_filename <- paste0(cv_directory, "full_", K_val, "_", N_val, "_", partition, ".RData")
reduced_filename <- paste0(cv_directory, "reduced_", K_val, "_", N_val, "_", partition, ".RData")

save(full_df, file = full_filename)
save(reduced_df, file = reduced_filename)
