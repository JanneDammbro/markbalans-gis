# Data Model – Markbalans GIS

Denna fil beskriver den övergripande datamodellen för **Markbalans GIS-plattformen**. Syftet är att förklara hur geografiska objekt, fastigheter, analysresultat och juridiska data kopplas samman i databasen.

Databasen bygger på **PostgreSQL + PostGIS** och är designad för att analysera hur infrastrukturprojekt påverkar fastigheter och byggnader.

---

# Översikt

Datamodellen är uppdelad i fem huvuddelar:

1. Referensdata
2. Projektdata
3. Fastighetsdata
4. Analysdata
5. Juridik och ersättning

```
Infrastructure Project
        │
        ▼
 Project Version
        │
 ┌──────┴─────────┐
 ▼                ▼
Corridor      Alignment
                   │
                   ▼
                Tower

        │
        ▼
     Property
        │
        ▼
     Building

        │
        ▼
  Spatial Analysis

        │
        ▼
Legal Cases / Compensation
```

---

# 1. Referensdata

Referensdata beskriver var informationen kommer ifrån.

### source_dataset

Beskriver varje dataleverans eller datakälla.

Exempel:

* shapefiler från Svenska kraftnät
* fastighetsdata från Lantmäteriet
* GIS-data från Trafikverket

Viktiga fält:

* dataset_id
* source_name
* received_date
* original_crs
* coverage_area

---

# 2. Infrastrukturprojekt

Denna del beskriver infrastrukturen som analyseras.

### infrastructure_project

Representerar ett projekt.

Exempel:

* ny kraftledning
* korridorutredning
* ledningsombyggnad

Viktiga fält:

* project_id
* project_name
* project_owner
* project_category
* voltage_kv

### project_version

Ett projekt kan ha flera versioner av geometri.

Exempel:

* första korridorförslag
* reviderad sträckning
* slutlig sträckning

---

# 3. Infrastrukturgeometri

### corridor_area

Polygon som representerar en korridor.

Exempel:

* utredningskorridor
* alternativ korridor
* vald korridor

### powerline_alignment

Linjegeometri för själva ledningen.

### tower_site

Punktobjekt som representerar stolpplacering.

---

# 4. Fastighetsdata

### property_unit

Representerar en fastighet.

Innehåller:

* fastighetsbeteckning
* kommun
* area
* fastighetsgeometri

### building_object

Representerar byggnader kopplade till en fastighet.

Exempel:

* bostadshus
* ekonomibyggnader
* industribyggnader

---

# 5. Analysdata

Analyslagret innehåller resultat från GIS-beräkningar.

### property_intersection

Beskriver hur en fastighet påverkas av en korridor eller ledning.

Beräkningar kan inkludera:

* överlappande area
* procent av fastigheten
* minsta avstånd till ledning

### building_proximity

Beräknar avstånd mellan byggnader och infrastruktur.

Exempel:

* hus inom 50 meter
* hus inom 100 meter
* hus inom 200 meter

### property_impact_summary

Sammanfattar påverkan på fastigheten.

Exempel:

* antal stolpar
* överlapp
* avstånd till ledning
* impact score

---

# 6. Juridik och ersättning

Denna del kopplar geografiska analyser till rättsfall.

### court_case

Representerar ett domstolsmål.

### compensation_case

Ersättningsärenden kopplade till fastigheter.

### voluntary_purchase

Frivilliga fastighetsförvärv.

Exempel:

* fastighet köps på grund av närhet till kraftledning

---

# 7. Dokumentarkiv

### document_archive

Lagrar dokument kopplade till projekt och mål.

Exempel:

* domar
* kartbilagor
* värderingsutlåtanden

---

# Designprinciper

Datamodellen bygger på följande principer:

1. **Versionshantering av projekt**

Geometri kan ändras över tid och därför lagras flera versioner.

2. **Separation mellan data och analys**

Rådata lagras separat från analysresultat.

3. **Spårbarhet**

Alla data ska kunna kopplas tillbaka till ursprunglig datakälla.

4. **Nationell skalbarhet**

Databasen ska kunna lagra analyser för hela Sverige.

---

# Framtida utveckling

Planerade funktioner:

* import av shapefiler och GeoPackage
* automatiserad fastighetsanalys
* analys av avstånd mellan hus och ledningar
* nationell praxisdatabas

---

# Sammanfattning

Markbalans GIS-datamodellen kopplar samman:

* infrastrukturprojekt
* geografiska objekt
* fastigheter
* byggnader
* analysresultat
* juridiska beslut

Det gör det möjligt att analysera hur infrastruktur påverkar fastigheter i stor skala.

