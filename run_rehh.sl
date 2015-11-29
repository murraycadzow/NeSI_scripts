#!/bin/bash
#SBATCH -J selection
#SBATCH -A uoo00008         # Project Account
#SBATCH --time=40:00:00     # Walltime
#SBATCH --mem-per-cpu=8000  # memory/cpu (in MB)
#SBATCH --cpus-per-task=12   # 12 OpenMP Threads
#SBATCH --mail-user=murray.cadzow@otago.ac.nz
#SBATCH --mail-type=ALL
export OPENBLAS_MAIN_FREE=1
POP=$1
i=$2
#echo slurm jobib = $SLURM_JOBID > $SLURM_SUBMIT_DIR/dirs.txt
#echo slurm submit dir = $SLURM_SUBMIT_DIR >> $SLURM_SUBMIT_DIR/dirs.txt
#echo slurm tmp dir = $TMP_DIR >> $SLURM_SUBMIT_DIR/dirs.txt
#echo chr $i

DIR=$SLURM_SUBMIT_DIR

module load Python/2.7.8-goolf-1.5.14
module load R/3.0.3-goolf-1.5.14

#srun gzip -dc $DIR/${POP}.chr${i}_biallelic.vcf.gz > $TMP_DIR/${POP}_chr${i}.vcf 
#cd $TMP_DIR && srun python ~/.local/bin/selection_pipeline -i $TMP_DIR/${POP}_chr${i}.vcf --phased-vcf -c $i --config-file $DIR/defaults_nesi.cfg --maf 0.01 --hwe 0.001 --TajimaD 30 --fay-Window-Width 30 --fay-Window-Jump 30 --ehh-window-size 10 --ehh-overlap 2 --big-gap 200 --small-gap 20 --small-gap-penalty 20 --population $POP --cores 1 --no-clean-up --no-ihs
#srun /home/murray.cadzow/.local/bin/haps_interpolate --haps results/${POP}_aachanged.haps --output ${POP}_genetic_dist.haps --genetic-map /home/murray.cadzow/uoo00008/selectionTools-wm/referencefiles/genetic_maps/genetic_map_chr${i}_combined_b37.txt --physical-position-output ${POP}_genetic_dist.pos


cd $TMP_DIR && Rscript /home/murray.cadzow/uoo00008/selectionTools1.1/corescripts/multicore_iHH.R -p ${POP} -i ${DIR}/${POP}${i}_gen.haps -c ${i} --window 10000000 --overlap 2000000 --maf 0.0 --big_gap 200000 --small_gap 20000 --small_gap_penalty 20000 --haplo_hh --physical_map_haps ${DIR}/${POP}${i}_gen.pos --cores 12 --working_dir . --offset 1 --ihs

srun tar -czf ${POP}chr${i}_rehh.tar.gz *
srun cp $TMP_DIR/*.tar.gz $DIR
