#!/usr/bin/env bash
# Runs one analysis stage in its own conda env.
# Usage: run.sh <stage> [config.yml]
#   stage: stage1 | stage2 | stage3 | stage4 | stage5 | infercnv
#   config defaults to the stage's config.yml (container paths: /data/..., /output)
set -euo pipefail

PIPELINE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENVS_DIR="${MAMBA_ROOT_PREFIX:-/opt/conda}/envs"

# No arguments: print usage and exit 0 (the CI smoke test relies on this); bad stage: exit 1
usage() { sed -n '2,5p' "$0" | sed 's/^# \{0,1\}//'; exit "${1:-0}"; }
[[ $# -ge 1 ]] || usage
stage="$1"

case "$stage" in
  stage1) env=snrnaseq; dir=snrnaseq/stage1_doublet_qc;     script=run_stage1.R ;;
  stage2) env=snrnaseq; dir=snrnaseq/stage2_seurat_simspec; script=run_stage2.R ;;
  stage3) env=downstream; dir=snrnaseq/stage3_malignant_nonmalignant; script=run_stage3.R ;;
  stage4) env=downstream; dir=snrnaseq/stage4_reclustering; script=run_stage4.R ;;
  stage5) env=cellchat; dir=snrnaseq/stage5_cellchat; script=run_stage5.R ;;
  infercnv) env=infercnv; dir=snrnaseq/supplementary_infercnv; script=run_infercnv.R ;;
  *) echo "Unknown stage: $stage" >&2; usage 1 >&2 ;;
esac

# A config that exists from the current directory (e.g. a mounted file) is made absolute;
# otherwise it is looked up in the stage folder (e.g. config_local.yml)
config="${2:-config.yml}"
if [[ -f "$config" ]]; then
  config="$(cd "$(dirname "$config")" && pwd)/$(basename "$config")"
fi

# Put the env first on PATH instead of `micromamba activate`, so this also works
# read-only under Apptainer/Singularity
export PATH="$ENVS_DIR/$env/bin:$PATH"
cd "$PIPELINE_DIR/$dir"
echo ">>> $stage: env=$env dir=$dir config=$config"
exec Rscript "$script" "$config"
