#!/bin/bash
#SBATCH -J rehh
#SBATCH -A uoo00008         # Project Account
#SBATCH --time=60:00:00     # Walltime
#SBATCH --mem-per-cpu=20240  # memory/cpu (in MB)
#SBATCH --cpus-per-task=4   # 12 OpenMP Threads
#SBATCH -C sb
export OPENBLAS_MAIN_FREE=1
i=$1
echo slurm jobib = $SLURM_JOBID > $SLURM_SUBMIT_DIR/dirs.txt
echo slurm submit dir = $SLURM_SUBMIT_DIR >> $SLURM_SUBMIT_DIR/dirs.txt
echo slurm tmp dir = $TMP_DIR >> $SLURM_SUBMIT_DIR/dirs.txt
echo chr $i

DIR=$SLURM_SUBMIT_DIR

module load Python/2.7.8-goolf-1.5.14
#module load Python/2.7.6-goolf-1.5.14
module load R/3.0.3-goolf-1.5.14
 
cd $TMP_DIR && srun /home/murray.cadzow/.local/bin/haps_interpolate --haps $DIR/AXIOM_aachanged.haps --output AXIOM_genetic_dist.haps --genetic-map /home/murray.cadzow/uoo00008/selectionTools-wm/referencefiles/genetic_maps/genetic_map_chr${i}_combined_b37.txt --physical-position-output AXIOM_genetic_dist.pos && srun Rscript /home/murray.cadzow/uoo00008/MerrimanSelectionPipeline/corescripts/multicore_iHH.R -p AXIOM -i $TMP_DIR/AXIOM_genetic_dist.haps -c $i --window 10000000 --overlap 2000000 --maf 0.0 --big_gap 200000 --small_gap 20000 --small_gap_penalty 20000 --haplo_hh --physical_map_haps $TMP_DIR/AXIOM_genetic_dist.pos --cores 4 --working_dir . --offset 1 --ihs

srun tar -czf chr${i}_ihh.tar.gz *
srun cp $TMP_DIR/*.tar.gz $DIR
