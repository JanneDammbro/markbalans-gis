# Setup Guide – Markbalans GIS

Denna guide beskriver hur man installerar och kör **Markbalans GIS-plattformen** lokalt.

Systemet består av tre huvuddelar:

1. PostgreSQL + PostGIS databas
2. Python-miljö
3. Markbalans analys- och importscript

---

# 1. Installera PostgreSQL

Installera PostgreSQL (version 14 eller senare rekommenderas).

[https://www.postgresql.org/download/](https://www.postgresql.org/download/)

När installationen är klar skapa en databas:

```
createdb markbalans
```

---

# 2. Aktivera PostGIS

Anslut till databasen:

```
psql markbalans
```

Aktivera PostGIS:

```
CREATE EXTENSION postgis;
```

Kontrollera installationen:

```
SELECT PostGIS_Version();
```

---

# 3. Skapa databasschemat

Kör SQL-filen från repositoryt:

```
psql markbalans -f sql/001_initial_schema.sql
```

Detta skapar alla tabeller i schemat:

```
gis_platform
```

---

# 4. Installera Python

Installera Python 3.10 eller senare.

Kontrollera installationen:

```
python --version
```

---

# 5. Skapa virtuell miljö

Rekommenderat är att använda en virtuell miljö.

```
python -m venv venv
```

Aktivera miljön:

Linux / Mac

```
source venv/bin/activate
```

Windows

```
venv\\Scripts\\activate
```

---

# 6. Installera beroenden

Installera Python-paketen:

```
pip install -r requirements.txt
```

---

# 7. Importera GIS-data

Exempel på import av shapefile:

```
python etl/import_shapefile.py data/corridor.shp corridor_area
```

Scriptet läser shapefilen och importerar geometri till PostGIS.

---

# 8. Kör analys

När data finns i databasen kan analyser köras.

Exempel:

```
python analysis/property_intersection.py <project_version_id> <corridor_id> <analysis_run_id>
```

Detta beräknar vilka fastigheter som ligger i korridoren.

---

# 9. Skapa rapport

Generera en CSV-rapport:

```
python analysis/generate_impact_report.py <project_version_id> impact_report.csv
```

Rapporten innehåller:

* fastighetsbeteckning
* kommun
* överlapp
* avstånd till ledning
* impact score

---

# 10. Projektstruktur

Repositoryt är organiserat enligt följande:

```
markbalans-gis
│
├── sql
│   └── 001_initial_schema.sql
│
├── etl
│   └── import_shapefile.py
│
├── analysis
│   ├── property_intersection.py
│   └── generate_impact_report.py
│
├── docs
│   ├── data_model.md
│   ├── architecture.md
│   └── setup.md
```

---

# Sammanfattning

Installationsprocessen består av:

1. installera PostgreSQL
2. aktivera PostGIS
3. skapa databasschema
4. installera Python-paket
5. importera geodata
6. köra analyser
7. generera rapporter

Efter dessa steg är Markbalans GIS redo att användas.
