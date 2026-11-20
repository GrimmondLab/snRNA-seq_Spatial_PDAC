#!/bin/bash
# Runs spatial Stage 1 on Spartan from the published .sif (v1.0.0).
# Edit the three paths and SAMPLES below, then: sbatch stage1_spartan.slurm
# Log: <submit dir>/pdac_spatial1_<job id>.log. Peak memory afterwards: seff <job id>
#
# By default (SAMPLES empty) it runs all 16 samples, then the robustness summary.
# Measured (v1.0.0, all 16 samples + summary, 2026-11-17): 46 min wall-clock, peak memory 8.4 GB,
# about 1.1 CPUs used on average. The samples run one after another; the log has a timestamp as each
# notebook starts. --mem and --time: the measured peak and run time with headroom.
#
#SBATCH --job-name=pdac_spatial1
#SBATCH --account=punim1848
#SBATCH --partition=sapphire
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=32G
#SBATCH --time=04:00:00
#SBATCH --output=%x_%j.log

set -euo pipefail

SIF=/path/to/pdac-snrnaseq_1.0.0.sif
# Holds xenium_raw/<sample>/ (cell_feature_matrix.h5 and cells.csv) and xenium_saved_objects/
# (the 16 .h5ad files from Xenium_480.tar and Xenium_314.tar); see README.md, "Running the spatial stages"
INPUT_DIR=/path/to/input
# Shared by all spatial stages: Stage 1 writes to spatial/stage1/ under it, and Stages 2 and 3 read from there
OUTPUT_DIR=/path/to/output
# Optional: the repository's spatial/stage1 folder, mounted over the copy in the image, to run notebooks
# changed after the image was built. Leave empty to use the image's.
CODE_DIR=

# Samples to run, e.g. SAMPLES="MH065_314" or SAMPLES="MH065_314 MH107_480".
# Empty: all 16 samples, then the robustness summary (which needs all 16, so it is left out otherwise).
SAMPLES=""

[[ -f "${SIF}" ]] || { echo "Not found: ${SIF}" >&2; exit 1; }
[[ -d "${INPUT_DIR}/xenium_saved_objects" ]] || { echo "Not found: ${INPUT_DIR}/xenium_saved_objects" >&2; exit 1; }
[[ -d "${INPUT_DIR}/xenium_raw" ]] || { echo "Not found: ${INPUT_DIR}/xenium_raw" >&2; exit 1; }
command -v apptainer > /dev/null || { echo "apptainer is not on PATH (module load it here?)" >&2; exit 1; }
code_bind=()
if [[ -n "${CODE_DIR}" ]]; then
  [[ -f "${CODE_DIR}/config.yml" && -f "${CODE_DIR}/MH074_314_stage1.ipynb" ]] || { echo "Not a spatial stage1 folder: ${CODE_DIR}" >&2; exit 1; }
  code_bind=(--bind "${CODE_DIR}:/pipeline/spatial/stage1:ro")
fi
# Show which notebooks the container will run: the fixed ones read the Leiden clusters from the saved object
if [[ -n "${CODE_DIR}" ]]; then echo "Code: ${CODE_DIR} (mounted over the image's copy)"; else echo "Code: the image's copy"; fi
echo "Notebooks reading the saved Leiden clusters (16 when fixed):" \
  "$(apptainer exec ${code_bind[@]+"${code_bind[@]}"} "${SIF}" sh -c 'grep -l "saved.obs\[LEIDEN_KEY\]" /pipeline/spatial/stage1/MH*_stage1.ipynb | wc -l' || true)"

# TMPDIR is on /output because the .sif is read-only
mkdir -p "${OUTPUT_DIR}/tmp"

config_args=()
if [[ -n "${SAMPLES}" ]]; then
  # Copy the stage config out of the image and keep only the chosen samples in its `notebooks` list
  config="${OUTPUT_DIR}/tmp/spatial1_config_${SLURM_JOB_ID:-manual}.yml"
  keep="$(printf '%s_stage1.ipynb|' ${SAMPLES})"
  apptainer exec --cleanenv --no-home ${code_bind[@]+"${code_bind[@]}"} "${SIF}" cat /pipeline/spatial/stage1/config.yml \
    | grep -v -E '^  - stage1_robustness_summary\.ipynb' \
    | awk -v keep="^  - (${keep%|})\$" '!/^  - .*_stage1\.ipynb$/ || $0 ~ keep' > "${config}"
  n="$(grep -c '_stage1\.ipynb$' "${config}" || true)"
  [[ "${n}" -eq "$(wc -w <<< "${SAMPLES}")" ]] || { echo "Unknown sample in SAMPLES: ${SAMPLES}" >&2; exit 1; }
  config_args=(/output/tmp/"$(basename "${config}")")
  samples="${SAMPLES}"
else
  samples="$(ls "${INPUT_DIR}/xenium_raw")"
fi

for s in ${samples}; do
  for f in cell_feature_matrix.h5 cells.csv; do
    [[ -f "${INPUT_DIR}/xenium_raw/${s}/${f}" ]] || { echo "Not found: ${INPUT_DIR}/xenium_raw/${s}/${f}" >&2; exit 1; }
  done
done

apptainer run --cleanenv --no-home \
  --env TMPDIR=/output/tmp \
  --bind "${INPUT_DIR}:/data/input:ro" \
  --bind "${OUTPUT_DIR}:/output" \
  ${code_bind[@]+"${code_bind[@]}"} \
  "${SIF}" spatial1 ${config_args[@]+"${config_args[@]}"}
