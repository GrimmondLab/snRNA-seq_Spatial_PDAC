#!/bin/bash
# Runs Stage 4 (reclustering and final annotation) on Spartan from the published .sif.
# Edit the three paths below, then: sbatch stage4_spartan.slurm
# Log: <submit dir>/pdac_stage4_<job id>.log. Peak memory afterwards: seff <job id>
#
# Measured (v1.0.0, 2026-11-17): 36 min wall-clock, peak memory 42.7 GB, about 1 CPU used on average.
# --cpus-per-task: none of the four Rmds starts parallel workers.
# --mem and --time: the measured peak and run time with headroom.
#
#SBATCH --job-name=pdac_stage4
#SBATCH --account=punim1848
#SBATCH --partition=sapphire
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=64G
#SBATCH --time=04:00:00
#SBATCH --output=%x_%j.log

set -euo pipefail

SIF=/path/to/pdac-snrnaseq_1.0.0.sif
INPUT_DIR=/path/to/input    # holds sts.simspec_css.sample.sct_final.RDS (Zenodo, md5 5996b8bfd886974b46dc3d39cb6c5428)
OUTPUT_DIR=/path/to/output/stage4
# Optional: this stage's folder from the repository (snrnaseq/stage4_reclustering), mounted over the
# copy in the image, to run code changed after the image was built. Leave empty to use the image's.
CODE_DIR=
# Optional, the same for the repository's shared/ folder (label_checks.R, sample_map.csv)
SHARED_DIR=

for f in "${SIF}" "${INPUT_DIR}/sts.simspec_css.sample.sct_final.RDS"; do
  [[ -f "${f}" ]] || { echo "Not found: ${f}" >&2; exit 1; }
done
code_bind=()
if [[ -n "${CODE_DIR}" ]]; then
  [[ -f "${CODE_DIR}/run_stage4.R" ]] || { echo "Not a stage4 folder: ${CODE_DIR}" >&2; exit 1; }
  code_bind=(--bind "${CODE_DIR}:/pipeline/snrnaseq/stage4_reclustering:ro")
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
echo "Fixed column removals seen in STS_Lymphoid_TNK.Rmd:" \
  "$(apptainer exec ${code_bind[@]+"${code_bind[@]}"} "${SIF}" grep -c '@meta.data\[\[' /pipeline/snrnaseq/stage4_reclustering/STS_Lymphoid_TNK.Rmd || true)"

# TMPDIR is on /output because the .sif is read-only
mkdir -p "${OUTPUT_DIR}/tmp"

apptainer run --cleanenv --no-home \
  --env TMPDIR=/output/tmp \
  --bind "${INPUT_DIR}:/data/input:ro" \
  --bind "${OUTPUT_DIR}:/output" \
  ${code_bind[@]+"${code_bind[@]}"} \
  "${SIF}" stage4
