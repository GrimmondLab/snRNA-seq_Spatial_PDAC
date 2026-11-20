# Spatial proteomics: MIBI and OPAL

The MIBI and OPAL analyses were done in collaboration with a team at WEHI, using the team's spatial proteomics tools:

- MIBI: QuPath 0.3.2 with the [MIBI extension](https://github.com/WEHI-SODA-Hub/MIBI_extension) (Mesmer segmentation and measurements), then [`sp_celltype_train`](https://github.com/WEHI-SODA-Hub/sp_celltype_train) and [`sp_celltype_apply`](https://github.com/WEHI-SODA-Hub/sp_celltype_apply) (cell typing).
- OPAL Panel 2: [`sp_segment`](https://github.com/WEHI-SODA-Hub/sp_segment) (Cellpose-SAM segmentation and measurements), then [`sp-classify`](https://github.com/mikemcka/qupath-extension-sp-classify) marker classifiers, run by a Nextflow pipeline.

Neither analysis is in the project image or `run.sh`. The images, settings, containers and expected results are on Zenodo, [10.5281/zenodo.24356840](https://doi.org/10.5281/zenodo.24356840) ("MIBI and OPAL PDAC analysis, containers and data"); the record's README lists every file. The MIBI cell–cell interaction analysis (Fig. 5G) also has its own container, defined in [`mibi/container/`](mibi/container/README.md) (Zenodo *DOI TBD*).

| Folder | Data | Manuscript figures |
|---|---|---|
| [`mibi/`](mibi/README.md) | MIBI, 8 patients, 29 FOVs after QC | Fig. 1F, 2E–G, 5G; Extended Data Fig. 2E, 6F |
| [`opal/`](opal/README.md) | OPAL multiplex immunofluorescence, 2 panels | Fig. 3H, 6H; Extended Data Fig. 9J |
