"""Generate PFU_Block.wav and PFU_Jump.wav for Godot audio."""
import math
import random
import struct
import wave
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "godot" / "assets" / "audio"
OUTPUT.mkdir(parents=True, exist_ok=True)
RATE = 44100

def write_wav(name: str, duration: float, sample_fn):
    frames = bytearray()
    count = int(RATE * duration)
    for index in range(count):
        t = index / RATE
        value = max(-1.0, min(1.0, sample_fn(t, duration)))
        frames.extend(struct.pack("<h", int(value * 32767)))
    with wave.open(str(OUTPUT / name), "wb") as target:
        target.setnchannels(1)
        target.setsampwidth(2)
        target.setframerate(RATE)
        target.writeframes(frames)
    print("SAVED_AUDIO", name)

def envelope(t: float, duration: float, attack=0.01, release=0.2) -> float:
    return min(1.0, t / max(attack, 0.001)) * min(1.0, (duration - t) / max(release, 0.001))

rng = random.Random(9281)
noise = [rng.uniform(-1, 1) for _ in range(int(RATE * 2))]

# Metallic shield clang / deflection
write_wav("PFU_Block.wav", 0.32, lambda t, d: envelope(t, d, 0.001, 0.25) * (
    0.55 * math.sin(2 * math.pi * 920 * t) +
    0.35 * math.sin(2 * math.pi * 1440 * t) +
    0.25 * math.sin(2 * math.pi * 2100 * t) +
    0.20 * noise[int(t * RATE)] * math.exp(-t * 18)
))

# Jump whoosh / energy leap
write_wav("PFU_Jump.wav", 0.28, lambda t, d: envelope(t, d, 0.02, 0.20) * (
    0.45 * math.sin(2 * math.pi * (160 + t * 480) * t) +
    0.22 * noise[int(t * RATE)] * envelope(t, d, 0.01, 0.15)
))
