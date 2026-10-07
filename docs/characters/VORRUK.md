# VORRUK, der Sternenkoloss

Konzept nach der Concept-Art-Vorlage des Nutzers (brauner Koloss mit Fleischplatten und langen Krallenarmen; daneben eine lila-türkis gestreifte Alien-Hündin). Im Spiel umgesetzt in Paket 9.

## 1. Kurzüberblick
Vorruk ist ein drei Meter großer Außerirdischer, der mit seinem Sternenschiff in einem Hain abgestürzt ist. Er spricht kaum, versteht wenig und hat nur eins: seine Hündin **Zirra**, die mit ihm gefallen ist. Im Kampf ist er der schwerste Kämpfer des Spiels, mit gepanzerten Schlägen und enormer Reichweite. Zirra jagt die Gegner für ihn.

## 2. Charakterdaten
| | |
|---|---|
| Name | Vorruk, „der Sternenkoloss“ |
| Alter | unbekannt (nach eigener Zählung „drei Sternenwechsel“) |
| Geschlecht | männlich |
| Spezies | Ur-Koloss von einer fernen Welt (Plattenhaut, zwei Herzen) |
| Rolle/Klasse | Superschwergewicht / Beschützer |
| Welt | Science-Fantasy: Alien in einer Fantasywelt, die ihn für ein Monster hält |
| Moral | sanft und loyal. Er greift nie zuerst an. Seine Schwäche: Heimweh lähmt ihn. |
| Spielwerte | Vitalität 32, Kraft 29, Rüstung 24, Tempo 6, Technik 9 · Gewicht 1,48 (schwerster Kämpfer) |

## 3. Visuelles Design
- **Gesicht:** klein im Verhältnis zum Körper, tief liegende Augen mit violettem Schimmer, ein schwerer Brauenwulst. Über dem Schädel liegen gefaltete Hautwülste wie Gesteinsschichten.
- **Haut:** braun wie gebrannter Ton, mit cremefarbenen Bauch- und Innenflächen. Überlappende Fleischplatten auf Rücken und Schultern.
- **Körper:** drei Meter groß, mit überlangen Armen, die bis zu den Knien reichen. Vier Krallen pro Hand, kurze, stämmige Beine mit Klauenfüßen. Er steht leicht vornübergebeugt.
- **Silhouette:** ein umgekehrtes Dreieck (riesiger Oberkörper, schmale Hüfte, breite Füße). Unverwechselbar.
- **Kostüm:** keins. Seine Platten sind Rüstung genug. Zirras Halsband aus Sternenmetall trägt er als Armreif.
- **Zeichen:** Brandnarben auf der Brust vom Absturz.
- **Farbschema:** Ton-Braun und Creme, violettes Randlicht. Zirra setzt den Kontrast mit Lila und Türkis.

## 4. Anatomie und Skelett
- **Skelett:** zweibeinig, mit zusätzlichen Plattenknochen auf Rücken und Schultern (dermaler Panzer). Die Arme haben ein verlängertes Ellenbein, die Hände vier Finger mit Krallen.
- **Zwei Herzen:** Er ist sehr ausdauernd, aber langsam im Antritt.
- **Bewegung:** Schwere Schritte, der Boden staubt. Beim Rennen stützt er sich ab und zu auf die Knöchel. Er springt kurz und landet schwer. Im Kampf schwingt er weit mit den langen Armen, die Platten fangen Treffer ab (Rüstung bei Smashes). Statt auszuweichen dreht er die Rückenplatten zum Gegner.
- **Für die Animation:** Mixamo-Brute-Rig (`mutant_titan`). Platten und Krallen sind steif an den Knochen befestigt und werden im Code erzeugt.

## 5. Einzigartige Besonderheit: „Sternenpanzer“
- **Herkunft:** Auf seiner Heimatwelt regnen Meteore. Sein Volk wuchs mit Panzerplatten auf.
- **Funktion:** Seine schweren Angriffe haben Rüstung, das heißt, Treffer unterbrechen sie nicht. Das Abwärts-Spezial „Plattenpanzer“ gibt ihm 3 s lang Rüstung gegen alles.
- **Stärke:** Er setzt Angriffe durch, wird kaum weggeschleudert und hat sehr viel Reichweite.
- **Schwächen:** Er ist der langsamste Kämpfer, hat nur einen Luftsprung und ist ein großes Ziel, verwundbar für Würfe und Zoner.
- **Ausbaumöglichkeiten:** „Meteorhaut“ (Rüstung wirft Angreifer zurück), „Zwei Herzen“ (heilt sich bei niedrigem Leben einmal).

## 6. Waffen und Fähigkeiten
**Waffe:** die Krallen, je vier gebogene Klauen pro Hand, hart wie Obsidian.
**Kampfstil:** Er hält Abstand mit Reichweite, schlägt gepanzert durch, und Zirra setzt den Gegner unter Druck.

| Angriff | Wirkung | Visuell | Taktik |
|---|---|---|---|
| Krallenhieb (Jab) | weiter Schlag mit Rüstung | Krallenspur | Raum kontrollieren |
| Langarm (→Tilt) | 2,9 m Reichweite | der Arm streckt sich weit | Gegner auf Abstand halten |
| Plattenheber (↑Tilt) | Aufwärtsschlag | Platten klappen auf | Luftabwehr |
| Bodenkralle (↓Tilt) | flacher Hieb | Erdfurchen | trifft niedrig |
| Sternenschmetterer (→Smash) | stärkster Smash im Spiel | Druckwelle | KO-Schlag mit Rüstung |

**Spezialfähigkeiten:**
1. **Zirra, hol sie!** (Signatur): Die Hündin rennt los, springt Fliegenden hinterher und beißt immer wieder.
2. **Kolosssprung** (↑Spezial): Sprung mit Rundumtreffer.
3. **Plattenpanzer** (↓Spezial): 3 s Rüstung.

**Ultimative Fähigkeit / Finisher: „HEIMWEH DER STERNE“** (↓ ↓ ← Schlag). Vorruk hebt den Gegner hoch, Zirra heult, und er wirft ihn in den Himmel, dorthin, wo er selbst herkommt.

## 7. Helfertier: ZIRRA, die Sternenhündin
- **Spezies:** Sternenhündin. Sie kombiniert drei Elemente: einen schlanken Hundekörper, leuchtende Türkisstreifen (Biolumineszenz) und Ohren, die wie Antennen Schwingungen spüren.
- **Aussehen:** so groß wie ein Wolf. Das Fell ist violett, die Streifen glühen türkis, die Augen leuchten, der Schwanz ist lang und spitz.
- **Persönlichkeit:** verspielt, eifersüchtig und unerschrocken.
- **Bindung:** Sie lag beim Absturz unter Vorruk und er hat sie mit seinem Körper geschützt. Seitdem weicht sie nicht von ihm.
- **Fähigkeiten:** 1) *Sternenbiss* (wiederholte Bisse). 2) *Sprung* (folgt Gegnern in die Luft). 3) *Heulen* (Finisher, Erzählung).
- **Passiv:** Sie läuft immer zum nächsten Gegner, mit 7,5 m/s.
- **Schwäche:** Sie verschwindet nach 3,4 s. Es kann immer nur eine Zirra geben.
- **Beschwörung:** Vorruk pfeift tief, die Erde summt, und Zirra springt aus seinem Schatten.
- **Kommunikation:** Knurren, Bellen und Leuchtmuster in den Streifen (schnell blinkend: Freude).
- **Entwicklung:** „Rudelmutter“, sie bekommt Welpen aus Licht.

## 8. Hintergrundgeschichte
- **Herkunft:** eine Meteoritenwelt weit draußen. Vorruk war Wächter eines Sternenschiffs.
- **Beziehungen:** Zirra. Auf der neuen Welt kommen Lepora (Jägerin) und der Mutant (ebenfalls ein „Monster“) dazu.
- **Wendepunkt:** der Absturz im Hain.
- **Größter Verlust:** seine Welt, seine Sprache, sein Schiff.
- **Größtes Ziel:** nach Hause, so glaubt er. In Wahrheit: ein Zuhause.
- **Größte Angst:** dass Zirra etwas passiert.
- **Innerer Konflikt:** Er schaut nur nach oben und sieht nicht, wer unten auf ihn wartet.
- **Verbindung zur Welt:** Er ist der Fremde, den alle fürchten, bis sie ihn kennen.
- **Entwicklung (Legende „Der Weg nach Hause“):** Ein Jäger hält ihn für ein Monster, der Mutant fordert ihn, Bel Marduk bietet ihm das Schiff gegen eine Schlacht, und Vorruk baut stattdessen ein Haus im Krater.

## 9. Gameplay-Konzept
- **Distanz:** mittel (2–3 m). Zirra übernimmt die Distanz.
- **Stärken:** Reichweite, Rüstung, Schaden, und er überlebt viel.
- **Schwächen:** Tempo, Luftkampf, ein großes Ziel, verwundbar für Würfe.
- **Ressource:** Super-Leiste. Zirra hat 4 s Abklingzeit, der Plattenpanzer 6,5 s.
- **Rolle im Team:** Frontkämpfer und Beschützer.
- **Builds:** 1) Bollwerk (Panzer, Konter durch Rüstung). 2) Rudel (Zirra so oft wie möglich). 3) Abrissbirne (nur Smashes).
- **Synergie mit Zirra:** Zirra hält den Gegner beschäftigt, Vorruk schlägt gepanzert zu.
- **Konter:** schnelle Kämpfer mit Luftangriffen, Würfe und Zoner, die Zirra ausweichen.

## 10. Dialoge
- **Kampfsprüche:** „Vorruk … stark.“ · „Zirra! Hol!“ · „Klein. Du. Sehr klein.“ · „Sterne … weit weg.“ · „Nicht Monster. Vorruk.“
- **Emotional:** „Zirra … alles was Vorruk hat.“ · „Vorruk war hochschauen so lange … nicht gesehen, was unten ist.“ · „Haus. Mit Tür für Riesen.“
- **Zu Zirra:** „Gutes Mädchen.“ · „Nicht beißen die Kinder, Zirra.“ · „Wir zwei. Immer.“
- **Ikonischer Satz:** „Nach Hause ist, wo Zirra schläft.“
- **Vorstellung:** Nacht im Hain. Ein Krater glüht. Etwas Riesiges richtet sich auf, Schatten fallen über die Bäume. Ein lila Licht springt heraus und bellt. Vorruk legt die Kralle sanft auf Zirras Kopf und schaut zu den Sternen.

## 11. Concept-Art-Beschreibung
Monumentale Totale in einer Hochebene mit Felsnadeln, ein Riesenbaum im Dunst, Vorruk im Vordergrund, Zirra zu seinen Füßen, dazu Begleitkreaturen (ein Insektendrache, ein kleiner Holzkobold). Weiches Tageslicht durch Dunst, Haut mit Subsurface-Streuung, glänzende Krallen, biolumineszente Hundestreifen. Die Silhouette lebt von den Armen, die bis zum Boden reichen.
- **Kampfpose:** breitbeinig, ein Arm zum Schlag erhoben, die Platten aufgestellt.
- **Beschwörungspose:** Er kniet, die Kralle am Boden, Zirra springt aus dem Schatten.

## 12. 3D- und Animationshinweise
- **Modell im Spiel:** Mixamo-Körper `mutant_titan` mit Recolor (Ton-Braun) und Hautton. Platten, Krallen und Kopfwülste werden in `hero_gear.gd` erzeugt. Größe wie die Schwergewichte (2,15 m Spielhöhe).
- **Zirra:** Projektilform `alien_hound` (`weapon_models.gd`), im Kampf 1,6-fach vergrößert. Sie schaut in Laufrichtung und wippt beim Laufen.
- **Audio:** `sfx/hound` (Knurren und Bellen, synthetisch).

## 13. Wichtigste Designmerkmale
Arme bis zum Boden mit vier Krallen · überlappende Fleischplatten · kleiner Kopf mit Wülsten · Ton-Braun und Creme · Zirra in Lila und Türkis.
