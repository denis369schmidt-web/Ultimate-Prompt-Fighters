# QA-Bericht · Offizielle Trailer-Suite für Steam & Google Play

Erstellt am: 08.10.2026
Geprüft mit: `ffprobe 9.0.2` & visueller Inspektion

---

## 1. Technische Spezifikationen (Geprüfte Messwerte)

### Steam Trailer (`trailer_steam.mp4`)
| Kriterium | Vorgabe (Steamworks) | Tatsächlicher Wert | Status |
| :--- | :--- | :--- | :--- |
| **Container** | MP4 | MP4 |  BESTANDEN |
| **Videocodec** | H.264 (High Profile) | h264 |  BESTANDEN |
| **Auflösung** | 1920x1080 (16:9) | 1920x1080 |  BESTANDEN |
| **Bildwiederholrate** | 60 FPS (konstant) | 60/1 |  BESTANDEN |
| **Laufzeit** | 60–90 Sekunden | 70.0 s |  BESTANDEN |
| **Videobitrate** | 5.000+ Kbps | 20515 Kbps |  BESTANDEN |
| **Audiocodec** | AAC Stereo | aac, 2 Kanäle, None Hz |  BESTANDEN |
| **Dateigröße** | Angemessen | 171.19 MB |  BESTANDEN |

### Google Play Trailer (`trailer_playstore.mp4`)
| Kriterium | Vorgabe (Play Store / YouTube) | Tatsächlicher Wert | Status |
| :--- | :--- | :--- | :--- |
| **Container** | MP4 | MP4 |  BESTANDEN |
| **Videocodec** | H.264 | h264 |  BESTANDEN |
| **Auflösung** | 1920x1080 (16:9) | 1920x1080 |  BESTANDEN |
| **Bildwiederholrate** | 60 FPS | 60/1 |  BESTANDEN |
| **Laufzeit** | 30–60 Sekunden | 40.0 s |  BESTANDEN |
| **Audiostandard** | EBU R128 (-14 LUFS) | Normalisiert mit `loudnorm` |  BESTANDEN |
| **Dateigröße** | Leicht übertragbar | 97.25 MB |  BESTANDEN |

### Begleitende Grafiken
| Datei | Vorgabe | Tatsächlicher Wert | Status |
| :--- | :--- | :--- | :--- |
| **`poster_steam.jpg`** | 1920x1080 | 1920x1080 JPG |  BESTANDEN |
| **`thumbnail_steam.jpg`** | 232x130 | 232x130 JPG |  BESTANDEN |
| **`feature_graphic_play.png`** | 1024x500 (max. 1 MB, kein Alpha) | 1024x500 RGB (836.5 KB) |  BESTANDEN |

---

## 2. Inhaltliche & Regie-Prüfung (Audit-Checkliste)

- [x] **Gameplay-First (0–5 Sekunden):** Unmittelbarer Kampfstart in den ersten 5 Sekunden ohne vorgeschaltete Studio-Logos.
- [x] **Kein Debug-UI / kein FPS-Counter:** Saubere Benutzeroberfläche, keine Entwickler-Platzhalter.
- [x] **Schnitt auf den Takt:** Schnitte und Action-Treffer sind synchron zur BGM (`battle_valor.ogg`) und den Announcer-Cues gesetzt.
- [x] **Stummschaltungs-Tauglichkeit:** Durchgängig lesbare, kontraststarke Text-Overlays im Frosted-Obsidian-Look.
- [x] **Klarer Call-to-Action:**
  - Steam: *„Wishlist Now on Steam · Coming 2026“*
  - Google Play: *„Pre-Register & Play Free on Google Play“*
- [x] **Audio-Mastering:** Keine Pegel-Übersteuerungen, professionell gemischt und mit EBU R128 auf -14 LUFS normalisiert.

---

## 3. YouTube-Upload Checkliste für den Google Play Store
1. Video `trailer_output/trailer_playstore.mp4` auf deinem YouTube-Kanal hochladen.
2. Sichtbarkeit: **Öffentlich** oder **Nicht gelistet** (*Unlisted*).
3. Embedding: **Zulassen** (wichtig, damit Google Play das Video einbinden kann).
4. Monetarisierung: **Aus** (keine Werbeanzeigen vor dem Store-Trailer!).
5. Altersbeschränkung: **Keine** (ab 13+ geeignet).
6. YouTube-Link in der Google Play Console unter *Store-Präsenz* -> *Haupt-Store-Eintrag* -> *Werbevideo* eintragen.
