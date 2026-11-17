#!/bin/bash
# Runs Stage 5 (CellChat) on Spartan from the published .sif.
# Edit the three paths below, then: sbatch stage5_spartan.slurm
# Log: <submit dir>/pdac_stage5_<job id>.log. Peak memory afterwards: seff <job id>
#
# Measured (v1.0.0, 2026-11-16): 5 h 46 min wall-clock, peak memory 65.7 GB, CPU efficiency 2.3%.
# --cpus-per-task: Cellchat.Rmd starts 20 parallel workers (future multisession) for the first
# analysis and 10 for the second, so the job asks for 20 CPUs, although most of the run is serial.
# --mem and --time: the measured peak and run time with headroom.
#
#SBATCH --job-name=pdac_stage5
#SBATCH --account=punim1848
#SBATCH --partition=sapphire
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --mem=96G
#SBATCH --time=12:00:00
#SBATCH --output=%x_%j.log

set -euo pipefail

SIF=/path/to/pdac-snrnaseq_1.0.0.sif
INPUT_DIR=/path/to/input    # holds sts.simspec_css.sample.sct_final.RDS (Zenodo, md5 5996b8bfd886974b46dc3d39cb6c5428)
OUTPUT_DIR=/path/to/output/stage5

for f in "${SIF}" "${INPUT_DIR}/sts.simspec_css.sample.sct_final.RDS"; do
  [[ -f "${f}" ]] || { echo "Not found: ${f}" >&2; exit 1; }
done
command -v apptainer > /dev/null || { echo "apptainer is not on PATH (module load it here?)" >&2; exit 1; }

# TMPDIR is on /output because the .sif is read-only
mkdir -p "${OUTPUT_DIR}/tmp"

apptainer run --cleanenv --no-home \
  --env TMPDIR=/output/tmp \
  --bind "${INPUT_DIR}:/data/input:ro" \
  --bind "${OUTPUT_DIR}:/output" \
  "${SIF}" stage5
