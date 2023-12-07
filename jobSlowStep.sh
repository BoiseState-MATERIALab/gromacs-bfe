#!/bin/bash
#SBATCH -J MD_OSM_SMI10B16_SPCE_21_30_states
#SBATCH -o log_slurm.o%j # output and error file name (%j expands to jobID)
#SBATCH -n 48 # total number of tasks requested
#SBATCH -N 1 # number of nodes you want to run on
#SBATCH -p bsudfq # queue (partition)
#SBATCH -t 96:00:00 # run time
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user gabrielmiles@u.boisestate.edu

module load slurm
module load gcc
module load gromacs

# Set some environment variables
HOME=~/scratch/SMI10B16/OSM-SMI10B16-SPCE
echo "Simulation home directory set to $HOME"
MDP=$HOME/MDP
echo ".mdp files are stored in $MDP"

# Folder for run data - be sure to update this!
RUN=$HOME/Run1
echo "Run data will be stored in $RUN"
cd $RUN

#Make directory for free energy results files
mkdir bar
BAR=$RUN/bar


for i in {21..30}
do

    LAMBDA=$i

    # A new directory will be created for each value of lambda and
    # at each step in the workflow for maximum organization.

    cd Lambda_$LAMBDA

    #################
    # PRODUCTION MD #
    #################

    echo "Starting production MD simulation..."

    mkdir md
    cd md

    gmx_mpi grompp -f $MDP/md/md_$LAMBDA.mdp -c $RUN/Lambda_$LAMBDA/npt/npt_$LAMBDA.gro -p $HOME/topol.top -t $RUN/Lambda_$LAMBDA/npt/npt_$LAMBDA.cpt -o md_$LAMBDA.tpr -n $HOME/index.ndx -maxwarn 1
    gmx_mpi mdrun -deffnm md_$LAMBDA -dhdl md_$LAMBDA.xvg 

    echo "Production MD complete for lambda=$LAMBDA."
    
    #Put a copy of the .xvg file in in bar directory for future use
    cp md_$LAMBDA.xvg $BAR/md_$LAMBDA.xvg
	
    cd $RUN

done

# End
echo "Ending. Job completed."

exit
