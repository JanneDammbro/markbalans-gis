"""Markbalans GIS - Generate impact report

Purpose:
    Create a simple CSV report from gis_platform.property_impact_summary
    for a selected project version.

Usage:
    python generate_impact_report.py <project_version_id> <output_csv>
"""

from __future__ import annotations

import csv
import os
import sys
from typing import Iterable

import psycopg2
from psycopg2.extras import RealDictCursor

DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://postgres:postgres@localhost:5432/markbalans",
)


def get_connection():
    return psycopg2.connect(DATABASE_URL)


def fetch_report_rows(project_version_id: str) -> Iterable[dict]:
    query = """
        SELECT
            p.property_designation,
            p.municipality_name,
            s.total_overlap_area_m2,
            s.max_overlap_pct,
            s.min_distance_to_alignment_m,
            s.min_distance_to_tower_m,
            s.dwelling_count_within_100m,
            s.dwelling_count_within_200m,
            s.tower_count_on_property,
            s.impact_score,
            s.impact_rank_project
        FROM gis_platform.property_impact_summary s
        JOIN gis_platform.property_unit p
          ON p.property_id = s.property_id
        WHERE s.project_version_id = %s
        ORDER BY s.impact_score DESC NULLS LAST,
                 s.total_overlap_area_m2 DESC NULLS LAST,
                 p.property_designation ASC
    """

    conn = get_connection()
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute(query, (project_version_id,))
            rows = cur.fetchall()
            return list(rows)
    finally:
        conn.close()


def write_csv(rows: Iterable[dict], output_csv: str) -> None:
    rows = list(rows)
    fieldnames = [
        "property_designation",
        "municipality_name",
        "total_overlap_area_m2",
        "max_overlap_pct",
        "min_distance_to_alignment_m",
        "min_distance_to_tower_m",
        "dwelling_count_within_100m",
        "dwelling_count_within_200m",
        "tower_count_on_property",
        "impact_score",
        "impact_rank_project",
    ]

    with open(output_csv, "w", newline="", encoding="utf-8") as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        for row in rows:
            writer.writerow({key: row.get(key) for key in fieldnames})


def main(argv: list[str]) -> int:
    if len(argv) != 3:
        print(
            "Användning: python generate_impact_report.py <project_version_id> <output_csv>",
            file=sys.stderr,
        )
        return 1

    project_version_id = argv[1]
    output_csv = argv[2]

    try:
        rows = fetch_report_rows(project_version_id)
        write_csv(rows, output_csv)
        print(f"Rapport skapad: {output_csv} ({len(rows)} rader)")
        return 0
    except Exception as exc:
        print(f"Fel: {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
