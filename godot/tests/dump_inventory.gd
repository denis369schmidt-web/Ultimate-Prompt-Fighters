extends SceneTree
## Prints one tab-separated line per roster fighter: stats, attacks, signature, finisher,
## model file, rig and texture use. Basis for the fighter inventory in docs/ROSTER_INVENTORY.md.
## Usage: godot --headless --path godot -s tests/dump_inventory.gd

const Prompt = preload("res://scripts/prompt_interpreter.gd")
const FighterView = preload("res://scripts/fighter_view.gd")
const Combat = preload("res://scripts/combat.gd")
const Signatures = preload("res://scripts/signatures.gd")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var app = load("res://main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	var presets: Array = app.mk_presets.duplicate(true)
	app.queue_free()
	await process_frame
	var n := 0
	var model_users := {}
	var rows: Array = []
	for preset in presets:
		if preset.id == "fusionskammer": continue
		n += 1
		var p: Dictionary = Prompt.interpret(preset.prompt, 0)
		var view = FighterView.new()
		root.add_child(view)
		view.setup(p)
		var path: String = view.get_meta("model_path")
		model_users[path] = model_users.get(path, []) + [preset.id]
		var bones: int = view.skeleton.get_bone_count() if view.skeleton != null else 0
		var rig := "keins"
		if view.skeleton != null:
			var first: String = view.skeleton.get_bone_name(0)
			rig = "Mixamo" if view.skeleton.find_bone("mixamorig_Hips") >= 0 or view.skeleton.find_bone("mixamorig:Hips") >= 0 or first.begins_with("mixamorig") else "eigen(%s)" % first
		var tex := 0
		var mats := 0
		for m in view.model.find_children("*", "MeshInstance3D", true, false):
			if m.mesh == null: continue
			for s in range(m.mesh.get_surface_count()):
				var mat = m.get_active_material(s)
				mats += 1
				if mat is BaseMaterial3D and mat.albedo_texture != null: tex += 1
		var sig: Dictionary = Signatures.for_family(p.family)
		var fin: Dictionary = Combat.finisher_for(p)
		rows.append([n, preset.id, preset.name, p.family, p.element, "%.2f" % p.weight, "%.2f" % p.speed,
			int(p.health), "%s/%s/%s/%s/%s" % [p.stats.vitality, p.stats.power, p.stats.defense, p.stats.speed, p.stats.technique],
			"%s r%.2f" % [p.standard.name, p.standard.range], "%s(%s)" % [p.special.name, p.special.get("type", "")],
			sig.get("mech", "-"), fin.name, path.get_file(), "%s %d" % [rig, bones], "%d/%d" % [tex, mats], p.get("modules", [])])
		view.free()
	for r in rows:
		print("INV\t" + "\t".join(r.map(func(v): return str(v))))
	for path in model_users:
		if model_users[path].size() > 1: print("SHARED\t%s\t%s" % [path.get_file(), ",".join(model_users[path])])
	quit()
