@echo off
setlocal
if not exist "%~dp0builds\windows\PromptFighterUltimate.exe" (
  echo Der Windows-Build fehlt. Bitte zuerst scripts\Build-Windows.ps1 ausfuehren.
  pause
  exit /b 1
)
start "" /D "%~dp0builds\windows" "%~dp0builds\windows\PromptFighterUltimate.exe"
