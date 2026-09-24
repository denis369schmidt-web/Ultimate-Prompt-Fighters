"""Generate deterministic, original placeholder WAV effects for PFU."""

from __future__ import annotations

import math
import random
import struct
import wave
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "game" / "Content" / "Audio" / "Source"
RATE = 44100


def write_wav(name: str, duration: float, sample_fn) -> None:
    OUTPUT.mkdir(parents=True, exist_ok=True)
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


def envelope(t: float, duration: float, attack=0.01, release=0.2) -> float:
    return min(1.0, t / max(attack, 0.001)) * min(1.0, (duration - t) / max(release, 0.001))


def main() -> None:
    rng = random.Random(7701)
    noise = [rng.uniform(-1, 1) for _ in range(int(RATE * 2))]
    write_wav("PFU_Hit.wav", 0.22, lambda t, d: envelope(t, d, 0.002, 0.16) * (0.52 * noise[int(t * RATE)] + 0.35 * math.sin(2 * math.pi * (150 - t * 260) * t)))
    write_wav("PFU_ElectricSpecial.wav", 0.72, lambda t, d: envelope(t, d, 0.015, 0.22) * (0.32 * math.sin(2 * math.pi * (620 + 170 * math.sin(2 * math.pi * 18 * t)) * t) + 0.18 * noise[int(t * RATE)]))
    write_wav("PFU_LavaSpecial.wav", 0.85, lambda t, d: envelope(t, d, 0.02, 0.3) * (0.38 * math.sin(2 * math.pi * (92 - t * 25) * t) + 0.2 * noise[int(t * RATE)]))
    write_wav("PFU_RoundStart.wav", 0.65, lambda t, d: envelope(t, d, 0.01, 0.18) * 0.42 * math.sin(2 * math.pi * (290 + t * 420) * t))
    write_wav("PFU_Victory.wav", 1.15, lambda t, d: envelope(t, d, 0.01, 0.28) * 0.32 * math.sin(2 * math.pi * (220 * (1.0 if t < 0.35 else 1.25 if t < 0.7 else 1.5)) * t))
    print(f"PFU_AUDIO_GENERATED_OK files={len(list(OUTPUT.glob('*.wav')))}")


if __name__ == "__main__":
    main()

