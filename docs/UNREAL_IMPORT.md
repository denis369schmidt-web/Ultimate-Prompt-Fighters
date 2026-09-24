# Unreal-Importplan

Dieser Ablauf wird erst nach der Unreal-Installation ausgeführt und anschließend mit echten Importprotokollen ergänzt.

## FBX-Dateien

- `exports/PFU_ShadowNinja.fbx` – eigenes Skelett `SK_Ninja`, 7 Actions
- `exports/PFU_LavaGolem.fbx` – eigenes Skelett `SK_Golem`, 7 Actions
- `exports/PFU_BrokenMoonkeep.fbx` – statische Arenageometrie

Erwartete Importoptionen für die Kämpfer:

- Skeletal Mesh: an
- Import Mesh: an
- Import Animations: an
- Import Uniform Scale: 1,0
- Convert Scene / Force Front X Axis anhand eines ersten Sichttests festlegen, nicht blind übernehmen
- Ninja und Golem nicht auf dasselbe Skelett zwingen

## Äquivalente Unreal-Materialien

- Ninja Armor: Base Color dunkelblau, Metallic 0,58, Roughness 0,34
- Ninja Cloth: Base Color navy, Metallic 0, Roughness 0,82
- Ninja Electric: cyanfarbene Emission, mobile-tauglich begrenzen
- Golem Rock: dunkelbraunes Basalt, Metallic 0,18, Roughness 0,72
- Golem Armor: fast schwarzes Vulkangestein, Metallic 0,30, Roughness 0,58
- Golem Lava: orange/rote Emission; keine teure dynamische Tessellation
- Arena: einfache Stone/Dark Stone/Timber/Iron-Materialinstanzen und zwei sparsame Ember-Emissionen

Blender-Knoten gelten nicht als automatisch übertragen. Nach dem Import werden Unreal-Materialinstanzen ausdrücklich erstellt und auf mobile Shader-Komplexität geprüft.

## Noch ausstehende echte Prüfung

- Maßstab in Zentimetern
- X-Vorwärtsachse und Bodenhöhe
- Skelett-Hierarchie und Clipnamen
- Verformung in allen sieben Animationen
- Bodenkontakt und Überschneidungen
- Materialslots
- einfache Kollision für Arena und Kämpfer

