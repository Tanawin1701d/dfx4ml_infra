"""
Reads ./result (hex profiling data) and inserts one row per testcase into the
query_explore table of the DuckDB experiment database.

Unknown fields (board, freq, bin_file_size, bin_file_size_2, input_dim,
inter_dim, output_dim) are copied from the existing single-query reference row.
is_result_checked is always set to False for inserted rows.

result file format (tab/space separated, values in hex):
    size    rm_0 recon    rm_0 exec    rm_1 recon    rm_1 exec
    100     0x167a9b      0x21719      0x162430       0x1a16d
    ...

Usage:
    python collect_result.py [--result PATH] [--db PATH] [--dry-run]
"""

import argparse
import sys
from pathlib import Path

import duckdb

RESULT_FILE_DEFAULT = Path(__file__).parent / "result"
DB_FILE_DEFAULT     = Path(__file__).parent.parents[2] / "experiment" / "dfx4ml_result"

REFERENCE_QUERY_SIZE = 17500   # the existing single-query row to copy unknowns from


def parse_result_file(path: Path) -> list[dict]:
    rows = []
    with path.open() as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("size"):
                continue
            parts = line.split()
            if len(parts) != 5:
                print(f"WARNING: skipping malformed line: {line!r}", file=sys.stderr)
                continue
            rows.append({
                "query_size":   int(parts[0]),
                "recon_time_1": int(parts[1], 16),
                "exec_time_1":  int(parts[2], 16),
                "recon_time_2": int(parts[3], 16),
                "exec_time_2":  int(parts[4], 16),
            })
    return rows


def fetch_reference_row(conn: duckdb.DuckDBPyConnection) -> dict:
    row = conn.execute(
        "SELECT board, bin_file_size, freq, input_dim, inter_dim, output_dim, bin_file_size_2 "
        "FROM query_explore WHERE query_size = ? LIMIT 1",
        [REFERENCE_QUERY_SIZE],
    ).fetchone()
    if row is None:
        raise RuntimeError(
            f"No reference row found for query_size={REFERENCE_QUERY_SIZE} in query_explore. "
            "Update REFERENCE_QUERY_SIZE in this script."
        )
    return {
        "board":          row[0],
        "bin_file_size":  row[1],
        "freq":           row[2],
        "input_dim":      row[3],
        "inter_dim":      row[4],
        "output_dim":     row[5],
        "bin_file_size_2": row[6],
    }


def insert_rows(conn: duckdb.DuckDBPyConnection, parsed: list[dict], ref: dict, dry_run: bool) -> None:
    sql = """
        INSERT INTO query_explore (
            board, recon_time_1, recon_time_2, exec_time_1, exec_time_2,
            bin_file_size, freq, query_size, input_dim, inter_dim, output_dim,
            is_result_checked, bin_file_size_2
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """
    for r in parsed:
        params = (
            ref["board"],
            r["recon_time_1"],
            r["recon_time_2"],
            r["exec_time_1"],
            r["exec_time_2"],
            ref["bin_file_size"],
            ref["freq"],
            r["query_size"],
            ref["input_dim"],
            ref["inter_dim"],
            ref["output_dim"],
            False,
            ref["bin_file_size_2"],
        )
        if dry_run:
            print(f"[DRY-RUN] INSERT query_size={r['query_size']}  "
                  f"recon1={r['recon_time_1']}  exec1={r['exec_time_1']}  "
                  f"recon2={r['recon_time_2']}  exec2={r['exec_time_2']}")
        else:
            conn.execute(sql, params)
            print(f"  inserted query_size={r['query_size']:6d}  "
                  f"recon1={r['recon_time_1']:10d}  exec1={r['exec_time_1']:10d}  "
                  f"recon2={r['recon_time_2']:10d}  exec2={r['exec_time_2']:10d}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--result", type=Path, default=RESULT_FILE_DEFAULT,
                        help=f"Path to result file (default: {RESULT_FILE_DEFAULT})")
    parser.add_argument("--db", type=Path, default=DB_FILE_DEFAULT,
                        help=f"Path to DuckDB experiment database (default: {DB_FILE_DEFAULT})")
    parser.add_argument("--dry-run", action="store_true",
                        help="Print what would be inserted without writing to the database")
    args = parser.parse_args()

    if not args.result.exists():
        sys.exit(f"ERROR: result file not found: {args.result}")
    if not args.db.exists():
        sys.exit(f"ERROR: database not found: {args.db}")

    print(f"Result file : {args.result}")
    print(f"Database    : {args.db}")

    parsed = parse_result_file(args.result)
    print(f"Parsed {len(parsed)} testcase(s) from result file")

    conn = duckdb.connect(str(args.db), read_only=args.dry_run)
    try:
        ref = fetch_reference_row(conn)
        print(f"Reference row (query_size={REFERENCE_QUERY_SIZE}): {ref}")
        print()
        insert_rows(conn, parsed, ref, dry_run=args.dry_run)
        if not args.dry_run:
            print(f"\nDone — {len(parsed)} row(s) inserted into query_explore.")
        else:
            print(f"\n[DRY-RUN] No changes written.")
    finally:
        conn.close()


if __name__ == "__main__":
    main()
