extends SceneTree

func _initialize():
    for family in ["ninja", "golem"]:
        var sc = load("res://assets/models/%s.glb" % family).instantiate()
        var skels = sc.find_children("*", "Skeleton3D", true, false)
        var anims = sc.find_children("*", "AnimationPlayer", true, false)
        print("=== Family: ", family, " ===")
        if skels.size() > 0:
            var sk = skels[0]
            print("Skeleton: ", sk.name, " bones=", sk.get_bone_count())
            for b in range(sk.get_bone_count()):
                print("  Bone ", b, ": ", sk.get_bone_name(b))
        if anims.size() > 0:
            var ap = anims[0]
            var clip_name = "%s_Idle" % ("Ninja" if family == "ninja" else "Golem")
            var anim = ap.get_animation(clip_name)
            if anim:
                print("Animation: ", clip_name, " tracks=", anim.get_track_count())
                for t in range(anim.get_track_count()):
                    print("  Track ", t, ": path=", anim.track_get_path(t), " type=", anim.track_get_type(t))
    quit(0)
