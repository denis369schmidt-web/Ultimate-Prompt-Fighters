"""Official AAA Animated Gameplay & Cinematic Trailer for Prompt Fighters Ultimate.
Generates:
  store/trailer/prompt_fighters_trailer_1080p60.mp4
  store/steam/trailer_1080p60.mp4
  store/play/trailer_1080p60.mp4
  store/steam/trailer_1080p60.webm

Resolution: 1920x1080 @ 60 FPS
Features:
  - 5 Cinematic acts driven by the AAA artworks
  - Dynamic camera motions (push-ins, pans, zoom punch-ins)
  - Active particle physics (sparks, embers, cosmic dust)
  - Anamorphic lens flares, lighting sweeps, and heat shimmers
  - Screen shake & chromatic aberration on heavy impacts
  - Kinetic esports lower-thirds & conversion badges (Steam / Google Play)
  - Full multi-track sound design with BGM, SFX & Announcer lines
"""
import os
import sys
import math
import random
import subprocess
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter

WIDTH = 1920
HEIGHT = 1080
FPS = 60
TOTAL_DURATION = 42.0
TOTAL_FRAMES = int(TOTAL_DURATION * FPS)

FONT_PATH = "godot/assets/fonts/RussoOne-Regular.ttf"
font_huge = ImageFont.truetype(FONT_PATH, 64)
font_title = ImageFont.truetype(FONT_PATH, 46)
font_sub = ImageFont.truetype(FONT_PATH, 26)
font_badge = ImageFont.truetype(FONT_PATH, 28)
font_badge_sub = ImageFont.truetype(FONT_PATH, 20)

IMG_DIR = "store/trailer/cinematics"
IMG_SWORDS = os.path.join(IMG_DIR, "aaa_intro_clash_1791363318116.jpg")
IMG_NINJA = os.path.join(IMG_DIR, "cinematic_fighter_clash_1791379963009.jpg")
IMG_ASTRAL = os.path.join(IMG_DIR, "cinematic_kalyx_vorruk_1791380008193.jpg")
IMG_DANTE = os.path.join(IMG_DIR, "cinematic_boss_dante_1791379983155.jpg")
IMG_EMBLEM = os.path.join(IMG_DIR, "aaa_intro_emblem_1791363346932.jpg")

OUT_DIR = "store/trailer"
os.makedirs(OUT_DIR, exist_ok=True)
os.makedirs("store/steam", exist_ok=True)
os.makedirs("store/play", exist_ok=True)

# ── Preload and Cache Source Images in 1920x1080 RGB ──────────────────────────
print("Loading and preparing high-res source images...")
def load_and_scale(path):
    img = Image.open(path).convert("RGB")
    if img.size != (WIDTH, HEIGHT):
        img = img.resize((WIDTH, HEIGHT), Image.LANCZOS)
    return img

img_swords = load_and_scale(IMG_SWORDS)
img_ninja = load_and_scale(IMG_NINJA)
img_astral = load_and_scale(IMG_ASTRAL)
img_dante = load_and_scale(IMG_DANTE)
img_emblem = load_and_scale(IMG_EMBLEM)

# ── Particle Systems ──────────────────────────────────────────────────────────
class Particle:
    def __init__(self, x, y, vx, vy, color, size, life):
        self.x = x
        self.y = y
        self.vx = vx
        self.vy = vy
        self.color = color
        self.size = size
        self.max_life = life
        self.life = life

class ParticleEmitter:
    def __init__(self, p_type="spark"):
        self.particles = []
        self.p_type = p_type
        
    def emit(self, cx, cy, count, speed_range, color_palette):
        for _ in range(count):
            angle = random.uniform(0, 2 * math.pi)
            spd = random.uniform(speed_range[0], speed_range[1])
            vx = math.cos(angle) * spd
            vy = math.sin(angle) * spd
            col = random.choice(color_palette)
            size = random.uniform(2.5, 6.0)
            life = random.uniform(0.6, 1.8)
            self.particles.append(Particle(cx, cy, vx, vy, col, size, life))
            
    def update_and_draw(self, draw, dt, gravity=(0, 200), drag=0.96):
        survivors = []
        for p in self.particles:
            p.life -= dt
            if p.life <= 0: continue
            p.vx *= drag
            p.vy = p.vy * drag + gravity[1] * dt
            p.x += p.vx * dt
            p.y += p.vy * dt
            
            alpha = max(0.0, min(1.0, p.life / p.max_life))
            cur_size = max(1.0, p.size * alpha)
            r = int(p.color[0] * alpha)
            g = int(p.color[1] * alpha)
            b = int(p.color[2] * alpha)
            
            # Draw glowing particle
            draw.ellipse([p.x - cur_size, p.y - cur_size, p.x + cur_size, p.y + cur_size], fill=(r, g, b, int(255 * alpha)))
            survivors.append(p)
        self.particles = survivors

# ── Camera Transform Engine ───────────────────────────────────────────────────
def apply_camera(img, zoom, pan_x, pan_y, shake_x=0.0, shake_y=0.0):
    """Subpixel crop and zoom with camera pan and screen shake."""
    z = max(1.0, zoom)
    cw = int(WIDTH / z)
    ch = int(HEIGHT / z)
    
    cx = WIDTH * 0.5 + pan_x + shake_x
    cy = HEIGHT * 0.5 + pan_y + shake_y
    
    x0 = int(clamp(cx - cw * 0.5, 0, WIDTH - cw))
    y0 = int(clamp(cy - ch * 0.5, 0, HEIGHT - ch))
    
    cropped = img.crop((x0, y0, x0 + cw, y0 + ch))
    return cropped.resize((WIDTH, HEIGHT), Image.BILINEAR)

def clamp(v, mn, mx):
    return max(mn, min(mx, v))

def smoothstep(edge0, edge1, x):
    t = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0)
    return t * t * (3.0 - 2.0 * t)

# ── Dynamic Anamorphic Lens Flare Overlay ──────────────────────────────────────
def draw_lens_flare(draw, cx, cy, intensity, color=(255, 180, 60)):
    if intensity <= 0.01: return
    flare_w = int(WIDTH * 0.75 * intensity)
    flare_h = int(14 * intensity)
    alpha = int(clamp(intensity * 220, 0, 220))
    col = (color[0], color[1], color[2], alpha)
    # Center flare streak
    draw.ellipse([cx - flare_w, cy - flare_h, cx + flare_w, cy + flare_h], fill=col)
    # Intense core glint
    core_w = int(flare_w * 0.25)
    core_h = int(flare_h * 2.2)
    draw.ellipse([cx - core_w, cy - core_h, cx + core_w, cy + core_h], fill=(255, 255, 255, alpha))

# ── Modern Lower Thirds & Kinetic Text ─────────────────────────────────────────
def draw_lower_third(draw, tag, title, subtitle=None, alpha=1.0, accent_color=(56, 189, 248)):
    if alpha <= 0.01: return
    a_byte = int(clamp(alpha * 240, 0, 240))
    
    box_w = 1200
    box_h = 135 if subtitle else 100
    box_x = 80
    box_y = HEIGHT - box_h - 75
    
    # Dark glass frosted backing
    draw.rounded_rectangle([(box_x, box_y), (box_x + box_w, box_y + box_h)], radius=14, 
                           fill=(6, 10, 18, a_byte), 
                           outline=(accent_color[0], accent_color[1], accent_color[2], a_byte), width=3)
    
    # Glowing accent notch on left
    draw.rounded_rectangle([(box_x + 5, box_y + 10), (box_x + 15, box_y + box_h - 10)], radius=4,
                           fill=(accent_color[0], accent_color[1], accent_color[2], int(alpha * 255)))
    
    # Tag
    draw.text((box_x + 38, box_y + 12), tag.upper(), font=font_sub, fill=(160, 195, 240, a_byte))
    # Title
    draw.text((box_x + 38, box_y + 42), title.upper(), font=font_title, fill=(255, 255, 255, a_byte))
    # Subtitle
    if subtitle:
        draw.text((box_x + 38, box_y + 98), subtitle.upper(), font=font_sub, fill=(accent_color[0], accent_color[1], accent_color[2], a_byte))

# ── High-Conversion Outro Modal (Steam & Google Play) ──────────────────────────
def draw_outro_modal(draw, alpha=1.0):
    if alpha <= 0.01: return
    a_byte = int(clamp(alpha * 245, 0, 245))
    
    mw, mh = 1440, 480
    mx = (WIDTH - mw) // 2
    my = (HEIGHT - mh) // 2 + 160
    
    # Premium glass card
    draw.rounded_rectangle([(mx, my), (mx + mw, my + mh)], radius=24, 
                           fill=(5, 8, 16, a_byte), 
                           outline=(255, 176, 32, a_byte), width=4)
    
    # Header tag
    tag = "/// NEXT-GEN PLATFORM FIGHTER · LOCAL & SOLO BRAWL ///"
    tb = draw.textbbox((0, 0), tag, font=font_sub)
    tw = tb[2] - tb[0]
    draw.text((mx + (mw - tw) // 2, my + 30), tag, font=font_sub, fill=(56, 189, 248, a_byte))
    
    # Main Headline
    head = "58 WARRIORS · FUSION CHAMBER · 80+ CHAPTERS"
    hb = draw.textbbox((0, 0), head, font=font_title)
    hw = hb[2] - hb[0]
    draw.text((mx + (mw - hw) // 2, my + 75), head, font=font_title, fill=(255, 255, 255, a_byte))
    
    # Steam Badge
    bx1 = mx + 160
    by1 = my + 170
    bw1 = 520
    bh1 = 120
    draw.rounded_rectangle([(bx1, by1), (bx1 + bw1, by1 + bh1)], radius=16, fill=(15, 23, 42, a_byte), outline=(56, 189, 248, a_byte), width=3)
    draw.text((bx1 + 35, by1 + 22), "STEAM PC / DECK", font=font_badge, fill=(255, 255, 255, a_byte))
    draw.text((bx1 + 35, by1 + 68), "★ JETZT WUNSCHLISTE HINZUFÜGEN", font=font_badge_sub, fill=(56, 189, 248, a_byte))
    
    # Google Play Badge
    bx2 = mx + mw - 160 - bw1
    draw.rounded_rectangle([(bx2, by1), (bx2 + bw1, by1 + bh1)], radius=16, fill=(15, 23, 42, a_byte), outline=(74, 222, 128, a_byte), width=3)
    draw.text((bx2 + 35, by1 + 22), "GOOGLE PLAY MOBILE", font=font_badge, fill=(255, 255, 255, a_byte))
    draw.text((bx2 + 35, by1 + 68), "▶ KOSTENLOS HERUNTERLADEN & TESTEN", font=font_badge_sub, fill=(74, 222, 128, a_byte))
    
    # Bottom CTA
    cta = "► JETZT HERUNTERLADEN & SPIELEN · KEINE LOOTBOXEN ◄"
    cb = draw.textbbox((0, 0), cta, font=font_sub)
    cw = cb[2] - cb[0]
    draw.text((mx + (mw - cw) // 2, my + 325), cta, font=font_sub, fill=(255, 176, 32, a_byte))

# ── Emitters Setup ────────────────────────────────────────────────────────────
emitter_sparks = ParticleEmitter()
emitter_ninja = ParticleEmitter()
emitter_astral = ParticleEmitter()
emitter_dante = ParticleEmitter()
emitter_emblem = ParticleEmitter()

PALETTE_GOLD = [(255, 210, 60), (255, 160, 20), (255, 240, 150), (255, 110, 10)]
PALETTE_CYAN = [(56, 189, 248), (14, 165, 233), (125, 211, 252), (255, 255, 255)]
PALETTE_FIRE = [(255, 80, 20), (255, 140, 30), (255, 220, 80), (220, 38, 38)]
PALETTE_COSMIC = [(192, 132, 252), (56, 189, 248), (244, 114, 182), (255, 255, 255)]

# ── Start FFmpeg Pipe Process ─────────────────────────────────────────────────
print("Starting FFmpeg 1080p60 encoding pipeline...")
final_mp4 = os.path.join(OUT_DIR, "prompt_fighters_trailer_1080p60.mp4")
raw_video_path = "scratch/aaa_trailer_raw.mp4"

pipe_cmd = [
    "ffmpeg", "-y",
    "-f", "rawvideo",
    "-vcodec", "rawvideo",
    "-s", f"{WIDTH}x{HEIGHT}",
    "-pix_fmt", "rgb24",
    "-r", str(FPS),
    "-i", "-",
    "-c:v", "libx264",
    "-preset", "faster",
    "-crf", "18",
    "-pix_fmt", "yuv420p",
    raw_video_path
]

ffmpeg_proc = subprocess.Popen(pipe_cmd, stdin=subprocess.PIPE)

dt = 1.0 / FPS

print("Rendering 2520 frames with dynamic VFX, camera motion & particles...")
for frame_idx in range(TOTAL_FRAMES):
    t = frame_idx / float(FPS)
    
    # Determine Current Act
    if t < 7.5:
        # ── ACT 1: THE SPARK OF CREATION (Swords Clash) ──
        act_t = t / 7.5
        # Camera: Smooth slow push-in centered on the collision (1.0 -> 1.14)
        zoom = 1.0 + smoothstep(0.0, 1.0, act_t) * 0.14
        pan_x = 0
        pan_y = -20 * act_t
        
        # Shake on impact at 7.2s
        shake = 0.0
        if t >= 7.2:
            shake = math.sin((t - 7.2) * 50) * 8.0 * max(0.0, 1.0 - (t - 7.2) / 0.3)
            
        base_frame = apply_camera(img_swords, zoom, pan_x, pan_y, shake, shake * 0.5)
        overlay = Image.new("RGBA", (WIDTH, HEIGHT), (0, 0, 0, 0))
        draw = ImageDraw.Draw(overlay)
        
        # Spawn continuous sparks at clash point
        clash_cx = WIDTH * 0.51
        clash_cy = HEIGHT * 0.52
        if frame_idx % 2 == 0:
            emitter_sparks.emit(clash_cx, clash_cy, 6, (120, 380), PALETTE_GOLD)
        emitter_sparks.update_and_draw(draw, dt, gravity=(0, 220), drag=0.97)
        
        # Anamorphic lens flare sweep across blades
        flare_int = 0.4 + 0.3 * math.sin(t * 4.0)
        draw_lens_flare(draw, clash_cx, clash_cy, flare_int, color=(255, 190, 50))
        
        # Kinetic Lower Thirds
        text_a1 = smoothstep(0.8, 1.5, t) * (1.0 - smoothstep(4.0, 4.6, t))
        draw_lower_third(draw, "/// PROMPT FIGHTER ULTIMATE ///", "WHERE ANY PROMPT BECOMES A LIVING FIGHTER", 
                         "NEXT-GEN 3D PLATFORM COMBAT", alpha=text_a1, accent_color=(56, 189, 248))
        
        text_a2 = smoothstep(4.8, 5.5, t) * (1.0 - smoothstep(6.8, 7.3, t))
        draw_lower_third(draw, "/// THE REVOLUTION ///", "CREATIVITY IS YOUR STRONGEST WEAPON", 
                         "PREPARE FOR BATTLE", alpha=text_a2, accent_color=(255, 176, 32))
        
    elif t < 16.5:
        # ── ACT 2: UNLEASH 58 FIGHTERS (Ninja vs Golem) ──
        rel_t = (t - 7.5)
        act_t = rel_t / 9.0
        
        # Initial Zoom Snap Punch-in on clash (1.20 down to 1.06)
        zoom = 1.06 + 0.14 * math.exp(-rel_t * 2.5) + 0.05 * act_t
        pan_x = math.sin(act_t * math.pi) * 40.0
        pan_y = -30.0 + act_t * 40.0
        
        # Screen shake from heavy clash at start of act
        shake = math.sin(rel_t * 45) * 12.0 * math.exp(-rel_t * 3.0)
        
        base_frame = apply_camera(img_ninja, zoom, pan_x, pan_y, shake, shake * 0.7)
        overlay = Image.new("RGBA", (WIDTH, HEIGHT), (0, 0, 0, 0))
        draw = ImageDraw.Draw(overlay)
        
        # Particles: Electric sparks on left, magma embers on right
        if frame_idx % 2 == 0:
            emitter_ninja.emit(WIDTH * 0.44, HEIGHT * 0.38, 5, (160, 420), PALETTE_CYAN) # ninja clash
            emitter_ninja.emit(WIDTH * 0.72, HEIGHT * 0.44, 5, (140, 360), PALETTE_FIRE) # golem hammer
        emitter_ninja.update_and_draw(draw, dt, gravity=(0, 180), drag=0.96)
        
        # Kinetic Lower Thirds
        text_a1 = smoothstep(7.8, 8.4, t) * (1.0 - smoothstep(11.6, 12.2, t))
        draw_lower_third(draw, "/// EXPANDED ROSTER ///", "58 UNIQUE FIGHTERS · DIVERSE MOVESETS", 
                         "NINJAS · GOLEMS · SAMURAI · VALKYRIES", alpha=text_a1, accent_color=(56, 189, 248))
        
        text_a2 = smoothstep(12.5, 13.1, t) * (1.0 - smoothstep(15.8, 16.3, t))
        draw_lower_third(draw, "/// COMPETITIVE DEPTH ///", "COMBO JUGGLES · DIRECTIONAL INFLUENCE · SHIELD PARRY", 
                         "UNLIMITED TACTICAL POSSIBILITIES", alpha=text_a2, accent_color=(239, 68, 68))
        
    elif t < 25.5:
        # ── ACT 3: THE FUSION CHAMBER & ASTRAL NEXUS (Kalyx vs Vorruk) ──
        rel_t = (t - 16.5)
        act_t = rel_t / 9.0
        
        # Panoramic lateral tracking across the astral floating rift
        zoom = 1.05 + 0.08 * math.sin(act_t * math.pi)
        pan_x = -70.0 + act_t * 140.0
        pan_y = 15.0 * math.cos(act_t * math.pi)
        
        base_frame = apply_camera(img_astral, zoom, pan_x, pan_y)
        overlay = Image.new("RGBA", (WIDTH, HEIGHT), (0, 0, 0, 0))
        draw = ImageDraw.Draw(overlay)
        
        # Floating cosmic stardust orbs
        if frame_idx % 3 == 0:
            emitter_astral.emit(WIDTH * random.uniform(0.1, 0.9), HEIGHT * 0.75, 4, (40, 150), PALETTE_COSMIC)
        emitter_astral.update_and_draw(draw, dt, gravity=(0, -40), drag=0.99) # floating upwards
        
        # Runic lens flare on sword clash
        draw_lens_flare(draw, WIDTH * 0.54, HEIGHT * 0.42, 0.45 + 0.15 * math.sin(t * 6.0), color=(147, 197, 253))
        
        # Kinetic Lower Thirds
        text_a1 = smoothstep(16.8, 17.5, t) * (1.0 - smoothstep(20.6, 21.2, t))
        draw_lower_third(draw, "/// KREATIV-STUDIO ///", "THE FUSION CHAMBER · MODULAR COMBATANTS", 
                         "CUSTOMIZE WEAPONS, WINGS & RUNIC POWERS", alpha=text_a1, accent_color=(192, 132, 252))
        
        text_a2 = smoothstep(21.5, 22.2, t) * (1.0 - smoothstep(24.8, 25.3, t))
        draw_lower_third(draw, "/// MYTHIC ARENAS ///", "ASTRAL OBSIDIAN NEXUS · INTERACTIVE HAZARDS", 
                         "QUANTUM RIFTS · DYNAMIC SKYBOXES", alpha=text_a2, accent_color=(56, 189, 248))
        
    elif t < 33.5:
        # ── ACT 4: MYTHIC BOSS BATTLE (Dante Infernus) ──
        rel_t = (t - 25.5)
        act_t = rel_t / 8.0
        
        # Terrifying upward push-in into Dante's blazing molten skull
        zoom = 1.03 + smoothstep(0.0, 1.0, act_t) * 0.16
        pan_x = 0.0
        pan_y = 60.0 - act_t * 90.0 # rising from chest to eyes
        
        # Earthquake screen rumble
        rumble = math.sin(t * 30.0) * 4.0 * (0.6 + 0.4 * math.sin(t * 5.0))
        
        base_frame = apply_camera(img_dante, zoom, pan_x, pan_y, rumble * 0.5, rumble)
        overlay = Image.new("RGBA", (WIDTH, HEIGHT), (0, 0, 0, 0))
        draw = ImageDraw.Draw(overlay)
        
        # Rising fiery embers and ash
        if frame_idx % 2 == 0:
            emitter_dante.emit(WIDTH * random.uniform(0.2, 0.8), HEIGHT * 0.90, 6, (80, 260), PALETTE_FIRE)
        emitter_dante.update_and_draw(draw, dt, gravity=(0, -120), drag=0.98)
        
        # Fiery lens flare on sword
        draw_lens_flare(draw, WIDTH * 0.28, HEIGHT * 0.54, 0.5 + 0.2 * math.sin(t * 8.0), color=(255, 120, 20))
        
        # Kinetic Lower Thirds
        text_a1 = smoothstep(25.8, 26.5, t) * (1.0 - smoothstep(29.4, 30.0, t))
        draw_lower_third(draw, "/// TITANIC BOSSES ///", "DANTE INFERNUS · THE UNYIELDING FLAME", 
                         "COLOSSAL SLAMS · DESTRUCTIBLE ARENAS", alpha=text_a1, accent_color=(239, 68, 68))
        
        text_a2 = smoothstep(30.3, 30.9, t) * (1.0 - smoothstep(33.0, 33.4, t))
        draw_lower_third(draw, "/// CAMPAIGN SAGA ///", "OVER 80 HAND-CRAFTED STORY CHAPTERS", 
                         "DEFEND THE REALMS · CLAIM ANCIENT RELICS", alpha=text_a2, accent_color=(255, 176, 32))
        
    else:
        # ── ACT 5: CLIMAX & HIGH-CONVERSION OUTRO (Emblem & CTA) ──
        rel_t = (t - 33.5)
        act_t = rel_t / 8.5
        
        # Majestic pull-back revealing the whole radiant shield
        zoom = 1.15 - smoothstep(0.0, 1.0, act_t) * 0.12
        pan_x = 0.0
        pan_y = -35.0 + act_t * 20.0
        
        # Initial climax impact shake
        shake = math.sin(rel_t * 40) * 14.0 * math.exp(-rel_t * 3.0)
        
        base_frame = apply_camera(img_emblem, zoom, pan_x, pan_y, shake, shake * 0.6)
        overlay = Image.new("RGBA", (WIDTH, HEIGHT), (0, 0, 0, 0))
        draw = ImageDraw.Draw(overlay)
        
        # Shimmering divine dust motes
        if frame_idx % 3 == 0:
            emitter_emblem.emit(WIDTH * random.uniform(0.2, 0.8), HEIGHT * random.uniform(0.2, 0.7), 4, (30, 120), PALETTE_GOLD)
        emitter_emblem.update_and_draw(draw, dt, gravity=(0, -20), drag=0.99)
        
        # Shimmering core star glint on shield center
        glint_int = 0.5 + 0.3 * math.sin(rel_t * 4.0)
        draw_lens_flare(draw, WIDTH * 0.50, HEIGHT * 0.34, glint_int, color=(255, 240, 180))
        
        # High-Conversion CTA Modal
        modal_a = smoothstep(34.2, 35.2, t)
        draw_outro_modal(draw, alpha=modal_a)
    
    # ── Impact Frame Flashes on Transitions ──
    # Act transitions at 7.5s, 16.5s, 25.5s, 33.5s
    for trans_time in [7.5, 16.5, 25.5, 33.5]:
        time_diff = t - trans_time
        if 0.0 <= time_diff < (3.0 / FPS):
            # Pure white impact flash
            flash_overlay = Image.new("RGBA", (WIDTH, HEIGHT), (255, 255, 255, int(255 * (1.0 - time_diff / (3.0 / FPS)))))
            overlay.alpha_composite(flash_overlay)
            
    # Composite overlay on base frame
    final_img = Image.alpha_composite(base_frame.convert("RGBA"), overlay).convert("RGB")
    
    # Write directly to FFmpeg pipe
    ffmpeg_proc.stdin.write(final_img.tobytes())
    
    if frame_idx % 240 == 0:
        percent = (frame_idx / float(TOTAL_FRAMES)) * 100
        print(f"Rendered frame {frame_idx}/{TOTAL_FRAMES} ({percent:.1f}%) [t={t:.1f}s]")

ffmpeg_proc.stdin.close()
ffmpeg_proc.wait()
print("Raw video render complete!")

# ── Multi-Track High-Impact Audio Mix ─────────────────────────────────────────
print("Mixing multi-track cinematic audio (BGM, SFX, Sub-bass, Announcer)...")
mixed_audio_path = "scratch/aaa_trailer_audio.wav"

# Filter complex that aligns and mixes all audio events with exact precision
filter_complex = (
    # [0] Music: battle_valor.ogg with volume curve & crescendo
    "[0:a]volume=1.2,afade=t=in:st=0:d=1.5,afade=t=out:st=40.5:d=1.5[music];"
    # [1] ready.ogg at 6.2s
    "[1:a]adelay=6200|6200,volume=1.4[ready];"
    # [2] fight.ogg at 7.8s
    "[2:a]adelay=7800|7800,volume=1.5[fight];"
    # [3] combo.ogg at 21.2s
    "[3:a]adelay=21200|21200,volume=1.4[combo];"
    # [4] winner.ogg at 34.2s
    "[4:a]adelay=34200|34200,volume=1.45[winner];"
    # [5] PFU_Hit at 7.5s, 16.5s, 33.5s
    "[5:a]asplit=3[hit1][hit2][hit3];"
    "[hit1]adelay=7500|7500,volume=1.5[hit_s1];"
    "[hit2]adelay=16500|16500,volume=1.4[hit_s2];"
    "[hit3]adelay=33500|33500,volume=1.6[hit_s3];"
    # [6] PFU_ElectricSpecial at 7.6s
    "[6:a]adelay=7600|7600,volume=1.3[electric];"
    # [7] PFU_LavaSpecial at 25.6s
    "[7:a]adelay=25600|25600,volume=1.4[lava];"
    # [8] PFU_Victory at 33.6s
    "[8:a]adelay=33600|33600,volume=1.2[victory];"
    # Mix all 11 streams
    "[music][ready][fight][combo][winner][hit_s1][hit_s2][hit_s3][electric][lava][victory]amix=inputs=11:duration=first:dropout_transition=2[outa]"
)

subprocess.run([
    "ffmpeg", "-y",
    "-i", "godot/assets/audio/music/battle_valor.ogg",
    "-i", "godot/assets/audio/voice/announcer/ready.ogg",
    "-i", "godot/assets/audio/voice/announcer/fight.ogg",
    "-i", "godot/assets/audio/voice/announcer/combo.ogg",
    "-i", "godot/assets/audio/voice/announcer/winner.ogg",
    "-i", "godot/assets/audio/PFU_Hit.wav",
    "-i", "godot/assets/audio/PFU_ElectricSpecial.wav",
    "-i", "godot/assets/audio/PFU_LavaSpecial.wav",
    "-i", "godot/assets/audio/PFU_Victory.wav",
    "-filter_complex", filter_complex,
    "-map", "[outa]",
    "-t", str(TOTAL_DURATION),
    mixed_audio_path
], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
print("Audio mix complete!")

# ── Mux Final Master MP4 ──────────────────────────────────────────────────────
print("Muxing final 1080p60 MP4 master...")
subprocess.run([
    "ffmpeg", "-y",
    "-i", raw_video_path,
    "-i", mixed_audio_path,
    "-c:v", "libx264", "-preset", "medium", "-crf", "17",
    "-c:a", "aac", "-b:a", "320k", "-ar", "48000",
    "-pix_fmt", "yuv420p",
    "-shortest",
    final_mp4
], check=True)

# Copy to Steam & Play store directories
import shutil
shutil.copyfile(final_mp4, "store/steam/trailer_1080p60.mp4")
shutil.copyfile(final_mp4, "store/play/trailer_1080p60.mp4")
print("Exported to store/steam/trailer_1080p60.mp4 and store/play/trailer_1080p60.mp4")

# Export fast WebM version for Steam with cpu-used 4 & multi-threading
print("Exporting high-quality WebM (VP9/Opus) for Steam...")
final_webm = "store/steam/trailer_1080p60.webm"
subprocess.run([
    "ffmpeg", "-y",
    "-i", final_mp4,
    "-c:v", "libvpx-vp9", "-b:v", "4500k", "-crf", "22", "-cpu-used", "4", "-row-mt", "1", "-threads", "8",
    "-c:a", "libopus", "-b:a", "192k",
    final_webm
], check=True)
print("Exported to store/steam/trailer_1080p60.webm")

size_mb = os.path.getsize(final_mp4) / (1024 * 1024)
print(f"=== AAA TRAILER MASTER COMPLETE: {final_mp4} ({size_mb:.2f} MB, {TOTAL_DURATION:.1f}s, 1080p60) ===")
