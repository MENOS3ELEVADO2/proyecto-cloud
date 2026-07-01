from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
import pandas as pd
import io
import boto3
import os
from datetime import datetime
from sqlalchemy import create_engine, text
from pydantic import BaseModel

app = FastAPI(title="Plataforma de Análisis Seguro")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

S3_BUCKET = "proyecto-cloud-datos-864846952757"
s3_client = boto3.client("s3", region_name="us-east-1")

DB_HOST = os.environ.get("DB_HOST", "proyecto-cloud-db.clj08iu19kau.us-east-1.rds.amazonaws.com")
DB_NAME = os.environ.get("DB_NAME", "proyectocloud")
DB_USER = os.environ.get("DB_USER", "postgres")
DB_PASSWORD = os.environ.get("DB_PASSWORD", "CambiaEstaClave123!")
DB_URL = f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:5432/{DB_NAME}"

engine = create_engine(DB_URL)

class LoginRequest(BaseModel):
    email: str
    password: str

def init_db():
    with engine.connect() as conn:
        conn.execute(text("""
            CREATE TABLE IF NOT EXISTS analisis (
                id SERIAL PRIMARY KEY,
                nombre_archivo VARCHAR(255),
                filas INTEGER,
                columnas TEXT,
                fecha TIMESTAMP DEFAULT NOW()
            )
        """))
        conn.execute(text("""
            CREATE TABLE IF NOT EXISTS usuarios (
                id SERIAL PRIMARY KEY,
                email VARCHAR(255) UNIQUE,
                password VARCHAR(255),
                rol VARCHAR(50),
                nombre VARCHAR(255)
            )
        """))
        conn.execute(text("""
            INSERT INTO usuarios (email, password, rol, nombre) VALUES
            ('jefe@empresa.com', 'Jefe2026!', 'jefe', 'Gerente General'),
            ('analista@empresa.com', 'Analista2026!', 'analista', 'Analista de Datos'),
            ('seguridad@empresa.com', 'Seguridad2026!', 'seguridad', 'Oficial de Ciberseguridad')
            ON CONFLICT (email) DO NOTHING
        """))
        conn.commit()

@app.on_event("startup")
def startup_event():
    try:
        init_db()
    except Exception as e:
        print(f"Error inicializando DB: {e}")

@app.get("/api/")
def home():
    return {"status": "API funcionando"}

@app.post("/api/login")
def login(datos: LoginRequest):
    with engine.connect() as conn:
        result = conn.execute(
            text("SELECT email, password, rol, nombre FROM usuarios WHERE email = :email"),
            {"email": datos.email}
        )
        usuario = result.fetchone()

    if not usuario or usuario.password != datos.password:
        return {"exito": False, "error": "Credenciales incorrectas"}

    return {"exito": True, "email": usuario.email, "rol": usuario.rol, "nombre": usuario.nombre}

@app.post("/api/upload")
async def analizar_archivo(file: UploadFile = File(...)):
    contenido = await file.read()

    if file.filename.endswith(".csv"):
        df = pd.read_csv(io.BytesIO(contenido))
    elif file.filename.endswith(".json"):
        df = pd.read_json(io.BytesIO(contenido))
    else:
        return {"error": "Solo CSV o JSON"}

    nombre_s3 = f"uploads/{datetime.now().strftime('%Y%m%d%H%M%S')}_{file.filename}"
    s3_client.put_object(Bucket=S3_BUCKET, Key=nombre_s3, Body=contenido)

    columnas_str = ",".join(df.columns)
    with engine.connect() as conn:
        conn.execute(
            text("INSERT INTO analisis (nombre_archivo, filas, columnas) VALUES (:nombre, :filas, :columnas)"),
            {"nombre": file.filename, "filas": len(df), "columnas": columnas_str}
        )
        conn.commit()

    return {
        "archivo": file.filename,
        "guardado_en_s3": nombre_s3,
        "filas": len(df),
        "columnas": list(df.columns),
        "estadisticas": df.describe().to_dict()
    }

@app.get("/api/historial")
def ver_historial():
    with engine.connect() as conn:
        result = conn.execute(text("SELECT id, nombre_archivo, filas, columnas, fecha FROM analisis ORDER BY fecha DESC LIMIT 20"))
        rows = [dict(row._mapping) for row in result]
    return {"historial": rows}

@app.get("/api/health")
def health_check():
    return {"status": "ok"}