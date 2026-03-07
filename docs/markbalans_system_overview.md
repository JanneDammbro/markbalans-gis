# Markbalans – Systemöversikt

Detta dokument visar **hela Markbalans-plattformen** i ett sammanhängande schema, från datainsamling till analys, fältobservationer, juridik och rapportering.

Syftet är att göra det tydligt hur alla delar hänger ihop och hur plattformen kan utvecklas vidare till en nationell infrastruktur- och fastighetsdatabas.

---

# Översiktlig systembild

```text
                              MARKBALANS
         Nationell plattform för analys av infrastrukturintrång

 ┌─────────────────────────────────────────────────────────────────────┐
 │                         EXTERNA DATAKÄLLOR                         │
 └─────────────────────────────────────────────────────────────────────┘
            │                  │                   │
            │                  │                   │
            ▼                  ▼                   ▼
   Svenska kraftnät      Lantmäteriet        Trafikverket / Ei / domstolar
   - korridorer          - fastigheter       - projektdata
   - linjegeometrier     - byggnader         - beslut
   - stolpplatser        - registerdata      - praxis / avgöranden
            \                |                  /
             \               |                 /
              \              |                /
               ▼             ▼               ▼
 ┌─────────────────────────────────────────────────────────────────────┐
 │                           ETL / IMPORTLAGER                        │
 │  etl/import_shapefile.py                                           │
 │  framtida: import_geopackage.py, import_documents.py               │
 └─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
 ┌─────────────────────────────────────────────────────────────────────┐
 │                     POSTGRESQL + POSTGIS                           │
 │                         schema: gis_platform                       │
 └─────────────────────────────────────────────────────────────────────┘
                                │
     ┌──────────────────────────┼──────────────────────────┐
     │                          │                          │
     ▼                          ▼                          ▼
┌───────────────┐       ┌──────────────────┐      ┌────────────────────┐
│ PROJEKTDATA   │       │ FASTIGHETSDATA   │      │ JURIDIK / ERSÄTTN. │
├───────────────┤       ├──────────────────┤      ├────────────────────┤
│ project       │       │ property_unit    │      │ court_case         │
│ version       │       │ building_object  │      │ compensation_case  │
│ corridor_area │       │ ownership        │      │ voluntary_purchase │
│ alignment     │       │ parties          │      │ document_archive   │
│ tower_site    │       └──────────────────┘      └────────────────────┘
└───────────────┘
     │                          │                          │
     └───────────────┬──────────┴──────────┬──────────────┘
                     │                     │
                     ▼                     ▼
           ┌───────────────────┐   ┌──────────────────────┐
           │   ANALYSMOTOR     │   │   FÄLTAPP / MOBIL    │
           ├───────────────────┤   ├──────────────────────┤
           │ property_         │   │ Faltappen.tsx        │
           │ intersection.py   │   │ field-observation    │
           │ building distance │   │ foton / GPS / noter  │
           │ impact summary    │   │ offline-synk         │
           └───────────────────┘   └──────────────────────┘
                     │                     │
                     │                     ▼
                     │         ┌───────────────────────────┐
                     │         │   FRAMTIDA TABELLER       │
                     │         ├───────────────────────────┤
                     │         │ field_observation         │
                     │         │ field_photo               │
                     │         │ sync_queue                │
                     │         └───────────────────────────┘
                     │                     │
                     └─────────────┬───────┘
                                   │
                                   ▼
                    ┌──────────────────────────────────┐
                    │ ANALYSRESULTAT / RAPPORTERING    │
                    ├──────────────────────────────────┤
                    │ property_intersection            │
                    │ building_proximity               │
                    │ property_impact_summary          │
                    │ generate_impact_report.py        │
                    │ CSV / Excel / karta / rapport    │
                    └──────────────────────────────────┘
                                   │
                                   ▼
                    ┌──────────────────────────────────┐
                    │        STRATEGISKT UTFALL        │
                    ├──────────────────────────────────┤
                    │ - tidig identifiering            │
                    │ - intrångsbedömning              │
                    │ - prioritering av fastigheter    │
                    │ - jämförelse mot praxis          │
                    │ - underlag för ersättning        │
                    │ - nationell kunskapsdatabas      │
                    └──────────────────────────────────┘
```

---

# Huvudidé

Markbalans består av fem samverkande delar:

## 1. Externa datakällor

Data hämtas från exempelvis:

* Svenska kraftnät
* Lantmäteriet
* Trafikverket
* Energimarknadsinspektionen
* domstolar
* handlingar och GIS-underlag

---

## 2. Importlager (ETL)

Importlagret läser in rådata till plattformen.

Nuvarande komponent:

* `etl/import_shapefile.py`

Framtida komponenter:

* `etl/import_geopackage.py`
* `etl/import_documents.py`
* `etl/normalize_property_data.py`

---

## 3. Databaslager

Kärnan är PostgreSQL/PostGIS med schemat `gis_platform`.

Här lagras:

* projekt och projektversioner
* korridorer, linjer och stolpplatser
* fastigheter och byggnader
* juridik, ersättning och dokument
* analysresultat

---

## 4. Analyslager

Analysmotorn räknar ut hur infrastrukturen påverkar fastigheter.

Exempel:

* vilka fastigheter ligger i korridoren
* hur nära ligger byggnader kraftledningen
* hur många stolpar berör en fastighet
* vilka objekt ska prioriteras

Nuvarande filer:

* `analysis/property_intersection.py`
* `analysis/generate_impact_report.py`

Framtida filer:

* `analysis/building_distance_analysis.py`
* `analysis/tower_impact_analysis.py`
* `analysis/risk_score.py`

---

## 5. Fältapp

Fältappen blir datainsamlingslager ute i verkligheten.

Nuvarande prototyp:

* `field-app/Faltappen.tsx`
* `field-app/README.md`

Framtida datamodell:

* `field_observation`
* `field_photo`
* `field_sync_event`

Det gör att plattformen kan lagra:

* observationer från platsbesök
* foton
* GPS-punkter
* anteckningar
* bedömning av påverkan

---

# Strategisk styrka

Den stora styrkan i Markbalans är att plattformen förenar:

* **myndighetsdata**
* **GIS-analys**
* **fältobservationer**
* **juridik och praxis**
* **rapportering och beslutsstöd**

Det gör systemet ovanligt starkt, eftersom det inte bara visar geometri utan även kan beskriva faktisk påverkan på fastigheter.

---

# Rekommenderad fortsatt utveckling

## Nästa databastabeller

* `field_observation`
* `field_photo`
* `field_sync_queue`

## Nästa analysfiler

* `analysis/building_distance_analysis.py`
* `analysis/create_field_observation_summary.py`

## Nästa appdelar

* karta i Fältappen
* direkt uppslag av fastighet
* synk mot databasen
* export till rapport

---

# Sammanfattning

Markbalans är uppbyggt som en sammanhängande plattform där:

1. externa data importeras,
2. lagras i PostGIS,
3. analyseras mot fastigheter och byggnader,
4. kompletteras med fältobservationer,
5. kopplas till juridik och ersättning,
6. och sammanställs till rapporter och beslutsunderlag.

Detta är grunden för en nationell plattform för analys av infrastrukturintrång i Sverige.
