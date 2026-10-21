#!/usr/bin/env bash
# Usage: /workspace/kateb/transcribe.sh <audio-file> [--model small|medium|large-v3] [--timestamps] [--vad] [--prompt TEXT]  (default model: large-v3)
exec /workspace/kateb/venv/bin/python /workspace/kateb/transcribe.py "$@"
