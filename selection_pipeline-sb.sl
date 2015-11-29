#!/bin/bash
#SBATCH -J selection
#SBATCH -A uoo00008         # Project Account
#SBATCH --time=60:00:00     # Walltime
#SBATCH --mem-per-cpu=30240  # memory/cpu (in MB)
#SBATCH --cpus-per-task=6   # 10 OpenMP Threads
#SBATCH -C sb

export OPENBLAS_MAIN_FREE=1
i=$1
echo slurm jobib = $SLURM_JOBID > $SLURM_SUBMIT_DIR/dirs.txt
echo slurm submit dir = $SLURM_SUBMIT_DIR >> $SLURM_SUBMIT_DIR/dirs.txt
echo slurm tmp dir = $TMP_DIR >> $SLURM_SUBMIT_DIR/dirs.txt
echo chr $i

DIR=$SLURM_SUBMIT_DIR

module load Python/2.7.8-goolf-1.5.14
module load R/3.0.3-goolf-1.5.14


cd $TMP_DIR && srun python ~/.local/bin/selection_pipeline  --vcf $DIR/OMNI_chr${i}_aligned.vcf -c ${i} --config-file $DIR/../defaults_nesi-sb.cfg --maf 0.01 --hwe 0.001 --TajimaD 30 --fay-Window-Width 30 --fay-Window-Jump 30 --ehh-window-size 10 --ehh-overlap 2 --big-gap 200 --small-gap 20 --small-gap-penalty 20 --population OMNI --cores 6 --imputation --impute-split-size 5 --no-clean-up

srun tar -czf chr${i}.tar.gz * 
srun cp $TMP_DIR/chr${i}.tar.gz $DIR/
