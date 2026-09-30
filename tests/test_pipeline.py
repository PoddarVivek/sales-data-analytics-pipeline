import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

import pytest

import pipeline


@pytest.fixture(scope="module")
def con():
    return pipeline.build_database()


@pytest.fixture(scope="module")
def results(con):
    return pipeline.run_all(con)


def test_cleaning_keeps_rows_accounted_for(con):
    raw = con.execute("SELECT COUNT(*) FROM retail_sales_raw").fetchone()[0]
    kept = con.execute("SELECT COUNT(*) FROM retail_sales").fetchone()[0]
    dropped = dict(con.execute("SELECT * FROM data_quality_log").fetchall())[
        "rows dropped (missing quantity, price, cogs or total)"]
    assert raw == kept + dropped


def test_no_nulls_in_money_columns_after_cleaning(con):
    nulls = con.execute(
        "SELECT COUNT(*) FROM retail_sales WHERE quantity IS NULL OR price_per_unit IS NULL "
        "OR cogs IS NULL OR total_sale IS NULL").fetchone()[0]
    assert nulls == 0


def test_revenue_identity_holds(con):
    bad = con.execute(
        "SELECT COUNT(*) FROM retail_sales WHERE ABS(total_sale - quantity * price_per_unit) > 0.01").fetchone()[0]
    assert bad == 0


def test_category_totals_reconcile_with_grand_total(con, results):
    grand = con.execute("SELECT SUM(total_sale) FROM retail_sales").fetchone()[0]
    assert results["q03_revenue_profit_by_category"]["revenue"].sum() == pytest.approx(grand)


def test_monthly_totals_reconcile_with_grand_total(con, results):
    grand = con.execute("SELECT SUM(total_sale) FROM retail_sales").fetchone()[0]
    assert results["q07_monthly_revenue"]["revenue"].sum() == pytest.approx(grand)


def test_shifts_cover_every_order(con, results):
    kept = con.execute("SELECT COUNT(*) FROM retail_sales").fetchone()[0]
    assert results["q11_orders_by_shift"]["orders"].sum() == kept


def test_every_query_returns_rows(results):
    for name, df in results.items():
        assert len(df) > 0, name
