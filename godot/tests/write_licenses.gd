extends SceneTree

func _initialize() -> void:
    var output := ""
    for arg in OS.get_cmdline_user_args():
        if arg.begins_with("--output="): output = arg.trim_prefix("--output=")
    if output.is_empty():
        quit(1)
        return
    var file := FileAccess.open(output, FileAccess.WRITE)
    if not file:
        quit(1)
        return
    file.store_string("GODOT ENGINE " + Engine.get_version_info().string + "\n\n")
    file.store_string(Engine.get_license_text())
    file.store_string("\n\nTHIRD-PARTY COPYRIGHT NOTICES\n\n")
    file.store_string(JSON.stringify(Engine.get_copyright_info(), "  "))
    file.store_string("\n\nTHIRD-PARTY LICENSES\n\n")
    var licenses := Engine.get_license_info()
    for name in licenses:
        file.store_string(name + "\n" + licenses[name] + "\n\n")
    file.close()
    quit()
