#!/bin/bash
# Runs spatial Stage 3 (malignant cells and TILs, Tuft cells, TIL regions, TLS, MH097 PanIN) on Spartan from the
# published .sif. Needs the Stage 1 and Stage 2 output: run stage1_spartan.slurm and stage2_spartan.slurm first,
# with the same OUTPUT_DIR.
# Edit the paths below, then: sbatch stage3_spartan.slurm
# Log: <submit dir>/pdac_spatial3_<job id>.log. Peak memory afterwards: seff <job id>
#
# Measured in v1.0.0 (job 35240101): 4 min, peak 5.1 GB, about 1 CPU on average. The requests below leave room.
#
#SBATCH --job-name=pdac_spatial3
#SBATCH --account=punim1848
#SBATCH --partition=sapphire
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=16G
#SBATCH --time=01:00:00
#SBATCH --output=%x_%j.log

set -euo pipefail

SIF=/path/to/pdac-snrnaseq_1.0.0.sif
# The input folder given to stage1_spartan.slurm. Holds xenium_raw/<sample>/ for the 16 PDAC samples and
# xenium_raw_tnbc/TNBC_1/ to TNBC_4/ for the four TNBC sections (GEO GSE281886; see ../README.md for which GEO
# sample goes in which folder). Each folder has cell_feature_matrix.h5 and cells.csv.
INPUT_DIR=/path/to/input
# The OUTPUT_DIR given to stage1_spartan.slurm and stage2_spartan.slurm. Stage 3 writes to spatial/stage3/ under it
OUTPUT_DIR=/path/to/output
# Optional: the repository's spatial/stage3 folder, mounted over the copy in the image, to run notebooks
# changed after the image was built. Leave empty to use the image's.
CODE_DIR=

SAMPLES="MH065_314 MH074_314 MH096_314 MH097_314 MH099_314 MH104_314 MH106_314 MH107_314
         MH065_480 MH074_480 MH096_480 MH097_480 MH099_480 MH104_480 MH106_480 MH107_480"

[[ -f "${SIF}" ]] || { echo "Not found: ${SIF}" >&2; exit 1; }
command -v apptainer > /dev/null || { echo "apptainer is not on PATH (module load it here?)" >&2; exit 1; }

# Check every input before starting, so a missing file does not stop the run halfway
missing=0
need() { [[ -f "$1" ]] || { echo "Not found: $1" >&2; missing=1; }; }
for s in ${SAMPLES}; do
  need "${OUTPUT_DIR}/spatial/stage1/${s}/${s}.h5ad"
  need "${INPUT_DIR}/xenium_raw/${s}/cell_feature_matrix.h5"
  need "${INPUT_DIR}/xenium_raw/${s}/cells.csv"
done
for t in TNBC_1 TNBC_2 TNBC_3 TNBC_4; do
  need "${INPUT_DIR}/xenium_raw_tnbc/${t}/cell_feature_matrix.h5"
  need "${INPUT_DIR}/xenium_raw_tnbc/${t}/cells.csv"
done
need "${OUTPUT_DIR}/spatial/stage2/Combined_CLR_transform_global_CN_stage2.h5ad"

code_bind=()
if [[ -n "${CODE_DIR}" ]]; then
  [[ -f "${CODE_DIR}/config.yml" && -f "${CODE_DIR}/stage3_tuft.ipynb" ]] || { echo "Not a spatial stage3 folder: ${CODE_DIR}" >&2; exit 1; }
  code_bind=(--bind "${CODE_DIR}:/pipeline/spatial/stage3:ro")
fi
if [[ -n "${CODE_DIR}" ]]; then echo "Code: ${CODE_DIR} (mounted over the image's copy)"; else echo "Code: the image's copy"; fi

# stage3_tuft.ipynb needs the saved MH096_480 clusters and MH099_480 UMAP in tuft_inputs/
for f in MH096_480_anno.csv.gz MH099_480_umap.csv.gz; do
  apptainer exec --cleanenv --no-home ${code_bind[@]+"${code_bind[@]}"} "${SIF}" \
    test -f "/pipeline/spatial/stage3/tuft_inputs/${f}" \
    || { echo "Not found in the image (or CODE_DIR): spatial/stage3/tuft_inputs/${f}" >&2; missing=1; }
done
[[ "${missing}" -eq 0 ]] || { echo "Inputs missing: nothing was run" >&2; exit 1; }
echo "All inputs found"

# TMPDIR is on /output because the .sif is read-only
mkdir -p "${OUTPUT_DIR}/tmp"

# The notebooks' own checks need the original subset and region objects, which are not deposited, so they are
# skipped in the image
apptainer run --cleanenv --no-home \
  --env TMPDIR=/output/tmp \
  --bind "${INPUT_DIR}:/data/input:ro" \
  --bind "${OUTPUT_DIR}:/output" \
  ${code_bind[@]+"${code_bind[@]}"} \
  "${SIF}" spatial3
