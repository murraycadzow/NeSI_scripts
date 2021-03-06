#!/bin/bash
#SBATCH -J nsl_array
#SBATCH -A uoo00008         # Project Account
#SBATCH --time=23:00:00     # Walltime
#SBATCH --mem=4096  # memory/node (in MB)
#SBATCH --cpus-per-task=10   # 10 OpenMP Threads
#SBATCH --array=1-22


POP=$1
i=$SLURM_ARRAY_TASK_ID
echo $POP chr $i

DIR=$SLURM_SUBMIT_DIR


srun tar -C $TMP_DIR -xzf ${POP}_in_selscan.tar.gz ${POP}/chr${i}/* 
cd $TMP_DIR && srun ~/uoo00008/selscan/src/selscan --nsl --hap ${POP}/chr${i}/${POP}${i}_selscan.selscanhaps --map  ${POP}/chr${i}/${POP}${i}_selscan.selscanmap --threads 10 --out ${TMP_DIR}/${POP}${i}
srun tar -czf ${POP}_chr${i}_nsl.tar.gz *log *out
srun cp ${POP}_chr${i}_nsl.tar.gz $DIR
