"""Run the retail sales pipeline: load, clean, analyse, export.

    python pipeline.py

Reads data/retail_sales.csv, runs the SQL in sql/ on an in-memory DuckDB database,
writes each query result to outputs/results/*.csv, draws charts to outputs/charts/
and writes outputs/insights.md.
"""
import re
from pathlib import Path

import duckdb

ROOT = Path(__file__).parent
OUT = ROOT / "outputs"


def build_database(root=ROOT):
    """Return a DuckDB connection with retail_sales (clean) and data_quality_log tables."""
    con = duckdb.connect()
    csv_path = (root / "data" / "retail_sales.csv").as_posix()
    for script in ("01_schema.sql", "02_cleaning.sql"):
        sql = (root / "sql" / script).read_text(encoding="utf-8")
        con.execute(sql.replace("data/retail_sales.csv", csv_path))
    return con


def load_queries(root=ROOT):
    """Split 03_analysis.sql into {name: sql} using the '-- name:' markers."""
    text = (root / "sql" / "03_analysis.sql").read_text(encoding="utf-8")
    parts = re.split(r"^-- name: (\w+)\s*$", text, flags=re.M)
    return {parts[i]: parts[i + 1].strip().rstrip(";") for i in range(1, len(parts), 2)}


def run_all(con, root=ROOT):
    return {name: con.execute(sql).df() for name, sql in load_queries(root).items()}


def main():
    import report

    (OUT / "results").mkdir(parents=True, exist_ok=True)
    con = build_database()
    results = run_all(con)
    quality = con.execute("SELECT * FROM data_quality_log").df()
    for name, df in {**results, "data_quality_log": quality}.items():
        df.to_csv(OUT / "results" / f"{name}.csv", index=False)

    report.charts(results, OUT / "charts")
    report.insights(results, quality, OUT / "insights.md")
    print(quality.to_string(index=False))
    print(f"\n{len(results)} queries exported to {OUT / 'results'}")


if __name__ == "__main__":
    main()
