import shutil
from pathlib import Path

BASE = Path(__file__).parent
EXPORT = BASE / "export"

NOTEBOOKS = [
    "test.ipynb",
    "test_dfx_mng.ipynb",
]

EXPORT.mkdir(exist_ok=True)

for nb in NOTEBOOKS:
    src = BASE / nb
    dst = EXPORT / nb
    shutil.copy2(src, dst)
    print(f"Copied {src.name} -> {dst}")
