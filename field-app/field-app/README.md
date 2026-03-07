# Fältappen – Markbalans

## Översikt

**Fältappen** är den mobila arbetsytan för Markbalans GIS‑plattform. Den är tänkt att användas vid platsbesök när man analyserar infrastrukturintrång, till exempel kraftledningar, korridorer och stolpplatser, och deras påverkan på fastigheter och byggnader.

Appen gör det möjligt för fältpersonal att:

* identifiera aktuell fastighet eller projektpost
* registrera observationer på plats
* ta och koppla foton till observationer
* dokumentera avstånd, exponering och markpåverkan
* arbeta offline i områden utan täckning
* synkronisera observationer till Markbalans GIS‑plattformen

Syftet är att koppla **verkliga observationer i fält** till den analytiska GIS‑plattformen.

---

# Roll i Markbalans‑systemet

Fältappen utgör **datainsamlingslagret i fält** i Markbalans arkitektur.

Systemstruktur:

```
Fältapp (mobil)
      │
      ▼
Observationer i fält
      │
      ▼
Markbalans GIS databas (PostGIS)
      │
      ▼
GIS‑analyser
      │
      ▼
Rapporter och intrångsanalys
```

Detta gör det möjligt att kombinera:

* GIS‑analys
* juridisk information
* fältobservationer

i ett sammanhängande system.

---

# Huvudfunktioner

## Fastighetsidentifiering

Appen kan söka fram eller ladda ett objekt kopplat till:

* fastighetsbeteckning
* kommun
* projekt‑ID

Alla observationer kopplas därmed direkt till rätt fastighet eller projekt.

---

## Registrering av observationer

Fältanvändare kan dokumentera exempelvis:

* bostadshus nära kraftledning
* möjlig stolpplacering
* påverkan på markanvändning
* påverkan på skogsbruk
* problem med tillfartsvägar

Varje observation kan innehålla:

* observationstyp
* påverkan / allvarlighetsgrad
* fältanteckningar
* tidsstämpel

---

## Positionsdata

Appen kan registrera geografisk position via GPS.

Exempel på lagrade värden:

* latitud
* longitud
* GPS‑noggrannhet

I senare versioner kan positionen överlagras med:

* fastighetsgränser
* kraftledningskorridorer
* stolpplatser

---

## Fotodokumentation

Fotografier är ofta viktiga i intrångsärenden.

Appen kan:

* ta bilder direkt i appen
* koppla bilder till observationer
* lagra bilder offline
* synkronisera bilder till systemet senare

Exempel på dokumentation:

* synlighet av kraftledning från bostad
* terräng vid stolpplacering
* påverkan på vägar
* påverkan på skogsbruk

---

## Offline‑funktion

Fältarbete sker ofta i områden utan mobil täckning.

Därför stödjer appen:

* lokal lagring av observationer
* lokal lagring av bilder
* synkronisering när uppkoppling finns

---

# Koppling till GIS‑plattformen

I framtida versioner kommer Fältappen kopplas direkt till Markbalans backend.

Relevanta databastabeller är exempelvis:

* `property_unit`
* `building_object`
* `powerline_alignment`
* `tower_site`
* `property_intersection`
* `property_impact_summary`

Fältobservationer kan lagras i en ny tabell, exempelvis:

```
field_observation
```

Exempel på fält:

* observation_id
* property_id
* project_version_id
* observation_type
* observation_note
* impact_level
* latitude
* longitude
* created_at

---

# Teknologi

Prototypen är byggd med:

* React
* TypeScript
* Tailwind UI‑komponenter

Framtida versioner kan köras som:

* mobil webbapp
* Progressive Web App (PWA)
* native mobilapp via wrapper

---

# Framtida utveckling

Planerade funktioner:

* integrerad kartvy
* visualisering av kraftledningskorridorer
* automatisk avståndsberäkning
* direkt uppslag av fastigheter
* offlinekö för data
* automatisk synkronisering
* rapporter baserade på fältobservationer

---

# Syfte

Fältappen binder samman tre delar av Markbalans‑plattformen:

* **fältobservationer** (verkligheten på plats)
* **GIS‑analys** (databearbetning)
* **juridiskt underlag** (intrång och ersättning)

Tillsammans skapar dessa komponenter en plattform för att analysera hur infrastruktur påverkar fastigheter i Sverige.
