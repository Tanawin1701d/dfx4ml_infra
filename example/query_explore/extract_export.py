import re
import shutil
import logging
from pathlib import Path
from datetime import datetime

BUILD_PRJ_DIR = Path(__file__).parent / "build_prj_0"
EXPORT_HW_DIR = Path(__file__).parent / "export_0" / "hw"

RUNS_DIR = BUILD_PRJ_DIR / "link_prj" / "link_prj.runs"

PARENT_IMPL_NAME = "impl_dfx"
CHILD_IMPL_PATTERN = re.compile(r"^child_(\d+)_impl_dfx$")
PARTIAL_BIN_GLOB = "*partial.bin"
WRAPPER_BIN_GLOB = "*wrapper.bin"


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


def copy_full_bitstream(parent_run: Path, hw_dir: Path, log: logging.Logger) -> None:
    matches = list(parent_run.glob(WRAPPER_BIN_GLOB))
    if not matches:
        log.error(f"No wrapper .bin found in {parent_run}")
        return
    src = matches[0]
    dst = hw_dir / "system.bin"
    shutil.copy2(src, dst)
    log.info(f"FULL   {src.name}  ->  {dst}")


def copy_partial_bitstreams(runs: dict[int, Path], hw_dir: Path, log: logging.Logger) -> None:
    for child_idx, run_path in sorted(runs.items()):
        matches = list(run_path.glob(PARTIAL_BIN_GLOB))
        if not matches:
            log.warning(f"No partial .bin found in {run_path.name}")
            continue
        src = matches[0]
        dst = hw_dir / f"rm_{child_idx}.bin"
        shutil.copy2(src, dst)
        log.info(f"PARTIAL [{run_path.name}]  {src.name}  ->  {dst.name}")


def main() -> None:
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

    copy_full_bitstream(parent_run, EXPORT_HW_DIR, log)
    copy_partial_bitstreams(runs, EXPORT_HW_DIR, log)

    log.info("=== done ===")


if __name__ == "__main__":
    main()
