#!/bin/bash
# Runs Stage 2 on Spartan from the published .sif.
# Edit the three paths below, then: sbatch stage2_spartan.slurm
# Log: <submit dir>/pdac_stage2_<job id>.log. Peak memory afterwards: seff <job id>
#
# --mem: 128 GB in the README is untested at full scale, and Stage 1 peaked at 258 GB
# against a documented 64 GB. Size this down from the measured peak.
# --cpus-per-task: config.yml has workers: 28, but neither Rmd uses the worker pool
# (bpp is created and never passed on), so Stage 2 doesn't need 28 CPUs.
#
#SBATCH --job-name=pdac_stage2
#SBATCH --account=punim1848
#SBATCH --partition=sapphire
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=400G
#SBATCH --time=2-00:00:00
#SBATCH --output=%x_%j.log

set -euo pipefail

SIF=/path/to/pdac-snrnaseq_0.2.2.sif
INPUT_DIR=/path/to/input    # holds qc.dbl.fltrd.sts.sce.RDS (the deposited object, not a Stage 1 rerun)
OUTPUT_DIR=/path/to/output/stage2

for f in "${SIF}" "${INPUT_DIR}/qc.dbl.fltrd.sts.sce.RDS"; do
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
