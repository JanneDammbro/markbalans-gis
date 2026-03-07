"""
Import shapefile into PostGIS
Markbalans GIS platform
"""

import sys
import geopandas as gpd
import psycopg2
from sqlalchemy import create_engine

DATABASE_URL = "postgresql://postgres:postgres@localhost:5432/markbalans"


def import_shapefile(shapefile_path, table_name):

    print("Läser shapefile...")
    gdf = gpd.read_file(shapefile_path)

    print("Ansluter till databasen...")
    engine = create_engine(DATABASE_URL)

    print("Importerar data...")
    gdf.to_postgis(
        table_name,
        engine,
        schema="gis_platform",
        if_exists="append",
        index=False
    )

    print("Import klar")


if __name__ == "__main__":

    if len(sys.argv) != 3:
        print("Användning:")
        print("python import_shapefile.py <shapefile> <table>")
        sys.exit(1)

    shapefile = sys.argv[1]
    table = sys.argv[2]

    import_shapefile(shapefile, table)
