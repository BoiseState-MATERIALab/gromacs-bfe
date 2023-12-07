#!/bin/bash
#SBATCH -J MD_OSM_SMI10B16_SPCE_Fast_Step
#SBATCH -o log_slurm.o%j # output and error file name (%j expands to jobID)
#SBATCH -n 48 # total number of tasks requested
#SBATCH -N 1 # number of nodes you want to run on
#SBATCH -p bsudfq # queue (partition)
#SBATCH -t 36:00:00 # run time
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=gabrielmiles@u.boisestate.edu

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

for i in {0..30}
do
    LAMBDA=$i

    # A new directory will be created for each value of lambda and
    # at each step in the workflow for maximum organization.

    mkdir Lambda_$LAMBDA
    cd Lambda_$LAMBDA

    ##############################
    # ENERGY MINIMIZATION STEEP  #
    ##############################
    echo "Starting minimization for lambda = $LAMBDA..." 

    # Iterative calls to grompp and mdrun to run the simulations

    # Steepest Descent
    mkdir em-steep
    cd em-steep

    gmx_mpi grompp -f $MDP/em-steep/em_steep_$LAMBDA.mdp -c $HOME/solv_ions.gro -p $HOME/topol.top -o em_steep_$LAMBDA.tpr -maxwarn 1
    gmx_mpi mdrun -deffnm em_steep_$LAMBDA

    cd ..

    # Conjugate Gradient
    mkdir em-cg
    cd em-cg

    gmx_mpi grompp -f $MDP/em-cg/em_cg_$LAMBDA.mdp -c ../em-steep/em_steep_$LAMBDA.gro -p $HOME/topol.top -o em_cg_$LAMBDA.tpr -maxwarn 1
    gmx_mpi mdrun -deffnm em_cg_$LAMBDA
	
    cd ..

    sleep 10

    #####################
    # NVT EQUILIBRATION #
    #####################
    echo "Starting constant volume equilibration..."

    mkdir nvt
    cd nvt

    gmx_mpi grompp -f $MDP/nvt/nvt_$LAMBDA.mdp -c ../em-cg/em_cg_$LAMBDA.gro -r ../em-cg/em_cg_$LAMBDA.gro -p $HOME/topol.top -n $HOME/index.ndx -o nvt_$LAMBDA.tpr -maxwarn 1

    gmx_mpi mdrun -deffnm nvt_$LAMBDA 

    echo "Constant volume equilibration complete."

    cd ..

    sleep 10

    #####################
    # NPT EQUILIBRATION #
    #####################
    echo "Starting constant pressure equilibration..."

    mkdir npt
    cd npt

    gmx_mpi grompp -f $MDP/npt/npt_$LAMBDA.mdp -c ../nvt/nvt_$LAMBDA.gro -p $HOME/topol.top -t ../nvt/nvt_$LAMBDA.cpt -o npt_$LAMBDA.tpr -r ../nvt/nvt_$LAMBDA.gro -n $HOME/index.ndx -maxwarn 1
    gmx_mpi mdrun -deffnm npt_$LAMBDA

    echo "Constant pressure equilibration complete."

    sleep 10

   
    # End
    echo "Ending. Job completed for lambda = $LAMBDA"

    cd $RUN
done

