---
name: pfu-test
description: Runs the Prompt Fighters Godot test suites (all or one) headless and reports PFU_TEST_SUMMARY lines and failures. Use after any change to scripts/, tests/ or shaders/ in the godot project, or when the user asks to test.
---

# Prompt Fighters – Tests

Godot binary (Windows, winget):
`$LOCALAPPDATA/Microsoft/WinGet/Packages/GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe/Godot_v4.7.2-stable_win64_console.exe`

Project: `godot/` in this repo. Every `tests/test_*.gd` except `test_base.gd` is a suite.

## All suites (Git Bash)

```bash
cd godot
G="$LOCALAPPDATA/Microsoft/WinGet/Packages/GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe/Godot_v4.7.2-stable_win64_console.exe"
for t in tests/test_*.gd; do [ "$t" = tests/test_base.gd ] && continue
  timeout 900 "$G" --headless --path . -s "$t" 2>&1 | grep -E "PFU_TEST_SUMMARY|^FAIL|SCRIPT ERROR"; done
```

One suite: `"$G" --headless --path . -s tests/test_kits.gd`.

## Rules

- `SCRIPT ERROR` in a suite counts as a failure even when the summary says `failed=0`:
  the error aborts the test function and silently skips the checks after it.
- New PNG/OGG/WAV assets need `"$G" --headless --path . --import` once before tests see them.
- Files are CRLF. Patch with Python using `newline=''`; `sed -i` in Git Bash strips the CRs.
- Report the summary line of every suite; on failure show the FAIL lines and fix the cause,
  do not weaken a test unless the tested behavior was changed on purpose.
