extends SceneTree
## Lists, for each roster prompt, the resolved model, its skeleton and animation clips.

const Prompt = preload("res://scripts/prompt_interpreter.gd")
const FighterView = preload("res://scripts/fighter_view.gd")

const PROMPTS := [
	"Blitzschneller Schattenninja mit elektrischen Klingen",
	"Gepanzerter Lavagolem mit brennenden Fäusten",
	"Strahlende Moe Valkyrie Paladin Kriegerin mit Lichtflügeln und Rapier",
	"Mächtiger Cyber Drachenritter mit flammendem Drachen-Großschwert",
	"Son Goku Super Saiyan Kamehameha Dragon Ball Z",
	"Prinz Vegeta Saiyajin Royal Armor Final Flash Galick Gun",
	"Frieza Final Form Emperor Death Beam Supernova Dragon Ball Z",
	"Sub-Zero Lin Kuei Cryomancer ice ninja kori blade",
	"Pain Nagato Akatsuki Rinnegan Shinra Tensei",
	"Monkey D. Luffy Strohhut Gum-Gum One Piece Mugiwara",
	"Roronoa Zoro Santoryu Drei Schwerter Wado Ichimonji Onigiri",
	"Naruto Uzumaki Rasengan Konoha Stirnband Kyuubi Sage Mode",
	"Sasuke Uchiha Chidori Sharingan Kusanagi Shimenawa Blitz",
	"Saitama One Punch Man Serious Punch Caped Baldy Hero",
	"Tanjiro Kamado Hinokami Kagura Nichirin Hanafuda Checkered Haori",
	"Sonic the Hedgehog Blue Blur Super Spin Dash Sega",
	"Akaza Upper Rank 3 Hakai Satsu Compass Needle Kimetsu",
	"Weißer Drache mit eiskaltem Blick Burst Stream Yu-Gi-Oh",
	"Glurak Flammen-Drache Drachenschwingen Feuersturm Pokemon",
	"Jackal God Anubis wielding dual Khopesh",
	"Void Specter crystal phantom warrior with void lance",
	"Phoenix Empress with feather armor and phoenix glaive",
	"Golden Armored Golem ancient guardian titan Tripo",
	"Fran rabbit warrior huntress bow Tripo",
	"Thorn Sorceress dark magic Tripo",
	"Nyx Harvester of Souls demon scythe reaper Tripo",
	"Cat Girl Kitsune Warrior blade Tripo",
	"Blue Wyrm Frost Dragon beast Tripo",
	"White Cyborg Android Mech warrior Tripo",
	"Reaper Skeleton Hound nether beast Tripo",
	"Ancient Treant Wood Golem nature Tripo",
	"Celestial Nine Tailed Fox Kyuubi spirit Tripo",
	"Sylvan Beast Treant quadruped creature Tripo",
	"Steel Knight Ritter in Vollplatte mit eisernem Schild",
	"Vanguard Soldat mit Cyber-Rüstung und Photonenkanone",
	"Sorceress Medea Erzmagierin mit astraler Dunkelmagie",
	"Skeleton Reaper Untoter Seelenernter mit Knochensense",
	"Mutant Titan kolossaler Koloss mit Giftschlag",
	"SWAT SpecOps Taktischer Agent mit Schockgranaten",
	"Samurai Dreyar Meister mit Wind-Klingen und Sturm-Schritten",
	"Korsar Corsair Piratenkapitän mit Entermesser und Donnerbüchse",
	"Vampirfürst Vlad Gothic Lord mit Blut-Magie und Fledermaus-Schwarm",
	"Erzmagier Pyrus Feuerzauberer mit Meteorschlag und Flammenstab",
	"Warrok Koloss Urzeitlicher Berserker mit Knochenkeule und Erdbeben",
]

func _initialize() -> void:
	var scene := Node3D.new()
	root.add_child(scene)
	for text in PROMPTS:
		var p: Dictionary = Prompt.interpret(text, 0)
		var t0 := Time.get_ticks_usec()
		var view = FighterView.new()
		scene.add_child(view)
		view.setup(p)
		var ms := (Time.get_ticks_usec() - t0) / 1000.0
		var clips: Array = []
		if view.animation:
			clips = Array(view.animation.get_animation_list())
		var bones: int = view.skeleton.get_bone_count() if view.skeleton else 0
		var meshes: int = view.model.find_children("*", "MeshInstance3D", true, false).size()
		print("ROSTER|%s|%s|model=%s|bones=%d|meshes=%d|setup_ms=%.0f|mapped=%s|clips=%s" % [
			p.family, p.name, view.get_meta("model_path", "?"), bones, meshes, ms, str(view.clip_map.keys()), str(clips)])
		view.free()
	quit(0)
