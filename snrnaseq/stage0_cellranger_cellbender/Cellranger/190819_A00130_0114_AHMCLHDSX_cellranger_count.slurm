#!/bin/bash
#SBATCH -J cellranger_count_190819_A00130_0114_AHMCLHDSX
#SBATCH -p physical
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=192000
#SBATCH --time=3-00:00:00
#SBATCH -o slurm.%N.%j.out # STDOUT
#SBATCH -e slurm.%N.%j.err # STDERR

CELLRANGER_HOME=/home/frossello/extras/frossello/cellranger-6.1.1
HUMAN_INDEX=/home/frossello/extras/frossello/cellranger-gtx-refdata/refdata-gex-GRCh38-2020-A
#FASTQS=/data/cephfs/punim0010/projects/Rossello_PDACs_snRNAseq/fastqs/GTX
SAMPLE_FASTQS=$(cat run_sample_details.txt | tr '\n' " ")
MEM=60
CORES=10
J=3

parallel --progress --joblog cellranger_6.1.1.count_190819_A00130_0114_AHMCLHDSX_GRCh38-2020-A.log -j$J $CELLRANGER_HOME/cellranger count --id='{=1 s:/$::;s:.*/::; =}' --transcriptome=$HUMAN_INDEX --include-introns --fastqs={1} --localmem=$MEM --localcores=$CORES ::: $SAMPLE_FASTQS
