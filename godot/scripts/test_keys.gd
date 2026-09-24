extends SceneTree

func _initialize():
    var n = load("res://assets/models/ninja.glb").instantiate()
    var anim = n.find_children("*", "AnimationPlayer", true, false)[0]
    var idle = anim.get_animation("Ninja_Idle")
    for t in range(idle.get_track_count()):
        var path = str(idle.track_get_path(t))
        var type = idle.track_get_type(t)
        if "upperarm" in path or "lowerarm" in path:
            print("Track: ", path, " type=", type, " keys=", idle.track_get_key_count(t))
            for k in range(idle.track_get_key_count(t)):
                print("  key ", k, " time=", idle.track_get_key_time(t, k), " val=", idle.track_get_key_value(t, k))
    quit(0)
