# Project Setup Instructions

## System Requirements
Allocate 8 GB of RAM to the job per core assigned to a node/computer used for running in parallel.  

## Modifications needed to script to run on own system: 

- No changes needed to the R file. It loads everything needed from system environmental variables. 
- Line 5 should be changed to the project’s local parent folder. E.g. if the project is in a folder /users/tyler/debug_help, then LAB_DIR=/users/tyler
- Harvard uses SLURM for its cluster scheduler. Adjust configurations on line 2-8. If running interactively/locally, just delete those lines and edit lines 20 & 21 to match the number of CPUs assigned to the job. If using a different scheduler, edit those same lines accordingly. 
- Harvard uses Singularity containers (similar to Docker) on its cluster. If your system does also, adjust lines 6-8 accordingly. If not, lines 18 and 30 should be adjusted to directly run the Rscript command. (This can be done by just deleting everything on those lines before the term ‘Rscript’.)