extends SceneTree

const PRESETS = [
	{"id": "ninja", "name": "VOLT NINJA", "prompt": "Blitzschneller Schattenninja mit elektrischen Klingen"},
	{"id": "golem", "name": "LAVA GOLEM", "prompt": "Gepanzerter Lavagolem mit brennenden Fäusten"},
	{"id": "valkyrie", "name": "VALKYRIE", "prompt": "Strahlende Moe Valkyrie Paladin Kriegerin mit Lichtflügeln und Rapier"},
	{"id": "dragon", "name": "IGNIS DRAKE", "prompt": "Mächtiger Cyber Drachenritter mit flammendem Drachen-Großschwert"},
	{"id": "goku", "name": "SON GOKU", "prompt": "Son Goku Super Saiyan Kamehameha Dragon Ball Z"},
	{"id": "vegeta", "name": "VEGETA", "prompt": "Prinz Vegeta Saiyajin Royal Armor Final Flash Galick Gun"},
	{"id": "frieza", "name": "FREEZER", "prompt": "Frieza Final Form Emperor Death Beam Supernova Dragon Ball Z"},
	{"id": "subzero", "name": "SUB-ZERO", "prompt": "Sub-Zero Lin Kuei Cryomancer ice ninja kori blade"},
	{"id": "pain", "name": "PAIN", "prompt": "Pain Nagato Akatsuki Rinnegan Shinra Tensei"},
	{"id": "luffy", "name": "RUFFY", "prompt": "Monkey D. Luffy Strohhut Gum-Gum One Piece Mugiwara"},
	{"id": "zoro", "name": "ZORO", "prompt": "Roronoa Zoro Santoryu Drei Schwerter Wado Ichimonji Onigiri"},
	{"id": "naruto", "name": "NARUTO", "prompt": "Naruto Uzumaki Rasengan Konoha Stirnband Kyuubi Sage Mode"},
	{"id": "sasuke", "name": "SASUKE", "prompt": "Sasuke Uchiha Chidori Sharingan Kusanagi Shimenawa Blitz"},
	{"id": "saitama", "name": "SAITAMA", "prompt": "Saitama One Punch Man Serious Punch Caped Baldy Hero"},
	{"id": "tanjiro", "name": "TANJIRO", "prompt": "Tanjiro Kamado Hinokami Kagura Nichirin Hanafuda Checkered Haori"},
	{"id": "sonic", "name": "SONIC", "prompt": "Sonic the Hedgehog Blue Blur Super Spin Dash Sega"},
	{"id": "akaza", "name": "AKAZA", "prompt": "Akaza Upper Rank 3 Hakai Satsu Compass Needle Kimetsu"},
	{"id": "blue_eyes", "name": "BLUE-EYES", "prompt": "Weißer Drache mit eiskaltem Blick Burst Stream Yu-Gi-Oh"},
	{"id": "charizard", "name": "GLURAK", "prompt": "Glurak Flammen-Drache Drachenschwingen Feuersturm Pokemon"},
	{"id": "anubis", "name": "ANUBIS", "prompt": "Jackal God Anubis wielding dual Khopesh"},
	{"id": "specter", "name": "SPECTER", "prompt": "Void Specter crystal phantom warrior with void lance"},
	{"id": "phoenix", "name": "PHOENIX", "prompt": "Phoenix Empress with feather armor and phoenix glaive"},
	{"id": "golden_golem", "name": "GOLD GOLEM", "prompt": "Golden Armored Golem ancient guardian titan Tripo"},
	{"id": "tripo_fran_statue", "name": "FRAN VIERA", "prompt": "Fran rabbit warrior huntress bow Tripo"},
	{"id": "tripo_fantasy_female", "name": "THORN WITCH", "prompt": "Thorn Sorceress dark magic Tripo"},
	{"id": "tripo_nyx_harvester", "name": "NYX HARVESTER", "prompt": "Nyx Harvester of Souls demon scythe reaper Tripo"},
	{"id": "tripo_cat_girl", "name": "KITSUNE", "prompt": "Cat Girl Kitsune Warrior blade Tripo"},
	{"id": "tripo_dragon_blue", "name": "BLUE WYRM", "prompt": "Blue Wyrm Frost Dragon beast Tripo"},
	{"id": "tripo_white_sci", "name": "CYBORG MECH", "prompt": "White Cyborg Android Mech warrior Tripo"},
	{"id": "tripo_skeleton_dog", "name": "REAPER HOUND", "prompt": "Reaper Skeleton Hound nether beast Tripo"},
	{"id": "tripo_wooden_forest", "name": "TREANT GOLEM", "prompt": "Ancient Treant Wood Golem nature Tripo"},
	{"id": "tripo_nine_tailed", "name": "CELESTIAL FOX", "prompt": "Celestial Nine Tailed Fox Kyuubi spirit Tripo"},
	{"id": "tripo_quadruped_tree", "name": "SYLVAN BEAST", "prompt": "Sylvan Beast Treant quadruped creature Tripo"},
	{"id": "steel_knight", "name": "STEEL KNIGHT", "prompt": "Steel Knight Ritter in Vollplatte mit eisernem Schild"},
	{"id": "vanguard_soldier", "name": "VANGUARD", "prompt": "Vanguard Soldat mit Cyber-Rüstung und Photonenkanone"},
	{"id": "sorceress_medea", "name": "SORCERESS", "prompt": "Sorceress Medea Erzmagierin mit astraler Dunkelmagie"},
	{"id": "skeleton_reaper", "name": "REAPER", "prompt": "Skeleton Reaper Untoter Seelenernter mit Knochensense"},
	{"id": "mutant_titan", "name": "MUTANT", "prompt": "Mutant Titan kolossaler Koloss mit Giftschlag"},
	{"id": "swat_specops", "name": "SWAT AGENT", "prompt": "SWAT SpecOps Taktischer Agent mit Schockgranaten"},
	{"id": "samurai_dreyar", "name": "SAMURAI", "prompt": "Samurai Dreyar Meister mit Wind-Klingen und Sturm-Schritten"},
	{"id": "pirate_captain", "name": "KORSAR", "prompt": "Korsar Corsair Piratenkapitän mit Entermesser und Donnerbüchse"},
	{"id": "vampire_lord", "name": "VLAD", "prompt": "Vampirfürst Vlad Gothic Lord mit Blut-Magie und Fledermaus-Schwarm"},
	{"id": "wizard_sorcerer", "name": "PYRUS", "prompt": "Erzmagier Pyrus Feuerzauberer mit Meteorschlag und Flammenstab"},
	{"id": "warrok_brute", "name": "WARROK", "prompt": "Warrok Koloss Urzeitlicher Berserker mit Knochenkeule und Erdbeben"},
	{"id": "fusionskammer", "name": "FUSION", "prompt": "Fusionskammer: Eigenen Wunsch-Kämpfer erschaffen"}
]

func _init() -> void:
	print("--- TESTE ALLE KÄMPFER IM ROSTER ---")
	var interp = load("res://scripts/prompt_interpreter.gd").new()
	var fview_script = load("res://scripts/fighter_view.gd")

	for i in range(PRESETS.size()):
		var entry = PRESETS[i]
		var prompt = entry.get("prompt", "")
		var prof = interp.interpret(prompt, 0)
		var view = Node3D.new()
		view.set_script(fview_script)
		
		var root = Node3D.new()
		root.add_child(view)
		
		view.setup(prof)
		
		var skel_info := "No Skel"
		if view.skeleton != null:
			skel_info = "Skel (" + str(view.skeleton.get_bone_count()) + " bones)"
			var mapped: Array = []
			for k in view.bone_map:
				mapped.append(k + ":" + str(view.bone_map[k]))
			skel_info += " [mapped: " + ", ".join(mapped) + "]"
		
		for pose in ["Idle", "Move", "Attack", "SpecialAttack", "HitReact", "Victory"]:
			view.update_state({"x": 0.0, "y": 0.0, "facing": 1.0, "pose": pose, "blocking": false}, 0.016)

		var model_desc = "NULL"
		if view.model != null:
			model_desc = view.model.name
		print(str(i+1).pad_zeros(2), ": ", prof.name, " (fam: ", prof.family, ") -> Model: ", model_desc, " | ", skel_info)
		root.queue_free()

	print("--- ALLE KÄMPFER ERFOLGREICH GETESTET ---")
	quit()
