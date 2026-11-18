#!/bin/bash
# Runs spatial Stage 2 (niches, single-sample figures, neighbourhood profiling) on Spartan from the published .sif.
# Starts from either:
#   - the Stage 1 output (STAGE1_SOURCE=stage1, the default): run stage1_spartan.slurm first, with the same OUTPUT_DIR
#   - the 16 processed objects deposited on Zenodo (STAGE1_SOURCE=deposited), without running Stage 1. In the image,
#     Stage 1 reproduces these objects exactly (labels, gene-set scores and Nhood z-scores)
# Edit the paths below, then: sbatch stage2_spartan.slurm
# Log: <submit dir>/pdac_spatial2_<job id>.log. Peak memory afterwards: seff <job id>
#
# Measured in v1.0.0 from the Stage 1 output (job 35237912): 8 min, peak 9.0 GB, about 1.3 CPUs on average.
# The requests below leave room.
#
#SBATCH --job-name=pdac_spatial2
#SBATCH --account=punim1848
#SBATCH --partition=sapphire
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=32G
#SBATCH --time=02:00:00
#SBATCH --output=%x_%j.log

set -euo pipefail

SIF=/path/to/pdac-snrnaseq_1.0.0.sif
# Stage 2 writes to spatial/stage2/ under OUTPUT_DIR. With STAGE1_SOURCE=stage1, this is the OUTPUT_DIR given to
# stage1_spartan.slurm (Stage 1 wrote spatial/stage1/<sample>/<sample>.h5ad under it). With STAGE1_SOURCE=deposited,
# any folder; use a new one to keep an earlier Stage 2 output.
OUTPUT_DIR=/path/to/output
# stage1: start from the Stage 1 output in OUTPUT_DIR. deposited: start from the processed objects in DEPOSITED_DIR
STAGE1_SOURCE=stage1
# With STAGE1_SOURCE=deposited: the folder holding the 16 .h5ad files extracted from Xenium_480.tar and Xenium_314.tar
# (Zenodo), with their names as in the archives. This is xenium_saved_objects/ in the Stage 1 input folder.
DEPOSITED_DIR=
# Optional: the repository's spatial/stage2 folder, mounted over the copy in the image, to run notebooks
# changed after the image was built. Leave empty to use the image's.
CODE_DIR=
# Optional: a folder holding stage2_niche_labels_original.csv.gz (Zenodo 10.5281/zenodo.23933322) and, if you have
# it, stage2_niche_labels.csv.gz from the earlier rerun. Neither is in the image or the repository. After the run,
# each cell's niche is compared with them; leave empty to skip the comparison.
REFERENCE_DIR=
# yes: skip the notebooks and only run the comparison, on the Stage 2 output already in OUTPUT_DIR
COMPARE_ONLY=no

SAMPLES="MH065_314 MH074_314 MH096_314 MH097_314 MH099_314 MH104_314 MH106_314 MH107_314
         MH065_480 MH074_480 MH096_480 MH097_480 MH099_480 MH104_480 MH106_480 MH107_480"

# The deposited file of each sample, as named in the archives (the same names the Stage 1 notebooks read)
deposited_file() {
  case "$1" in
    MH065_314) echo MH065_0010614_region1_setseed_Oct25.h5ad ;;
    MH065_480) echo MH065_setseed_v2.h5ad ;;
    MH074_314) echo MH074_010617_region4_setseed_v2.h5ad ;;
    MH074_480) echo MH074_setseed_v2.h5ad ;;
    MH096_314) echo MH096_0010614_region4_setseed_v2.h5ad ;;
    MH096_480) echo MH096_setseed_v2.h5ad ;;
    MH097_314) echo MH097_0010614_region3_setseed_v2.h5ad ;;
    MH097_480) echo MH097_setseed_v2.h5ad ;;
    MH099_314) echo MH099_0010614_region2_setseed_v2.h5ad ;;
    MH099_480) echo MH099_setseed_v2.h5ad ;;
    MH104_314) echo MH104_0010617_region1_setseed_v2.h5ad ;;
    MH104_480) echo MH104_setseed_v2.h5ad ;;
    MH106_314) echo MH106_010617_region3_setseed_v2.h5ad ;;
    MH106_480) echo MH106_setseed_v2.h5ad ;;
    MH107_314) echo MH107_0010617_region2_setseed_v2.h5ad ;;
    MH107_480) echo MH107_setseed_v2.h5ad ;;
  esac
}

[[ -f "${SIF}" ]] || { echo "Not found: ${SIF}" >&2; exit 1; }
command -v apptainer > /dev/null || { echo "apptainer is not on PATH (module load it here?)" >&2; exit 1; }
case "${STAGE1_SOURCE}" in
  stage1)
    for s in ${SAMPLES}; do
      [[ -f "${OUTPUT_DIR}/spatial/stage1/${s}/${s}.h5ad" ]] || { echo "Stage 1 output not found: ${OUTPUT_DIR}/spatial/stage1/${s}/${s}.h5ad" >&2; exit 1; }
    done ;;
  deposited)
    [[ -n "${DEPOSITED_DIR}" ]] || { echo "STAGE1_SOURCE=deposited needs DEPOSITED_DIR" >&2; exit 1; }
    for s in ${SAMPLES}; do
      [[ -f "${DEPOSITED_DIR}/$(deposited_file "${s}")" ]] || { echo "Deposited object not found for ${s}: ${DEPOSITED_DIR}/$(deposited_file "${s}")" >&2; exit 1; }
    done ;;
  *) echo "STAGE1_SOURCE must be stage1 or deposited, not: ${STAGE1_SOURCE}" >&2; exit 1 ;;
esac
code_bind=()
if [[ -n "${CODE_DIR}" ]]; then
  [[ -f "${CODE_DIR}/config.yml" && -f "${CODE_DIR}/stage2_niches.ipynb" ]] || { echo "Not a spatial stage2 folder: ${CODE_DIR}" >&2; exit 1; }
  code_bind=(--bind "${CODE_DIR}:/pipeline/spatial/stage2:ro")
fi
if [[ -n "${CODE_DIR}" ]]; then echo "Code: ${CODE_DIR} (mounted over the image's copy)"; else echo "Code: the image's copy"; fi
if [[ -n "${REFERENCE_DIR}" ]]; then
  [[ -f "${REFERENCE_DIR}/stage2_niche_labels_original.csv.gz" ]] || { echo "Not found: ${REFERENCE_DIR}/stage2_niche_labels_original.csv.gz" >&2; exit 1; }
fi

# TMPDIR is on /output because the .sif is read-only
mkdir -p "${OUTPUT_DIR}/tmp"

deposited_bind=()
config_args=()
if [[ "${STAGE1_SOURCE}" == deposited ]]; then
  echo "Input: the deposited processed objects in ${DEPOSITED_DIR}"
  # Stage 2 reads <STAGE1_DIR>/<sample>/<sample>.h5ad: link each deposited file under that name. The links point to
  # the container path /deposited, so they only resolve inside the container.
  deposited_bind=(--bind "${DEPOSITED_DIR}:/deposited:ro")
  links="${OUTPUT_DIR}/tmp/stage1_deposited"
  rm -rf "${links}"
  for s in ${SAMPLES}; do
    mkdir -p "${links}/${s}"
    ln -s "/deposited/$(deposited_file "${s}")" "${links}/${s}/${s}.h5ad"
  done
  # Copy the stage config out of the image and point STAGE1_DIR to the links
  config="${OUTPUT_DIR}/tmp/spatial2_config_${SLURM_JOB_ID:-manual}.yml"
  apptainer exec --cleanenv --no-home ${code_bind[@]+"${code_bind[@]}"} "${SIF}" cat /pipeline/spatial/stage2/config.yml \
    | sed 's#^\(  STAGE1_DIR:\).*#\1 /output/tmp/stage1_deposited#' > "${config}"
  grep -q '^  STAGE1_DIR: /output/tmp/stage1_deposited$' "${config}" || { echo "Could not set STAGE1_DIR in ${config}" >&2; exit 1; }
  config_args=(/output/tmp/"$(basename "${config}")")

  # Check that each deposited object holds what Stage 2 reads, before starting
  apptainer exec --cleanenv --no-home \
    --bind "${OUTPUT_DIR}:/output" "${deposited_bind[@]}" \
    "${SIF}" /opt/conda/envs/spatial/bin/python -I -c '
import os, sys
import anndata as ad
links = "/output/tmp/stage1_deposited"
need = {"obs": ["cell_class_threshold"], "obsm": ["spatial"], "uns": ["cell_class_threshold_nhood_enrichment"]}
# Read only for single-sample figures: Fig. 1D (MH065_314) and Extended Data Fig. 5C (MH106_480)
extra = {"MH065_314": {"obs": ["anno"], "obsm": ["X_umap"]}, "MH106_480": {"obs": ["leiden_2"], "obsm": ["X_umap"]}}
missing = []
for s in sorted(os.listdir(links)):
    a = ad.read_h5ad(os.path.join(links, s, s + ".h5ad"), backed="r")
    want = {k: v + extra.get(s, {}).get(k, []) for k, v in need.items()}
    have = {"obs": a.obs.columns, "obsm": a.obsm.keys(), "uns": a.uns.keys()}
    gone = [f"{k}[{x}]" for k, v in want.items() for x in v if x not in have[k]]
    print(f"{s}: {a.n_obs} cells", "OK" if not gone else "missing " + ", ".join(gone))
    missing += gone
    a.file.close()
sys.exit(1 if missing else 0)
' || { echo "A deposited object lacks something Stage 2 reads: nothing was run" >&2; exit 1; }
else
  echo "Input: the Stage 1 output in ${OUTPUT_DIR}/spatial/stage1"
fi

# Stage 2 reads only the Stage 1 objects, so no input folder is mounted
if [[ "${COMPARE_ONLY}" != yes ]]; then
  apptainer run --cleanenv --no-home \
    --env TMPDIR=/output/tmp \
    --bind "${OUTPUT_DIR}:/output" \
    ${deposited_bind[@]+"${deposited_bind[@]}"} \
    ${code_bind[@]+"${code_bind[@]}"} \
    "${SIF}" spatial2 ${config_args[@]+"${config_args[@]}"}
fi

# The notebook's own check needs the original combined object, which is not deposited, so it is skipped in the
# image. Compare the niche of each cell with the original per-cell labels instead, if REFERENCE_DIR is set.
if [[ -z "${REFERENCE_DIR}" ]]; then
  echo "REFERENCE_DIR is empty: niches not compared with the original"
  exit 0
fi
[[ -f "${OUTPUT_DIR}/spatial/stage2/stage2_niche_labels.csv.gz" ]] || { echo "Stage 2 output not found: ${OUTPUT_DIR}/spatial/stage2/stage2_niche_labels.csv.gz" >&2; exit 1; }
apptainer exec --cleanenv --no-home \
  --bind "${OUTPUT_DIR}:/output" \
  --bind "${REFERENCE_DIR}:/reference:ro" \
  "${SIF}" /opt/conda/envs/spatial/bin/python -I -c '
import pandas as pd
cols = ["combined_id", "cell_class_threshold", "niche_CLR_km", "global_niche_CLR"]
new = pd.read_csv("/output/spatial/stage2/stage2_niche_labels.csv.gz", usecols=cols, index_col="combined_id")
import os
rows = [("Cells", len(new))]
for name, path in [("original", "/reference/stage2_niche_labels_original.csv.gz"),
                   ("earlier rerun", "/reference/stage2_niche_labels.csv.gz")]:
    if not os.path.exists(path):
        continue
    ref = pd.read_csv(path, usecols=cols, index_col="combined_id")
    shared = new.index.intersection(ref.index)
    rows.append((f"Cells shared with the {name}", len(shared)))
    for key, what in [("cell_class_threshold", "cell_class_threshold"), ("niche_CLR_km", "K-means cluster"), ("global_niche_CLR", "niche")]:
        same = (new.loc[shared, key].astype(str) == ref.loc[shared, key].astype(str))
        rows.append((f"Same {what} as the {name}", f"{100 * same.mean():.4f}% ({(~same).sum()} cells differ)"))
out = pd.DataFrame(rows, columns=["measure", "value"])
out.to_csv("/output/spatial/stage2/stage2_image_check.tsv", sep="\t", index=False)
print(out.to_string(index=False))
'
