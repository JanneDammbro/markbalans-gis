"""Markbalans GIS - Property intersection analysis

Purpose:
    Calculate which properties intersect a selected corridor and store the
    result in gis_platform.property_intersection.

Notes:
    - This is a first working foundation script.
    - It uses PostgreSQL/PostGIS for the actual spatial calculations.
    - Update DATABASE_URL before running locally.
"""

from __future__ import annotations

import os
import sys
from dataclasses import dataclass

import psycopg2
from psycopg2.extras import RealDictCursor


DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://postgres:postgres@localhost:5432/markbalans",
)


@dataclass
class AnalysisInput:
    project_version_id: str
    corridor_id: str
    analysis_run_id: str


def get_connection():
    """Create and return a PostgreSQL connection."""
    return psycopg2.connect(DATABASE_URL)


def validate_ids(conn, data: AnalysisInput) -> None:
    """Check that project version, corridor and analysis run exist."""
    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute(
            """
            SELECT EXISTS (
                SELECT 1
                FROM gis_platform.project_version
                WHERE project_version_id = %s
            ) AS exists_project_version
            """,
            (data.project_version_id,),
        )
        project_exists = cur.fetchone()["exists_project_version"]

        cur.execute(
            """
            SELECT EXISTS (
                SELECT 1
                FROM gis_platform.corridor_area
                WHERE corridor_id = %s
                  AND project_version_id = %s
            ) AS exists_corridor
            """,
            (data.corridor_id, data.project_version_id),
        )
        corridor_exists = cur.fetchone()["exists_corridor"]

        cur.execute(
            """
            SELECT EXISTS (
                SELECT 1
                FROM gis_platform.analysis_run
                WHERE analysis_run_id = %s
                  AND project_version_id = %s
            ) AS exists_analysis_run
            """,
            (data.analysis_run_id, data.project_version_id),
        )
        run_exists = cur.fetchone()["exists_analysis_run"]

    if not project_exists:
        raise ValueError("project_version_id finns inte i databasen.")
    if not corridor_exists:
        raise ValueError("corridor_id finns inte eller tillhör inte project_version_id.")
    if not run_exists:
        raise ValueError("analysis_run_id finns inte eller tillhör inte project_version_id.")


def delete_existing_results(conn, data: AnalysisInput) -> None:
    """Delete prior intersection results for the same run/corridor."""
    with conn.cursor() as cur:
        cur.execute(
            """
            DELETE FROM gis_platform.property_intersection
            WHERE project_version_id = %s
              AND corridor_id = %s
              AND analysis_run_id = %s
              AND analysis_type = 'corridor_overlap'
            """,
            (data.project_version_id, data.corridor_id, data.analysis_run_id),
        )


def insert_property_intersections(conn, data: AnalysisInput) -> int:
    """Run the spatial overlay and insert calculated results."""
    with conn.cursor() as cur:
        cur.execute(
            """
            INSERT INTO gis_platform.property_intersection (
                project_version_id,
                property_id,
                corridor_id,
                alignment_id,
                analysis_type,
                intersection_geometry,
                intersection_area_m2,
                intersection_length_m,
                share_of_property_pct,
                min_distance_to_alignment_m,
                min_distance_to_tower_m,
                impact_class,
                analysis_run_id
            )
            SELECT
                %s AS project_version_id,
                p.property_id,
                c.corridor_id,
                NULL AS alignment_id,
                'corridor_overlap' AS analysis_type,
                ST_Multi(ST_Intersection(p.geometry, c.geometry)) AS intersection_geometry,
                ST_Area(ST_Intersection(p.geometry, c.geometry)) AS intersection_area_m2,
                NULL AS intersection_length_m,
                CASE
                    WHEN NULLIF(ST_Area(p.geometry), 0) IS NULL THEN NULL
                    ELSE (ST_Area(ST_Intersection(p.geometry, c.geometry)) / ST_Area(p.geometry)) * 100
                END AS share_of_property_pct,
                (
                    SELECT MIN(ST_Distance(p.geometry, a.geometry))
                    FROM gis_platform.powerline_alignment a
                    WHERE a.project_version_id = %s
                ) AS min_distance_to_alignment_m,
                (
                    SELECT MIN(ST_Distance(p.geometry, t.geometry))
                    FROM gis_platform.tower_site t
                    WHERE t.project_version_id = %s
                ) AS min_distance_to_tower_m,
                CASE
                    WHEN ST_Area(ST_Intersection(p.geometry, c.geometry)) >= 50000 THEN 'severe'
                    WHEN ST_Area(ST_Intersection(p.geometry, c.geometry)) >= 10000 THEN 'high'
                    WHEN ST_Area(ST_Intersection(p.geometry, c.geometry)) >= 1000 THEN 'moderate'
                    ELSE 'low'
                END AS impact_class,
                %s AS analysis_run_id
            FROM gis_platform.property_unit p
            JOIN gis_platform.corridor_area c
              ON c.corridor_id = %s
             AND c.project_version_id = %s
            WHERE ST_Intersects(p.geometry, c.geometry)
            """,
            (
                data.project_version_id,
                data.project_version_id,
                data.project_version_id,
                data.analysis_run_id,
                data.corridor_id,
                data.project_version_id,
            ),
        )
        return cur.rowcount


def main(argv: list[str]) -> int:
    if len(argv) != 4:
        print(
            "Användning: python property_intersection.py <project_version_id> <corridor_id> <analysis_run_id>",
            file=sys.stderr,
        )
        return 1

    data = AnalysisInput(
        project_version_id=argv[1],
        corridor_id=argv[2],
        analysis_run_id=argv[3],
    )

    conn = get_connection()
    try:
        validate_ids(conn, data)
        delete_existing_results(conn, data)
        inserted_rows = insert_property_intersections(conn, data)
        conn.commit()
        print(f"Klart. {inserted_rows} fastighetsöverlapp har sparats i property_intersection.")
        return 0
    except Exception as exc:
        conn.rollback()
        print(f"Fel: {exc}", file=sys.stderr)
        return 2
    finally:
        conn.close()


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
