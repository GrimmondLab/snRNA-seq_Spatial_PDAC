#!/bin/bash
# Runs Stage 2 on Spartan from the published .sif.
# Edit the three paths below, then: sbatch stage2_spartan.slurm
# Log: <submit dir>/pdac_stage2_<job id>.log. Peak memory afterwards: seff <job id>
#
# Measured (v1.0.0, 2026-11-17): 2 h wall-clock, peak memory 108 GB, about 1.4 CPUs used on average.
# --mem and --time: the measured peak and run time with headroom.
# --cpus-per-task: config.yml has workers: 28, but neither Rmd uses the worker pool
# (bpp is created and never passed on), so Stage 2 doesn't need 28 CPUs.
#
#SBATCH --job-name=pdac_stage2
#SBATCH --account=punim1848
#SBATCH --partition=sapphire
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=160G
#SBATCH --time=08:00:00
#SBATCH --output=%x_%j.log

set -euo pipefail

SIF=/path/to/pdac-snrnaseq_1.0.0.sif
# INPUT_DIR holds both deposited objects (Zenodo 10.5281/zenodo.23933322):
#   qc.dbl.fltrd.sts.sce.RDS              post-QC object, the input (not a Stage 1 rerun)
#   sts.simspec_css.sample.sct_final.RDS  final object, source of cell_class and simspec_cell_class
INPUT_DIR=/path/to/input
OUTPUT_DIR=/path/to/output/stage2

for f in "${SIF}" "${INPUT_DIR}/qc.dbl.fltrd.sts.sce.RDS" "${INPUT_DIR}/sts.simspec_css.sample.sct_final.RDS"; do
  [[ -f "${f}" ]] || { echo "Not found: ${f}" >&2; exit 1; }
done
command -v apptainer > /dev/null || { echo "apptainer is not on PATH (module load it here?)" >&2; exit 1; }

# TMPDIR is on /output because the .sif is read-only
mkdir -p "${OUTPUT_DIR}/tmp"

apptainer run --cleanenv --no-home \
  --env TMPDIR=/output/tmp \
  --bind "${INPUT_DIR}:/data/input:ro" \
  --bind "${OUTPUT_DIR}:/output" \
  "${SIF}" stage2
