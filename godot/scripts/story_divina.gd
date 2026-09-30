extends RefCounted
## Second story campaign: "DIE GÖTTLICHE PRÜFUNG" – after Dante's Divine Comedy.
## The wanderer loses his way in a dark forest, is led by the poet Vergil down through the
## nine circles of hell (ten demon princes, one per vice), climbs out past the frozen
## Lucifer and is then led by Beatrice up through the nine spheres of heaven, where the
## nine choirs of angels test him. Same step format as story_data.gd; fights against bosses
## use cast entries with "boss" (bosses.gd). Chapters carry a realm (earth, hell, heaven);
## "start" marks a realm's first chapter, which is always unlocked.

const TITLE := "DIE GÖTTLICHE PRÜFUNG"
const SUBTITLE := "Erde → Hölle → Himmel. Zehn Fürsten der Hölle, neun Chöre der Engel. Nach Dante Alighieri."

const CAST := {
	"dante": {"name": "DANTE", "title": "Der Wanderer", "color": "f7c844", "prompt": "Kairo der Sturmmönch mit Solar-Kanone"},
	"vergil": {"name": "VERGIL", "title": "Der Dichter aus dem Limbus", "color": "ff9a4a", "prompt": "Erzmagier Pyrus Feuerzauberer mit Meteorschlag und Flammenstab"},
	"beatrice": {"name": "BEATRICE", "title": "Das Licht, das ruft", "color": "ffe26a", "prompt": "Strahlende Moe Valkyrie Paladin Kriegerin mit Lichtflügeln und Rapier"},
	"woelfin": {"name": "DIE WÖLFIN", "title": "Hunger ohne Ende", "color": "a8a29e", "prompt": "Reaper Skeleton Hound nether beast"},
	"charon": {"name": "CHARON", "title": "Fährmann des Acheron", "color": "94a3b8", "prompt": ""},
	# Princes of hell.
	"ahriman": {"name": "AHRIMAN", "title": "Die leere Hülle · Materialismus", "color": "b91c1c", "prompt": "", "boss": "ahriman"},
	"lilith": {"name": "LILITH", "title": "Die Verführerin · Verführung", "color": "f472b6", "prompt": "", "boss": "lilith"},
	"asmodeus": {"name": "ASMODEUS", "title": "Fürst der Wollust", "color": "e11d48", "prompt": "", "boss": "asmodeus"},
	"beelzebub": {"name": "BEELZEBUB", "title": "Herr der Fliegen · Völlerei", "color": "84cc16", "prompt": "", "boss": "beelzebub"},
	"mammon": {"name": "MAMMON", "title": "Der Gierige · Gier", "color": "facc15", "prompt": "", "boss": "mammon"},
	"baphomet": {"name": "BAPHOMET", "title": "Der Zorn · Ungleichgewicht", "color": "f97316", "prompt": "", "boss": "baphomet"},
	"belphegor": {"name": "BELPHEGOR", "title": "Die Trägheit", "color": "a3a3a3", "prompt": "", "boss": "belphegor"},
	"bel_marduk": {"name": "BEL MARDUK", "title": "Der Krieg", "color": "dc2626", "prompt": "", "boss": "bel_marduk"},
	"leviathan": {"name": "LEVIATHAN", "title": "Der Neid", "color": "38bdf8", "prompt": "", "boss": "leviathan"},
	"lucifer": {"name": "LUZIFER", "title": "Der Gefallene · Hochmut", "color": "7dd3fc", "prompt": "", "boss": "lucifer"},
	# Choirs of heaven.
	"angelus": {"name": "ANGELUS", "title": "Wächter des Mondes", "color": "bfe3ff", "prompt": "", "boss": "angelus"},
	"michael": {"name": "MICHAEL", "title": "Erzengel des Schwertes", "color": "ffcf4a", "prompt": "", "boss": "michael"},
	"principatus": {"name": "PRINCIPATUS", "title": "Fürst der Völker", "color": "ff6b8a", "prompt": "", "boss": "principatus"},
	"potestas": {"name": "POTESTAS", "title": "Die Gewalt des Himmels", "color": "ffa94d", "prompt": "", "boss": "potestas"},
	"virtus": {"name": "VIRTUS", "title": "Die Tugend", "color": "9be7ff", "prompt": "", "boss": "virtus"},
	"dominatio": {"name": "DOMINATIO", "title": "Die Herrschaft", "color": "e9d5ff", "prompt": "", "boss": "dominatio"},
	"ophan": {"name": "OPHANIEL", "title": "Der Räderthron", "color": "ffd24a", "prompt": "", "boss": "ophan"},
	"cherub": {"name": "KERUVIM", "title": "Wächter des Tores", "color": "ff8a1f", "prompt": "", "boss": "cherub"},
	"seraph": {"name": "SERAPHAEL", "title": "Das brennende Auge", "color": "ff3b1f", "prompt": "", "boss": "seraph"},
	"stimme": {"name": "DIE STIMME", "title": "Die Liebe, die die Sterne bewegt", "color": "fff7e0", "prompt": ""},
}

## A boss chapter: hero + guide meet the boss, talk, fight, aftermath.
static func _boss_chapter(id: String, realm: String, title: String, sub: String, arena: String, guide: String, boss: String,
		lines_before: Array, qte: Dictionary, goal: String, lines_after: Array, start: bool = false) -> Dictionary:
	var steps: Array = [
		{"t": "stage", "cast": [{"id": "dante", "x": -4.0, "facing": 1}, {"id": guide, "x": -5.8, "facing": 1}, {"id": boss, "x": 4.2, "facing": -1}]},
		{"t": "cam", "shot": "sky", "time": 0.01},
		{"t": "title", "text": title, "sub": sub},
	]
	steps.append_array(lines_before)
	if not qte.is_empty(): steps.append(qte)
	steps.append({"t": "fight", "cast": ["dante", guide, boss], "teams": [0, 0, 9], "lives": [3, 3, 1],
		"qte": str(qte.get("flag", "")), "goal": goal})
	steps.append({"t": "stage", "cast": [{"id": "dante", "x": -1.8, "facing": 1}, {"id": guide, "x": -3.4, "facing": 1}, {"id": boss, "x": 3.2, "facing": -1}]})
	steps.append({"t": "cam", "shot": "wide", "time": 0.01})
	steps.append_array(lines_after)
	return {"id": id, "realm": realm, "title": sub, "arena": arena, "start": start, "steps": steps}

static func _say(who: String, text: String) -> Dictionary:
	return {"t": "say", "who": who, "text": text}

static func _narr(text: String) -> Dictionary:
	return {"t": "narrate", "text": text}

static func _qte(kind: String, keys: Array, text: String, flag: String, ok_line: String, fail_line: String) -> Dictionary:
	return {"t": "qte", "kind": kind, "keys": keys, "time": 1.4, "count": 12, "text": text, "flag": flag,
		"success": [{"t": "fx", "kind": "flash"}, _say("dante", ok_line)],
		"fail": [{"t": "fx", "kind": "shake"}, _say("dante", fail_line)]}

static func chapters() -> Array:
	var list: Array = []
	# ── PROLOG · ERDE ──
	list.append({"id": "d0", "realm": "earth", "title": "Der dunkle Wald", "arena": "mystic_grove", "start": true, "steps": [
		{"t": "stage", "cast": [{"id": "dante", "x": -3.0, "facing": 1}, {"id": "woelfin", "x": 7.5, "facing": -1}, {"id": "vergil", "x": -9.0, "facing": 1}]},
		{"t": "vanish", "who": 2},
		{"t": "cam", "shot": "sky", "time": 0.01},
		{"t": "title", "text": "PROLOG", "sub": "Der dunkle Wald"},
		_narr("In der Mitte seines Lebensweges fand sich der Kämpfer Dante in einem dunklen Wald wieder – denn der rechte Weg war verloren."),
		_narr("Er hatte jeden Gegner besiegt, jede Arena gewonnen. Und doch war da nur Leere, wo einst ein Ziel gewesen war."),
		{"t": "cam", "shot": "close", "who": 0, "time": 1.6},
		_say("dante", "Wie bin ich hierher gekommen? Ich weiß nur noch den Jubel … und dann nichts mehr."),
		_narr("Auf dem Hügel vor ihm brach das Morgenlicht durch die Bäume. Doch drei Bestien versperrten den Weg: ein Leopard, ein Löwe – und eine ausgehungerte Wölfin."),
		{"t": "move", "who": 1, "x": 3.0, "time": 1.4},
		{"t": "cam", "shot": "low", "who": 1, "time": 0.8},
		{"t": "fx", "kind": "shake"},
		_say("woelfin", "Grrraaah …"),
		_say("dante", "Leopard und Löwe weichen zurück. Aber diese Wölfin … sie ist nur Hunger. Sie lässt niemanden vorbei."),
		_qte("press", ["jump"], "DIE WÖLFIN SPRINGT – WEICH AUS!", "d0_wolf", "Zu langsam, Bestie!", "Ihre Zähne … nur ein Kratzer. Weiter!"),
		{"t": "fight", "cast": ["dante", "woelfin"], "lives": [3, 2], "qte": "d0_wolf", "goal": "Vertreibe die Wölfin!"},
		{"t": "stage", "cast": [{"id": "dante", "x": -1.6, "facing": 1}, {"id": "woelfin", "x": 6.5, "facing": 1}, {"id": "vergil", "x": -6.0, "facing": 1}]},
		{"t": "cam", "shot": "wide", "time": 0.01},
		_narr("Die Wölfin wich in den Schatten zurück. Doch schon wieder drängte die Dunkelheit heran."),
		{"t": "move", "who": 2, "x": -3.6, "time": 1.2},
		{"t": "cam", "shot": "two", "who": 0, "who2": 2, "time": 1.0},
		_say("vergil", "Du wirst sie nicht besiegen, indem du den Hügel hinaufrennst. Wer das Licht erreichen will, muss zuerst hinabsteigen."),
		_say("dante", "Wer bist du? Ein Geist? Ein Mensch?"),
		_say("vergil", "Einst ein Dichter. Nun ein Schatten aus dem Limbus. Man nannte mich Vergil."),
		_say("vergil", "Eine Frau aus dem Himmel schickt mich – Beatrice. Sie hat um dich geweint. Ich soll dich führen: hinab durch die Hölle, hinauf über den Läuterungsberg, bis sie dich selbst empfängt."),
		_say("dante", "Durch die Hölle … Wenn es der einzige Weg ist, dann geh voran, Meister."),
		_narr("Und so begann die Reise – hinab in das Reich, aus dem niemand zurückkehrt."),
	]})
	# ── INFERNO ──
	list.append(_boss_chapter("h1", "hell", "INFERNO · KREIS I", "Das Tor und der Limbus", "hell_gate", "vergil", "ahriman", [
		_narr("Über dem Tor standen Worte, dunkel wie getrocknetes Blut: LASST, DIE IHR EINTRETET, ALLE HOFFNUNG FAHREN."),
		_say("charon", "Weh euch, verderbte Seelen! Ihr hofft, den Himmel je zu sehen? Ich bringe euch ans andre Ufer – in ewige Nacht, in Glut und Eis."),
		_say("vergil", "Schweig, Fährmann. Es ist dort oben so gewollt, wo man vermag, was man will. Frag nicht weiter."),
		_narr("Hinter dem Acheron lag der Limbus: ein fahles Land ohne Qual und ohne Hoffnung. Und darüber schwebte ein riesiges, steinernes Gesicht."),
		{"t": "cam", "shot": "close", "who": 2, "time": 1.2},
		_say("ahriman", "Ihr Lebenden. Ihr habt Dinge gesammelt, als wären sie Seelen. Häuser. Gold. Ruhm. Sieh mich an – ich bin, was davon übrig bleibt."),
		_say("ahriman", "Eine Hülle. Glänzend. Leer. Werde wie ich, Kämpfer. Es tut nicht weh. Es tut gar nichts mehr."),
		_say("dante", "Ich hatte alles, was man sammeln kann. Und es war nichts. Das weiß ich jetzt – dank dir."),
	], _qte("mash", ["standard"], "DIE LEERE ZIEHT DICH AN – WEHR DICH!", "h1_void", "Ich gehöre dir nicht!", "Sie zerrt an mir … aber ich stehe noch."),
		"Zerschlage die leere Hülle AHRIMAN!", [
		_say("ahriman", "Ein Riss … in mir … da ist … nichts …"),
		{"t": "vanish", "who": 2},
		_say("vergil", "Materialismus ist die erste Täuschung. Die Hölle beginnt dort, wo man die Dinge mehr liebt als das Leben. Komm – der Wind ruft uns."),
	], true))
	list.append(_boss_chapter("h2", "hell", "INFERNO · KREIS II", "Der Sturm der Verführung", "hell_flames", "vergil", "lilith", [
		_narr("Im zweiten Kreis heulte ein Sturm, der nie ruht. Er trug die Seelen der Liebenden, die sich ihrer Begierde ergaben – hin und her, auf und ab, ohne Rast."),
		_say("dante", "Sie rufen nach einander und können sich nie erreichen …"),
		{"t": "cam", "shot": "close", "who": 2, "time": 1.2},
		_say("lilith", "Warum so traurig, Wanderer? Bleib bei mir im Wind. Hier musst du nie wieder kämpfen. Nie wieder allein sein."),
		_say("vergil", "Sieh nicht in ihre Augen. Sie war die Erste, die sich weigerte zu dienen. Sie verführt, um zu besitzen."),
		_say("lilith", "Ach, Dichter. Du bist nur neidisch, dass dich niemand je so gerufen hat."),
	], _qte("sequence", ["jump", "block", "standard"], "WIDERSTEHE IHREM LOCKRUF!", "h2_charm", "Deine Stimme hat keine Macht über mich!", "Beinahe … Nein. Ich will selbst gehen."),
		"Widerstehe LILITH!", [
		_say("lilith", "Du … hättest … bleiben können …"),
		_say("dante", "Ein Leben im Wind ist kein Leben. Weiter, Meister."),
	]))
	list.append(_boss_chapter("h3", "hell", "INFERNO · KREIS II", "Der Fürst der Wollust", "hell_flames", "vergil", "asmodeus", [
		_narr("Tiefer im Sturm, wo der Wind heißer wurde, humpelte eine Gestalt mit einem Stock durch die Flammen – lächelnd, als gehöre ihr jede Seele hier."),
		{"t": "cam", "shot": "close", "who": 2, "time": 1.2},
		_say("asmodeus", "Lilith verführt. Ich verzehre. Die Begierde ist ein Feuer, Wanderer – und ich bin ihr Brennholz, ihr Blasebalg, ihr Fürst."),
		_say("asmodeus", "Jede Seele hier hat sich selbst verkauft. Für einen Blick. Einen Kuss. Eine Nacht. Was ist dein Preis?"),
		_say("dante", "Ich habe keinen. Nicht mehr."),
	], {}, "Lösche das Feuer des ASMODEUS!", [
		_say("asmodeus", "Kein Preis … Dann bist du … wertlos … für mich …"),
		_say("vergil", "Gut. Wer nichts mehr begehrt, den kann niemand kaufen. Doch vor uns wartet der Hunger."),
	]))
	list.append(_boss_chapter("h4", "hell", "INFERNO · KREIS III", "Der ewige Regen", "hell_flames", "vergil", "beelzebub", [
		_narr("Im dritten Kreis fiel ein kalter, schmutziger Regen, schwer und ewig. Die Seelen der Maßlosen lagen im Schlamm, und über ihnen summte es."),
		_say("dante", "Dieses Geräusch … Tausende Fliegen."),
		{"t": "cam", "shot": "close", "who": 2, "time": 1.2},
		_say("beelzebub", "Bssssss … Frisches Fleisch. Lebendes Fleisch. Die Völlerei ist der ehrlichste Hunger, Wanderer. Man frisst, bis nichts mehr übrig ist – und dann frisst man sich selbst."),
		_say("vergil", "Der Herr der Fliegen. Einst ein Gott, dem man Opfer brachte. Nun nur noch Hunger mit Flügeln."),
	], _qte("mash", ["special"], "DER SCHWARM HÜLLT DICH EIN – BRENN IHN WEG!", "h4_swarm", "Weg mit euch!", "Sie beißen … aber ich sehe noch den Weg."),
		"Besiege BEELZEBUB, den Herrn der Fliegen!", [
		_say("beelzebub", "Nicht … satt … nie … satt …"),
		_say("dante", "Es gibt Hunger, den kein Essen stillt. Ich glaube, ich verstehe langsam, wohin wir gehen."),
	]))
	list.append(_boss_chapter("h5", "hell", "INFERNO · KREIS IV", "Die Last des Goldes", "hell_city", "vergil", "mammon", [
		_narr("Im vierten Kreis wälzten die Geizigen und die Verschwender schwere Lasten gegeneinander, prallten zusammen und schrien: »Warum hältst du fest?« – »Warum wirfst du weg?«"),
		{"t": "cam", "shot": "close", "who": 2, "time": 1.2},
		_say("mammon", "Pape Satàn, pape Satàn aleppe! Wer wagt es, meine Schatzkammer zu betreten, ohne zu bezahlen?"),
		_say("mammon", "Alles hat einen Preis, Kämpfer. Deine Siege. Deine Freunde. Deine Seele. Ich führe über alles Buch – und du bist tief in meiner Schuld."),
		_say("vergil", "Er hat die Welt gelehrt, dass Schulden Ketten sind. Lass dich nicht von seinen Ketten fassen."),
	], {}, "Brich MAMMONs Ketten der Gier!", [
		_say("mammon", "Meine Münzen … sie rollen weg … meine … MEINE …"),
		_say("dante", "Er hält seinen Schatz noch im Fallen fest. Welch ein Elend."),
	]))
	list.append(_boss_chapter("h6", "hell", "INFERNO · KREIS V", "Der Sumpf des Zorns", "hell_city", "vergil", "baphomet", [
		_narr("Der Styx lag schwarz und brodelnd vor den Mauern der Stadt Dis. Darin kämpften die Zornigen gegeneinander – mit Fäusten, Zähnen, ohne Ende."),
		{"t": "cam", "shot": "close", "who": 2, "time": 1.2},
		_say("baphomet", "Oben wie unten! Licht wie Dunkel! Ich bin das Gleichgewicht – und ich habe es zerbrochen! ZORN ist das Einzige, was ehrlich ist!"),
		_say("dante", "Ich kenne diesen Zorn. Er hat mich durch jede Arena getragen. Und er hat mich hierher gebracht."),
		_say("vergil", "Dann besiege ihn nicht mit Zorn. Besiege ihn mit Ruhe."),
	], _qte("press", ["block"], "BAPHOMETS HÖRNER – HALTE STAND!", "h6_horns", "Ich bleibe ruhig.", "Sein Zorn trifft mich … aber er reißt mich nicht mit."),
		"Stelle das Gleichgewicht wieder her – besiege BAPHOMET!", [
		_say("baphomet", "Warum … bist du … nicht wütend …?"),
		_say("dante", "Weil ich endlich weiß, gegen wen ich wirklich kämpfe."),
	]))
	list.append(_boss_chapter("h7", "hell", "INFERNO · VOR DEN MAUERN VON DIS", "Die Trägheit des Herzens", "hell_city", "vergil", "belphegor", [
		_narr("Unter dem Schlamm des Styx lagen die Trägen – jene, die nie etwas wagten, und seufzten Blasen an die Oberfläche. Vor dem Tor der Stadt thronte ihr Fürst."),
		{"t": "cam", "shot": "close", "who": 2, "time": 1.2},
		_say("belphegor", "Mmh … Wozu weitergehen? Wozu kämpfen? Setz dich. Ruh dich aus. Morgen ist auch noch ein Tag. Und übermorgen. Und die Ewigkeit."),
		_say("dante", "Meine Beine werden schwer … so schwer …"),
		_say("vergil", "Das ist seine Macht! Er muss nicht aufstehen – er lässt dich einfach aufgeben. Beweg dich, Dante!"),
	], _qte("mash", ["jump"], "DIE TRÄGHEIT LÄHMT DICH – BEWEG DICH!", "h7_sloth", "Ich stehe auf!", "Langsam … aber ich komme vorwärts."),
		"Überwinde BELPHEGOR, die Trägheit!", [
		_say("belphegor", "Du … hättest … einfach … sitzen … bleiben … können …"),
		_narr("Ein Bote des Himmels öffnete mit einem Stab das Tor von Dis. Kein Dämon wagte, sich ihm in den Weg zu stellen."),
	]))
	list.append(_boss_chapter("h8", "hell", "INFERNO · KREIS VII", "Der Strom aus Blut", "hell_flames", "vergil", "bel_marduk", [
		_narr("Im siebten Kreis floss der Phlegethon – ein Strom aus kochendem Blut. Darin standen die Gewalttäter, Tyrannen und Kriegsherren, so tief, wie ihre Schuld war."),
		{"t": "cam", "shot": "close", "who": 2, "time": 1.2},
		_say("bel_marduk", "Ich war ein Gott, bevor eure Städte Namen hatten. Jede Schlacht wurde in meinem Namen geschlagen. Jeder Speer trug meinen Segen."),
		_say("bel_marduk", "Du bist ein Kämpfer. Du gehörst zu mir. Knie nieder, und ich gebe dir tausend Kriege."),
		_say("dante", "Ich habe genug gekämpft, um zu wissen: Kein Krieg hat mir je etwas gegeben, das ich behalten konnte."),
	], {}, "Beende den ewigen Krieg – besiege BEL MARDUK!", [
		_say("bel_marduk", "Ein Kämpfer … der den Krieg ablehnt … unmöglich …"),
		_say("vergil", "Nur der tiefste Abgrund liegt noch vor uns. Das Übelsack – und darunter das Eis."),
	]))
	list.append(_boss_chapter("h9", "hell", "INFERNO · KREIS VIII", "Die Gräben des Betrugs", "hell_city", "vergil", "leviathan", [
		_narr("Der achte Kreis bestand aus zehn Gräben, einer grausamer als der andere. In ihnen die Betrüger, Heuchler, Diebe – und in den dunklen Wassern wand sich etwas Riesiges."),
		{"t": "cam", "shot": "close", "who": 2, "time": 1.2},
		_say("leviathan", "Ich sehe, was du hast, Wanderer. Einen Führer. Einen Weg. Eine, die um dich weint. Warum du? Warum nicht ICH?"),
		_say("leviathan", "Der Neid ist das Meer, in dem alle Betrüger schwimmen. Ich will alles, was du bist – und ich nehme es mir."),
		_say("dante", "Du kannst meinen Weg nicht stehlen. Du müsstest ihn selbst gehen."),
	], _qte("sequence", ["jump", "special", "standard"], "DIE FLUT BRICHT HEREIN!", "h9_flood", "Über die Welle!", "Das Wasser reißt mich mit – aber ich halte mich fest."),
		"Bezwinge LEVIATHAN, den Neid!", [
		_say("leviathan", "Warum … hast … DU … es …"),
		_say("vergil", "Jetzt, Dante. Jetzt kommt der Grund aller Dinge. Nimm allen Mut zusammen."),
	]))
	list.append(_boss_chapter("h10", "hell", "INFERNO · KREIS IX", "Cocytus – das ewige Eis", "cocytus", "vergil", "lucifer", [
		_narr("Am tiefsten Punkt der Welt brannte kein Feuer. Dort war nur Eis. Die Verräter steckten darin – bis zum Hals, bis über die Augen, ganz und gar."),
		_narr("Und in der Mitte, halb im Eis gefangen, schlug eine riesige Gestalt ihre Flügel. Jeder Schlag erzeugte den eisigen Wind, der den See gefrieren ließ."),
		{"t": "cam", "shot": "low", "who": 2, "time": 1.4},
		{"t": "fx", "kind": "shake"},
		_say("lucifer", "Ein Lebender. Hier. Nach all den Äonen."),
		_say("lucifer", "Ich war der Schönste von allen. Der Lichtträger. Ich stand zur Rechten des Throns – und wollte nur, was mir zustand: selbst Gott zu sein."),
		_say("lucifer", "Hochmut, nennen sie es. Ich nenne es Wahrheit. Und du, Kämpfer – bist du nicht auch nur hier, weil du glaubtest, du bräuchtest niemanden?"),
		_say("dante", "Vielleicht war ich wie du. Aber ich bin nicht allein gekommen."),
		_say("vergil", "Hier endet die Hölle, Dante. Und hier endet mein Weg an deiner Seite. Lass uns ihn gemeinsam beenden."),
	], _qte("sequence", ["block", "jump", "special", "standard"], "DER EISWIND DER SECHS FLÜGEL!", "h10_ice", "Das Eis bricht!", "Die Kälte kriecht in mich … aber mein Herz brennt noch."),
		"ENDKAMPF DER HÖLLE: Besiege LUZIFER!", [
		_say("lucifer", "Das Licht … in dir … es ist … nicht deins … es wurde … dir geschenkt …"),
		_say("dante", "Ja. Und das ist der Unterschied zwischen uns."),
		{"t": "fx", "kind": "flash"},
		_narr("Sie kletterten an den zottigen Flanken des Gefallenen hinab, durch den Mittelpunkt der Erde – und plötzlich war unten oben."),
		_narr("Ein langer, dunkler Gang. Ein fernes Rauschen. Und dann, endlich: »Und so traten wir hinaus, die Sterne wiederzusehen.«"),
		_say("vergil", "Mein Weg endet hier, am Fuß des Berges. Wer den Himmel betritt, braucht eine andere Führung als die meine. Sie wartet auf dich."),
	]))
	# ── PARADISO ──
	list.append(_boss_chapter("p1", "heaven", "PARADISO · ERSTE SPHÄRE", "Der Himmel des Mondes", "heaven_spheres", "beatrice", "angelus", [
		_narr("Über dem Läuterungsberg, im Garten auf seinem Gipfel, wartete sie: Beatrice. Und mit ihr stieg Dante empor – schneller als ein Blitz, hinein in die Sphären des Himmels."),
		_say("beatrice", "Dante. Du hast die Hölle gesehen, weil du sie sehen musstest. Jetzt wirst du lernen, das Licht zu ertragen. Jede Sphäre prüft dich – nicht mit Hass, sondern mit Wahrheit."),
		_say("dante", "Ich habe Dämonen besiegt. Wie schwer kann ein Engel sein?"),
		_say("beatrice", "Schwerer. Denn einen Engel kannst du nicht hassen."),
		{"t": "cam", "shot": "close", "who": 2, "time": 1.2},
		_say("angelus", "Willkommen im Himmel des Mondes, Wanderer. Hier wohnen jene, die ein Gelübde gaben und es nicht ganz hielten. Hältst du, was du versprichst?"),
	], {}, "Die erste Prüfung: Bestehe vor ANGELUS!", [
		_say("angelus", "Dein Wille ist beständig. Steig höher, Wanderer. Das Licht wird heller."),
		_say("beatrice", "Siehst du? Er hat dich nicht besiegen wollen. Er wollte wissen, ob du stehst."),
	], true))
	list.append(_boss_chapter("p2", "heaven", "PARADISO · ZWEITE SPHÄRE", "Der Himmel des Merkur", "heaven_spheres", "beatrice", "michael", [
		_narr("Im Merkur leuchteten die Seelen jener, die Gutes taten – aber auch für Ruhm und Ehre. Und über ihnen stand ein Engel in goldener Rüstung, das Flammenschwert erhoben."),
		{"t": "cam", "shot": "close", "who": 2, "time": 1.2},
		_say("michael", "Ich warf den Hochmütigen aus dem Himmel. Ich kenne das Gesicht des Stolzes, Wanderer – und ich sehe noch einen Schatten davon in dir."),
		_say("dante", "Dann zeig ihn mir, Erzengel. Ich will ihn loswerden."),
	], _qte("press", ["block"], "DAS FLAMMENSCHWERT FÄLLT!", "p2_sword", "Ich halte stand!", "Das Feuer brennt … und reinigt."),
		"Die zweite Prüfung: Kämpfe gegen MICHAEL!", [
		_say("michael", "Du kämpfst nicht mehr für Ruhm. Gut. Das Schwert ist zufrieden."),
	]))
	list.append(_boss_chapter("p3", "heaven", "PARADISO · DRITTE SPHÄRE", "Der Himmel der Venus", "heaven_spheres", "beatrice", "principatus", [
		_narr("Die Venus glühte rosenrot. Hier leuchteten die Seelen der Liebenden – jener, deren Liebe am Ende das Richtige wählte."),
		{"t": "cam", "shot": "close", "who": 2, "time": 1.2},
		_say("principatus", "Ich wache über die Völker und ihre Herrscher. In jeder Hand trage ich einen Kranz – Rosen und Dornen. Wer liebt, muss beides tragen."),
		_say("dante", "In der Hölle habe ich gesehen, was aus Liebe wird, die nur nimmt."),
		_say("principatus", "Dann zeig mir die Liebe, die gibt."),
	], {}, "Die dritte Prüfung: Bestehe vor PRINCIPATUS!", [
		_say("principatus", "Du hast gelernt. Trag den Rosenkranz weiter, Wanderer."),
	]))
	list.append(_boss_chapter("p4", "heaven", "PARADISO · VIERTE SPHÄRE", "Der Himmel der Sonne", "heaven_spheres", "beatrice", "potestas", [
		_narr("In der Sonne tanzten die Seelen der Weisen in leuchtenden Kreisen. Ihr Wächter trug Speer und Kreuzstab – jene Macht, die die Dämonen an der Kette hält."),
		{"t": "cam", "shot": "close", "who": 2, "time": 1.2},
		_say("potestas", "Ohne uns würde die Hölle die Welt verschlingen. Stärke ohne Weisheit ist nur Gewalt. Zeig mir, dass du den Unterschied kennst."),
	], _qte("sequence", ["jump", "block", "special"], "DER SPEERREGEN DER GEWALTEN!", "p4_spears", "Durch den Regen!", "Ein Speer streift mich – ich lerne daraus."),
		"Die vierte Prüfung: Kämpfe gegen POTESTAS!", [
		_say("potestas", "Du schlägst, wo es nötig ist, und nicht mehr. Das ist Weisheit. Geh."),
	]))
	list.append(_boss_chapter("p5", "heaven", "PARADISO · FÜNFTE SPHÄRE", "Der Himmel des Mars", "heaven_spheres", "beatrice", "virtus", [
		_narr("Im roten Mars bildeten die Seelen der Glaubenskämpfer ein gewaltiges leuchtendes Kreuz. Davor schwebte eine Gestalt mit Zepter und Schriftrolle."),
		{"t": "cam", "shot": "close", "who": 2, "time": 1.2},
		_say("virtus", "Auf dieser Rolle steht jede Tat, die du begangen hast. Jeder Sieg. Jede Grausamkeit. Tapferkeit bedeutet, sie alle anzusehen."),
		_say("dante", "Dann lies sie vor. Ich laufe nicht mehr weg."),
	], {}, "Die fünfte Prüfung: Stelle dich VIRTUS!", [
		_say("virtus", "Du hast nicht weggesehen. Das ist die tapferste Tat von allen."),
	]))
	list.append(_boss_chapter("p6", "heaven", "PARADISO · SECHSTE SPHÄRE", "Der Himmel des Jupiter", "heaven_spheres", "beatrice", "dominatio", [
		_narr("Im Jupiter formten die Seelen der Gerechten einen Adler aus Licht, der mit einer Stimme aus tausend Stimmen sprach. Über ihm herrschte die Herrschaft selbst."),
		{"t": "cam", "shot": "close", "who": 2, "time": 1.2},
		_say("dominatio", "Mein Zepter wägt jede Seele. Gerechtigkeit ohne Gnade ist Grausamkeit. Gnade ohne Gerechtigkeit ist Schwäche. Wo stehst du?"),
		_say("dante", "Ich habe in der Hölle keine Gnade gesehen. Ich will sie hier lernen."),
	], _qte("press", ["jump"], "DAS URTEIL FÄLLT!", "p6_judgement", "Ich nehme es an!", "Es wiegt schwer … aber gerecht."),
		"Die sechste Prüfung: Bestehe vor DOMINATIO!", [
		_say("dominatio", "Die Waage ist im Gleichgewicht. Steig auf zu den Thronen."),
	]))
	list.append(_boss_chapter("p7", "heaven", "PARADISO · SIEBTE SPHÄRE", "Der Himmel des Saturn", "wheel_heaven", "beatrice", "ophan", [
		_narr("Im stillen Saturn stieg eine goldene Leiter bis in unsichtbare Höhen. Die Seelen der Betrachtenden glitten daran auf und ab. Und dann – Räder in Rädern, voller Augen ringsum."),
		_say("dante", "Was … ist das?"),
		_say("beatrice", "Die Throne. Sie tragen die Herrlichkeit selbst. Sieh nicht weg, Dante – auch wenn deine Augen brennen."),
		{"t": "cam", "shot": "close", "who": 2, "time": 1.2},
		_say("ophan", "WIR SEHEN ALLES. WIR SEHEN DICH. KANNST DU DICH SELBST ANSEHEN, OHNE ZU ZITTERN?"),
	], {}, "Die siebte Prüfung: Halte dem Blick von OPHANIEL stand!", [
		_say("ophan", "DU ZITTERST. ABER DU SIEHST HIN. DAS GENÜGT."),
	]))
	list.append(_boss_chapter("p8", "heaven", "PARADISO · ACHTE SPHÄRE", "Der Himmel der Fixsterne", "heaven_gate", "beatrice", "cherub", [
		_narr("Unter den Fixsternen prüften die Heiligen Dante in Glaube, Hoffnung und Liebe. Und vor dem Tor zur letzten Sphäre stand der Wächter mit dem Flammenschwert, das sich nach allen Seiten wendet."),
		{"t": "cam", "shot": "close", "who": 2, "time": 1.2},
		_say("cherub", "Vier Gesichter habe ich: Mensch, Löwe, Stier und Adler. Mit allen vieren sehe ich dich. Einst bewachte ich den Garten, aus dem die Menschen vertrieben wurden."),
		_say("cherub", "Warum sollte ich einen Menschen hindurchlassen?"),
		_say("dante", "Weil ich nicht mehr derselbe bin, der den Wald betreten hat."),
	], _qte("sequence", ["jump", "block", "standard", "special"], "DAS FLAMMENSCHWERT WENDET SICH!", "p8_gate", "Durch die Flamme!", "Das Feuer versengt mich – und ich gehe weiter."),
		"Die achte Prüfung: Bestehe vor KERUVIM!", [
		_say("cherub", "Das Tor ist offen. Zum ersten Mal seit dem Garten."),
	]))
	list.append(_boss_chapter("p9", "heaven", "PARADISO · NEUNTE SPHÄRE", "Das Primum Mobile", "empyrean", "beatrice", "seraph", [
		_narr("Das Primum Mobile – die schnellste aller Sphären, die alle anderen bewegt. In ihrer Mitte ein einziger Punkt aus Licht, so hell, dass das Auge sich schließen muss. Um ihn kreisten die Chöre der Engel."),
		_narr("Und am innersten Kreis, dem Punkt am nächsten, brannte ein Auge – umhüllt von sechs Flügeln aus Feuer."),
		{"t": "cam", "shot": "close", "who": 2, "time": 1.2},
		_say("seraph", "Ich bin die Liebe, die brennt. Ich stehe dem Licht am nächsten. Niemand, der nicht brennt, kann an mir vorbei."),
		_say("beatrice", "Dies ist die letzte Prüfung, Dante. Nicht Kraft, nicht Mut – nur ob dein Herz dem Feuer standhält."),
		_say("dante", "Dann soll es brennen."),
	], _qte("sequence", ["block", "jump", "special", "standard"], "DAS BRENNENDE AUGE ÖFFNET SICH!", "p9_eye", "Ich halte seinem Blick stand!", "Das Feuer … es tut nicht weh. Es wärmt."),
		"ENDKAMPF DES HIMMELS: Bestehe vor SERAPHAEL!", [
		_say("seraph", "Du brennst. Nicht aus Zorn, nicht aus Stolz. Aus Liebe. Geh hindurch."),
	]))
	# ── EPILOG · EMPYREUM ──
	list.append({"id": "p10", "realm": "heaven", "title": "Das Empyreum", "arena": "empyrean", "start": false, "steps": [
		{"t": "stage", "cast": [{"id": "dante", "x": -1.6, "facing": 1}, {"id": "beatrice", "x": 1.6, "facing": -1}]},
		{"t": "cam", "shot": "sky", "time": 0.01},
		{"t": "title", "text": "EPILOG", "sub": "Das Empyreum"},
		_narr("Jenseits aller Sphären lag das Empyreum – ein Himmel, der nicht aus Raum besteht, sondern aus reinem Licht."),
		_narr("Die Seligen saßen dort in einer unermesslichen weißen Rose, und die Engel flogen zwischen ihren Blättern wie Bienen zwischen Blüten."),
		{"t": "cam", "shot": "two", "who": 0, "who2": 1, "time": 1.4},
		_say("beatrice", "Hier endet mein Weg an deiner Seite. Sieh hinauf, Dante. Das ist es, was du im dunklen Wald gesucht hast."),
		_say("dante", "Ich habe Siege gesucht. Gold. Ruhm. Und die ganze Zeit war es … das hier."),
		{"t": "qte", "kind": "sequence", "keys": ["jump", "standard", "special", "block"], "time": 1.6, "text": "SIEH IN DAS LICHT!", "flag": "p10_light",
			"success": [{"t": "fx", "kind": "flash"}, _narr("Drei Kreise aus Licht, drei Farben, ein einziger Umfang – und in ihrer Mitte, gemalt in derselben Farbe, das Bild eines Menschen.")],
			"fail": [{"t": "fx", "kind": "flash"}, _narr("Das Licht war zu hell für seine Augen. Und doch sah er – nicht mit den Augen, sondern mit etwas, für das es kein Wort gibt.")]},
		_say("stimme", "Du bist gegangen, wo niemand zurückkehrt, und du bist zurückgekehrt. Nun geh zurück in die Welt – und erzähl ihnen davon."),
		{"t": "pose", "who": 0, "pose": "Victory", "time": 1.6},
		_narr("Hier versagte die Kraft der hohen Schau. Doch schon drehte seinen Wunsch und Willen, wie ein Rad, das gleichmäßig bewegt wird –"),
		_narr("– die Liebe, die die Sonne bewegt und die anderen Sterne."),
		{"t": "credits"},
	]})
	return list

const CREDITS := [
	"PROMPT FIGHTER", "DIE GÖTTLICHE PRÜFUNG", "frei nach Dante Alighieri", "", "",
	"DANTE – der Wanderer", "VERGIL – der Dichter aus dem Limbus", "BEATRICE – das Licht, das ruft", "",
	"INFERNO", "Ahriman · Lilith · Asmodeus · Beelzebub · Mammon", "Baphomet · Belphegor · Bel Marduk · Leviathan · Luzifer", "",
	"PARADISO", "Angelus · Michael · Principatus · Potestas · Virtus", "Dominatio · Ophaniel · Keruvim · Seraphael", "", "",
	"Danke fürs Spielen.", "", "»L'amor che move il sole e l'altre stelle.«"]

static var _cache: Array = []

## Same interface as story_data.gd (CHAPTERS / chapter_count), built once.
static func all() -> Array:
	if _cache.is_empty(): _cache = chapters()
	return _cache

static func chapter_count() -> int:
	return all().size()
