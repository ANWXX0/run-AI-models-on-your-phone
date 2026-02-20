THIS SCRIPT IS AI GENERATED SLOP THAT WORKED ON MY PHONE.

ABOUT

The goal of this script is to turn your Black Shark 1 (or any Termux-capable Android device) into a fully local AI server that you can access via LAN or automation scripts like OpenClaw.

Here’s a breakdown:

1️⃣ Install all AI models and dependencies

Chat (LLM) → Phi-2 2.7B Q4 via llama.cpp

Purpose: answer questions, generate text, be your “brain” for automation tasks.

API endpoint: /chat

Audio processing

Whisper.cpp (small) → Speech-to-text → /transcribe

Purpose: convert voice notes, WhatsApp audio, or any audio file into text.

Piper TTS → Text-to-speech → /tts

Purpose: turn text responses into voice audio, offline.

Image generation → Stable Diffusion Mini / Tiny → /generate

Purpose: generate simple AI images locally (512×512), fully offline.

2️⃣ Set up all required tools on Termux

Python packages: FastAPI, uvicorn, numpy, requests, pydantic<2

Rust + build tools (clang, cmake, ninja, etc.) → required for some AI wheels

tmux → keep the server running in background

wget/git → download models

3️⃣ Create a unified API server

Uses FastAPI to expose endpoints for:

/chat → text-based LLM

/transcribe → audio → text

/tts → text → audio

/generate → prompt → image

This allows OpenClaw or other automation scripts to interact with your AI stack via simple HTTP requests.

4️⃣ Make it local, offline, and persistent

All models are downloaded to your phone (~/llama.cpp/models, ~/whisper.cpp/models, etc.)

No cloud dependency → privacy-friendly

Can run in tmux → detached from Termux session

Accessible over LAN → control it from PC, tablet, or another phone

✅ Overall purpose

Turn your phone into a mini AI server that can:

Chat like an AI assistant

Process and generate audio

Generate simple images

Be fully controllable via API for automation tasks (like OpenClaw)# run-AI-models-on-your-phone
