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
