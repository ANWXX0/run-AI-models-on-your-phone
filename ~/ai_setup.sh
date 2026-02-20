#!/data/data/com.termux/files/usr/bin/bash
# ==========================================
# Unified LLM + Audio + Simple Image Setup
# Termux / Android (Black Shark 1)
# ==========================================

set -e

# --------------------------
# 1️⃣ Update Termux & install dependencies
# --------------------------
pkg update -y && pkg upgrade -y
pkg install -y git python clang cmake make wget curl ffmpeg tmux rust autoconf automake libtool pkg-config ninja patchelf

# Python packages (Termux-safe, pydantic<2 avoids Rust build issues)
pip install --no-build-isolation "pydantic<2" fastapi uvicorn numpy requests

# --------------------------
# 2️⃣ Setup llama.cpp (Phi-2 2.7B Q4)
# --------------------------
cd $HOME
git clone https://github.com/ggerganov/llama.cpp
cd llama.cpp
cmake -B build
cmake --build build -j4

mkdir -p $HOME/llama.cpp/models
cd $HOME/llama.cpp/models

wget https://huggingface.co/TheBloke/phi-2-GGUF/resolve/main/phi-2.Q4_K_M.gguf

# --------------------------
# 3️⃣ Setup whisper.cpp (small model)
# --------------------------
cd $HOME
git clone https://github.com/ggerganov/whisper.cpp
cd whisper.cpp
cmake -B build
cmake --build build -j4

mkdir -p $HOME/whisper.cpp/models
cd $HOME/whisper.cpp/models
wget https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-small.en.bin

# --------------------------
# 4️⃣ Setup Piper TTS
# --------------------------
cd $HOME
git clone https://github.com/rhasspy/piper
cd piper
pip install -r requirements.txt

mkdir -p voices
cd voices
wget https://github.com/rhasspy/piper/releases/download/0.4/en_us_mimic3_small.pt

# --------------------------
# 5️⃣ Setup Stable Diffusion Mini
# --------------------------
cd $HOME
git clone https://github.com/hlky/stable-diffusion.cpp
cd stable-diffusion.cpp
cmake -B build
cmake --build build -j4

mkdir -p models
cd models
wget https://huggingface.co/CompVis/stable-diffusion-mini/resolve/main/sd-mini-v1-1.gguf

# --------------------------
# 6️⃣ Setup FastAPI unified API server
# --------------------------
cd $HOME
mkdir -p ai_api
cat > $HOME/ai_api/server.py << 'EOF'
from fastapi import FastAPI, UploadFile, File
import subprocess
import os
import uuid

app = FastAPI()
HOME = os.environ['HOME']

# ------------------- Chat -------------------
@app.post("/chat")
async def chat(prompt: str):
    cmd = f"{HOME}/llama.cpp/build/bin/server -m {HOME}/llama.cpp/models/phi-2.Q4_K_M.gguf -p \"{prompt}\" -n 128"
    result = subprocess.getoutput(cmd)
    return {"response": result}

# ------------------- Audio Transcription -------------------
@app.post("/transcribe")
async def transcribe(file: UploadFile = File(...)):
    file_path = f"/tmp/{uuid.uuid4()}.wav"
    with open(file_path, "wb") as f:
        f.write(await file.read())
    cmd = f"{HOME}/whisper.cpp/build/whisper -m {HOME}/whisper.cpp/models/ggml-small.en.bin -f {file_path}"
    result = subprocess.getoutput(cmd)
    os.remove(file_path)
    return {"transcription": result}

# ------------------- TTS -------------------
@app.post("/tts")
async def tts(text: str):
    out_file = f"/tmp/{uuid.uuid4()}.wav"
    cmd = f"python3 {HOME}/piper/piper.py --model {HOME}/piper/voices/en_us_mimic3_small.pt --text \"{text}\" --out {out_file}"
    subprocess.getoutput(cmd)
    return {"file": out_file}

# ------------------- Image Generation -------------------
@app.post("/generate")
async def generate(prompt: str):
    out_file = f"/tmp/{uuid.uuid4()}.png"
    cmd = f"{HOME}/stable-diffusion.cpp/build/bin/sd-server -m {HOME}/stable-diffusion.cpp/models/sd-mini-v1-1.gguf -p \"{prompt}\" -o {out_file}"
    subprocess.getoutput(cmd)
    return {"file": out_file}
EOF

# --------------------------
# 7️⃣ Instructions to run API
# --------------------------
echo "Installation complete!"
echo "Run unified API with:"
echo "---------------------------------------"
echo "tmux new -s ai_api"
echo "python3 $HOME/ai_api/server.py --host 0.0.0.0 --port 8080"
echo "Detach with CTRL+B, D to keep running"
echo "---------------------------------------"
echo "API Endpoints:"
echo "POST /chat       → JSON {prompt: 'text'}"
echo "POST /transcribe → upload .wav file"
echo "POST /tts        → JSON {text: 'text'}"
echo "POST /generate   → JSON {prompt: 'text'}"
