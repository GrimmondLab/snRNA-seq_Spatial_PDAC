#!/bin/bash
# Runs Stage 3 (malignant and non-malignant analysis) on Spartan from the published .sif.
# Edit the three paths below, then: sbatch stage3_spartan.slurm
# Log: <submit dir>/pdac_stage3_<job id>.log. Peak memory afterwards: seff <job id>
#
# Measured (v1.0.0, 2026-11-17): 42 min wall-clock, peak memory 84.8 GB, about 1.1 CPUs used on average.
# --cpus-per-task: neither Rmd starts parallel workers.
# --mem and --time: the measured peak and run time with headroom.
#
#SBATCH --job-name=pdac_stage3
#SBATCH --account=punim1848
#SBATCH --partition=sapphire
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=128G
#SBATCH --time=04:00:00
#SBATCH --output=%x_%j.log

set -euo pipefail

SIF=/path/to/pdac-snrnaseq_1.0.0.sif
# INPUT_DIR holds both deposited files (Zenodo 10.5281/zenodo.23933322):
#   sts.simspec_css.sample.sct_final.RDS  final annotated object (md5 5996b8bfd886974b46dc3d39cb6c5428)
#   tuft.snv.df.csv                       KRAS mutation calls per tuft cell
INPUT_DIR=/path/to/input
OUTPUT_DIR=/path/to/output/stage3
# Optional: this stage's folder from the repository (snrnaseq/stage3_malignant_nonmalignant), mounted over the
# copy in the image, to run code changed after the image was built. Leave empty to use the image's.
CODE_DIR=
# Optional, the same for the repository's shared/ folder (label_checks.R, sample_map.csv)
SHARED_DIR=

for f in "${SIF}" "${INPUT_DIR}/sts.simspec_css.sample.sct_final.RDS" "${INPUT_DIR}/tuft.snv.df.csv"; do
  [[ -f "${f}" ]] || { echo "Not found: ${f}" >&2; exit 1; }
done
code_bind=()
if [[ -n "${CODE_DIR}" ]]; then
  [[ -f "${CODE_DIR}/run_stage3.R" ]] || { echo "Not a stage3 folder: ${CODE_DIR}" >&2; exit 1; }
  code_bind=(--bind "${CODE_DIR}:/pipeline/snrnaseq/stage3_malignant_nonmalignant:ro")
fi
if [[ -n "${SHARED_DIR}" ]]; then
  [[ -f "${SHARED_DIR}/label_checks.R" ]] || { echo "Not a shared folder: ${SHARED_DIR}" >&2; exit 1; }
  code_bind+=(--bind "${SHARED_DIR}:/pipeline/shared:ro")
fi
command -v apptainer > /dev/null || { echo "apptainer is not on PATH (module load it here?)" >&2; exit 1; }

# Show which code the container will run: the fixed files remove columns with @meta.data[[...]] <- NULL
if [[ -n "${CODE_DIR}" ]]; then echo "Code: ${CODE_DIR} (mounted over the image's copy)"; else echo "Code: the image's copy"; fi
if [[ -n "${SHARED_DIR}" ]]; then echo "Shared: ${SHARED_DIR} (mounted over the image's copy)"; else echo "Shared: the image's copy"; fi
echo "label_checks.R handles 100% agreement:" \
  "$(apptainer exec ${code_bind[@]+"${code_bind[@]}"} "${SIF}" grep -c 'if (all(same))' /pipeline/shared/label_checks.R || true)"
echo "Fixed column removals seen in STS_Malignant.Rmd:" \
  "$(apptainer exec ${code_bind[@]+"${code_bind[@]}"} "${SIF}" grep -c '@meta.data\[\[' /pipeline/snrnaseq/stage3_malignant_nonmalignant/STS_Malignant.Rmd || true)"

# TMPDIR is on /output because the .sif is read-only
mkdir -p "${OUTPUT_DIR}/tmp"

apptainer run --cleanenv --no-home \
  --env TMPDIR=/output/tmp \
  --bind "${INPUT_DIR}:/data/input:ro" \
  --bind "${OUTPUT_DIR}:/output" \
  ${code_bind[@]+"${code_bind[@]}"} \
  "${SIF}" stage3
