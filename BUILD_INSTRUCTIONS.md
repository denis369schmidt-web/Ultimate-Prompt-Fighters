# Build & Run Instructions: Prompt Fighter Ultimate

## 1. Voraussetzungen (Windows)
- **Godot Engine 4.7.2 stable** (Installiert via WinGet oder Direkt-Download):
  Standardpfad: `C:\Users\schmidtdenis\AppData\Local\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64_console.exe`
- **Blender 4.5.5 LTS** (für 3D-Modell-Builds):
  `tools\blender-4.5.5-windows-x64\blender.exe`
- **Python 3.10+** (mit Pillow für Textur- & Porträt-Generierung):
  `pip install Pillow numpy`

---

## 2. Spiel starten (Lokales Testen)

### Normaler Spielstart mit Menü & 13 Kämpfern:
```powershell
& "C:\Users\schmidtdenis\AppData\Local\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64_console.exe" --path .\godot
```

### Direkter KI-vs-KI Smoke-Test (Autonomous Mode):
```powershell
& "C:\Users\schmidtdenis\AppData\Local\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64_console.exe" --path .\godot -- ++ --smoke
```

---

## 3. Testsuite ausführen (Headless)

### Alle 13 Charaktere prüfen:
```powershell
& "C:\Users\schmidtdenis\AppData\Local\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64_console.exe" --headless --path .\godot --script res://scripts/test_all_playable.gd
```

### Kern-Kampfmechanik & Smash-Physik testen:
```powershell
& "C:\Users\schmidtdenis\AppData\Local\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64_console.exe" --headless --path .\godot --script res://tests/test_game.gd
```

---

## 4. Assets neu importieren (Headless)
Falls neue 3D-Modelle (.glb) oder Texturen (.png) hinzugefügt wurden:
```powershell
& "C:\Users\schmidtdenis\AppData\Local\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64_console.exe" --headless --path .\godot --editor --import --quit
```

---

## 5. Steuerung im Spiel

### Spieler 1 (Cyan / Tastatur links)
- **Laufen:** `A` / `D`
- **Springen (Doppelsprung):** `W`
- **Blocken / Plattform nach unten durchfallen:** `S`
- **Standard-Angriff:** `F`
- **Spezial-Fähigkeit:** `G`
- **Greifen / Werfen / Objekt aufheben:** `E`

### Spieler 2 (Orange / Pfeiltasten)
- **Laufen:** `←` / `→`
- **Springen (Doppelsprung):** `↑`
- **Blocken / Plattform nach unten durchfallen:** `↓`
- **Standard-Angriff:** `K`
- **Spezial-Fähigkeit:** `L`
- **Greifen / Werfen / Objekt aufheben:** `O`
