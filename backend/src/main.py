from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
import pandas as pd
import io

app = FastAPI(title="Plataforma de Análisis Seguro")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def home():
    return {"status": "API funcionando"}

@app.post("/upload")
async def analizar_archivo(file: UploadFile = File(...)):
    contenido = await file.read()
    
    if file.filename.endswith(".csv"):
        df = pd.read_csv(io.BytesIO(contenido))
    elif file.filename.endswith(".json"):
        df = pd.read_json(io.BytesIO(contenido))
    else:
        return {"error": "Solo CSV o JSON"}

    return {
        "archivo": file.filename,
        "filas": len(df),
        "columnas": list(df.columns),
        "estadisticas": df.describe().to_dict()
    }