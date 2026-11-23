# Spatial proteomics: MIBI and OPAL

The MIBI and OPAL analyses were done in collaboration with a team at WEHI, using the team's spatial proteomics tools:

- MIBI: QuPath 0.3.2 with the [MIBI extension](https://github.com/WEHI-SODA-Hub/MIBI_extension) (Mesmer segmentation and measurements), then [`sp_celltype_preprocess`](https://github.com/WEHI-SODA-Hub/sp_celltype_preprocess), [`sp_celltype_train`](https://github.com/WEHI-SODA-Hub/sp_celltype_train) and [`sp_celltype_apply`](https://github.com/WEHI-SODA-Hub/sp_celltype_apply) (cell typing). Versions and settings: [`mibi/README.md`](mibi/README.md#segmentation-and-cell-typing-steps-0a0b).
- OPAL Panel 1: Phenochart, inForm and QuPath, largely by hand (see [`opal/README.md`](opal/README.md#panel-1-workflow)).
- OPAL Panel 2: stitching and tiling containers, [`sp_segment`](https://github.com/WEHI-SODA-Hub/sp_segment) (Cellpose-SAM segmentation and measurements), then [`sp-classify`](https://github.com/mikemcka/qupath-extension-sp-classify) marker classifiers, run by a Nextflow pipeline (see [`opal/README.md`](opal/README.md#panel-2-workflow)).

Neither analysis is in the project image or `run.sh`. The images, settings, containers and expected results are on Zenodo, [10.5281/zenodo.24356840](https://doi.org/10.5281/zenodo.24356840) ("MIBI and OPAL PDAC analysis, containers and data"); the record's README lists every file. The MIBI cell–cell interaction analysis (Fig. 5G) also has its own container, defined in [`mibi/container/`](mibi/container/README.md) (Zenodo [10.5281/zenodo.24394013](https://doi.org/10.5281/zenodo.24394013)).

| Folder | Data | Manuscript figures |
|---|---|---|
| [`mibi/`](mibi/README.md) | MIBI, 8 patients, 29 FOVs after QC | Fig. 1F, 2E–G, 5G; Extended Data Fig. 2E, 6F |
| [`opal/`](opal/README.md) | OPAL multiplex immunofluorescence, 2 panels | Fig. 3H, 6H; Extended Data Fig. 9J |
