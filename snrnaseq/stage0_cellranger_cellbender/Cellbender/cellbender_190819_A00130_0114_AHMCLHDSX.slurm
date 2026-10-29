#!/bin/bash
#SBATCH -p physical
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=48
#SBATCH --mem=96000
#SBATCH --time=5-00:00:00
#SBATCH -o slurm.%N.%j.out # STDOUT
#SBATCH -e slurm.%N.%j.err # STDERR

source /home/${USER}/.bashrc
source activate CellBender

PROJECT_HOME=~/projects/PDAC_Atlas_GTX
RAW_FEATURE_DATA=$PROJECT_HOME/data/counts.cellranger.6.1.1/190819_A00130_0114_AHMCLHDSX
CELLBENDER_DATA=$PROJECT_HOME/data/cellBender/samples/190819_A00130_0114_AHMCLHDSX

for i in $(cat $RAW_FEATURE_DATA/samples.txt);
do
	SAMPLE=$(grep $i $CELLBENDER_DATA/sample_cellbender_args.csv | awk -F"," '{print $1}')
	EXPECTED_CELLS=$(grep $i $CELLBENDER_DATA/sample_cellbender_args.csv | awk -F"," '{print $2}')
	TOTAL_DROPS=$(grep $i $CELLBENDER_DATA/sample_cellbender_args.csv | awk -F"," '{print $3}')
	echo $SAMPLE
	echo "$SAMPLE expected no. of cells $EXPECTED_CELLS"
	echo "$SAMPLE total no. of droplets $TOTAL_DROPS"

if [ ! -f $CELLBENDER_DATA/$i/$i\_cellbender.pdf ]
then
echo "Running sample $i"
echo "mkdir $CELLBENDER_DATA/$i"
mkdir $CELLBENDER_DATA/$i
echo "cellbender remove-background --input $RAW_FEATURE_DATA/$i/outs/raw_feature_bc_matrix --output $CELLBENDER_DATA/$i/$i\_cellbender.h5 --expected-cells $EXPECTED_CELLS --total-droplets-included $TOTAL_DROPS"
cellbender remove-background --input $RAW_FEATURE_DATA/$i/outs/raw_feature_bc_matrix --output $CELLBENDER_DATA/$i/$i\_cellbender.h5 --expected-cells $EXPECTED_CELLS --total-droplets-included $TOTAL_DROPS
else
echo "Running Cellbender on sample $i finished"
fi	
done

