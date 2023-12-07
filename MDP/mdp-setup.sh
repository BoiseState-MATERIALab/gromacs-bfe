#!/bin/bash
# Author: Gabe Miles
# Date: 9/13/22
# Description: Sets up .mdp parameter files for each lambda state. 
# Creates copy of original .mdp, and insert proper init_lambda_state value for
# specific lambda state.

mkdir em-steep
mkdir em-cg
mkdir nvt
mkdir npt
mkdir md

for i in {0..30}
do

    # Create copy of each mdp, replace marked line with value
    cp em-steep.mdp em-steep/em_steep_$i.mdp
    perl -pi -w -e "s/0 ; MARKER/$i/g" "em-steep/em_steep_$i.mdp"

    cp em-cg.mdp em-cg/em_cg_$i.mdp
    perl -pi -w -e "s/0 ; MARKER/$i/g" "em-cg/em_cg_$i.mdp"
    
    cp nvt.mdp nvt/nvt_$i.mdp
    perl -pi -w -e "s/0 ; MARKER/$i/g" "nvt/nvt_$i.mdp"

    cp npt.mdp npt/npt_$i.mdp
    perl -pi -w -e "s/0 ; MARKER/$i/g" "npt/npt_$i.mdp"

    cp md.mdp md/md_$i.mdp
    perl -pi -w -e "s/0 ; MARKER/$i/g" "md/md_$i.mdp"

done

exit
