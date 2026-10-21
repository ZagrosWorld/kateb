#!/usr/bin/env python3
"""Kateb Persian STT. Usage: transcribe.sh <audio> [--model small|medium|large-v3] [--timestamps] [--vad] [--prompt TEXT]"""
import argparse, os, subprocess, sys, tempfile, time
os.environ.setdefault("HF_HUB_DISABLE_PROGRESS_BARS", "1")
from faster_whisper import WhisperModel

p = argparse.ArgumentParser()
p.add_argument("audio")
p.add_argument("--model", default=os.environ.get("KATEB_MODEL", "large-v3"))
p.add_argument("--timestamps", action="store_true")
p.add_argument("--vad", action="store_true")
p.add_argument("--prompt", default=None, help="optional initial prompt / glossary hint (names, terms)")
a = p.parse_args()
if not os.path.isfile(a.audio):
    sys.exit(f"no such file: {a.audio}")

# normalise any container (m4a/webm/mp4/ogg) to 16 kHz mono wav via ffmpeg
import numpy as np
raw = subprocess.run(["ffmpeg", "-nostdin", "-loglevel", "error", "-i", a.audio,
                      "-ac", "1", "-ar", "16000", "-f", "f32le", "-"], check=True,
                     capture_output=True).stdout
audio = np.frombuffer(raw, dtype=np.float32)
t0 = time.time()
m = WhisperModel(a.model, device="cpu", compute_type="int8",
                 download_root="/workspace/kateb/models")
segs, info = m.transcribe(audio, language="fa", task="transcribe", beam_size=5, vad_filter=a.vad, temperature=0.0, condition_on_previous_text=False, initial_prompt=a.prompt)
out = []
for s in segs:
    out.append(f"[{s.start:6.1f}-{s.end:6.1f}] {s.text.strip()}" if a.timestamps else s.text.strip())
print(("\n" if a.timestamps else " ").join(out).strip())
print(f"[model={a.model} audio={info.duration:.1f}s elapsed={time.time()-t0:.1f}s]", file=sys.stderr)
