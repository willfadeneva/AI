from fastapi import FastAPI
app = FastAPI()

@app.get("/")
async def root():
    return {"service": "KOKORO-TTS", "status": "ready"}
