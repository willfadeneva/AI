#!/usr/bin/env bash

# Docker Compose Setup Script for n8n + STT Services + Kokoro-TTS
# Now with complete Whisper-STT requirements
set -e  # Exit on error

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

log() {
    printf "\n[%s] %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$1"
}

cleanup() {
    log "Cleaning up existing containers..."
    cd "$SCRIPT_DIR"
    docker-compose down --remove-orphans --volumes 2>/dev/null || true
}

create_compose_file() {
    log "Creating docker-compose.yml..."
    cat > "$SCRIPT_DIR/docker-compose.yml" << 'EOL'
version: "3.9"

services:
  n8n:
    image: n8nio/n8n:latest
    restart: unless-stopped
    ports:
      - "127.0.0.1:5678:5678"
    volumes:
      - ./n8n-data:/home/node/.n8n
    environment:
      - N8N_RUNNERS_ENABLED=true
      - N8N_BASIC_AUTH_USER=admin
      - N8N_BASIC_AUTH_PASSWORD=admin

  flask-stt:
    build: ./flask-stt
    ports:
      - "5000:5000"
    volumes:
      - ./flask-stt/app:/app

  whisper-stt:
    build: ./whisper
    ports:
      - "6000:5000"
    volumes:
      - ./whisper/app:/app
    environment:
      - FLASK_ENV=production
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]

  kokoro-tts:
    build: ./kokoro-tts
    ports:
      - "8000:8000"
    volumes:
      - ./kokoro-tts/app:/app
EOL
}

setup_services() {
    log "Configuring services..."
    
    # Create directory structure
    mkdir -p {flask-stt,whisper,kokoro-tts}/app n8n-data
    
    # Setup Flask-STT
    cat > flask-stt/Dockerfile << 'EOL'
FROM python:3.9-slim
WORKDIR /app
COPY ./app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY ./app .
CMD ["python", "app.py"]
EOL

    echo "flask==2.0.3" > flask-stt/app/requirements.txt
    echo "werkzeug==2.0.3" >> flask-stt/app/requirements.txt

    cat > flask-stt/app/app.py << 'EOL'
from flask import Flask, jsonify
app = Flask(__name__)

@app.route('/')
def status():
    return jsonify({"service": "FLASK-STT", "status": "ready"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
EOL

    # Setup Whisper-STT with complete requirements
    cat > whisper/Dockerfile << 'EOL'
FROM python:3.9-slim
RUN apt-get update && apt-get install -y ffmpeg
WORKDIR /app
COPY ./app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY ./app .
CMD ["python", "app.py"]
EOL

    cat > whisper/app/requirements.txt << 'EOL'
flask==2.0.3
werkzeug==2.0.3
openai-whisper==20231106
torch==2.0.1
ffmpeg-python==0.2.0
numpy==1.23.5
tqdm==4.64.1
EOL

    cat > whisper/app/app.py << 'EOL'
from flask import Flask, request, jsonify
import whisper
import os

app = Flask(__name__)
model = whisper.load_model("base")

@app.route('/')
def status():
    return jsonify({"service": "WHISPER-STT", "status": "ready"})

@app.route('/transcribe', methods=['POST'])
def transcribe():
    if 'audio' not in request.files:
        return jsonify({"error": "No audio file provided"}), 400
    
    audio = request.files['audio']
    temp_path = "/tmp/uploaded_audio"
    audio.save(temp_path)
    
    try:
        result = model.transcribe(temp_path)
        os.remove(temp_path)
        return jsonify({"text": result["text"]})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
EOL

    # Setup Kokoro-TTS
    cat > kokoro-tts/Dockerfile << 'EOL'
FROM python:3.9-slim
WORKDIR /app
COPY ./app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY ./app .
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
EOL

    cat > kokoro-tts/app/requirements.txt << 'EOL'
fastapi==0.68.0
uvicorn==0.15.0
EOL

    cat > kokoro-tts/app/main.py << 'EOL'
from fastapi import FastAPI
app = FastAPI()

@app.get("/")
async def root():
    return {"service": "KOKORO-TTS", "status": "ready"}
EOL
    
    chmod -R 777 n8n-data
}

main() {
    cd "$SCRIPT_DIR"
    cleanup
    create_compose_file
    setup_services
    
    log "Building and starting services (this may take several minutes)..."
    docker-compose up -d --build
    
    log "Waiting for initialization (30 seconds)..."
    sleep 30
    
    log "\n\033[1;32mServices ready:\033[0m"
    echo -e "• n8n: \033[1;34mhttp://127.0.0.1:5678\033[0m (admin/admin)"
    echo -e "• Flask-STT: \033[1;34mhttp://127.0.0.1:5000/\033[0m"
    echo -e "• Whisper-STT: \033[1;34mhttp://localhost:6000\033[0m"
    echo -e "• Kokoro-TTS: \033[1;34mhttp://localhost:8000\033[0m"
    
    log "\nTest Whisper-STT transcription:"
    echo "curl -F 'audio=@your_audio.wav' http://localhost:6000/transcribe"
}

main