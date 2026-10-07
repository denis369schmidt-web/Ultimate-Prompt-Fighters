"""Builds the official AAA 1080p60 Gameplay Trailer for Steam and Google Play.
Generates:
  store/trailer/prompt_fighters_trailer_1080p60.mp4
  store/steam/trailer_1080p60.mp4
  store/play/trailer_1080p60.mp4
  store/steam/trailer_1080p60.webm

Requires: ffmpeg, Pillow, numpy
"""
import os
import subprocess
import sys
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter

WIDTH = 1920
HEIGHT = 1080
FPS = 60
FONT_PATH = "godot/assets/fonts/RussoOne-Regular.ttf"

OUT_DIR = "store/trailer"
os.makedirs(OUT_DIR, exist_ok=True)
os.makedirs("store/steam", exist_ok=True)
os.makedirs("store/play", exist_ok=True)

TEMP_DIR = "scratch/trailer_build"
os.makedirs(TEMP_DIR, exist_ok=True)

font_large = ImageFont.truetype(FONT_PATH, 54)
font_sub = ImageFont.truetype(FONT_PATH, 28)
font_brand = ImageFont.truetype(FONT_PATH, 72)
font_callout = ImageFont.truetype(FONT_PATH, 34)

def load_shot(name):
    path = os.path.join("store/steam/screenshots", name)
    if not os.path.exists(path):
        path = os.path.join("store/raw", name)
    img = Image.open(path).convert("RGBA")
    if img.size != (WIDTH, HEIGHT):
        img = img.resize((WIDTH, HEIGHT), Image.LANCZOS)
    return img

def render_lower_third(title, subtitle=None, tag="PROMPT FIGHTERS ULTIMATE", accent_color=(255, 176, 32)):
    overlay = Image.new("RGBA", (WIDTH, HEIGHT), (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    
    # Cinematic subtle top/bottom letterbox bars
    draw.rectangle([(0, 0), (WIDTH, 36)], fill=(0, 0, 0, 220))
    draw.rectangle([(0, HEIGHT - 36), (WIDTH, HEIGHT)], fill=(0, 0, 0, 220))
    
    # Lower third container
    box_w = 1100
    box_h = 130 if subtitle else 96
    box_x = 70
    box_y = HEIGHT - box_h - 70
    
    # Dark frosted glass backing
    draw.rounded_rectangle([(box_x, box_y), (box_x + box_w, box_y + box_h)], radius=12, fill=(10, 14, 24, 230), outline=(accent_color[0], accent_color[1], accent_color[2], 240), width=3)
    
    # Glowing accent notch on left
    draw.rounded_rectangle([(box_x + 4, box_y + 8), (box_x + 14, box_y + box_h - 8)], radius=4, fill=(accent_color[0], accent_color[1], accent_color[2], 255))
    
    # Tag
    draw.text((box_x + 36, box_y + 12), tag.upper(), font=font_sub, fill=(160, 185, 220, 220))
    
    # Title
    draw.text((box_x + 36, box_y + 44), title.upper(), font=font_large, fill=(255, 255, 255, 255))
    
    # Subtitle
    if subtitle:
        draw.text((box_x + 36, box_y + 104), subtitle.upper(), font=font_sub, fill=(accent_color[0], accent_color[1], accent_color[2], 255))
        
    return overlay

def render_outro_overlay():
    overlay = Image.new("RGBA", (WIDTH, HEIGHT), (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    
    # Center modal
    mw, mh = 1400, 620
    mx = (WIDTH - mw) // 2
    my = (HEIGHT - mh) // 2
    
    draw.rounded_rectangle([(mx, my), (mx + mw, my + mh)], radius=24, fill=(8, 12, 22, 235), outline=(255, 176, 32, 255), width=4)
    
    # Title
    t = "PROMPT FIGHTERS ULTIMATE"
    tb = draw.textbbox((0, 0), t, font=font_brand)
    tw = tb[2] - tb[0]
    draw.text((mx + (mw - tw) // 2, my + 80), t, font=font_brand, fill=(255, 255, 255, 255))
    
    # Subtitle
    sub = "/// NEXT-GEN PLATFORM FIGHTER — 58 WARRIORS — FUSION CHAMBER ///"
    sb = draw.textbbox((0, 0), sub, font=font_sub)
    sw = sb[2] - sb[0]
    draw.text((mx + (mw - sw) // 2, my + 180), sub, font=font_sub, fill=(56, 189, 248, 255))
    
    # Steam Callout button
    bx1 = mx + 160
    by1 = my + 320
    bw = 480
    bh = 110
    draw.rounded_rectangle([(bx1, by1), (bx1 + bw, by1 + bh)], radius=16, fill=(20, 32, 54, 255), outline=(56, 189, 248, 255), width=3)
    st = "★ WISHLIST NOW ON STEAM"
    stb = draw.textbbox((0, 0), st, font=font_callout)
    stw = stb[2] - stb[0]
    draw.text((bx1 + (bw - stw) // 2, by1 + 35), st, font=font_callout, fill=(255, 255, 255, 255))
    
    # Google Play Callout button
    bx2 = mx + mw - 160 - bw
    draw.rounded_rectangle([(bx2, by1), (bx2 + bw, by1 + bh)], radius=16, fill=(36, 24, 12, 255), outline=(255, 176, 32, 255), width=3)
    gt = "▶ GET IT ON GOOGLE PLAY"
    gtb = draw.textbbox((0, 0), gt, font=font_callout)
    gtw = gtb[2] - gtb[0]
    draw.text((bx2 + (bw - gtw) // 2, by1 + 35), gt, font=font_callout, fill=(255, 255, 255, 255))
    
    # Footer
    foot = "100% OFFLINE CAPABLE · ZERO MICROTRANSACTIONS · NO LOOTBOXES"
    fb = draw.textbbox((0, 0), foot, font=font_sub)
    fw = fb[2] - fb[0]
    draw.text((mx + (mw - fw) // 2, my + 490), foot, font=font_sub, fill=(148, 163, 184, 255))
    
    return overlay

print("Extracting intro clip...")
# Extract first 4.6 seconds (276 frames) from godot/assets/video/intro.ogv as 1920x1080 60fps
intro_clip_path = os.path.join(TEMP_DIR, "part00_intro.mp4")
subprocess.run([
    "ffmpeg", "-y", "-i", "godot/assets/video/intro.ogv",
    "-t", "4.6",
    "-vf", "scale=1920:1080:flags=lanczos,fps=60",
    "-c:v", "libx264", "-preset", "fast", "-crf", "17",
    "-pix_fmt", "yuv420p",
    intro_clip_path
], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
print("Intro clip extracted.")

# Define trailer scenes
# Each scene: (shot_filename, duration_sec, title, subtitle, accent_color, zoom_in_bool)
scenes = [
    ("screenshot_01_1920x1080.jpg", 5.8, "58 UNIQUE FIGHTERS", "15x4 ROSTER GRID · CUSTOM STATS & PLAYSTYLES", (56, 189, 248), True),
    ("screenshot_02_1920x1080.jpg", 6.0, "ASTRAL OBSIDIAN NEXUS", "DYNAMIC ROTATING RINGS & INTERACTIVE HAZARDS", (192, 132, 252), False),
    ("screenshot_03_1920x1080.jpg", 5.8, "SIGNATURE ABILITIES", "FROST & EMBER CROWNS · TIME BOMBS · GLITCH SWAPS", (244, 114, 182), True),
    ("screenshot_04_1920x1080.jpg", 6.2, "4-PLAYER LOCAL COUCH BRAWL", "FREE-FOR-ALL · 2v2 TAG TEAMS · WEAPON DROPS & TRAPS", (251, 191, 36), False),
    ("screenshot_07_1920x1080.jpg", 6.5, "PROMPT FUSION CHAMBER", "TYPE ANY CONCEPT → INSTANT 3D FIGHTER (100% OFFLINE)", (168, 85, 247), True),
    ("screenshot_06_1920x1080.jpg", 5.8, "COLOSSAL BOSS BATTLES", "21-CHAPTER CAMPAIGN · INFERNAL LORDS & ANGELIC CHOIRS", (239, 68, 68), False),
    ("screenshot_05_1920x1080.jpg", 5.5, "CINEMATIC FINISHERS", "OVER 50+ STUNNING FINISHER EXECUTIONS", (249, 115, 22), True),
]

segment_files = [intro_clip_path]

for idx, (shot_file, dur, title, sub, accent, zoom) in enumerate(scenes, 1):
    print(f"Rendering scene {idx}: {title} ({dur}s)...")
    base_img = load_shot(shot_file)
    overlay = render_lower_third(title, sub, accent_color=accent)
    
    total_frames = int(dur * FPS)
    seg_mp4 = os.path.join(TEMP_DIR, f"part{idx:02d}.mp4")
    
    # Pipe frames directly to ffmpeg
    cmd = [
        "ffmpeg", "-y",
        "-f", "rawvideo", "-vcodec", "rawvideo",
        "-s", f"{WIDTH}x{HEIGHT}", "-pix_fmt", "rgba",
        "-r", str(FPS), "-i", "-",
        "-c:v", "libx264", "-preset", "ultrafast", "-crf", "18",
        "-pix_fmt", "yuv420p",
        seg_mp4
    ]
    proc = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    
    # Animate subtle Ken Burns camera zoom/pan
    for f in range(total_frames):
        t = f / float(total_frames)
        scale = 1.0 + (0.07 * t if zoom else 0.07 * (1.0 - t))
        
        # Scale base image
        sw = int(WIDTH * scale)
        sh = int(HEIGHT * scale)
        scaled = base_img.resize((sw, sh), Image.BILINEAR)
        cx = (sw - WIDTH) // 2
        cy = (sh - HEIGHT) // 2
        frame = scaled.crop((cx, cy, cx + WIDTH, cy + HEIGHT))
        
        # Lower third fade-in
        fade_t = min(1.0, f / 18.0)
        if fade_t < 1.0:
            ol = overlay.copy()
            r, g, b, a = ol.split()
            a = a.point(lambda v: int(v * fade_t))
            ol.putalpha(a)
            frame.alpha_composite(ol)
        else:
            frame.alpha_composite(overlay)
            
        proc.stdin.write(frame.tobytes())
        
    proc.stdin.close()
    proc.wait()
    segment_files.append(seg_mp4)

# Render Scene 8: Outro CTA (5.5s)
print("Rendering outro scene...")
outro_dur = 5.5
outro_frames = int(outro_dur * FPS)
outro_bg = load_shot("screenshot_08_1920x1080.jpg").filter(ImageFilter.GaussianBlur(10))
outro_overlay = render_outro_overlay()
outro_mp4 = os.path.join(TEMP_DIR, "part08_outro.mp4")

cmd = [
    "ffmpeg", "-y",
    "-f", "rawvideo", "-vcodec", "rawvideo",
    "-s", f"{WIDTH}x{HEIGHT}", "-pix_fmt", "rgba",
    "-r", str(FPS), "-i", "-",
    "-c:v", "libx264", "-preset", "ultrafast", "-crf", "18",
    "-pix_fmt", "yuv420p",
    outro_mp4
]
proc = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
for f in range(outro_frames):
    t = f / float(outro_frames)
    scale = 1.0 + 0.04 * t
    sw = int(WIDTH * scale)
    sh = int(HEIGHT * scale)
    scaled = outro_bg.resize((sw, sh), Image.BILINEAR)
    cx = (sw - WIDTH) // 2
    cy = (sh - HEIGHT) // 2
    frame = scaled.crop((cx, cy, cx + WIDTH, cy + HEIGHT))
    
    fade_t = min(1.0, f / 24.0)
    ol = outro_overlay.copy()
    r, g, b, a = ol.split()
    a = a.point(lambda v: int(v * fade_t))
    ol.putalpha(a)
    frame.alpha_composite(ol)
    
    proc.stdin.write(frame.tobytes())
    
proc.stdin.close()
proc.wait()
segment_files.append(outro_mp4)

print("Concatenating video segments...")
# Create concat list
concat_list_file = os.path.join(TEMP_DIR, "concat.txt")
with open(concat_list_file, "w", encoding="utf-8") as f:
    for seg in segment_files:
        abs_seg = os.path.abspath(seg).replace("\\", "/")
        f.write(f"file '{abs_seg}'\n")

raw_video_path = os.path.join(TEMP_DIR, "combined_video.mp4")
subprocess.run([
    "ffmpeg", "-y", "-f", "concat", "-safe", "0",
    "-i", concat_list_file,
    "-c", "copy",
    raw_video_path
], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

# Get combined video duration
probe = subprocess.run([
    "ffprobe", "-v", "error", "-show_entries", "format=duration",
    "-of", "default=noprint_wrappers=1:nokey=1", raw_video_path
], capture_output=True, text=True, check=True)
total_duration = float(probe.stdout.strip())
print(f"Total video duration: {total_duration:.2f} seconds.")

print("Composing high-impact audio mix...")
# Mix battle_valor music with announcer lines
mixed_audio_path = os.path.join(TEMP_DIR, "soundtrack.wav")
filter_complex = (
    # [0] battle_valor music starting at 4.4s with 0.8s fade-in, volume 0.75
    "[0:a]adelay=4400|4400,afade=t=in:st=4.4:d=0.8,afade=t=out:st=49.0:d=2.5,volume=0.75[music];"
    # [1] ready.ogg at 5.0s
    "[1:a]adelay=5000|5000,volume=1.3[ready];"
    # [2] choose_your_character.ogg at 7.0s
    "[2:a]adelay=7000|7000,volume=1.35[choose];"
    # [3] fight.ogg at 11.2s
    "[3:a]adelay=11200|11200,volume=1.4[fight];"
    # [4] combo.ogg at 24.5s
    "[4:a]adelay=24500|24500,volume=1.3[combo];"
    # [5] winner.ogg at 48.0s
    "[5:a]adelay=48000|48000,volume=1.35[winner];"
    # [6] PFU_Hit at 11.0s and 43.5s
    "[6:a]asplit=2[hit1][hit2];"
    "[hit1]adelay=11000|11000,volume=1.2[hit_s1];"
    "[hit2]adelay=43500|43500,volume=1.5[hit_s2];"
    # Merge all
    "[music][ready][choose][fight][combo][winner][hit_s1][hit_s2]amix=inputs=8:duration=first:dropout_transition=2[outa]"
)

subprocess.run([
    "ffmpeg", "-y",
    "-i", "godot/assets/audio/music/battle_valor.ogg",
    "-i", "godot/assets/audio/voice/announcer/ready.ogg",
    "-i", "godot/assets/audio/voice/announcer/choose_your_character.ogg",
    "-i", "godot/assets/audio/voice/announcer/fight.ogg",
    "-i", "godot/assets/audio/voice/announcer/combo.ogg",
    "-i", "godot/assets/audio/voice/announcer/winner.ogg",
    "-i", "godot/assets/audio/PFU_Hit.wav",
    "-filter_complex", filter_complex,
    "-map", "[outa]",
    "-t", str(total_duration),
    mixed_audio_path
], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

print("Muxing final 1080p60 MP4 master...")
final_mp4 = os.path.join(OUT_DIR, "prompt_fighters_trailer_1080p60.mp4")
subprocess.run([
    "ffmpeg", "-y",
    "-i", raw_video_path,
    "-i", mixed_audio_path,
    "-c:v", "libx264", "-preset", "medium", "-crf", "18",
    "-c:a", "aac", "-b:a", "320k", "-ar", "48000",
    "-pix_fmt", "yuv420p",
    "-shortest",
    final_mp4
], check=True)

# Copy to store/steam and store/play
import shutil
shutil.copyfile(final_mp4, "store/steam/trailer_1080p60.mp4")
shutil.copyfile(final_mp4, "store/play/trailer_1080p60.mp4")
print("Exported to store/steam/trailer_1080p60.mp4 and store/play/trailer_1080p60.mp4")

# Also export WebM for Steam
print("Exporting WebM version for Steam...")
final_webm = "store/steam/trailer_1080p60.webm"
subprocess.run([
    "ffmpeg", "-y",
    "-i", final_mp4,
    "-c:v", "libvpx-vp9", "-b:v", "4000k", "-crf", "24", "-cpu-used", "4", "-row-mt", "1", "-threads", "8",
    "-c:a", "libopus", "-b:a", "192k",
    final_webm
], check=True)
print("Exported to store/steam/trailer_1080p60.webm")

size_mb = os.path.getsize(final_mp4) / (1024 * 1024)
print(f"TRAILER BUILD COMPLETE: {final_mp4} ({size_mb:.2f} MB, {total_duration:.1f}s, 1080p60)")
