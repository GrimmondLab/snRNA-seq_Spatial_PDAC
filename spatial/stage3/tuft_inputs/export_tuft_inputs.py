"""Save the two values stage3_tuft.ipynb needs from the original Tuft region objects.

- MH096_480_anno.csv.gz: the cluster-based annotation (anno) of each cell, used to relabel
  Endocrine-scored cells outside the Endocrine cluster. The region's Leiden clustering doesn't
  reproduce exactly, so the saved clusters are used.
- MH099_480_umap.csv.gz: the UMAP coordinates of each cell, so Extended Data Fig. 4B keeps
  its published layout.

Run once, in the xenium.squidpy environment, where the original objects are:

    python export_tuft_inputs.py /path/to/original_regions

The two files are written next to this script.
"""
import os
import sys

import numpy as np
import pandas as pd
import scanpy as sc

archived_dir = sys.argv[1]
out_dir = os.path.dirname(os.path.abspath(__file__))

mh096 = sc.read_h5ad(os.path.join(archived_dir, "MH096_ADM_cropped_setseed.h5ad"), backed="r")
anno = mh096.obs[["anno"]].astype(str)
anno.index.name = "cell_id"
anno.to_csv(os.path.join(out_dir, "MH096_480_anno.csv.gz"))
mh096.file.close()

mh099 = sc.read_h5ad(os.path.join(archived_dir, "_MH099_ADM_cropped_highmag_ss_Dec25.h5ad"), backed="r")
umap = np.asarray(mh099.obsm["X_umap"])
pd.DataFrame({"UMAP_1": umap[:, 0], "UMAP_2": umap[:, 1]}, index=pd.Index(mh099.obs_names, name="cell_id")).to_csv(
    os.path.join(out_dir, "MH099_480_umap.csv.gz"), float_format="%.17g"
)
mh099.file.close()
print("Wrote MH096_480_anno.csv.gz and MH099_480_umap.csv.gz to", out_dir)
