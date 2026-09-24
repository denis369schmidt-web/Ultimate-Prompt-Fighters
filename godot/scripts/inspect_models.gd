extends SceneTree

func _initialize():
    for f in ["dragon", "valkyrie"]:
        print("=== Family: ", f, " ===")
        var scene = load("res://assets/models/" + f + ".glb").instantiate()
        var meshes = scene.find_children("*", "MeshInstance3D", true, false)
        print("Found ", meshes.size(), " meshes:")
        for m in meshes:
            var surfs = m.mesh.get_surface_count()
            var aabb = m.mesh.get_aabb()
            var mat_names = []
            for s in range(surfs):
                var mat = m.get_active_material(s)
                mat_names.append(mat.resource_name if mat else "null")
            print("  Mesh: ", m.name, " AABB=", aabb, " mats=", mat_names)
    quit(0)
