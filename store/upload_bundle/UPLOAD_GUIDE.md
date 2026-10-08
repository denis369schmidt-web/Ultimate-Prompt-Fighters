# Store-Upload Checklist · Steam & Google Play

Alle Bild-Dateien in diesem Bundle wurden exakt nach den offiziellen Store-Spezifikationen von Valve (Steamworks) und Google Play Console im AAA-Standard generiert.

---

## 1. Steamworks Upload (partner.steamgames.com)

Gehe im Steamworks-Dashboard zu:
`Deine App` -> `Store-Seite bearbeiten` -> Tab `Grafik-Assets` & `Bibliothek-Assets`:

| Steamworks Feld | Dateipfad im Bundle | Pixelmaß | Anmerkung |
| :--- | :--- | :--- | :--- |
| **Haupt-Kapsel (Main Capsule)** | `steam/main_capsule_1232x706.png` | 1232 x 706 | Startseite & Sales-Events |
| **Header-Kapsel** | `steam/header_capsule_920x430.png` | 920 x 430 | Oben rechts auf der Store-Seite |
| **Kleine Kapsel (Small Capsule)** | `steam/small_capsule_462x174.png` | 462 x 174 | Suchleiste & Empfehlungen |
| **Vertikale Kapsel** | `steam/vertical_capsule_748x896.png` | 748 x 896 | Kategorie-Raster & Steam-App |
| **Seiten-Hintergrund** | `steam/page_background_1438x810.png` | 1438 x 810 | Atmosphärischer Hintergrund |
| **Bibliothek-Kapsel (Library Capsule)** | `steam/library_capsule_600x900.png` | 600 x 900 | 2:3 Cover im Steam-Client |
| **Bibliothek-Header** | `steam/library_header_920x430.png` | 920 x 430 | Bibliotheks-Detailansicht |
| **Bibliothek-Held (Library Hero)** | `steam/library_hero_3840x1240.png` | 3840 x 1240 | Textloser Panoramabackdrop |
| **Bibliothek-Logo (Transparent)** | `steam/library_logo_transparent.png`| 1280 x 720 | 32-Bit PNG mit Transparenz |
| **Community-Symbol** | `steam/community_icon_184x184.jpg` | 184 x 184 | Community Hub & Freunde |
| **Client-Symbol** | `steam/client_icon.ico` | Multi-ICO | Desktop-Icon & Windows-EXE |
| **Screenshots (8 Stück)** | `steam/screenshots/*.jpg` | 1920 x 1080 | 1080p Marketing-Screenshots |

---

## 2. Google Play Console Upload (play.google.com/console)

Gehe in der Play Console zu:
`Deine App` -> `Store-Präsenz` -> `Haupt-Store-Eintrag`:

| Google Play Feld | Dateipfad im Bundle | Pixelmaß | Vorgabe |
| :--- | :--- | :--- | :--- |
| **App-Symbol (App Icon)** | `google_play/app_icon_512x512.png` | 512 x 512 | 32-Bit PNG, max. 1 MB |
| **Vorstellungsgrafik (Feature Graphic)**| `google_play/feature_graphic_1024x500.png`| 1024 x 500 | 24-Bit PNG ohne Alpha |
| **Smartphone-Screenshots (8 Stück)**| `google_play/screenshots/*.png` | 1920 x 1080 | Mind. 4, ideal 8 im Querformat |
| **Tablet-Screenshots (7" & 10")** | dieselben `google_play/screenshots/*.png` | 1920 x 1080 | Erhöht Tablet-Sichtbarkeit |

---

## 3. Video-Trailer (Bereits gerendert)

- **Steam Trailer (MP4 & WebM)**:
  - `store/steam/trailer_1080p60.mp4` (H.264/AAC, 39.6 MB)
  - `store/steam/trailer_1080p60.webm` (VP9/Opus, 26.9 MB)
- **Google Play Trailer**:
  - YouTube-URL des Videos eintragen oder `store/play/trailer_1080p60.mp4` auf YouTube hochladen und verlinken.
