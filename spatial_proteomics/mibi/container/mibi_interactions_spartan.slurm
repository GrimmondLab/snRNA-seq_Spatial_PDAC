#!/bin/bash
# Builds the MIBI cell-cell interaction container (optional) and runs the Fig. 5G analysis on Spartan.
# Edit the paths below, then: sbatch mibi_interactions_spartan.slurm
# Log: <submit dir>/mibi_fig5g_<job id>.log. Peak memory afterwards: seff <job id>
#
# Built and run on Spartan (2026-11-20); the requests below were enough for the build and the run.
#
#SBATCH --job-name=mibi_fig5g
#SBATCH --account=punim1848
#SBATCH --partition=sapphire
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=04:00:00
#SBATCH --output=%x_%j.log

set -euo pipefail

# The repository's spatial_proteomics/mibi folder (holds container/ and Fig5g_heatmap_cell_cell_comm.R)
MIBI_DIR=/path/to/snRNA-seq_Spatial_PDAC/spatial_proteomics/mibi
# The container. With BUILD=yes it is built here from container/mibi_interactions.def first
SIF=/path/to/mibi_interactions.sif
BUILD=yes
# spe.rds from Zenodo 10.5281/zenodo.24360404. Leave empty to download it into OUTPUT_DIR
SPE=
# Results go to OUTPUT_DIR/fig5g (or fig5g_seed<seed>)
OUTPUT_DIR=/path/to/output
# Optional seed for the permutation test. The original analysis set none; leave empty to run it the same way
SEED=

SPE_MD5=598e75d349e9aca23fcb8a5eadbdee6b
# File link of the version that holds spe.rds (a concept DOI does not serve files)
SPE_URL=https://zenodo.org/records/24360405/files/spe.rds

command -v apptainer > /dev/null || { echo "apptainer is not on PATH (module load it here?)" >&2; exit 1; }
[[ -f "${MIBI_DIR}/container/mibi_interactions.def" ]] || { echo "Not the mibi folder: ${MIBI_DIR}" >&2; exit 1; }
mkdir -p "${OUTPUT_DIR}"

if [[ "${BUILD}" == "yes" ]]; then
  echo "Building ${SIF} ($(date))"
  # --fakeroot is needed to install packages during the build. If Spartan does not allow it, build the
  # container elsewhere (any Linux machine with Apptainer) and copy the .sif here with BUILD=no
  ( cd "${MIBI_DIR}" && apptainer build --force --fakeroot "${SIF}" container/mibi_interactions.def )
  apptainer exec --cleanenv --no-home "${SIF}" cat /opt/mibi/package_versions.tsv
fi
[[ -f "${SIF}" ]] || { echo "Not found: ${SIF}" >&2; exit 1; }

if [[ -z "${SPE}" ]]; then
  SPE="${OUTPUT_DIR}/spe.rds"
  [[ -f "${SPE}" ]] || curl -fL --retry 3 -o "${SPE}" "${SPE_URL}"
fi
echo "${SPE_MD5}  ${SPE}" | md5sum -c - || { echo "spe.rds checksum differs from the Zenodo record" >&2; exit 1; }

run_dir="${OUTPUT_DIR}/fig5g${SEED:+_seed${SEED}}"
mkdir -p "${run_dir}"
spe_dir="$(cd "$(dirname "${SPE}")" && pwd)"

echo "Running Fig. 5G analysis ($(date)), ${SLURM_CPUS_PER_TASK:-8} workers, seed: ${SEED:-none}"
apptainer run --cleanenv --no-home \
  -B "${spe_dir}":/data:ro \
  -B "${run_dir}":/output \
  "${SIF}" "/data/$(basename "${SPE}")" /output "${SLURM_CPUS_PER_TASK:-8}" ${SEED:+"${SEED}"}

cp "${MIBI_DIR}/container/../Cell_cell_interaction_sessioninfo.txt" "${run_dir}/sessionInfo_original.txt"
apptainer exec --cleanenv --no-home "${SIF}" cat /opt/mibi/package_versions.tsv > "${run_dir}/package_versions.tsv"
echo "Done ($(date)). Results: ${run_dir}"
ls -l "${run_dir}"
