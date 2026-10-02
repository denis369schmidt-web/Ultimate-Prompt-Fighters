extends RefCounted
## Third and central story campaign: "DER RISS ZWISCHEN DEN WELTEN".
## Ties the whole game together: after "Die letzte Zeile" (Lexara, Volt, Aria, Nulla → Nova) and
## "Die göttliche Prüfung" (Dante), Aria's quill breaks. Twelve shards fall into the worlds (the
## arenas) and lodge in the hearts of fighters, each one feeding that fighter's deepest wound.
## Volt and Nova travel the worlds, fight the wounded, heal them and win them as friends.
## Behind it all stands Oryn, the prophet who saw every world die and wants to crush them into
## one to save them. Act II can be played in any order ("requires"); bonds made along the way
## and the choices ("choice" steps, flags) decide which of three endings the epilogue shows.
##
## Same step format as story_data.gd, plus:
##   music   mood (calm|sad|hope|tense|fight|boss|boss_final) – story_mode crossfades the music
##   choice  text, options: [{label, flag, steps}] – the player decides; the flag is remembered
##   branch  flag, steps, else – plays steps when the flag is set (else otherwise)
##   bonds   min, steps, else – plays steps when at least `min` bond flags are set
## Chapters: "requires" lists chapter ids that must be done first; "act" groups the menu.
## Cast entries carry a "voice" for the voiced dialogue (tools/voice_lines.py).

const TITLE := "DER RISS ZWISCHEN DEN WELTEN"
const SUBTITLE := "Die Feder der Schreiberin ist zerbrochen. Zwölf Splitter, zwölf Wunden, eine Welt nach der anderen. Finde sie alle – und entscheide, wer gerettet wird."

## Bond flags: every healed fighter who joins Volt. The true ending needs most of them.
const BONDS := ["bond_bruno", "bond_jubei", "bond_glaciem", "bond_zip", "bond_tobi", "bond_ren", "bond_templar", "bond_varakh", "bond_raiga"]

const CAST := {
	"volt": {"name": "VOLT", "title": "Der letzte Promptgeborene", "color": "49def4",
		"prompt": "Blitzschneller Schattenninja mit elektrischen Klingen", "voice": {"model": "thorsten", "pitch": 0.0, "speed": 1.0}},
	"nova": {"name": "NOVA", "title": "Die einst die Leere war", "color": "c084fc",
		"prompt": "Void Specter crystal phantom warrior with void lance", "voice": {"model": "kerstin", "pitch": -1.0, "speed": 1.05}},
	"aria": {"name": "ARIA", "title": "Die Schreiberin", "color": "f9a8d4",
		"prompt": "Sorceress Medea Erzmagierin mit astraler Dunkelmagie", "voice": {"model": "kerstin", "pitch": 1.5, "speed": 1.12}},
	"erzaehler": {"name": "", "title": "", "color": "e2e8f0", "prompt": "", "voice": {"model": "thorsten", "pitch": -1.5, "speed": 1.08}},
	"bruno": {"name": "BRUNO", "title": "Der Unbesiegte", "color": "ffd23f",
		"prompt": "Bruno der Einschlag-Held mit Meteorfaust", "voice": {"model": "emotional:sleepy", "pitch": -2.0, "speed": 1.05}},
	"hikaru": {"name": "HIKARU", "title": "Erbe der Glutklinge", "color": "ff6524",
		"prompt": "Hikaru der Glutklingen-Wanderer mit Morgenrotschnitt", "voice": {"model": "thorsten", "pitch": 2.5, "speed": 0.95}},
	"jubei": {"name": "JUBEI", "title": "Meister der drei Klingen", "color": "3bfac8",
		"prompt": "Jubei der Windklingen-Wanderer mit Sturmschnitt", "voice": {"model": "emotional:neutral", "pitch": -3.0, "speed": 1.1}},
	"glaciem": {"name": "GLACIEM", "title": "Das gefrorene Herz", "color": "9be7ff",
		"prompt": "Glaciem die Frostassassine mit Eissplitter", "voice": {"model": "kerstin", "pitch": -2.0, "speed": 1.1}},
	"zip": {"name": "ZIP", "title": "Der Kurier, der nie ankam", "color": "3b82f6",
		"prompt": "Zip der Blitzkurier mit Turbo-Sprint", "voice": {"model": "emotional:amused", "pitch": 3.5, "speed": 0.88}},
	"tobi": {"name": "TOBI", "title": "Kapitän ohne Mannschaft", "color": "ff2b2b",
		"prompt": "Tobi der Federfaust-Raufbold mit Schleuderfaust", "voice": {"model": "emotional:amused", "pitch": 1.5, "speed": 0.95}},
	"seraphine": {"name": "SERAPHINE", "title": "Kapitänin der Salzkrähe", "color": "38bdf8",
		"prompt": "Korsar Corsair Piratenkapitän mit Entermesser und Donnerbüchse", "voice": {"model": "kerstin", "pitch": -3.5, "speed": 1.0}},
	"ren": {"name": "REN", "title": "Die Kirschkriegerin", "color": "ff9b3d",
		"prompt": "Ren die Kirschkriegerin mit Blütenwirbel", "voice": {"model": "kerstin", "pitch": 2.5, "speed": 0.98}},
	"amethya": {"name": "AMETHYA", "title": "Die Donnerhexe", "color": "60d5ff",
		"prompt": "Amethya die Donnerhexe mit Amethystblitz", "voice": {"model": "kerstin", "pitch": 0.0, "speed": 1.08}},
	"templar": {"name": "TEMPLAR", "title": "Wächter der verbrannten Stadt", "color": "ff5a1f",
		"prompt": "Mächtiger Cyber Drachenritter mit flammendem Drachen-Großschwert", "voice": {"model": "emotional:angry", "pitch": -4.0, "speed": 1.12}},
	"kairo": {"name": "KAIRO", "title": "Der Sturmmönch", "color": "7dd3fc",
		"prompt": "Kairo der Sturmmönch mit Solar-Kanone", "voice": {"model": "thorsten", "pitch": -2.0, "speed": 1.12}},
	"varakh": {"name": "VARAKH", "title": "Der Scharlachfürst", "color": "ffe838",
		"prompt": "Varakh der Scharlachfürst mit Nova-Strahl", "voice": {"model": "emotional:angry", "pitch": 0.5, "speed": 1.0}},
	"xylar": {"name": "XYLAR", "title": "Der Leerenkaiser", "color": "c084fc",
		"prompt": "Xylar der Leerenkaiser mit Nadelstrahl", "voice": {"model": "emotional:disgusted", "pitch": -5.0, "speed": 1.15}},
	"raiga": {"name": "RAIGA", "title": "Die Donnerfaust mit dem Kompass", "color": "00e5ff",
		"prompt": "Raiga die Donnerfaust mit Sternschlag", "voice": {"model": "kerstin", "pitch": -4.5, "speed": 1.05}},
	"oryn": {"name": "ORYN", "title": "Der Prophet, der das Ende sah", "color": "9900ee",
		"prompt": "Oryn der Schwerkraftprophet mit Abstoßungswelle", "voice": {"model": "emotional:whisper", "pitch": -2.5, "speed": 1.15}},
	"dante": {"name": "DANTE", "title": "Der Wanderer", "color": "f7c844",
		"prompt": "Kairo der Sturmmönch mit Solar-Kanone", "voice": {"model": "thorsten", "pitch": -1.0, "speed": 1.05}},
	"riss": {"name": "RISS-SCHATTEN", "title": "Was der Riss ausspuckt", "color": "ff3b5c",
		"prompt": "Crimson Schattenninja mit roten Klingen", "voice": {"model": "emotional:whisper", "pitch": -6.0, "speed": 1.2}},
	"lucifer": {"name": "LUZIFER", "title": "Der Gefallene", "color": "7dd3fc", "prompt": "", "boss": "lucifer",
		"voice": {"model": "emotional:disgusted", "pitch": -7.0, "speed": 1.2}},
}

# ── step helpers ──

static func _say(who: String, text: String) -> Dictionary:
	return {"t": "say", "who": who, "text": text}

static func _narr(text: String) -> Dictionary:
	return {"t": "narrate", "text": text}

static func _music(mood: String) -> Dictionary:
	return {"t": "music", "mood": mood}

static func _cam(shot: String, who: int = 0, time: float = 1.6, who2: int = 1) -> Dictionary:
	return {"t": "cam", "shot": shot, "who": who, "who2": who2, "time": time}

static func _stage(cast: Array) -> Dictionary:
	var c: Array = []
	for e in cast: c.append({"id": e[0], "x": e[1], "facing": e[2]})
	return {"t": "stage", "cast": c}

static func _pose(who: int, pose: String, time: float = 0.8) -> Dictionary:
	return {"t": "pose", "who": who, "pose": pose, "time": time}

static func _fight(cast: Array, goal: String, lives: Array = [], teams: Array = [], qte: String = "") -> Dictionary:
	var f := {"t": "fight", "cast": cast, "goal": goal}
	if not lives.is_empty(): f["lives"] = lives
	if not teams.is_empty(): f["teams"] = teams
	if qte != "": f["qte"] = qte
	return f

static func _choice(text: String, a_label: String, a_flag: String, a_steps: Array, b_label: String, b_flag: String, b_steps: Array) -> Dictionary:
	return {"t": "choice", "text": text, "options": [
		{"label": a_label, "flag": a_flag, "steps": a_steps}, {"label": b_label, "flag": b_flag, "steps": b_steps}]}

static func _qte(kind: String, keys: Array, text: String, flag: String, ok: Array, fail: Array, count: int = 12) -> Dictionary:
	return {"t": "qte", "kind": kind, "keys": keys, "time": 1.4 if kind == "press" else 3.0, "count": count, "text": text, "flag": flag,
		"success": ok, "fail": fail}

static func _chapter(id: String, act: String, title: String, arena: String, requires: Array, steps: Array) -> Dictionary:
	return {"id": id, "act": act, "title": title, "arena": arena, "requires": requires, "start": requires.is_empty(), "steps": steps}

# ── the saga ──

static func chapters() -> Array:
	var list: Array = []

	# ───────────────────────────── PROLOG ─────────────────────────────
	list.append(_chapter("s0", "prolog", "Die zerbrochene Feder", "blood_moon", [], [
		_stage([["volt", -2.0, 1], ["nova", 0.4, -1], ["riss", 9.0, -1]]),
		{"t": "vanish", "who": 2},
		_music("calm"),
		_cam("sky", 0, 0.01),
		{"t": "title", "text": "PROLOG", "sub": "Die zerbrochene Feder"},
		_narr("Ein Jahr ist vergangen, seit Lexara neu geschrieben wurde. Diesmal nicht von einer Hand – sondern von vielen."),
		_narr("Die Leere bekam einen Namen: Nova. Und die Welten, die einst getrennt waren, wuchsen zusammen wie Äste eines Baumes."),
		_cam("two", 0, 2.0, 1),
		_say("nova", "Weißt du, was ich am meisten vermisse, seit ich keine Leere mehr bin? Nichts. Ich vermisse gar nichts. Das ist neu."),
		_say("volt", "Du lernst schnell. Aria sagt, ein Jahr Leben fühlt sich für dich an wie hundert."),
		_say("nova", "Aria sagt viel, seit sie nicht mehr schreibt. Sie hustet Tinte, Volt. Hast du das gesehen?"),
		_say("volt", "… Ich habe es gesehen."),
		{"t": "fx", "kind": "flash"},
		_music("tense"),
		{"t": "fx", "kind": "shake"},
		_say("aria", "Volt! Nova! Die Feder – sie bricht! Haltet sie fest, sie –"),
		_narr("Ein Klang wie Glas, das im Inneren der Welt zerspringt. Zwölf Lichter fallen vom Himmel – in zwölf Richtungen."),
		{"t": "fx", "kind": "ink", "who": 1},
		{"t": "appear", "who": 2},
		{"t": "move", "who": 2, "x": 3.2, "time": 1.2},
		_cam("close", 2, 1.4),
		_say("riss", "Endlich … ein Spalt in der Geschichte. Durch jeden Spalt passt ein Schatten."),
		_cam("two", 0, 1.2, 2),
		_say("volt", "Nova, bleib hinter mir."),
		_say("nova", "Ich war die Leere. Ich bleibe hinter niemandem."),
		_qte("press", ["jump"], "DER SCHATTEN SPRINGT – AUSWEICHEN!", "s0_dodge",
			[_pose(0, "Victory", 0.4), _say("volt", "Zu langsam. Jetzt hör mir zu.")],
			[_pose(0, "HitReact", 0.5), {"t": "fx", "kind": "shake"}, _say("volt", "Ngh … er ist schneller als er aussieht.")]),
		_fight(["volt", "nova", "riss"], "WIRF DEN RISS-SCHATTEN ZURÜCK!", [3, 3, 2], [0, 0, 1], "s0_dodge"),
		_stage([["volt", -1.6, 1], ["nova", -0.2, 1], ["aria", 2.0, -1]]),
		_music("sad"),
		_cam("close", 2, 2.0),
		_pose(2, "Defeat", 1.2),
		_say("aria", "Die Feder … war nicht nur mein Werkzeug. Sie war das, was von mir übrig war, nachdem ich Lexara gerettet hatte."),
		_say("volt", "Dann holen wir sie zurück. Alle zwölf Splitter."),
		_say("aria", "Jeder Splitter sucht sich ein Herz. Ein verletztes Herz. Und er macht die Wunde größer, bis nichts anderes mehr bleibt."),
		_say("nova", "Dann sind es nicht zwölf Splitter, die wir suchen. Es sind zwölf Menschen, die gerade zerbrechen."),
		_cam("two", 0, 1.6, 1),
		_say("aria", "Volt … wenn du sie findest – kämpfe nicht gegen sie. Kämpfe für sie."),
		_narr("Und so begann die längste Reise, die je in Lexara geschrieben wurde."),
	]))

	# ───────────────────────────── AKT I · DIE SPUR DER SPLITTER ─────────────────────────────
	list.append(_chapter("s1", "act1", "Der Unbesiegte", "imperial_colosseum", ["s0"], [
		_stage([["volt", -3.0, 1], ["nova", -4.4, 1], ["bruno", 3.0, -1]]),
		_music("calm"),
		_cam("sky", 0, 0.01),
		{"t": "title", "text": "AKT I · KAPITEL 1", "sub": "Der Unbesiegte"},
		_narr("Das Kolosseum ist leer. Keine Stimmen, kein Jubel. Nur ein Mann in der Mitte der Arena, der in den Himmel starrt."),
		_cam("close", 2, 1.8),
		_say("bruno", "Neunhundertzweiundachtzig Kämpfe. Neunhundertzweiundachtzig Siege. Jeder mit einem Schlag."),
		_say("bruno", "Weißt du, wie sich das anfühlt? Wie gar nichts. Ich habe vergessen, ob ich noch etwas fühlen kann."),
		_cam("two", 0, 1.4, 2),
		_say("volt", "Der Splitter in dir macht das schlimmer. Lass mich ihn rausholen."),
		_say("bruno", "Dann triff mich. Einmal nur. Wenn du das schaffst, glaube ich dir, dass ich noch lebe."),
		_say("nova", "Volt … er bittet dich nicht um einen Kampf. Er bittet dich, ihn aufzuwecken."),
		_music("fight"),
		_fight(["volt", "nova", "bruno"], "TRIFF DEN UNBESIEGTEN!", [3, 3, 3], [0, 0, 1]),
		_stage([["volt", -1.4, 1], ["nova", -2.8, 1], ["bruno", 1.4, -1]]),
		_music("hope"),
		_cam("close", 2, 1.6),
		_pose(2, "Dazed", 1.0),
		_say("bruno", "Das … hat wehgetan."),
		_say("bruno", "Hahaha … es hat WEHGETAN! Ich spüre es! Ich spüre meinen Arm, meinen Puls, meine Wut, meine Freude!"),
		_say("volt", "Willkommen zurück."),
		_say("bruno", "Der Splitter hat geflüstert, ich sei allein, weil ich zu stark bin. Aber ich war allein, weil ich nie jemanden nah genug rangelassen habe."),
		_choice("Bruno bietet dir den Splitter – und seine Faust.",
			"„Komm mit uns.“", "bond_bruno", [_say("bruno", "Endlich ein Gegner, der mich zurückschlägt. Ich meine – ein Freund. Ich übe noch.")],
			"„Bleib und heile.“", "bruno_stays", [_say("bruno", "Vielleicht hast du recht. Aber ruf mich, wenn du jemanden brauchst, der nicht umfällt.")]),
		_narr("Der erste Splitter. Er glüht warm in Volts Hand – wie ein Herzschlag, der sich daran erinnert, wie man schlägt."),
	]))

	list.append(_chapter("s2", "act1", "Glut und Erbe", "volcano_sanctum", ["s1"], [
		_stage([["volt", -3.4, 1], ["hikaru", -1.6, 1], ["jubei", 3.4, -1]]),
		_music("tense"),
		_cam("sky", 0, 0.01),
		{"t": "title", "text": "AKT I · KAPITEL 2", "sub": "Glut und Erbe"},
		_narr("Im Glutheiligtum wartet ein junger Schwertkämpfer auf Volt. Seine Klinge ist warm, seine Stimme ist es nicht."),
		_cam("two", 0, 1.4, 1),
		_say("hikaru", "Mein Meister trägt einen Splitter. Er hat drei Dörfer niedergebrannt, weil er glaubt, er müsse alle Feuer der Welt zuerst löschen."),
		_say("hikaru", "Er hat mich großgezogen, nachdem meine Familie im Feuer starb. Ich kann ihn nicht allein bekämpfen. Ich kann es nicht."),
		_cam("close", 2, 1.6),
		_say("jubei", "Hikaru. Du solltest nicht hier sein. Ich habe dich damals nicht vor den Flammen beschützt. Jetzt beschütze ich alle davor."),
		_say("hikaru", "Indem du selbst zu den Flammen wirst?"),
		_say("jubei", "Drei Klingen, drei Schwüre: Nie wieder zu spät. Nie wieder zu schwach. Nie wieder ein Kind, das weint."),
		_say("volt", "Der Splitter hat aus deinen Schwüren Ketten gemacht."),
		_qte("mash", ["standard"], "JUBEIS DRITTE KLINGE – HALTE DAGEGEN!", "s2_clash",
			[_say("hikaru", "Meister … deine Hand zittert. Du willst das hier nicht.")],
			[{"t": "fx", "kind": "shake"}, _say("hikaru", "Er ist zu stark … Volt, er ist zu stark!")]),
		_music("fight"),
		_fight(["volt", "hikaru", "jubei"], "BEFREIE JUBEI VON SEINEM SCHWUR!", [3, 3, 3], [0, 0, 1], "s2_clash"),
		_stage([["volt", -2.4, 1], ["hikaru", -0.6, 1], ["jubei", 1.2, -1]]),
		_music("sad"),
		_cam("two", 1, 1.6, 2),
		_pose(2, "Defeat", 1.0),
		_say("jubei", "Ich habe die Glocke gehört an jenem Tag. Ich war zwei Hügel entfernt. Zwei Hügel, Hikaru."),
		_say("hikaru", "Und du bist trotzdem gerannt. Bis deine Füße bluteten. Ich weiß es. Ich habe dich gesehen, als du mich aus der Asche gezogen hast."),
		_say("hikaru", "Du warst nicht zu spät für mich, Meister. Du warst genau rechtzeitig."),
		_say("jubei", "…"),
		_pose(2, "Victory", 0.8),
		_say("jubei", "Dann lass mich diesmal neben dir stehen. Nicht vor dir."),
		{"t": "set", "flag": "bond_jubei"},
		_narr("Zwei Splitter. Und hinter dem Vulkan öffnet sich der Himmel in alle Richtungen – die Welten warten nicht in einer Reihe."),
		_say("nova", "Volt. Ich spüre sie jetzt alle. Sieben Herzen, die schreien. Wohin zuerst?"),
	]))

	# ───────────────────────────── AKT II · DIE VERLORENEN WELTEN (freie Reihenfolge) ─────────────────────────────
	list.append(_chapter("s3", "act2", "Das gefrorene Herz", "frozen_summit", ["s2"], [
		_stage([["volt", -3.0, 1], ["nova", -4.4, 1], ["glaciem", 3.0, -1]]),
		_music("sad"),
		_cam("sky", 0, 0.01),
		{"t": "title", "text": "AKT II", "sub": "Das gefrorene Herz"},
		_narr("Auf dem Gipfel schneit es nach oben. Jede Flocke ist eine Erinnerung, die jemand nicht mehr haben wollte."),
		_cam("close", 2, 1.8),
		_say("glaciem", "Geht. Hier oben gibt es nichts, was ihr retten könnt. Ich habe alles eingefroren, was wehtun könnte."),
		_say("nova", "Auch dich selbst?"),
		_say("glaciem", "Besonders mich selbst. Mein kleiner Bruder ist in einen Riss gerannt. Er wollte nur einen Brief abliefern. Er kam nie an."),
		_say("glaciem", "Wenn ich nichts fühle, vermisse ich ihn nicht. Das ist der Handel. Der Splitter hat ihn mir angeboten, und ich habe ja gesagt."),
		_say("volt", "Und wenn er noch lebt?"),
		_say("glaciem", "Sag das nicht. Sag das NICHT. Hoffnung ist das Einzige, was hier oben noch schmelzen kann."),
		_music("fight"),
		_fight(["volt", "nova", "glaciem"], "BRICH DAS EIS UM GLACIEMS HERZ!", [3, 3, 3], [0, 0, 1]),
		_stage([["volt", -1.4, 1], ["nova", -2.8, 1], ["glaciem", 1.4, -1]]),
		_music("hope"),
		_pose(2, "Dazed", 1.0),
		_say("glaciem", "Es … taut. Ich hatte vergessen, wie sehr Wärme brennt."),
		_say("nova", "Dein Bruder. Wie hieß er?"),
		_say("glaciem", "Zip. Er war der schnellste Junge in drei Welten. Er hat mir jeden Morgen eine Blume vom anderen Ende der Welt gebracht."),
		_say("volt", "Dann suchen wir ihn. Zusammen."),
		{"t": "set", "flag": "bond_glaciem"},
		_narr("Ein dritter Splitter – und ein Name, der plötzlich wieder etwas bedeutet."),
	]))

	list.append(_chapter("s4", "act2", "Der Kurier, der nie ankam", "neon_metropolis", ["s3"], [
		_stage([["volt", -3.6, 1], ["glaciem", -2.0, 1], ["zip", 6.0, -1]]),
		_music("tense"),
		_cam("sky", 0, 0.01),
		{"t": "title", "text": "AKT II", "sub": "Der Kurier, der nie ankam"},
		_narr("Die Neonstadt im Riss. Hier ist es immer kurz vor Mitternacht. Seit einem Jahr. Seit genau einem Jahr."),
		{"t": "move", "who": 2, "x": -6.0, "time": 0.5},
		{"t": "move", "who": 2, "x": 6.0, "time": 0.5},
		_say("zip", "Nicht jetzt, nicht jetzt, ich bin spät dran! Ich muss den Brief abliefern, sie wartet, sie wartet doch schon so lange!"),
		_cam("close", 1, 1.4),
		_say("glaciem", "… Zip?"),
		_cam("close", 2, 1.0),
		_say("zip", "Wer bist du? Ich kenne dich nicht. Ich kenne niemanden. Ich kenne nur den Weg. Und der Weg hört nicht auf."),
		_say("volt", "Der Splitter hat ihn in einer Schleife gefangen. Er rennt dieselbe Runde, immer wieder, und vergisst bei jedem Schritt."),
		_say("glaciem", "Dann halte ich ihn auf. Und wenn ich ihn festfrieren muss, bis er sich erinnert."),
		_qte("sequence", ["jump", "standard", "special"], "SCHNEIDE IHM DEN WEG AB!", "s4_catch",
			[_say("glaciem", "Hab dich. Du entkommst mir nicht noch einmal.")],
			[{"t": "fx", "kind": "shake"}, _say("zip", "Zu langsam, zu langsam, alle sind immer zu langsam!")]),
		_music("fight"),
		_fight(["glaciem", "volt", "zip"], "HALTE ZIP AUF – OHNE IHN ZU VERLIEREN!", [3, 3, 3], [0, 0, 1], "s4_catch"),
		_stage([["glaciem", -0.9, 1], ["volt", -3.0, 1], ["zip", 0.9, -1]]),
		_music("sad"),
		_cam("two", 0, 1.8, 2),
		_pose(2, "Defeat", 1.0),
		_say("zip", "Der Brief … er ist ganz nass. Ich wollte ihn nicht nass machen."),
		_say("glaciem", "Lies ihn mir vor."),
		_say("zip", "„Liebe große Schwester. Heute bringe ich dir eine Blume vom Ende der Welt. Bitte hör auf, so viel allein zu sein.“"),
		_say("glaciem", "Zip … du Dummkopf. Du warst das Ende der Welt. Du warst immer genug."),
		_say("zip", "… Schwester? Bin ich angekommen? Bin ich endlich angekommen?"),
		_say("glaciem", "Ja. Du bist zu Hause."),
		{"t": "set", "flag": "bond_zip"},
		_narr("Manche Splitter brechen nicht durch einen Schlag. Sondern durch einen Satz, den man ein Jahr zu spät hört."),
	]))

	list.append(_chapter("s5", "act2", "Das Ende der Karte", "pirate_galleon", ["s2"], [
		_stage([["volt", -3.4, 1], ["seraphine", -5.0, 1], ["tobi", 3.0, -1]]),
		_music("calm"),
		_cam("sky", 0, 0.01),
		{"t": "title", "text": "AKT II", "sub": "Das Ende der Karte"},
		_narr("Der Hafen der Salzkrähe. Ein Schiff ohne Segel, ein Kapitän ohne Mannschaft, eine Karte ohne Ende."),
		_cam("close", 1, 1.6),
		_say("seraphine", "Tobi war mein Erster Maat, bevor er sein eigenes Schiff bekam. Er hat seiner Mannschaft das Ende der Karte versprochen."),
		_say("seraphine", "Dann kam der Sturm. Er war der Einzige, der zurückkam. Seitdem lacht er. Er hört einfach nicht auf zu lachen."),
		_cam("close", 2, 1.4),
		_say("tobi", "Hahaha! Gäste! Kommt an Bord, die Jungs sind nur kurz unter Deck! Sie kommen gleich, sie kommen ganz bestimmt gleich!"),
		_say("volt", "Tobi. Dein Schiff hat kein Unterdeck mehr."),
		_say("tobi", "… Sag das nicht so laut. Sonst hören sie dich. Und dann wissen sie, dass ich sie im Stich gelassen habe."),
		_music("fight"),
		_fight(["volt", "seraphine", "tobi"], "HOL TOBI AUS DEM STURM ZURÜCK!", [3, 3, 3], [0, 0, 1]),
		_stage([["volt", -1.8, 1], ["seraphine", -3.2, 1], ["tobi", 1.4, -1]]),
		_music("sad"),
		_pose(2, "Dazed", 1.0),
		_say("tobi", "Ich habe nicht gelacht, weil ich glücklich war. Ich habe gelacht, damit niemand hört, wie laut es in mir ist."),
		_say("seraphine", "Deine Mannschaft hat dir ihre letzte Nachricht hinterlassen. Ich habe sie ein Jahr lang aufbewahrt. Ich hatte Angst, sie dir zu geben."),
		_choice("Seraphine hält eine nasse Flaschenpost in der Hand.",
			"„Gib sie ihm.“", "tobi_letter", [
				_say("tobi", "„Kapitän, das Ende der Karte war nie ein Ort. Es war die Reise mit dir. Danke für alles.“"),
				_say("tobi", "… Sie haben es gewusst. Die ganze Zeit."),
				{"t": "set", "flag": "bond_tobi"}],
			"„Lass ihn erst zur Ruhe kommen.“", "tobi_wait", [
				_say("tobi", "Nein. Lies. Ich bin ein Jahr weggelaufen. Ich will nicht noch einen Tag weglaufen."),
				_say("seraphine", "„Kapitän, das Ende der Karte war nie ein Ort. Es war die Reise mit dir.“"),
				{"t": "set", "flag": "bond_tobi"}]),
		_narr("Tobi weint zum ersten Mal seit einem Jahr. Und danach lacht er – leiser, und diesmal echt."),
	]))

	list.append(_chapter("s6", "act2", "Blüte und Blitz", "mystic_grove", ["s2"], [
		_stage([["volt", -4.0, 1], ["ren", -1.2, -1], ["amethya", 1.6, -1]]),
		_music("tense"),
		_cam("sky", 0, 0.01),
		{"t": "title", "text": "AKT II", "sub": "Blüte und Blitz"},
		_narr("Im Lichthain kämpfen zwei Schwestern seit drei Tagen. Die Bäume sind verbrannt, die Kirschblüten schwarz."),
		_cam("two", 1, 1.4, 2),
		_say("ren", "Du bist gegangen! Mutter lag im Sterben und du bist gegangen, um mit Blitzen zu spielen!"),
		_say("amethya", "Ich bin gegangen, um eine Heilerin zu finden, die Donner bändigen kann! Ich kam zu spät, ja! Glaubst du, das weiß ich nicht?!"),
		_say("volt", "Welche von euch trägt den Splitter?"),
		_say("nova", "Beide, Volt. Er ist in zwei Hälften gebrochen. Eine Hälfte Neid, eine Hälfte Schuld. Sie nähren sich gegenseitig."),
		_choice("Wem stehst du im Kampf bei?",
			"Ren", "s6_ren", [_say("ren", "Endlich hört mir jemand zu. Dann sieh zu, wie sie fällt.")],
			"Amethya", "s6_amethya", [_say("amethya", "Danke. Aber ich will sie nicht besiegen. Ich will nur, dass sie mich ansieht.")]),
		_music("fight"),
		{"t": "branch", "flag": "s6_ren",
			"steps": [_fight(["volt", "ren", "amethya"], "BEENDE DEN STREIT DER SCHWESTERN!", [3, 3, 3], [0, 0, 1])],
			"else": [_fight(["volt", "amethya", "ren"], "BEENDE DEN STREIT DER SCHWESTERN!", [3, 3, 3], [0, 0, 1])]},
		_stage([["volt", -3.4, 1], ["ren", -0.9, 1], ["amethya", 0.9, -1]]),
		_music("sad"),
		_cam("two", 1, 1.8, 2),
		_say("amethya", "Ich habe ihre Hand gehalten, als sie ging. Du warst im Wald, Ren. Du hast ihr Lieblingslied gesungen, damit sie es hört."),
		_say("ren", "… Sie hat es gehört?"),
		_say("amethya", "Sie hat gelächelt. Ihr letztes Wort war dein Name."),
		_say("ren", "Und ich habe dich ein Jahr lang gehasst, weil ich dachte, du hättest sie allein gelassen."),
		_say("amethya", "Hass mich ruhig weiter. Aber tu es neben mir. Ich will nicht noch jemanden verlieren."),
		{"t": "set", "flag": "bond_ren"},
		_narr("Zwei Hälften eines Splitters, wieder vereint. Im verbrannten Hain treibt eine einzige Kirschblüte aus."),
	]))

	list.append(_chapter("s7", "act2", "Die Stadt, die niemand verlassen darf", "gladiator_fortress", ["s2"], [
		_stage([["volt", -3.4, 1], ["kairo", -5.0, 1], ["templar", 3.0, -1]]),
		_music("tense"),
		_cam("sky", 0, 0.01),
		{"t": "title", "text": "AKT II", "sub": "Die Stadt, die niemand verlassen darf"},
		_narr("Die Bastion brennt seit einem Jahr. Die Flammen verbrennen nichts mehr. Es ist nichts mehr da."),
		_cam("close", 1, 1.6),
		_say("kairo", "Ich bin Mönch der Stürme. Ich habe ihn gebeten, mit mir zu gehen. Dreihundert Mal. Er bleibt."),
		_cam("close", 2, 1.4),
		_say("templar", "Ich habe geschworen, diese Stadt zu schützen. Die Stadt ist gefallen. Also schütze ich die Asche. Jemand muss es tun."),
		_say("volt", "Es gibt hier niemanden mehr, Templar."),
		_say("templar", "Es gibt MICH. Wenn ich gehe, war alles umsonst. Jeder Name auf dieser Mauer. Jeder einzelne."),
		_say("kairo", "Der Splitter hat aus seiner Treue ein Grab gemacht. Und er hat sich selbst hineingelegt."),
		_music("boss"),
		_fight(["volt", "kairo", "templar"], "BEZWINGE DEN WÄCHTER DER ASCHE!", [3, 3, 4], [0, 0, 1]),
		_stage([["volt", -1.6, 1], ["kairo", -3.0, 1], ["templar", 1.4, -1]]),
		_music("sad"),
		_pose(2, "Defeat", 1.2),
		_say("templar", "Wenn ich gehe … wer erinnert sich dann an sie?"),
		_choice("Was sagst du dem Templer?",
			"„Du. Unterwegs. Jeden Tag.“", "templar_carry", [
				_say("volt", "Eine Mauer erinnert sich an nichts. Du schon. Trag ihre Namen mit dir, nicht ihre Asche."),
				_say("templar", "… Dann lass mich einen Stein mitnehmen. Nur einen.")],
			"„Wir bauen sie neu.“", "templar_rebuild", [
				_say("volt", "Wenn das hier vorbei ist, kommen wir zurück. Alle. Und bauen die Stadt neu, Stein für Stein."),
				_say("templar", "Ein Versprechen. Ich halte dich daran fest, Promptgeborener.")]),
		{"t": "set", "flag": "bond_templar"},
		_narr("Zum ersten Mal seit einem Jahr erlöschen die Flammen über der Bastion. Es ist sehr still. Und es ist gut."),
	]))

	list.append(_chapter("s8", "act2", "Der Sohn des Leerenkaisers", "hell_city", ["s2"], [
		_stage([["volt", -3.4, 1], ["varakh", -1.4, 1], ["xylar", 4.0, -1]]),
		_music("tense"),
		_cam("sky", 0, 0.01),
		{"t": "title", "text": "AKT II", "sub": "Der Sohn des Leerenkaisers"},
		_narr("Die Stadt aus schwarzem Glas. Hier herrscht Xylar, der Leerenkaiser. Und hier wartet sein Sohn seit zwanzig Jahren auf ein Wort."),
		_cam("two", 1, 1.4, 2),
		_say("varakh", "Vater. Ich habe die Sternenkrone erobert. Ich habe zehn Armeen besiegt. Ich habe alles getan, was du verlangt hast."),
		_say("xylar", "Und doch stehst du wieder vor mir und bettelst. Ein Prinz, der um Anerkennung fleht, ist kein Prinz."),
		_say("nova", "Der Splitter ist in Xylar, nicht in Varakh. Er hat ihm eingeredet, Liebe sei Schwäche."),
		_say("varakh", "Nein. Ich bitte nicht mehr. Ich fordere dich heraus. Wenn ich dich nicht stolz machen kann, mache ich dich wenigstens still."),
		_music("boss"),
		_fight(["varakh", "volt", "xylar"], "STELL DICH DEM LEERENKAISER!", [3, 3, 4], [0, 0, 1]),
		_stage([["varakh", -1.0, 1], ["volt", -3.2, 1], ["xylar", 1.2, -1]]),
		_music("sad"),
		_pose(2, "Defeat", 1.2),
		_say("xylar", "Weißt du, warum ich dir nie gesagt habe, dass ich stolz bin? Weil mein Vater es mir auch nie gesagt hat."),
		_say("xylar", "Ich dachte, wenn ich es dir sage, wirst du aufhören, stärker zu werden. Ich hatte Angst, dass du schwach bleibst. Wie ich."),
		_say("varakh", "Ich will nicht stärker werden. Ich will nur einmal hören, dass ich genug bin."),
		_say("xylar", "… Du bist genug, Varakh. Du warst es an dem Tag, an dem du geboren wurdest. Es tut mir leid, dass ich zwanzig Jahre zu feige war."),
		{"t": "set", "flag": "bond_varakh"},
		_narr("Ein Kaiser, der sich vor seinem Sohn verneigt. Die schwarze Stadt bekommt ihren ersten Sonnenaufgang."),
	]))

	list.append(_chapter("s9", "act2", "Der Kompass zeigt nach Hause", "cocytus", ["s2"], [
		_stage([["volt", -3.0, 1], ["nova", -4.4, 1], ["raiga", 3.0, -1]]),
		_music("calm"),
		_cam("sky", 0, 0.01),
		{"t": "title", "text": "AKT II", "sub": "Der Kompass zeigt nach Hause"},
		_narr("Im ewigen Eis sitzt eine Kriegerin vor einem Kompass mit zwölf Strahlen. Die Nadel dreht sich. Sie hört nie auf, sich zu drehen."),
		_cam("close", 2, 1.6),
		_say("raiga", "Mein Leben lang zeigte die Nadel in eine Richtung. Nach Hause, sagte man mir. Seit die Feder brach, dreht sie sich nur noch."),
		_say("raiga", "Ich habe kein Zuhause. Ich hatte nie eins. Der Splitter sagt, das sei der Grund, warum mich niemand vermisst."),
		_say("nova", "Volt … der Kompass. Siehst du die Zeichen? Das ist Arias Handschrift."),
		_say("volt", "Raiga. Wer hat dir diesen Kompass gegeben?"),
		_say("raiga", "Ich weiß es nicht. Ich bin mit ihm aufgewacht. Wie aus einem Traum, den jemand anderes geträumt hat."),
		_music("fight"),
		_fight(["volt", "nova", "raiga"], "HALTE DIE NADEL AN!", [3, 3, 3], [0, 0, 1]),
		_stage([["volt", -1.4, 1], ["nova", -2.8, 1], ["raiga", 1.4, -1]]),
		_music("hope"),
		_pose(2, "Dazed", 0.8),
		_narr("Die Nadel bleibt stehen. Sie zeigt auf Volt. Nein – auf das Licht in seiner Tasche. Auf die Splitter."),
		_say("raiga", "Sie zeigt … auf die Feder."),
		_say("nova", "Du bist Arias erste Zeichnung, Raiga. Bevor sie Lexara schrieb, bevor sie Volt schrieb. Du bist ihr erstes Wort."),
		_say("raiga", "Dann habe ich doch ein Zuhause. Es hat nur vergessen, nach mir zu suchen."),
		_say("volt", "Sie hat nicht vergessen. Sie liegt im Sterben. Komm mit uns und sag es ihr selbst."),
		{"t": "set", "flag": "bond_raiga"},
		_narr("Der Kompass zeigt jetzt in eine einzige Richtung. Und dort, am Horizont aller Welten, wartet ein Prophet."),
	]))

	# ───────────────────────────── AKT III · DIE LETZTE FEDER ─────────────────────────────
	var act3_req := ["s4", "s5", "s6", "s7", "s8", "s9"]
	list.append(_chapter("s10", "act3", "Der Prophet", "heaven_spheres", act3_req, [
		_stage([["volt", -3.4, 1], ["nova", -4.8, 1], ["oryn", 3.4, -1]]),
		_music("tense"),
		_cam("sky", 0, 0.01),
		{"t": "title", "text": "AKT III", "sub": "Der Prophet"},
		_narr("Zwischen den Sphären treibt ein Mann auf einem Ring aus Steinen. Um ihn kreisen die letzten drei Splitter."),
		_cam("close", 2, 1.8),
		_say("oryn", "Ihr habt neun Herzen geheilt. Rührend. Und völlig sinnlos. Ich habe gesehen, wie das endet. Jede Version. Tausendmal."),
		_say("oryn", "Die Welten driften auseinander. In hundert Jahren gibt es keine Brücken mehr. Jede Welt stirbt allein, in der Dunkelheit."),
		_say("volt", "Und dein Plan?"),
		_say("oryn", "Ich presse sie zusammen. Alle Welten, eine einzige. Kein Abschied mehr, kein Auseinanderdriften. Keine Einsamkeit."),
		_say("nova", "In einer einzigen Welt gibt es keinen Platz für alle. Du würdest die Hälfte von ihnen zerdrücken."),
		_say("oryn", "Die Hälfte. Statt aller. Das ist die Rechnung, die niemand machen will. Also mache ich sie."),
		_music("boss"),
		_fight(["volt", "nova", "oryn"], "HALTE DEN PROPHETEN AUF!", [3, 3, 4], [0, 0, 1]),
		_stage([["volt", -1.6, 1], ["nova", -3.0, 1], ["oryn", 1.6, -1]]),
		_cam("close", 2, 1.4),
		_say("oryn", "Gut. Sehr gut. Du bist stärker als in den meisten Versionen. Aber das ändert die Rechnung nicht."),
		_say("oryn", "Frag Aria, wer ich bin. Frag sie, wen sie zuerst geschrieben hat – und warum sie mich ausradiert hat."),
		{"t": "fx", "kind": "ink", "who": 2},
		{"t": "vanish", "who": 2},
		_say("nova", "Er ist in den Riss gesprungen. Volt … er hat Arias Augen."),
	]))

	list.append(_chapter("s11", "act3", "Durch Hölle und Himmel", "hell_flames", ["s10"], [
		_stage([["volt", -3.6, 1], ["dante", -1.8, 1], ["lucifer", 4.0, -1]]),
		_music("tense"),
		_cam("sky", 0, 0.01),
		{"t": "title", "text": "AKT III", "sub": "Durch Hölle und Himmel"},
		_narr("Der Riss führt durch die tiefsten Kreise. Und dort steht ein Wanderer, der diesen Weg schon einmal gegangen ist."),
		_cam("two", 0, 1.4, 1),
		_say("dante", "Ich bin durch neun Kreise gestiegen und durch neun Himmel. Ich kenne den Weg. Und ich kenne den, der ihn bewacht."),
		_say("volt", "Warum hilfst du uns?"),
		_say("dante", "Weil mich einmal jemand an der Hand genommen hat, als ich verloren war. Das schuldet man weiter."),
		_cam("close", 2, 1.6),
		_say("lucifer", "Wieder ein Wanderer. Wieder ein Held. Ihr kommt alle mit derselben Hoffnung und geht mit derselben Leere."),
		_say("dante", "Diesmal nicht. Diesmal kommen wir nicht allein."),
		_music("boss_final"),
		_fight(["volt", "dante", "lucifer"], "BRECHT DURCH DEN TIEFSTEN KREIS!", [3, 3, 1], [0, 0, 9]),
		_stage([["volt", -1.8, 1], ["dante", -3.4, 1], ["lucifer", 3.2, -1]]),
		_music("hope"),
		_say("dante", "Geh. Der Weg nach oben ist offen. Und Volt – egal was du dort oben findest: Liebe ist keine Schwäche. Sie ist der Weg."),
		_narr("Hinter dem Eis führt eine Treppe aus Licht nach oben. Zum Herzen aller Welten. Zu Aria."),
	]))

	list.append(_chapter("s12", "act3", "Das Herz des Risses", "empyrean", ["s11"], [
		_stage([["volt", -3.6, 1], ["aria", -1.4, 1], ["oryn", 3.6, -1]]),
		_music("sad"),
		_cam("sky", 0, 0.01),
		{"t": "title", "text": "AKT III", "sub": "Das Herz des Risses"},
		_cam("two", 1, 1.8, 2),
		_say("aria", "Oryn. Mein Bruder. Mein erster Satz. Ich habe dich geschrieben, als ich noch ein Kind war, und ich hatte Angst vor dir."),
		_say("oryn", "Du hast mich ausradiert, weil ich das Ende sehen konnte. Weil ich dir sagte, dass auch du einmal sterben wirst."),
		_say("aria", "Ich habe dich ausradiert, weil ich es nicht hören wollte. Das war falsch. Es tut mir leid, Oryn. Es tut mir so leid."),
		_say("oryn", "Zu spät, Schwester. Ich habe alle Splitter, die ich brauche. Die Welten werden eins – und niemand wird je wieder allein sein."),
		{"t": "bonds", "min": 6,
			"steps": [
				_narr("Hinter Volt öffnen sich Risse. Aus jedem tritt jemand, dessen Herz er geheilt hat."),
				_say("volt", "Du hast eine Sache nie gesehen, Oryn. Dass man nicht in derselben Welt leben muss, um nicht allein zu sein."),
				_say("nova", "Sie sind alle gekommen. Bruno. Jubei und Hikaru. Glaciem und Zip. Tobi. Ren und Amethya. Der Templer. Varakh. Raiga.")],
			"else": [
				_say("volt", "Ich bin vielleicht allein hier. Aber ich bin nicht allein gekommen.")]},
		_music("boss_final"),
		{"t": "bonds", "min": 6,
			"steps": [_fight(["volt", "nova", "raiga", "oryn"], "DER LETZTE KAMPF – FÜR ALLE WELTEN!", [3, 3, 3, 5], [0, 0, 0, 1])],
			"else": [_fight(["volt", "nova", "oryn"], "DER LETZTE KAMPF – FÜR ALLE WELTEN!", [3, 3, 5], [0, 0, 1])]},
		_stage([["volt", -1.8, 1], ["aria", -3.2, 1], ["oryn", 1.6, -1]]),
		_music("sad"),
		_pose(2, "Defeat", 1.2),
		_say("oryn", "Ich habe das Ende tausendmal gesehen. In keiner Version hat mir jemand die Hand gereicht."),
		_say("aria", "Dann ist das hier eine neue Version."),
		_narr("Zwölf Splitter schweben zwischen ihnen. Genug für eine Feder. Genug für eine einzige letzte Zeile."),
		_choice("Wofür schreibt die letzte Zeile?",
			"„Für Aria – sie soll leben.“", "end_aria", [
				_say("volt", "Du hast uns alle geschrieben. Jetzt schreiben wir dich."),
				_say("aria", "Volt, nein – die Welten …")],
			"„Für die Welten – schließt den Riss.“", "end_worlds", [
				_say("aria", "Dann gib mir die Feder. Das ist meine Zeile. Sie war es immer."),
				_say("volt", "Aria …")]),
	]))

	list.append(_chapter("s13", "epilog", "Die letzte Zeile, geschrieben von allen", "mystic_grove", ["s12"], [
		_stage([["volt", -1.6, 1], ["nova", -3.0, 1], ["aria", 1.6, -1]]),
		_cam("sky", 0, 0.01),
		{"t": "title", "text": "EPILOG", "sub": "Die letzte Zeile"},
		{"t": "bonds", "min": 8,
			"steps": [
				_music("hope"),
				_narr("Doch Volt schreibt die Zeile nicht allein. Jeder, dessen Herz geheilt wurde, legt eine Hand auf die Feder."),
				_say("nova", "Bruno schreibt: Mut. Jubei schreibt: Rechtzeitig. Glaciem schreibt: Wärme. Zip schreibt: Angekommen."),
				_say("volt", "Tobi schreibt: Reise. Ren und Amethya: Verzeihen. Der Templer: Erinnern. Varakh: Genug. Raiga: Zuhause."),
				_say("aria", "So viele Worte … ich hätte sie nie allein finden können."),
				_narr("Die Zeile wird so lang, dass sie für beides reicht. Der Riss schließt sich. Und Aria atmet – als Mensch, zum ersten Mal."),
				_say("aria", "Ich bin nicht mehr die Schreiberin. Ich bin nur noch Aria. Ist das … genug?"),
				_say("volt", "Für uns warst du immer genug."),
				_say("oryn", "Diese Version … habe ich nie gesehen. Schwester. Darf ich bleiben?"),
				_say("aria", "Du darfst bleiben. Diesmal radiere ich niemanden aus."),
				{"t": "set", "flag": "ending_true"}],
			"else": [
				{"t": "branch", "flag": "end_aria",
					"steps": [
						_music("hope"),
						_narr("Die Feder schreibt Aria zurück ins Leben. Aber die Welten bleiben getrennt – wie Inseln in einem dunklen Meer."),
						_say("aria", "Wir werden Brücken bauen müssen. Mit den Händen, nicht mit Tinte. Hilfst du mir?"),
						_say("volt", "Jeden Tag."),
						{"t": "set", "flag": "ending_aria"}],
					"else": [
						_music("sad"),
						_narr("Aria schreibt ihre letzte Zeile. Der Riss schließt sich. Die Welten wachsen zusammen, so wie früher."),
						_say("aria", "Ich werde in jedem Wort sein, das ihr sagt. Erzählt euch Geschichten, Volt. Dann bin ich nie ganz weg."),
						_say("nova", "Ich war einmal die Leere. Jetzt weiß ich, wie sich Verlust anfühlt. Es tut weh. Und es ist schön, dass es wehtut."),
						{"t": "set", "flag": "ending_worlds"}]}]},
		_narr("Und irgendwo in Lexara schreibt ein Kind mit einem Stock einen Namen in den Sand. Den ersten Satz einer neuen Geschichte."),
		{"t": "credits"},
	]))
	return list

const CREDITS := [
	"PROMPT FIGHTER", TITLE, "", "",
	"VOLT · NOVA · ARIA", "BRUNO · JUBEI · HIKARU", "GLACIEM · ZIP", "TOBI · SERAPHINE", "REN · AMETHYA",
	"TEMPLAR · KAIRO", "VARAKH · XYLAR", "RAIGA", "DANTE", "und ORYN, der das Ende sah", "", "",
	"MUSIK (CC0)", "Cleyton Kauffman · cynicmusic · Juhani Junkala", "nene · Yoiyami · Centurion_of_war", "",
	"SOUND & ANSAGER (CC0)", "Kenney", "", "AMBIENCE (CC BY 4.0)", "Nature Ambient Pack Vol 1 by JC Sounds", "",
	"STIMMEN", "Piper TTS · Thorsten-Voice · Kerstin (CC0)", "", "",
	"Danke fürs Spielen.", "", "Jede Geschichte braucht viele Hände.",
]
