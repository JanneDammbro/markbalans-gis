# markbalans-gis
GIS platform for infrastructure intrusion analysis (power lines, property impacts, legal cases)
# Markbalans GIS

## Infrastruktur- och fastighetsanalysplattform

**Markbalans GIS** är ett analysprojekt för att identifiera, analysera och visualisera hur stora infrastrukturprojekt påverkar fastigheter i Sverige. Plattformen fokuserar särskilt på kraftledningar och andra linjära infrastrukturer som kan innebära intrång i fastigheter.

Projektet kombinerar:

* geografiska data (GIS)
* fastighetsinformation
* analys av intrång och avstånd
* rättsfall och ersättningspraxis
* frivilliga fastighetsförvärv

Syftet är att bygga en nationell databas och analysmotor som gör det möjligt att förstå och analysera hur infrastrukturprojekt påverkar mark och fastigheter.

---

# Huvudfunktioner

## 1. Projekt- och korridoranalys

Systemet kan lagra och analysera data för exempelvis:

* kraftledningskorridorer
* ledningssträckningar
* stolpplaceringar
* alternativa sträckningar

Detta gör det möjligt att identifiera vilka fastigheter som berörs av ett projekt.

---

## 2. Fastighetsanalys

Plattformen kopplar infrastrukturprojekt till:

* fastighetsgränser
* byggnader
* fastighetsägare

Analysen kan beräkna:

* hur stor del av en fastighet som ligger i en korridor
* avstånd mellan bostadshus och kraftledningar
* hur många stolpar som hamnar på en fastighet
* intrångsnivå och påverkan

---

## 3. GIS‑baserad analysmotor

Analysplattformen använder **PostgreSQL + PostGIS** för att beräkna:

* skärningar mellan korridorer och fastigheter
* avstånd mellan byggnader och ledningar
* buffertzoner
* påverkan på fastigheter

Resultaten lagras i analyslager som gör det möjligt att rangordna berörda fastigheter.

---

## 4. Praxis och ersättning

Systemet innehåller även en struktur för att lagra:

* domstolsmål
* ersättningsnivåer
* intrångsbedömningar
* frivilliga fastighetsförvärv

Det gör det möjligt att analysera hur liknande intrång tidigare har bedömts.

---

# Databas

Kärnan i systemet är en **PostgreSQL/PostGIS‑databas**.

Den innehåller bland annat tabeller för:

* infrastructure_project
* project_version
* corridor_area
* powerline_alignment
* tower_site
* property_unit
* building_object
* property_intersection
* building_proximity
* property_impact_summary
* court_case
* compensation_case
* voluntary_purchase
* document_archive

Databasen gör det möjligt att analysera sambandet mellan:

* infrastruktur
* fastigheter
* byggnader
* juridiska beslut

---

# Projektstruktur

Repositoryt är organiserat enligt följande:

```
markbalans-gis
│
├── README.md
│
├── sql
│   └── 001_initial_schema.sql
│
├── etl
│   └── import_scripts
│
├── analysis
│   └── spatial_analysis
│
├── docs
│   └── data_model
```

---

# Datakällor

Exempel på datakällor som kan användas i plattformen:

* Svenska kraftnät
* Lantmäteriet
* Trafikverket
* Energimarknadsinspektionen
* kommunala planeringsdata
* domstolsavgöranden

---

# Möjliga analyser

Plattformen kan exempelvis besvara frågor som:

* vilka fastigheter ligger i en kraftledningskorridor
* hur nära bostadshus ligger kraftledningar
* vilka fastigheter som får störst intrång
* hur liknande intrång har ersatts i tidigare mål

---

# Syfte

Projektets långsiktiga mål är att bygga en nationell analysplattform som gör det möjligt att:

* förstå infrastrukturens påverkan på fastigheter
* analysera intrångsnivåer
* jämföra ersättningspraxis
* identifiera berörda fastighetsägare

---

# Status

Projektet är i ett tidigt utvecklingsskede och börjar med att bygga:

1. datamodell
2. GIS‑analysmotor
3. import av geodata
4. analys av fastighetsintrång

---

# Teknologi

Projektet använder bland annat:

* PostgreSQL
* PostGIS
* Python
* GIS‑analys

---

# Licens

Projektet utvecklas för analys och forskning kring infrastruktur och fastighetsintrång.
