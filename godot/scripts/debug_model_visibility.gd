extends SceneTree

const Prompt = preload("res://scripts/prompt_interpreter.gd")
const FighterView = preload("res://scripts/fighter_view.gd")

func _initialize():
	var scene = Node3D.new()
	root.add_child(scene)
	
	var prof = Prompt.interpret("golem", 0)
	var v = FighterView.new()
	scene.add_child(v)
	v.setup(prof)
	
	print("V Position: ", v.position, " Visible: ", v.visible)
	print("Model: ", v.model, " Model Visible: ", v.model.visible if v.model else "NO_MODEL", " Scale: ", v.model.scale if v.model else "NONE")
	
	if v.model:
		var meshes = v.model.find_children("*", "MeshInstance3D", true, false)
		print("Total Meshes: ", meshes.size())
		for i in range(min(5, meshes.size())):
			var m = meshes[i]
			print(" Mesh ", m.name, " Vis: ", m.visible, " GlobalPos: ", m.global_position, " MeshAABB: ", m.mesh.get_aabb() if m.mesh else "NO_MESH")
			print("   ActiveMat: ", m.get_active_material(0), " OverrideMat: ", m.get_surface_override_material(0))
			if m.get_surface_override_material(0):
				var mat = m.get_surface_override_material(0)
				print("   Mat AlbedoCol: ", mat.albedo_color, " AlbedoTex: ", mat.albedo_texture, " Cull: ", mat.cull_mode, " Triplanar: ", mat.uv1_triplanar, " Scale: ", mat.uv1_scale)
	
	quit(0)
