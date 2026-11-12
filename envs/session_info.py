"""Usage: python session_info.py <out_file> <module> [<module> ...]

Imports the modules the spatial notebooks use and saves their versions as a record of the image
(the Python counterpart of session_info.R). Fails if a module cannot be imported.
"""
import importlib
import platform
import sys
from importlib import metadata

out_file, modules = sys.argv[1], sys.argv[2:]
for m in modules:
    importlib.import_module(m)

lines = ["Environment recorded while building the Docker image",
         f"Python {platform.python_version()} ({platform.platform()})",
         "", "Imported: " + " ".join(modules), "", "Installed packages:"]
lines += sorted({f"{d.metadata['Name']}=={d.version}" for d in metadata.distributions()}, key=str.lower)
with open(out_file, "w") as fh:
    fh.write("\n".join(lines) + "\n")
