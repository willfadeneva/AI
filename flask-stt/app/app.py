from flask import Flask, jsonify
app = Flask(__name__)

@app.route('/')
def status():
    return jsonify({"service": "FLASK-STT", "status": "ready"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
