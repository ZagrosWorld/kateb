# Kateb Persian speech-to-text

## Slack voice note to text
1. `/workspace/kateb/fetch_slack_file.sh <slack_file_id>` downloads the file to `/workspace/kateb/inbox/` and prints the path. It uses `$SLACK_KATEB_USER_TOKEN`, and both curl calls use `-sf`, so a Slack error fails instead of being saved as audio. Never print the token.
2. `/workspace/kateb/transcribe.sh <path> [--model small|medium|large-v3] [--vad] [--prompt "names, terms"] [--timestamps]`

## Defaults (since 2026-10-11)
- Model: `large-v3`. You can override it with `--model` or the `KATEB_MODEL` env var.
- VAD is off by default. Use `--vad` only for long recordings. With VAD on, short notes came out garbled.
- Decoding: `language="fa"`, `beam_size=5`, `temperature=0.0`, `condition_on_previous_text=False`, and `initial_prompt` from `--prompt`.
- CPU threads are left at the faster-whisper default. Forcing `cpu_threads=os.cpu_count()` produced garbled output on the test clip.
- Test clip: `inbox/F0C88PHG84A_audio_message.m4a` (10 s) transcribes in one pass, in about 17 s, as «یه کتاب جدید برام درست کنید به اسم طبیعتگردی اول اینو برام درست کنید و بعد…».

## Setup
- venv: `/workspace/kateb/venv` (faster-whisper 1.2.1)
- models: `/workspace/kateb/models`
- ffmpeg reads m4a, webm, mp4, ogg, and wav.
