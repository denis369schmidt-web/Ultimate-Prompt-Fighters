# Art Direction

## Visuelles Ziel

Hochwertige, stilisierte 3D-Grafik mit klaren Silhouetten, kräftigem Form- und Materialkontrast, kontrollierter Detaildichte und gut lesbaren Kampfeffekten. Die Produktion bleibt mobile-tauglich und vermeidet Renderfunktionen, die eine starke Desktop-GPU voraussetzen.

## Arena – Die gebrochene Mondfeste

- Nächtliche, verfallene Zitadelle mit seitlich lesbarer Kampfebene.
- Gebrochene gotische Fenster, Pfeiler, Schutt und sichtbar improvisierte Reparaturen.
- Kühles Mondlicht und blaue Umgebungstöne.
- Sparsame orange Feuerakzente markieren Tiefe und interaktive Kampfzone.
- Hintergrunddetail darf die Kämpfersilhouetten nicht überlagern.

## Kämpfer A – Schattenninja

- Schlanke, schnelle Proportionen und dunkle segmentierte Rüstung.
- Stoffelemente für sekundäre Bewegung, ohne die Silhouette zu verwischen.
- Zwei kurze elektrische Klingen mit cyanfarbenem Leuchten.
- Schmale Schulterlinie, klar sichtbare Unterarme und bewegliche Knie-/Ellbogengelenke.

## Kämpfer B – Lavagolem

- Massige, breite Proportionen mit niedrigerem Schwerpunkt.
- Dunkle vulkanische Panzerplatten über einem glühenden inneren Körper.
- Große Fäuste als primäre Waffenform.
- Orangefarbene Risse konzentrieren sich an Brust, Schultern, Ellbogen und Händen.

## Produktionsregeln

- Silhouetten müssen auch ohne Material klar unterscheidbar bleiben.
- Emission wird sparsam eingesetzt und darf UI sowie Trefferlesbarkeit nicht überstrahlen.
- Aktiver Zielrenderer ist Godot Compatibility. glTF-PBR-Materialien werden importiert, Emissionsfarben und Rauheit ausdrücklich zur Laufzeit angepasst; Blender-Knoten gelten nicht pauschal als übertragbar.
- Konzeptansichten müssen Vorder-, Seiten- und Rückansicht, Materialdetails sowie einen Größenvergleich enthalten.

## Konzeptgrafiken und Konsistenzprüfung

Erzeugt mit dem eingebauten Bildgenerierungswerkzeug und projektlokal gespeichert:

- `art/references/shadow_ninja_turnaround.png`
- `art/references/lava_golem_turnaround.png`
- `art/references/broken_moonkeep_arena.png`
- `art/references/fighter_scale_comparison.png`

Festgestellte Abweichungen:

- Das Ninja-Turnaround zeigt sichtbares Haar, der Größenvergleich dagegen eine Kapuze. Für das 3D-Modell gilt der geschlossene Helm/die Maske als verbindliche Prototyp-Lösung; Haare bleiben ein späteres Modul.
- Die genauen Lavarisstexturen unterscheiden sich zwischen Golem-Turnaround und Größenvergleich. Verbindlich sind Positionen an Brust, Ellbogen und Knien; das exakte Rissmuster ist prozedural und muss nicht identisch sein.
- Das Arena-Konzept ist wesentlich detailreicher als das mobile Blockout. Das Blender-Modell übernimmt Komposition, Mondlicht, gotische Bögen und Feuerakzente, aber bewusst nicht die gesamte Mikrodetaillierung.

## Godot-Migration: tatsächlich sichtbarer Stand

Am 2026-09-18 alle drei Blender-Szenen über `scripts/export_godot_assets.py` als GLB exportiert und in Godot 4.7.2 importiert. Die Quellen bleiben unverändert. Fehlende neutrale Animationskanäle werden beim Export ergänzt, um Posenübernahme zwischen Clips zu vermeiden. Laufzeitskalierung 0,01 wandelt die vorhandenen Zentimeter-Koordinaten in Meter um.

Echte Spielbilder liegen in `docs/screenshots/`. Die Figuren sind gegliederte, starr gewichtete Low-Poly-Prototypen mit 18 Bones und je sieben Clips. Die Arena enthält einfache Säulen, gebrochene Fenster, Reparaturbalken, Schutt, Mond und Feuerstellen. Einfache PBR-Farben statt komplexer Shader; keine zwingenden Desktop-Spezialeffekte.

Die hochwertige Konzeptqualität ist ausdrücklich noch nicht erreicht. Offen sind feinere Silhouetten, Stoff, glaubwürdige Lavarisstexturen, präzisere Klingen-/Faustkontakte, Fußkorrekturen und vollständige Prüfung aller Gelenkposen in Bewegung. Der Importnachweis allein gilt nicht als abschließende Animationsabnahme. Einfache Trefferblitze und synthetische Sounds dienen vorerst der Rückmeldung.
