import re
import sys
import json
import shutil
import logging
from pathlib import Path
from datetime import datetime

BUILD_PRJ_DIR   = Path(__file__).parent / "build_prj_0"
EXPORT_DIR      = Path(__file__).parent / "export_0"
EXPORT_HW_DIR   = EXPORT_DIR / "hw"
EXPORT_DATA_DIR = EXPORT_DIR / "data"

NOTEBOOK_NAME         = "test.ipynb"
MULTI_NOTEBOOK_NAME   = "test_multi.ipynb"
INPUT_NPY_NAME        = "x_input_20000.npy"

RUNS_DIR = BUILD_PRJ_DIR / "link_prj" / "link_prj.runs"

PARENT_IMPL_NAME   = "impl_dfx"
CHILD_IMPL_PATTERN = re.compile(r"^child_(\d+)_impl_dfx$")
PARTIAL_BIN_GLOB   = "*partial.bin"
WRAPPER_BIN_GLOB   = "*wrapper.bin"

MANIFEST_PATH = EXPORT_DIR / ".extract_export_manifest.json"


# ── manifest helpers ────────────────────────────────────────────────────────

def load_manifest() -> list[str]:
    if not MANIFEST_PATH.exists():
        return []
    with MANIFEST_PATH.open() as f:
        return json.load(f)


def save_manifest(paths: list[Path]) -> None:
    MANIFEST_PATH.parent.mkdir(parents=True, exist_ok=True)
    with MANIFEST_PATH.open("w") as f:
        json.dump([str(p) for p in paths], f, indent=2)


# ── copy helpers ─────────────────────────────────────────────────────────────

def safe_copy(src: Path, dst: Path, log: logging.Logger, copied: list[Path]) -> None:
    """Copy src -> dst only if dst did not exist before this run."""
    if dst in copied:
        return
    pre_existed = dst.exists()
    shutil.copy2(src, dst)
    if not pre_existed:
        copied.append(dst)
        log.info(f"COPY  {src.name}  ->  {dst}")
    else:
        log.info(f"OVERWRITE  {src.name}  ->  {dst}  (pre-existing, not tracked)")


def setup_logger(hw_dir: Path) -> logging.Logger:
    hw_dir.mkdir(parents=True, exist_ok=True)
    log_path = hw_dir / "extract_export.log"
    logger = logging.getLogger("extract_export")
    logger.setLevel(logging.INFO)
    logger.handlers.clear()
    fh = logging.FileHandler(log_path)
    fh.setFormatter(logging.Formatter("%(asctime)s  %(levelname)s  %(message)s"))
    ch = logging.StreamHandler()
    ch.setFormatter(logging.Formatter("%(asctime)s  %(levelname)s  %(message)s"))
    logger.addHandler(fh)
    logger.addHandler(ch)
    return logger


# ── impl run collection ──────────────────────────────────────────────────────

def collect_impl_runs(runs_dir: Path) -> dict[int, Path]:
    """Return mapping: child_idx -> run_path.  impl_dfx is child 0."""
    runs = {}
    for d in sorted(runs_dir.iterdir()):
        if not d.is_dir():
            continue
        if d.name == PARENT_IMPL_NAME:
            runs[0] = d
        else:
            m = CHILD_IMPL_PATTERN.match(d.name)
            if m:
                runs[int(m.group(1))] = d
    return runs


# ── copy routines ─────────────────────────────────────────────────────────────

def copy_full_bitstream(parent_run: Path, hw_dir: Path, log: logging.Logger, copied: list[Path]) -> None:
    matches = list(parent_run.glob(WRAPPER_BIN_GLOB))
    if not matches:
        log.error(f"No wrapper .bin found in {parent_run}")
        return
    hw_dir.mkdir(parents=True, exist_ok=True)
    safe_copy(matches[0], hw_dir / "system.bin", log, copied)


def copy_partial_bitstreams(runs: dict[int, Path], hw_dir: Path, log: logging.Logger, copied: list[Path]) -> None:
    hw_dir.mkdir(parents=True, exist_ok=True)
    for child_idx, run_path in sorted(runs.items()):
        matches = list(run_path.glob(PARTIAL_BIN_GLOB))
        if not matches:
            log.warning(f"No partial .bin found in {run_path.name}")
            continue
        safe_copy(matches[0], hw_dir / f"rm_{child_idx}.bin", log, copied)


def copy_notebook_and_data(export_dir: Path, data_dir: Path, log: logging.Logger, copied: list[Path]) -> None:
    src_dir = Path(__file__).parent

    for nb_name in (NOTEBOOK_NAME, MULTI_NOTEBOOK_NAME):
        nb_src = src_dir / nb_name
        if nb_src.exists():
            export_dir.mkdir(parents=True, exist_ok=True)
            safe_copy(nb_src, export_dir / nb_name, log, copied)
        else:
            log.warning(f"Notebook not found: {nb_src}")

    npy_src = src_dir / INPUT_NPY_NAME
    if npy_src.exists():
        data_dir.mkdir(parents=True, exist_ok=True)
        safe_copy(npy_src, data_dir / INPUT_NPY_NAME, log, copied)
    else:
        log.warning(f"Input .npy not found: {npy_src}")


# ── clean ─────────────────────────────────────────────────────────────────────

def clean() -> None:
    manifest = load_manifest()
    if not manifest:
        print("Nothing to clean (no manifest found).")
        return

    for path_str in manifest:
        p = Path(path_str)
        if p.exists():
            p.unlink()
            print(f"REMOVED  {p}")
        else:
            print(f"SKIP     {p}  (already gone)")

    MANIFEST_PATH.unlink(missing_ok=True)
    print("Manifest removed. Clean complete.")


# ── main ──────────────────────────────────────────────────────────────────────

def main() -> None:
    if len(sys.argv) > 1 and sys.argv[1] == "--clean":
        clean()
        return

    log = setup_logger(EXPORT_HW_DIR)
    log.info(f"=== extract_export  {datetime.now().isoformat(timespec='seconds')} ===")
    log.info(f"Runs dir : {RUNS_DIR}")
    log.info(f"HW dir   : {EXPORT_HW_DIR}")

    if not RUNS_DIR.exists():
        log.error(f"Runs directory not found: {RUNS_DIR}")
        return

    runs = collect_impl_runs(RUNS_DIR)
    if not runs:
        log.error("No impl_dfx runs found.")
        return

    log.info(f"Found impl runs: { {idx: p.name for idx, p in sorted(runs.items())} }")

    parent_run = runs.get(0)
    if parent_run is None:
        log.error(f"Parent run '{PARENT_IMPL_NAME}' not found.")
        return

    copied: list[Path] = []

    copy_full_bitstream(parent_run, EXPORT_HW_DIR, log, copied)
    copy_partial_bitstreams(runs, EXPORT_HW_DIR, log, copied)
    copy_notebook_and_data(EXPORT_DIR, EXPORT_DATA_DIR, log, copied)

    save_manifest(copied)
    log.info(f"Manifest saved: {len(copied)} file(s) tracked")
    log.info("=== done ===")


if __name__ == "__main__":
    main()
