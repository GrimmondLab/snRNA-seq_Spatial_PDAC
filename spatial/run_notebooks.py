#!/usr/bin/env python
"""Runs the notebooks of one spatial stage in order with papermill.

Usage: python ../run_notebooks.py [config.yml]   (from the stage folder; run.sh does this)

The config lists the notebooks and the values for their `parameters` cell (see stageN/config.yml).
The executed notebooks are saved under `executed_dir`; the notebooks write their own results to
the folders given in the parameters. Nothing is written to the code folder, so it can be read-only.
"""
import os
import sys
from datetime import datetime

import papermill as pm
import yaml

cfg_file = sys.argv[1] if len(sys.argv) > 1 else "config.yml"
with open(cfg_file) as fh:
    cfg = yaml.safe_load(fh)

executed_dir = cfg["executed_dir"]
os.makedirs(executed_dir, exist_ok=True)

# Caches and Jupyter runtime files go under the output folder: the home directory may be
# missing or read-only (Apptainer with --no-home)
cache_dir = os.path.join(executed_dir, ".cache")
for var, sub in [("MPLCONFIGDIR", "matplotlib"), ("NUMBA_CACHE_DIR", "numba"), ("XDG_CACHE_HOME", "xdg"),
                 ("IPYTHONDIR", "ipython"), ("JUPYTER_RUNTIME_DIR", "jupyter_runtime"),
                 ("JUPYTER_DATA_DIR", "jupyter_data")]:
    os.environ[var] = os.path.join(cache_dir, sub)
    os.makedirs(os.environ[var], exist_ok=True)

shared = cfg.get("parameters") or {}
for entry in cfg["notebooks"]:
    # An entry is a file name, or {name: ..., parameters: {...}} for values specific to that notebook
    if isinstance(entry, str):
        entry = {"name": entry}
    name = entry["name"]
    params = {**shared, **(entry.get("parameters") or {})}
    # Pass only the parameters this notebook has in its `parameters` cell
    declared = pm.inspect_notebook(name)
    unknown = set(entry.get("parameters") or {}) - set(declared)
    if unknown:
        sys.exit(f"{name} has no parameter(s): {', '.join(sorted(unknown))}")
    params = {k: v for k, v in params.items() if k in declared}

    print(f">>> {datetime.now():%Y-%m-%d %H:%M:%S} running {name}", flush=True)
    for k, v in params.items():
        print(f"      {k} = {v!r}", flush=True)
    pm.execute_notebook(name, os.path.join(executed_dir, name), parameters=params,
                        cwd=os.getcwd(), progress_bar=False)
print(">>> done", flush=True)
