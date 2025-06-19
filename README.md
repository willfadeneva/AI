# AI Microservices Stack 🚀
![image](https://github.com/user-attachments/assets/4c524f89-d8eb-4011-8b0a-fa1ca8c8bf06)

![Docker](https://img.shields.io/badge/Docker-Containers-blue)
![Flask](https://img.shields.io/badge/Flask-API-green)
![Whisper](https://img.shields.io/badge/OpenAI-Whisper-purple)

A Dockerized AI stack featuring workflow automation, speech-to-text, and text-to-speech services.

## 🌟 Features
- **n8n**: Workflow automation (http://localhost:5678)
- **Whisper-STT**: OpenAI's speech-to-text (http://localhost:6001)
- **Flask-STT**: Alternative STT service (http://localhost:5000) 
- **Kokoro-TTS**: Japanese-focused text-to-speech (http://localhost:8000)

## 🛠️ Quick Start 1
```bash
# Clone and launch
git clone https://github.com/willfadeneva/AI.git
cd AI
docker-compose up -d --build

**## 🛠️ Quick Start 2**
# 🧠 AI Voice Agent Platform (Docker-Based)

This project sets up a complete voice/text AI agent platform using `docker-compose`, combining:

- Workflow automation (n8n)
- Speech-to-text (Flask + Whisper)
- Text-to-speech (Kokoro + Coqui)
- Support for English, Hindi, Punjabi, and Japanese
- Local-first design (everything is self-hosted except DeepSeek, if used)

---

## 🚀 How to Use This Setup

1. **Save the setup script**  
   Save the file as `setup_ai_folder.sh` in your project directory.

2. **Make it executable**  
   ```bash
   chmod +x setup_ai_folder.sh

3. Run the script
./setup_ai_folder.sh

4. Start all services
docker-compose up -d

📡 API Endpoints
Whisper-STT
bash
curl -F 'audio=@test.wav' http://localhost:6001/transcribe
Response:

json
{"text": "transcribed text"}
Kokoro-TTS
bash
curl -X POST http://localhost:8000/synthesize \
  -H "Content-Type: application/json" \
  -d '{"text":"こんにちは"}'

🐳 Container Ports
Service	Port	Description
n8n	5678	Workflow automation
Whisper-STT	6001	Speech-to-Text
Flask-STT	5000	Backup STT service
Kokoro-TTS	8000	Japanese TTS

🔧 Development
bash
# Rebuild a specific service
docker-compose up -d --build whisper-stt

# View logs
docker-compose logs -f flask-stt

🚀 Deployment
Production (with HTTPS)
nginx
# Nginx config example
location /whisper {
    proxy_pass http://localhost:6001;
    proxy_set_header Host $host;
}


📂 Project Structure
AI/
├── flask-stt/
│   ├── app/
│   │   ├── app.py          # Flask STT server
│   │   └── requirements.txt
├── whisper/
│   ├── app/
│   │   ├── transcribe.py   # Whisper processing
├── n8n/
│   └── workflows/          # Example workflows
├── kokoro/                 # Emotional intelligence module
│   ├── emotion_analysis.py # Emotion detection
│   └── requirements.txt

📝 License
MIT

### Key Features:
1. **Badges** - Visual indicators for technologies
2. **Port Table** - Quick service reference
3. **API Examples** - Ready-to-use curl commands
4. **Production Notes** - Nginx config snippet
5. **Modular Structure** - Clear directory layout


📡 API Documentation

🔉 Whisper-STT
bash
curl -F 'audio=@test.wav' http://localhost:6001/transcribe
Response:

json
{
  "text": "transcribed text",
  "language": "en"
}

🗣️ Kokoro-TTS
bash
curl -X POST http://localhost:8000/synthesize \
  -H "Content-Type: application/json" \
  -d '{"text":"こんにちは", "voice":"female_01"}'

🐳 Container Management
Command	Description
docker-compose logs -f n8n	View n8n logs
docker-compose restart whisper	Restart Whisper service
docker stats	Monitor resource usage

