# Store-Release: Steam und Google Play

Stand 07.10.2026, Spielversion 0.9.0. Store-Regeln am selben Tag an den offiziellen Quellen geprüft (Links am Ende).

## Was schon fertig im Projekt liegt

| Was | Wo |
|---|---|
| Steam-Texte (Kurz- und Langbeschreibung als BBCode, Tags, Sprachen, Funktionen, Inhalts- und KI-Angaben) | `store/texts/steam_de.txt` |
| Google-Play-Texte (Name, Kurz- und Langbeschreibung, Kategorie, In-App-Produkte mit IDs und Texten) | `store/texts/play_de.txt` |
| Datenschutzerklärung DE/EN als fertige Webseite (nur Platzhalter ausfüllen) | `store/legal/datenschutz.html` |
| Alle Store-Grafiken in den geforderten Pixelmaßen | `store/steam/`, `store/play/` |
| Rohbilder aus dem echten Spiel (Key-Art 4K, Screenshots, Logo, Icon) | `store/raw/` |
| Export-Preset „Google Play“ (AAB, Feature-Tag `play`) neben „Steam“ und „Android Mobile“ | `godot/export_presets.cfg` |
| SteamPipe-Vorlagen und Upload-Skript | `store/steampipe/` |
| Produkt-IDs und Preise im Spiel | `godot/scripts/products.gd` |

Grafiken neu erzeugen (nach Änderungen an Kämpfern oder Arenen):

```powershell
# aus dem Projektordner; nicht headless, die Bilder werden gerendert
& $godot --path godot --script res://tests/render_store_art.gd -- --out="$PWD\store\raw"
python scripts/store_art.py      # schneidet store/steam/* und store/play/* zu
```

## Vorher klären: Diese Punkte entscheiden über Verkäufe

1. **Bühnen-Optik.** Die 23 Shop-Arenen haben denselben Bühnenaufbau (gleiche Schwebeplattformen, Sockel, Kugeln, Eiskristalle, Stachelplatten); nur der Hintergrund wechselt. Dazu kommt mittig das „Arcane Center Battle Mandala“ (`arena_builder.gd`, noch nicht committet), eine flache, unbeleuchtete Farbscheibe. Auf Screenshots wirkt das billig und gleichförmig. Steam verlangt echte Spielszenen, verstecken ist also keine Lösung. Empfehlung: Mandala entfernen oder als echtes Bodenmuster (Textur, Relief) bauen und pro Arena ein eigenes Plattform-Layout.
2. **Nur Deutsch.** Das senkt die Reichweite auf Steam stark (der deutschsprachige Markt ist ein kleiner Teil der Steam-Nutzer). Eine englische Übersetzung ist der größte einzelne Umsatzhebel. Bis dahin ehrlich nur Deutsch angeben.
3. **Name überall gleich.** Logo und Store: „Prompt Fighters Ultimate“. `project.godot` heißt „Prompt Fighter Ultimate“ (ohne s). Nicht ändern: davon hängt der Speicherordner der Spielstände ab. In den Exporten ist der Produktname schon angeglichen. Vor dem Kauf der Store-Gebühren beim DPMA (register.dpma.de) und bei der EUIPO (euipo.europa.eu/eSearch) nach „Prompt Fighters“ suchen.
4. **Händlerstatus (EU-Digital-Services-Act).** Wer Geld verdient, gilt als Händler. Google Play zeigt dann **Anschrift, Telefon und E-Mail öffentlich** im Store an; Steam fragt die Angaben ebenfalls ab. Wenn die Privatadresse nicht öffentlich sein soll: Geschäftsadresse oder Impressums-Service vorher einrichten.
5. **Store-Plugins fehlen noch.** `store.gd` ist für GodotSteam und das Google-Play-Billing-Plugin vorbereitet, beide sind aber nicht im Projekt. Ohne sie läuft der Testmodus („es wird nichts berechnet“). Details in den Abschnitten unten.

## Steam

### Zeitplan

- Steam-Direct-Gebühr: 100 US-$ pro App (wird nach 1.000 $ Umsatz verrechnet). Zwischen Zahlung und Release liegen **mindestens 30 Tage**.
- Die Store-Seite muss **mindestens 2 Wochen** als „Demnächst verfügbar“ öffentlich sein.
- Valve prüft Store-Seite und Build jeweils 3–5 Werktage; Valve rät, je 7 Werktage einzuplanen.
- Realistisch also: Gebühr zahlen → in Woche 1 Store-Seite zur Prüfung → in Woche 2 „Demnächst verfügbar“ → in Woche 3–4 Build zur Prüfung → frühestens nach 30 Tagen Release.

### Schritte

1. **Konto:** partner.steamgames.com → als Steamworks-Partner registrieren, Steuerformular (W-8BEN für Personen in DE), Bankdaten, Identitätsprüfung. Dann Steam-Direct-Gebühr zahlen → App-ID.
2. **Store-Seite** (App-Admin → Store-Seite bearbeiten):
   - Texte aus `store/texts/steam_de.txt` übernehmen.
   - Grafiken hochladen:

     | Steamworks-Feld | Datei | Maß |
     |---|---|---|
     | Header-Capsule | `store/steam/header_capsule_920x430.png` | 920×430 |
     | Kleine Capsule | `store/steam/small_capsule_462x174.png` | 462×174 |
     | Haupt-Capsule | `store/steam/main_capsule_1232x706.png` | 1232×706 |
     | Vertikale Capsule | `store/steam/vertical_capsule_748x896.png` | 748×896 |
     | Seitenhintergrund (optional) | `store/steam/page_background_1438x810.png` | 1438×810 |
     | Screenshots (mind. 5) | `store/steam/screenshots/*.jpg` | 1920×1080 |
     | Bibliothek-Capsule | `store/steam/library_capsule_600x900.png` | 600×900 |
     | Bibliothek-Header | `store/steam/library_header_920x430.png` | 920×430 |
     | Bibliothek-Hero (ohne Text) | `store/steam/library_hero_3840x1240.png` | 3840×1240 |
     | Bibliothek-Logo (transparent) | `store/steam/library_logo_transparent.png` | max. 1280×720 |
     | Community-Symbol | `store/steam/community_icon_184x184.jpg` | 184×184 |
     | Client-Symbol | `store/steam/client_icon.ico` | .ico |

   - Inhaltsumfrage inkl. KI-Offenlegung: Antworten stehen in `steam_de.txt`. Die Story-Stimmen sind mit Piper TTS erzeugt und **müssen** als vorab generierte KI-Inhalte angegeben werden.
   - Preis: Vorschlag **7,99 €** (entspricht der Play-Vollversion; auf Steam ist alles enthalten, was die Play-Vollversion freischaltet). Steam rechnet die anderen Währungen vor – prüfen und übernehmen.
   - Trailer: siehe „Trailer & Clips“. Ohne Trailer verkauft eine Seite deutlich schlechter.
3. **Zur Prüfung einreichen**, danach „Demnächst verfügbar“ schalten. Ab dann Wunschlisten sammeln (Link überall teilen).
4. **GodotSteam einbauen** (für DLC-Besitz, Overlay, später Erfolge):
   - GodotSteam als **GDExtension** für Godot 4.7 aus der Godot Asset Library oder von godotsteam.com installieren (`godot/addons/godotsteam/`).
   - Zum lokalen Testen `steam_appid.txt` mit der App-ID neben die EXE legen (wird beim Upload ausgeschlossen).
   - Lizenz von GodotSteam (MIT) in `ASSET_LICENSES.md` eintragen; `steam_api64.dll` gehört in den Build.
5. **DLC** (App-Admin → „DLC hinzufügen“, keine weitere Gebühr): je ein DLC für `pack_neon`, `pack_legends`, `pack_arenas`, `pack_weapons`, `supporter` mit Preisen aus `products.gd`. Die DLC-App-IDs in `products.gd` bei `steam_dlc` eintragen. Jedes DLC braucht eine eigene kleine Store-Seite (Capsules + Screenshots).
6. **Build:** in Godot Export-Preset „Steam“ → `builds/steam/`. In Steamworks → SteamPipe → Depots die Depot-ID ablesen, in `store/steampipe/app_build.vdf` und `depot_windows.vdf` eintragen, dann:
   ```powershell
   .\store\steampipe\upload.ps1 -SteamUser <dein-steamworks-login>
   ```
   Build in Steamworks → SteamPipe → Builds auf den Zweig `default` setzen, Startoptionen setzen (`PromptFighterUltimate.exe`), Build zur Prüfung einreichen.
7. **Vor Release testen:** Steam Deck (Touch, Controller), Remote Play Together mit einem zweiten Konto, ein DLC-Kauf mit einem Test-Key.

## Google Play

### Wichtig vorab

- Entwicklerkonto: einmalig 25 US-$, Identitätsprüfung.
- **Private Konten, die nach dem 13.11.2023 angelegt wurden, dürfen erst in die Produktion, nachdem ein geschlossener Test mit mindestens 12 Testern 14 Tage am Stück lief.** Fällt die Zahl unter 12, beginnen die 14 Tage neu. Danach Fragebogen zu Testern und Feedback. Tester früh suchen (Freunde, Discord, Familie – jeder braucht ein Google-Konto und muss den Opt-in-Link annehmen).
- **Ziel-API:** Neue Apps und Updates müssen seit 31.08.2026 **Android 16 (API 36)** als Ziel haben (Verlängerung bis 01.11.2026 beantragbar). In Godot unter Projekt → Exportieren → „Google Play“ → *Target SDK* prüfen und auf 36 setzen, falls der Standard niedriger ist.

### Schritte

1. **Upload-Schlüssel erzeugen** (einmalig, gut sichern – ohne ihn keine Updates):
   ```powershell
   keytool -genkeypair -v -keystore "$env:USERPROFILE\keys\pfu-upload.keystore" -alias pfu-upload -keyalg RSA -keysize 2048 -validity 10000
   ```
   In Godot: Editor-Einstellungen bzw. Export-Preset „Google Play“ → *Keystore Release* = diese Datei, Alias und Passwort. Godot speichert das in `godot/.godot/export_credentials.cfg` (gitignored). **Keystore und Passwort nie ins Repo.** Google Play App Signing beim Anlegen der App aktiviert lassen.
2. **Android-Build-Vorlage installieren:** Projekt → „Android-Build-Vorlage installieren“ (nötig für AAB und Plugins). Android SDK/JDK in den Editor-Einstellungen eintragen.
3. **Billing-Plugin:** „Godot Google Play Billing“ (github.com/godot-sdk-integrations/godot-google-play-billing) passend zu Godot 4.7 installieren. **Achtung:** `store.gd` nutzt die ältere Schnittstelle (`startConnection`, Signal `sku_details_query_completed`). Neuere Plugin-Versionen haben Methoden und Signale umbenannt. Nach dem Einbau mit einem Testkonto prüfen und `store.gd` gegebenenfalls anpassen.
4. **Exportieren:** Preset „Google Play“ → `builds/play/PromptFighterUltimate.aab`. Bei jedem Upload `version/code` um 1 erhöhen.
5. **App anlegen** (Play Console → App erstellen): Name „Prompt Fighters Ultimate“, Spiel, kostenlos, Standardsprache Deutsch.
6. **Store-Eintrag:** Texte aus `store/texts/play_de.txt`. Grafiken:

   | Play-Feld | Datei | Vorgabe |
   |---|---|---|
   | App-Symbol | `store/play/app_icon_512x512.png` | 512×512, 32-Bit-PNG, max. 1 MB |
   | Vorstellungsgrafik | `store/play/feature_graphic_1024x500.png` | 1024×500, ohne Alpha |
   | Smartphone-Screenshots | `store/play/screenshots/*.png` | 2–8 Stück, für Spiele-Empfehlungen mind. 3 im Querformat ab 1920×1080 |
   | Tablet-Screenshots (7"/10") | dieselben Screenshots | optional, verbessert die Sichtbarkeit auf Tablets |

7. **App-Inhalte** (Play Console → Richtlinien → App-Inhalte) – vorbereitete Antworten:
   - **Datenschutzerklärung:** `store/legal/datenschutz.html` ausfüllen und öffentlich hosten (z. B. GitHub Pages), URL eintragen.
   - **Werbung:** Nein.
   - **App-Zugriff:** Alle Funktionen ohne Anmeldung verfügbar.
   - **Einstufung (IARC-Fragebogen):** Kategorie „Spiel“. Gewalt: ja – Kampf zwischen menschenähnlichen und fantastischen Figuren. Blut: ja, in Finishern, abschaltbar. Sexuelle Inhalte, Drogen, Glücksspiel, Schimpfwörter: nein. Nutzerinteraktion/Teilen von Inhalten: nein. Digitale Käufe: ja. Standort: nein. Ehrlich antworten; zu erwarten ist etwa USK 12–16 / PEGI 12–16, je nach Darstellung der Finisher.
   - **Zielgruppe:** 13+ (nicht für Kinder; passt zur Datenschutzerklärung und vermeidet die Familienrichtlinien).
   - **Datensicherheit:** Keine Daten erhoben, keine Daten geteilt. Das Android-Preset hat kein Internet-Recht, es gibt keine Analyse und keine Werbung. Käufe verarbeitet Google Play selbst. Vor dem Absenden in der Play-Hilfe „Datensicherheit“ nachlesen, ob für die Billing-Bibliothek etwas anzugeben ist.
   - **Finanzfunktionen, Gesundheit, Behörden, Nachrichten:** jeweils „nein“.
8. **In-App-Produkte** anlegen (IDs und Texte in `play_de.txt`, müssen exakt mit `products.gd` übereinstimmen). Zum Testen Lizenztester eintragen (Einstellungen → Lizenztests).
9. **Interner Test** (bis 100 Tester, sofort verfügbar): Build hochladen, auf echten Geräten prüfen (Touch, Leistung, Käufe).
10. **Geschlossener Test:** mind. 12 Tester, 14 Tage. Feedback sammeln und in einem Update umsetzen – Google fragt danach.
11. **Produktion beantragen**, danach gestaffeltes Rollout (z. B. 20 % → 100 %).

## Trailer & Clips

Ein Trailer ist auf beiden Stores der wichtigste Faktor nach der Capsule. Empfehlung (60–90 s, 1920×1080, 60 fps, ohne HUD-Marker):

1. 0–5 s: sofort ein Treffer, der einen Gegner aus der Arena schleudert (kein Logo-Intro).
2. 5–25 s: 6–8 Signatur-Techniken im schnellen Wechsel (Vlad Fledermausgestalt, Grimbolt Zeitbombe, Echo Phasentausch, Vanguard Orbitalschlag, Kettenwart Seelenfessel, Medea Astralfluch, Treant Wurzelfessel).
3. 25–40 s: Fusionskammer – Satz eintippen, Kämpfer erscheint, kämpft sofort.
4. 40–55 s: Bosse und ein Story-Moment (Dantes Hölle/Himmel), ein vertonter Satz.
5. 55–70 s: Vier Spieler gleichzeitig, ein Finisher.
6. Ende: Logo, „Jetzt auf die Wunschliste“ (Steam) – 3 s.

Für die Steam-Beschreibung zusätzlich 3–6 s lange Clips einzelner Signaturen als WebM/GIF (max. ca. 3 MB).
Aufnahme: OBS mit dem Spiel im Vollbild; Musik nur aus den lizenzierten Spieldateien.

## Quellen

- Steam-Grafiken: partner.steamgames.com/doc/store/assets/standard, …/assets/libraryassets
- Steam-Prüfung: partner.steamgames.com/doc/store/review_process; „Coming Soon“ und 30 Tage: partner.steamgames.com/doc/store/coming_soon, partner.steamgames.com/steamdirect
- Play-Grafiken und Texte: support.google.com/googleplay/android-developer/answer/9866151
- Play-Ziel-API: developer.android.com/google/play/requirements/target-sdk
- Play-Testpflicht für neue private Konten: support.google.com/googleplay/android-developer (Hilfe „App-Tests für neue private Entwicklerkonten“)
