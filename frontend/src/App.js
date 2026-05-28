import React, { useState } from 'react';
import './App.css';

function App() {
  const [resultado, setResultado] = useState(null);
  const [cargando, setCargando] = useState(false);

  const subirArchivo = async (e) => {
    const file = e.target.files[0];
    if (!file) return;
    
    setCargando(true);
    const formData = new FormData();
    formData.append('file', file);

    try {
      const res = await fetch('http://localhost:8000/upload', {
        method: 'POST',
        body: formData
      });
      const data = await res.json();
      setResultado(data);
    } catch (err) {
      setResultado({ error: 'No se pudo conectar al backend' });
    }
    setCargando(false);
  };

  return (
    <div className="App">
      <header className="App-header">
        <h1>📊 Plataforma de Análisis Seguro</h1>
        <p>Sube tu archivo CSV o JSON para analizarlo</p>
        <input type="file" accept=".csv,.json" onChange={subirArchivo} />
        {cargando && <p>⏳ Analizando...</p>}
        {resultado && (
          <div style={{textAlign:'left', marginTop:'20px'}}>
            <p>✅ Archivo: {resultado.archivo}</p>
            <p>📋 Filas: {resultado.filas}</p>
            <p>📌 Columnas: {resultado.columnas?.join(', ')}</p>
          </div>
        )}
      </header>
    </div>
  );
}

export default App;
