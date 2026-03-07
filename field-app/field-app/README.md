import React, { useMemo, useState } from "react";
import { motion } from "framer-motion";
import {
  MapPin,
  Camera,
  Home,
  FileText,
  AlertTriangle,
  CheckCircle2,
  Search,
  Plus,
  Layers3,
  WifiOff,
  Upload,
  TreePine,
  TowerControl,
} from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Progress } from "@/components/ui/progress";

const demoCases = [
  {
    id: "MB-2026-001",
    property: "Ljusdal Växna 3:14",
    municipality: "Ljusdal",
    status: "Pågående inventering",
    distance: "82 m till ledning",
    priority: "Hög",
  },
  {
    id: "MB-2026-002",
    property: "Hudiksvall Rogsta 1:27",
    municipality: "Hudiksvall",
    status: "Klar för rapport",
    distance: "146 m till stolpplats",
    priority: "Medel",
  },
  {
    id: "MB-2026-003",
    property: "Söderhamn Mo 5:8",
    municipality: "Söderhamn",
    status: "Ny observation",
    distance: "47 m till bostadshus",
    priority: "Akut",
  },
];

const demoObservations = [
  {
    time: "09:12",
    type: "Bostadshus",
    note: "Visuell exponering mot planerad kraftledning från tomt och köksfönster.",
    severity: "Hög",
  },
  {
    time: "09:34",
    type: "Stolpplats",
    note: "Möjlig stolpplacering nära infartsväg och skogsbryn.",
    severity: "Medel",
  },
  {
    time: "10:03",
    type: "Markpåverkan",
    note: "Tydlig påverkan på brukningsmönster och tillgänglighet till skifte.",
    severity: "Hög",
  },
];

function PriorityBadge({ value }: { value: string }) {
  const styles: Record<string, string> = {
    Akut: "bg-red-100 text-red-700 border-red-200",
    Hög: "bg-orange-100 text-orange-700 border-orange-200",
    Medel: "bg-yellow-100 text-yellow-700 border-yellow-200",
    Låg: "bg-green-100 text-green-700 border-green-200",
  };

  return <Badge className={`border ${styles[value] || ""}`}>{value}</Badge>;
}

export default function Faltappen() {
  const [search, setSearch] = useState("");
  const [selectedCase, setSelectedCase] = useState(demoCases[0]);
  const [observationType, setObservationType] = useState("Bostadshus");
  const [impactLevel, setImpactLevel] = useState("Hög");
  const [note, setNote] = useState("");
  const [photos, setPhotos] = useState(3);
  const [syncPercent, setSyncPercent] = useState(72);

  const filteredCases = useMemo(() => {
    return demoCases.filter(
      (item) =>
        item.property.toLowerCase().includes(search.toLowerCase()) ||
        item.id.toLowerCase().includes(search.toLowerCase()) ||
        item.municipality.toLowerCase().includes(search.toLowerCase())
    );
  }, [search]);

  return (
    <div className="min-h-screen bg-slate-50 p-4 md:p-8">
      <div className="mx-auto max-w-7xl space-y-6">
        <motion.div
          initial={{ opacity: 0, y: 12 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.35 }}
          className="grid gap-4 lg:grid-cols-[1.15fr_0.85fr]"
        >
          <Card className="rounded-2xl border-0 shadow-sm">
            <CardContent className="p-6">
              <div className="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
                <div>
                  <div className="mb-2 flex items-center gap-2 text-sm text-slate-500">
                    <Layers3 className="h-4 w-4" />
                    Markbalans GIS · Mobil fältapp
                  </div>
                  <h1 className="text-3xl font-semibold tracking-tight text-slate-900">Fältappen</h1>
                  <p className="mt-2 max-w-2xl text-sm text-slate-600">
                    Mobil arbetsyta för platsbesök, observationer, avståndsbedömning och underlag till intrångsanalys.
                  </p>
                </div>
                <div className="grid grid-cols-2 gap-3 md:grid-cols-3">
                  <Card className="rounded-2xl shadow-none">
                    <CardContent className="p-4">
                      <div className="text-xs text-slate-500">Aktiva objekt</div>
                      <div className="mt-1 text-2xl font-semibold">{demoCases.length}</div>
                    </CardContent>
                  </Card>
                  <Card className="rounded-2xl shadow-none">
                    <CardContent className="p-4">
                      <div className="text-xs text-slate-500">Bilder</div>
                      <div className="mt-1 text-2xl font-semibold">{photos}</div>
                    </CardContent>
                  </Card>
                  <Card className="rounded-2xl shadow-none col-span-2 md:col-span-1">
                    <CardContent className="p-4">
                      <div className="flex items-center gap-2 text-xs text-slate-500">
                        <WifiOff className="h-4 w-4" />
                        Offline-synk
                      </div>
                      <div className="mt-2 text-2xl font-semibold">{syncPercent}%</div>
                    </CardContent>
                  </Card>
                </div>
              </div>
            </CardContent>
          </Card>

          <Card className="rounded-2xl border-0 shadow-sm">
            <CardHeader className="pb-2">
              <CardTitle className="text-lg">Dagens fokus</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="rounded-2xl border bg-white p-4">
                <div className="flex items-start justify-between gap-4">
                  <div>
                    <div className="text-sm text-slate-500">Fastighet</div>
                    <div className="mt-1 text-lg font-semibold">{selectedCase.property}</div>
                    <div className="mt-1 text-sm text-slate-600">{selectedCase.id} · {selectedCase.municipality}</div>
                  </div>
                  <PriorityBadge value={selectedCase.priority} />
                </div>
                <div className="mt-4 grid grid-cols-2 gap-3 text-sm">
                  <div className="rounded-xl bg-slate-50 p-3">
                    <div className="text-slate-500">Status</div>
                    <div className="mt-1 font-medium text-slate-900">{selectedCase.status}</div>
                  </div>
                  <div className="rounded-xl bg-slate-50 p-3">
                    <div className="text-slate-500">Närhetsdata</div>
                    <div className="mt-1 font-medium text-slate-900">{selectedCase.distance}</div>
                  </div>
                </div>
              </div>
              <Button className="w-full rounded-2xl">
                <MapPin className="mr-2 h-4 w-4" />
                Starta platsbesök
              </Button>
            </CardContent>
          </Card>
        </motion.div>

        <div className="grid gap-6 lg:grid-cols-[0.95fr_1.35fr_0.9fr]">
          <Card className="rounded-2xl border-0 shadow-sm">
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-lg">
                <Search className="h-5 w-5" />
                Objektlista
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <Input
                placeholder="Sök fastighet, kommun eller ID"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                className="rounded-xl"
              />
              <div className="space-y-3">
                {filteredCases.map((item) => (
                  <button
                    key={item.id}
                    onClick={() => setSelectedCase(item)}
                    className={`w-full rounded-2xl border p-4 text-left transition hover:shadow-sm ${
                      selectedCase.id === item.id ? "border-slate-900 bg-slate-50" : "bg-white"
                    }`}
                  >
                    <div className="flex items-start justify-between gap-3">
                      <div>
                        <div className="text-sm font-medium text-slate-900">{item.property}</div>
                        <div className="mt-1 text-xs text-slate-500">{item.id} · {item.municipality}</div>
                        <div className="mt-2 text-sm text-slate-600">{item.status}</div>
                      </div>
                      <PriorityBadge value={item.priority} />
                    </div>
                  </button>
                ))}
              </div>
            </CardContent>
          </Card>

          <Card className="rounded-2xl border-0 shadow-sm">
            <CardHeader>
              <CardTitle className="text-lg">Fältformulär</CardTitle>
            </CardHeader>
            <CardContent>
              <Tabs defaultValue="observation" className="space-y-4">
                <TabsList className="grid w-full grid-cols-4 rounded-2xl">
                  <TabsTrigger value="observation">Observation</TabsTrigger>
                  <TabsTrigger value="property">Fastighet</TabsTrigger>
                  <TabsTrigger value="location">Position</TabsTrigger>
                  <TabsTrigger value="photos">Foto</TabsTrigger>
                </TabsList>

                <TabsContent value="observation" className="space-y-4">
                  <div className="grid gap-4 md:grid-cols-2">
                    <div className="space-y-2">
                      <label className="text-sm font-medium text-slate-700">Objekttyp</label>
                      <Select value={observationType} onValueChange={setObservationType}>
                        <SelectTrigger className="rounded-xl">
                          <SelectValue />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="Bostadshus">Bostadshus</SelectItem>
                          <SelectItem value="Stolpplats">Stolpplats</SelectItem>
                          <SelectItem value="Markpåverkan">Markpåverkan</SelectItem>
                          <SelectItem value="Tillfartsväg">Tillfartsväg</SelectItem>
                          <SelectItem value="Skogsbruk">Skogsbruk</SelectItem>
                        </SelectContent>
                      </Select>
                    </div>
                    <div className="space-y-2">
                      <label className="text-sm font-medium text-slate-700">Påverkan</label>
                      <Select value={impactLevel} onValueChange={setImpactLevel}>
                        <SelectTrigger className="rounded-xl">
                          <SelectValue />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="Låg">Låg</SelectItem>
                          <SelectItem value="Medel">Medel</SelectItem>
                          <SelectItem value="Hög">Hög</SelectItem>
                          <SelectItem value="Akut">Akut</SelectItem>
                        </SelectContent>
                      </Select>
                    </div>
                  </div>
                  <div className="space-y-2">
                    <label className="text-sm font-medium text-slate-700">Fältanteckning</label>
                    <Textarea
                      value={note}
                      onChange={(e) => setNote(e.target.value)}
                      placeholder="Beskriv siktlinje, närhet till bostad, väg, brukningshinder, markförhållanden eller annan relevant observation..."
                      className="min-h-[160px] rounded-2xl"
                    />
                  </div>
                  <div className="grid gap-3 md:grid-cols-3">
                    <Card className="rounded-2xl shadow-none">
                      <CardContent className="flex items-center gap-3 p-4">
                        <Home className="h-5 w-5 text-slate-600" />
                        <div>
                          <div className="text-xs text-slate-500">Bostadsnära</div>
                          <div className="font-medium">Ja</div>
                        </div>
                      </CardContent>
                    </Card>
                    <Card className="rounded-2xl shadow-none">
                      <CardContent className="flex items-center gap-3 p-4">
                        <TowerControl className="h-5 w-5 text-slate-600" />
                        <div>
                          <div className="text-xs text-slate-500">Närmsta ledning</div>
                          <div className="font-medium">82 m</div>
                        </div>
                      </CardContent>
                    </Card>
                    <Card className="rounded-2xl shadow-none">
                      <CardContent className="flex items-center gap-3 p-4">
                        <TreePine className="h-5 w-5 text-slate-600" />
                        <div>
                          <div className="text-xs text-slate-500">Skogsbruk</div>
                          <div className="font-medium">Påverkat</div>
                        </div>
                      </CardContent>
                    </Card>
                  </div>
                </TabsContent>

                <TabsContent value="property" className="space-y-4">
                  <div className="grid gap-4 md:grid-cols-2">
                    <Card className="rounded-2xl shadow-none">
                      <CardContent className="p-4">
                        <div className="text-xs text-slate-500">Fastighetsbeteckning</div>
                        <div className="mt-1 text-base font-semibold">{selectedCase.property}</div>
                      </CardContent>
                    </Card>
                    <Card className="rounded-2xl shadow-none">
                      <CardContent className="p-4">
                        <div className="text-xs text-slate-500">Kommun</div>
                        <div className="mt-1 text-base font-semibold">{selectedCase.municipality}</div>
                      </CardContent>
                    </Card>
                    <Card className="rounded-2xl shadow-none">
                      <CardContent className="p-4">
                        <div className="text-xs text-slate-500">Projekt-ID</div>
                        <div className="mt-1 text-base font-semibold">{selectedCase.id}</div>
                      </CardContent>
                    </Card>
                    <Card className="rounded-2xl shadow-none">
                      <CardContent className="p-4">
                        <div className="text-xs text-slate-500">Prioritet</div>
                        <div className="mt-2"><PriorityBadge value={selectedCase.priority} /></div>
                      </CardContent>
                    </Card>
                  </div>
                  <div className="rounded-2xl border bg-slate-50 p-4 text-sm text-slate-700">
                    Fältappen kan senare kopplas till fastighetsregister, byggnadsobjekt, project_version, property_impact_summary och dokumentarkiv i Markbalans GIS.
                  </div>
                </TabsContent>

                <TabsContent value="location" className="space-y-4">
                  <div className="grid gap-4 md:grid-cols-3">
                    <Card className="rounded-2xl shadow-none">
                      <CardContent className="p-4">
                        <div className="flex items-center gap-2 text-xs text-slate-500">
                          <MapPin className="h-4 w-4" />
                          Latitud
                        </div>
                        <div className="mt-1 text-base font-semibold">61.82741</div>
                      </CardContent>
                    </Card>
                    <Card className="rounded-2xl shadow-none">
                      <CardContent className="p-4">
                        <div className="flex items-center gap-2 text-xs text-slate-500">
                          <MapPin className="h-4 w-4" />
                          Longitud
                        </div>
                        <div className="mt-1 text-base font-semibold">16.10352</div>
                      </CardContent>
                    </Card>
                    <Card className="rounded-2xl shadow-none">
                      <CardContent className="p-4">
                        <div className="flex items-center gap-2 text-xs text-slate-500">
                          <AlertTriangle className="h-4 w-4" />
                          GPS-noggrannhet
                        </div>
                        <div className="mt-1 text-base font-semibold">± 6 m</div>
                      </CardContent>
                    </Card>
                  </div>
                  <div className="rounded-3xl border bg-gradient-to-br from-slate-100 to-slate-200 p-6">
                    <div className="mb-4 flex items-center justify-between">
                      <div>
                        <div className="text-sm font-medium text-slate-700">Kartvy / positionsyta</div>
                        <div className="text-xs text-slate-500">Plats för framtida kartintegration med fastighetsgräns, korridor och observationer.</div>
                      </div>
                      <Badge variant="secondary">Mockup</Badge>
                    </div>
                    <div className="grid h-64 place-items-center rounded-2xl border border-dashed border-slate-400 bg-white/60 text-center text-sm text-slate-500">
                      <div>
                        <MapPin className="mx-auto mb-3 h-8 w-8" />
                        Interaktiv karta kan kopplas hit i nästa steg.
                      </div>
                    </div>
                  </div>
                </TabsContent>

                <TabsContent value="photos" className="space-y-4">
                  <div className="grid gap-4 md:grid-cols-3">
                    {[1, 2, 3].map((item) => (
                      <div key={item} className="rounded-2xl border bg-slate-50 p-4">
                        <div className="grid h-32 place-items-center rounded-xl border border-dashed bg-white text-slate-400">
                          <Camera className="h-8 w-8" />
                        </div>
                        <div className="mt-3 text-sm font-medium">Bild {item}</div>
                        <div className="text-xs text-slate-500">Visningsriktning och platsinfo kan sparas här.</div>
                      </div>
                    ))}
                  </div>
                  <div className="flex flex-wrap gap-3">
                    <Button className="rounded-2xl" onClick={() => setPhotos((v) => v + 1)}>
                      <Plus className="mr-2 h-4 w-4" />
                      Lägg till foto
                    </Button>
                    <Button variant="outline" className="rounded-2xl">
                      <Upload className="mr-2 h-4 w-4" />
                      Synka media
                    </Button>
                  </div>
                </TabsContent>
              </Tabs>
            </CardContent>
          </Card>

          <div className="space-y-6">
            <Card className="rounded-2xl border-0 shadow-sm">
              <CardHeader>
                <CardTitle className="flex items-center gap-2 text-lg">
                  <FileText className="h-5 w-5" />
                  Senaste observationer
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                {demoObservations.map((obs, index) => (
                  <motion.div
                    key={`${obs.time}-${index}`}
                    initial={{ opacity: 0, x: 8 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: index * 0.05 }}
                    className="rounded-2xl border p-4"
                  >
                    <div className="flex items-start justify-between gap-3">
                      <div>
                        <div className="text-sm font-medium text-slate-900">{obs.type}</div>
                        <div className="mt-1 text-xs text-slate-500">{obs.time}</div>
                      </div>
                      <PriorityBadge value={obs.severity} />
                    </div>
                    <p className="mt-3 text-sm leading-6 text-slate-600">{obs.note}</p>
                  </motion.div>
                ))}
              </CardContent>
            </Card>

            <Card className="rounded-2xl border-0 shadow-sm">
              <CardHeader>
                <CardTitle className="text-lg">Synkstatus</CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div>
                  <div className="mb-2 flex items-center justify-between text-sm">
                    <span className="text-slate-600">Lokala fältrapporter</span>
                    <span className="font-medium">{syncPercent}%</span>
                  </div>
                  <Progress value={syncPercent} className="h-3 rounded-full" />
                </div>
                <div className="space-y-3 text-sm text-slate-600">
                  <div className="flex items-center gap-2"><CheckCircle2 className="h-4 w-4" /> 12 observationer sparade lokalt</div>
                  <div className="flex items-center gap-2"><Upload className="h-4 w-4" /> 4 poster väntar på synk</div>
                  <div className="flex items-center gap-2"><Camera className="h-4 w-4" /> 3 bilder redo för uppladdning</div>
                </div>
                <Button variant="outline" className="w-full rounded-2xl" onClick={() => setSyncPercent(100)}>
                  Synka nu
                </Button>
              </CardContent>
            </Card>
          </div>
        </div>
      </div>
    </div>
  );
}
