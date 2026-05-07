import re
import sys
import json
import shutil
import logging
from pathlib import Path
from datetime import datetime

VIVADO_PRJ_DIR = Path(__file__).parent / "vivado_prj"
EXPORT_DIR     = Path(__file__).parent / "export"
EXPORT_HW_DIR  = EXPORT_DIR / "hw"
EXPORT_SW_DIR  = EXPORT_DIR / "sw"

SRC_SW_DIR     = Path(__file__).parent / "sw"
SRC_NOTEBOOK   = Path(__file__).parent / "test.ipynb"

PRJ_NAME = "multi_explore"
RUNS_DIR = VIVADO_PRJ_DIR / f"{PRJ_NAME}.runs"

PARENT_IMPL_PATTERN = re.compile(r"^impl_\d+$")
CHILD_IMPL_PATTERN  = re.compile(r"^child_(\d+)_impl_\d+$")
REGION_PATTERN      = re.compile(r"hier_(\d+).*partial\.bin$")
# Matches hier_bd dirs: hier_{R}_inst_0 (config 0) or hier_{R}_{C}_inst_0 (config C)
WRAPPER_BIN_GLOB    = "*wrapper.bin"

HWH_TOP_SRC  = VIVADO_PRJ_DIR / f"{PRJ_NAME}.gen" / "sources_1" / "bd" / "system" / "hw_handoff" / "system.hwh"
DFX_CTRL_SRC = VIVADO_PRJ_DIR / f"{PRJ_NAME}.gen" / "sources_1" / "bd" / "system" / "ip" / "system_dfx_controller_0_0" / "documentation" / "configuration_information.txt"

MANIFEST_PATH = EXPORT_DIR / ".bin_extractor_manifest.json"


# ── manifest helpers ──────────────────────────────────────────────────────────

def load_manifest() -> list[str]:
    if not MANIFEST_PATH.exists():
        return []
    with MANIFEST_PATH.open() as f:
        return json.load(f)


def save_manifest(paths: list[Path]) -> None:
    MANIFEST_PATH.parent.mkdir(parents=True, exist_ok=True)
    with MANIFEST_PATH.open("w") as f:
        json.dump([str(p) for p in paths], f, indent=2)


# ── copy helper ───────────────────────────────────────────────────────────────

def safe_copy(src: Path, dst: Path, log: logging.Logger, copied: list[Path]) -> None:
    if dst in copied:
        return
    pre_existed = dst.exists()
    shutil.copy2(src, dst)
    if not pre_existed:
        copied.append(dst)
        log.info(f"COPY      {src.name}  ->  {dst}")
    else:
        log.info(f"OVERWRITE {src.name}  ->  {dst}  (pre-existing, not tracked)")


def setup_logger(hw_dir: Path) -> logging.Logger:
    hw_dir.mkdir(parents=True, exist_ok=True)
    log_path = hw_dir / "bin_extractor.log"
    logger = logging.getLogger("bin_extractor")
    logger.setLevel(logging.INFO)
    logger.handlers.clear()
    fh = logging.FileHandler(log_path)
    fh.setFormatter(logging.Formatter("%(asctime)s  %(levelname)s  %(message)s"))
    ch = logging.StreamHandler()
    ch.setFormatter(logging.Formatter("%(asctime)s  %(levelname)s  %(message)s"))
    logger.addHandler(fh)
    logger.addHandler(ch)
    return logger


# ── impl run collection ───────────────────────────────────────────────────────

def collect_impl_runs(runs_dir: Path) -> dict[int, Path]:
    """Return {config_idx -> run_path}. Parent impl (impl_N) is config 0."""
    runs: dict[int, Path] = {}
    for d in sorted(runs_dir.iterdir()):
        if not d.is_dir():
            continue
        if PARENT_IMPL_PATTERN.match(d.name):
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


def copy_hwh_files(hw_dir: Path, log: logging.Logger, copied: list[Path]) -> None:
    hw_dir.mkdir(parents=True, exist_ok=True)
    if HWH_TOP_SRC.exists():
        log.info(f"HWH source : {HWH_TOP_SRC}")
        safe_copy(HWH_TOP_SRC, hw_dir / "system.hwh", log, copied)
    else:
        log.error(f"system.hwh not found: {HWH_TOP_SRC}")


def copy_dfx_ctrl_cfg(hw_dir: Path, log: logging.Logger, copied: list[Path]) -> None:
    hw_dir.mkdir(parents=True, exist_ok=True)
    if DFX_CTRL_SRC.exists():
        log.info(f"DFX ctrl cfg source : {DFX_CTRL_SRC}")
        safe_copy(DFX_CTRL_SRC, hw_dir / "dfx_ctrl_cfg.txt", log, copied)
    else:
        log.error(f"DFX controller config not found: {DFX_CTRL_SRC}")


def copy_sw_and_notebook(log: logging.Logger, copied: list[Path]) -> None:
    EXPORT_SW_DIR.mkdir(parents=True, exist_ok=True)
    for src in sorted(SRC_SW_DIR.iterdir()):
        if src.is_file():
            safe_copy(src, EXPORT_SW_DIR / src.name, log, copied)
    if SRC_NOTEBOOK.exists():
        safe_copy(SRC_NOTEBOOK, EXPORT_DIR / SRC_NOTEBOOK.name, log, copied)
    else:
        log.warning(f"Notebook not found: {SRC_NOTEBOOK}")


def copy_partial_bitstreams(
    runs: dict[int, Path],
    hw_dir: Path,
    log: logging.Logger,
    copied: list[Path],
) -> None:
    """Copy all partial bins; output name: rm_{config_idx}_region_{region_idx}.bin"""
    hw_dir.mkdir(parents=True, exist_ok=True)
    for config_idx, run_path in sorted(runs.items()):
        partial_bins = sorted(run_path.glob("*partial.bin"))
        if not partial_bins:
            log.warning(f"No partial .bin found in {run_path.name}")
            continue
        for src in partial_bins:
            m = REGION_PATTERN.search(src.name)
            if not m:
                log.warning(f"Cannot parse region index from {src.name}, skipping")
                continue
            region_idx = int(m.group(1))
            dst_name = f"rm_{config_idx}_region_{region_idx}.bin"
            safe_copy(src, hw_dir / dst_name, log, copied)


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
    log.info(f"=== bin_extractor  {datetime.now().isoformat(timespec='seconds')} ===")
    log.info(f"Runs dir : {RUNS_DIR}")
    log.info(f"HW dir   : {EXPORT_HW_DIR}")

    if not RUNS_DIR.exists():
        log.error(f"Runs directory not found: {RUNS_DIR}")
        return

    runs = collect_impl_runs(RUNS_DIR)
    if not runs:
        log.error("No impl runs found.")
        return

    log.info(f"Found impl runs: { {idx: p.name for idx, p in sorted(runs.items())} }")

    parent_run = runs.get(0)
    if parent_run is None:
        log.error(f"No parent impl run matched pattern '{PARENT_IMPL_PATTERN.pattern}'")
        return

    copied: list[Path] = []

    copy_full_bitstream(parent_run, EXPORT_HW_DIR, log, copied)
    copy_partial_bitstreams(runs, EXPORT_HW_DIR, log, copied)
    copy_hwh_files(EXPORT_HW_DIR, log, copied)
    copy_dfx_ctrl_cfg(EXPORT_HW_DIR, log, copied)
    copy_sw_and_notebook(log, copied)

    save_manifest(copied)
    log.info(f"Manifest saved: {len(copied)} file(s) tracked")
    log.info("=== done ===")


if __name__ == "__main__":
    main()