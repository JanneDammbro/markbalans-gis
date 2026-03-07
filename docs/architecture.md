# System Architecture – Markbalans GIS

Denna fil beskriver den övergripande systemarkitekturen för **Markbalans GIS‑plattformen**.

Syftet är att visa hur data flödar genom systemet från rå geodata till analyser och rapporter.

---

# Översikt

Systemet består av fyra huvuddelar:

1. Datainsamling (ETL)
2. Databas (PostgreSQL/PostGIS)
3. Analysmotor
4. Rapportering

```
        Geodata
   (Svk, Lantmäteriet,
    Trafikverket m.fl.)
           │
           ▼
      ETL / Import
   import_shapefile.py
           │
           ▼
   PostgreSQL + PostGIS
      gis_platform
           │
           ▼
     GIS‑Analysmotor
 property_intersection.py
           │
           ▼
   Analysresultat-tabeller
 property_intersection
 property_impact_summary
           │
           ▼
      Rapporter
 generate_impact_report.py
           │
           ▼
         CSV / analyser
```

---

# 1. Datainsamling (ETL)

ETL‑lagret ansvarar för att läsa in geodata från externa källor.

Exempel på datakällor:

* Svenska kraftnät
* Lantmäteriet
* Trafikverket
* Energimarknadsinspektionen

Importen sker via Python‑script i mappen:

```
etl/
```

Nuvarande script:

```
import_shapefile.py
```

Funktion:

* läsa shapefiler
* läsa GeoPackage
* importera geometri till PostGIS

---

# 2. Databas

Kärnan i systemet är en **PostgreSQL/PostGIS‑databas**.

Schema:

```
gis_platform
```

Databasen innehåller flera lager av data:

### Infrastruktur

* infrastructure_project
* project_version
* corridor_area
* powerline_alignment
* tower_site

### Fastigheter

* property_unit
* building_object

### Analysresultat

* property_intersection
* building_proximity
* property_impact_summary

### Juridik

* court_case
* compensation_case
* voluntary_purchase

---

# 3. Analysmotor

Analyslagret innehåller Python‑script som kör GIS‑analyser direkt mot PostGIS.

Mapp:

```
analysis/
```

Exempel:

```
property_intersection.py
```

Den analyserar:

* vilka fastigheter ligger i en korridor
* överlapp mellan fastigheter och ledningskorridor
* avstånd till kraftledning

Resultaten lagras i databasen.

---

# 4. Rapportering

Rapportlagret exporterar analyser till rapporter.

Exempel:

```
generate_impact_report.py
```

Den skapar rapporter som visar:

* vilka fastigheter som påverkas
* hur stor del av fastigheten som påverkas
* ranking av intrång

Rapporter kan exporteras som:

* CSV
* Excel
* GIS‑lager

---

# Designprinciper

Systemet bygger på några centrala principer.

## Separation av lager

Data lagras i databasen medan analyser körs via script.

Det gör systemet flexibelt och skalbart.

## Spårbarhet

Alla dataset kopplas till en datakälla via `source_dataset`.

## Versionshantering

Infrastrukturprojekt kan ha flera versioner av geometri.

## Skalbarhet

Systemet är designat för att kunna analysera **hela Sverige**.

---

# Framtida arkitektur

Planerade komponenter:

* automatiserad dataimport
* API för analyser
* webbkarta
* automatiserade rapporter
* nationell databas över intrång och ersättningar

---

# Sammanfattning

Arkitekturen för Markbalans GIS består av:

* ETL för geodata
* PostGIS databas
* Python‑baserad GIS‑analys
* rapportgenerator

Tillsammans bildar dessa komponenter en plattform för att analysera hur infrastruktur påverkar fastigheter.
