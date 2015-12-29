#!/bin/bash
#SBATCH -J selscan_array
#SBATCH -A uoo00008         # Project Account
#SBATCH --time=12:00:00     # Walltime
#SBATCH --mem=4096  # memory/node (in MB)
#SBATCH --cpus-per-task=16   # 10 OpenMP Threads
#SBATCH --array=1-22
#SBATCH -C sb

POP1=$1
POP2=$2
i=$SLURM_ARRAY_TASK_ID
#echo $POP chr $i

DIR=$SLURM_SUBMIT_DIR

module load Python/2.7.8-goolf-1.5.14

#need ancestral file from omni/axiom
srun tar -C $TMP_DIR -xzf chr${i}.tar.gz results/${POP1}_aachanged.haps 

#create selscan file
cd $TMP_DIR && srun python /home/murray.cadzow/uoo00008/MerrimanSelectionPipeline/selection_pipeline/haps_interpolate.py \
--haps results/${POP1}_aachanged.haps \
--output ${POP1}_genetic_dist.haps \
--genetic-map /home/murray.cadzow/uoo00008/MerrimanSelectionPipeline/referencefiles/genetic_maps/genetic_map_chr${i}_combined_b37.txt \
--physical-position-output ${POP1}_genetic_dist.pos

srun python /home/murray.cadzow/uoo00008/MerrimanSelectionPipeline/selection_pipeline/haps_to_selscan.py \
--haps ${POP1}_genetic_dist.haps \
--pos ${POP1}_genetic_dist.pos \
--chr ${i} \
--output ${POP1}${i}_selscan

#need selscan file for POP2 (1KGP pops)
srun tar -C $TMP_DIR -xzf ~/uoo00008/selscan_in/${POP2}_in_selscan.tar.gz ${POP2}/${POP2}${i}_selscan.selscanhaps ${POP2}/${POP2}${i}_selscan.selscanmap
#merge selscan files
mkdir $TMP_DIR/${POP1}_${POP2}

cd $TMP_DIR/${POP1}_${POP2} && srun python /home/murray.cadzow/uoo00008/MerrimanSelectionPipeline/selection_pipeline/selscan_to_selscan_xpehh.py \
--pop1-prefix $TMP_DIR/${POP1}${i}_selscan \
--pop1-name ${POP1} \
--pop2-prefix $TMP_DIR/${POP2}/${POP2}${i}_selscan \
--pop2-name ${POP2} \
-c ${i} \
--out ./

ls $TMP_DIR/*

#srun tar -C $TMP_DIR -xzf ${POP1}_${POP2}.tar.gz ${POP1}_${POP2}/*${i}.xpehh* ${POP1}_${POP2}/*${i}.*.xp*
cd $TMP_DIR && srun ~/uoo00008/selscan/src/selscan \
--xpehh \
--hap ${POP1}_${POP2}/${POP1}_${i}.matches_${POP2}.xpehh_selscanhaps \
--map  ${POP1}_${POP2}/${POP1}_${POP2}_${i}.xpehh_selscanmap \
--ref ${POP1}_${POP2}/${POP2}_${i}.matches_${POP1}.xp_ehh_selscanhaps  \
--threads 16 \
--out ${TMP_DIR}/${POP1}_${POP2}_${i}

srun tar -czf ${POP1}_${POP2}_chr${i}_xpehh.tar.gz *log *.out ${POP1}_${POP2}/ ${POP1}${i}_selscan*
srun cp ${POP1}_${POP2}_chr${i}_xpehh.tar.gz $DIR
