# Project Setup Instructions

## System Requirements
Allocate 8 GB of RAM to the job per core assigned to a node/computer used for running in parallel.  

## Modifications needed to script to run on own system: 

- No changes needed to the R file. It loads everything needed from system environmental variables. 
- Line 5 should be changed to the project’s local parent folder. E.g. if the project is in a folder /users/tyler/debug_help, then LAB_DIR=/users/tyler
- Harvard uses SLURM for its cluster scheduler. Adjust configurations on line 2-8. If running interactively/locally, just delete those lines and edit lines 20 & 21 to match the number of CPUs assigned to the job. If using a different scheduler, edit those same lines accordingly. 
- Harvard uses Singularity containers (similar to Docker) on its cluster. If your system does also, adjust lines 6-8 accordingly. If not, lines 18 and 30 should be adjusted to directly run the Rscript command. (This can be done by just deleting everything on those lines before the term ‘Rscript’.)

## How to check for a data run

If the job runs to completion, the log file should look like the following, where the internal loop ran successfully 25 times:



```{r, eval = FALSE}
running
  '/usr/local/lib/R/bin/R --no-echo --no-restore --no-save --no-restore --file=proper_cross_validation.R'

Loading required package: ggplot2
Loading required package: lattice
── Attaching core tidyverse packages ──────────────────────── tidyverse 2.0.0 ──
✔ dplyr     1.1.4     ✔ readr     2.1.5
✔ forcats   1.0.0     ✔ stringr   1.5.1
✔ lubridate 1.9.3     ✔ tibble    3.2.1
✔ purrr     1.0.2     ✔ tidyr     1.3.1
── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
✖ dplyr::filter() masks stats::filter()
✖ dplyr::lag()    masks stats::lag()
✖ purrr::lift()   masks caret::lift()
ℹ Use the conflicted package (<http://conflicted.r-lib.org/>) to force all conflicts to become errors
Loading required package: Matrix

Attaching package: ‘Matrix’

The following objects are masked from ‘package:tidyr’:

    expand, pack, unpack


Attaching package: ‘future’

The following object is masked from ‘package:caret’:

    cluster

[1] 650
[1] "650"
[1] 162
[1] 1
[1] "2024-06-04 18:09:41 UTC"
[1] 2
[1] "2024-06-05 21:35:43 UTC"
[1] 3
[1] "2024-06-04 18:09:41 UTC"
[1] 4
[1] "2024-06-04 18:09:41 UTC"
[1] 5
[1] "2024-06-04 18:09:41 UTC"
[1] 6
[1] "2024-06-04 18:09:41 UTC"
[1] 7
[1] "2024-06-04 18:09:41 UTC"
[1] 8
[1] "2024-06-05 08:45:54 UTC"
[1] 9
[1] "2024-06-04 18:09:41 UTC"
[1] 10
[1] "2024-06-04 18:09:41 UTC"
[1] 11
[1] "2024-06-04 18:09:41 UTC"
[1] 12
[1] "2024-06-04 18:09:41 UTC"
[1] 13
[1] "2024-06-05 02:18:40 UTC"
[1] 14
[1] "2024-06-04 18:09:41 UTC"
[1] 15
[1] "2024-06-04 18:09:41 UTC"
[1] 16
[1] "2024-06-04 18:09:41 UTC"
[1] 17
[1] "2024-06-04 18:09:41 UTC"
[1] 18
[1] "2024-06-04 18:09:41 UTC"
[1] 19
[1] "2024-06-05 05:48:30 UTC"
[1] 20
[1] "2024-06-04 18:09:41 UTC"
[1] 21
[1] "2024-06-04 18:09:41 UTC"
[1] 22
[1] "2024-06-04 18:09:41 UTC"
[1] 23
[1] "2024-06-04 18:09:41 UTC"
[1] 24
[1] "2024-06-04 18:09:42 UTC"
[1] 25
[1] "2024-06-05 16:30:57 UTC"

```

By contrast, if there is an error, you may get a message about either a `segfault` or something like 

```{r, eval=FALSE}
running
  '/usr/local/lib/R/bin/R --no-echo --no-restore --no-save --no-restore --file=proper_cross_validation_debug.R'

Loading required package: ggplot2
Loading required package: lattice
── Attaching core tidyverse packages ──────────────────────── tidyverse 2.0.0 ──
✔ dplyr     1.1.4     ✔ readr     2.1.5
✔ forcats   1.0.0     ✔ stringr   1.5.1
✔ lubridate 1.9.3     ✔ tibble    3.2.1
✔ purrr     1.0.2     ✔ tidyr     1.3.1
── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
✖ dplyr::filter() masks stats::filter()
✖ dplyr::lag()    masks stats::lag()
✖ purrr::lift()   masks caret::lift()
ℹ Use the conflicted package (<http://conflicted.r-lib.org/>) to force all conflicts to become errors
Loading required package: Matrix

Attaching package: ‘Matrix’

The following objects are masked from ‘package:tidyr’:

    expand, pack, unpack


Attaching package: ‘future’

The following object is masked from ‘package:caret’:

    cluster

[1] 650
[1] "650"
[1] 162
[1] 1
[1] "2024-08-20 22:16:35 UTC"
[1] 2
[1] "2024-08-20 23:09:03 UTC"
[1] 3
[1] "2024-08-21 00:01:12 UTC"
[1] 4
[1] "2024-08-21 00:52:06 UTC"
[1] 5
[1] "2024-08-21 01:43:00 UTC"
[1] 6
[1] "2024-08-21 02:32:50 UTC"
[1] 7
[1] "2024-08-21 03:22:39 UTC"
[1] 8
[1] "2024-08-21 04:15:14 UTC"
[1] 9
[1] "2024-08-21 05:06:05 UTC"

Error in `map()`:
ℹ In index: 9.
Caused by error in `map()`:
ℹ In index: 103.
Caused by error:
! Mat::submat(): indices out of bounds or incorrectly used
Backtrace:
     ▆
  1. ├─... %>% mutate(K = K_val)
  2. ├─dplyr::mutate(., K = K_val)
  3. ├─dplyr::mutate(., N = N_val)
  4. ├─dplyr::mutate(., partition = partition)
  5. ├─dplyr::bind_rows(.)
  6. │ └─rlang::list2(...)
  7. ├─purrr::map(1:num_sims, MSE_simulation)
  8. │ └─purrr:::map_("list", .x, .f, ..., .progress = .progress)
  9. │   ├─purrr:::with_indexed_errors(...)
 10. │   │ └─base::withCallingHandlers(...)
 11. │   ├─purrr:::call_with_cleanup(...)
 12. │   └─global .f(.x[[i]], ...)
 13. │     └─purrr::map(...)
 14. │       └─purrr:::map_("list", .x, .f, ..., .progress = .progress)
 15. │         ├─purrr:::with_indexed_errors(...)
 16. │         │ └─base::withCallingHandlers(...)
 17. │         ├─purrr:::call_with_cleanup(...)
 18. │         └─.f(.x[[i]], ...)
 19. │           └─nuclearARD::accel_nuclear_gradient(...)
 20. │             └─nuclearARD:::compute_iteration(...)
 21. ├─base::stop(`<std::t__>`)
 22. └─purrr (local) `<fn>`(`<std::t__>`)
 23.   └─cli::cli_abort(...)
 24.     └─rlang::abort(...)
Execution halted

```

which arises because the data run caused the matrix to become so large that SVD failed, so subsetting based on singular values is no longer possible. 