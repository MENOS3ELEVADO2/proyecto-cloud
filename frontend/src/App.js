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
    <div className="dashboard-container">
      {/* Panel Lateral */}
      <aside className="sidebar">
        <div className="logo">DataML Platform</div>
        <nav className="menu">
          <a href="#ingesta" className="active">📊 Flujos de Ingesta</a>
          <a href="#jupyter">📓 Entornos Jupyter</a>
          <a href="#modelos">🧠 Modelos Predictivos</a>
          <a href="#custodia">🛡️ Custodia de Datos</a>
        </nav>
      </aside>

      {/* Contenido Principal */}
      <main className="main-content">
        <header className="main-header">
          <h2>Flujos de Ingesta <span className="badge">En tiempo real</span></h2>
        </header>

        <section className="upload-section">
          <label className="custom-upload">
            <span>📁 Seleccionar archivo (CSV o JSON)</span>
            <input type="file" accept=".csv,.json" onChange={subirArchivo} hidden />
          </label>
          {cargando && <div className="loader">⏳ Analizando data con Pandas...</div>}
        </section>

        {resultado && !resultado.error && (
          <div className="results-fade">
            {/* Tarjetas de Resumen */}
            <div className="cards-grid">
              <div className="card">
                <h3>Archivo Procesado</h3>
                <p className="card-value">{resultado.archivo}</p>
              </div>
              <div className="card">
                <h3>Total Registros</h3>
                <p className="card-value">{resultado.filas}</p>
              </div>
              <div className="card">
                <h3>Dimensiones</h3>
                <p className="card-value">{resultado.columnas?.length} Columnas</p>
              </div>
            </div>

            {/* Tabla de Estadísticas de Pandas */}
            <div className="table-container">
              <h3>Vista de Base de Datos - Estadísticas Descriptivas</h3>
              <div className="responsive-table">
                <table>
                  <thead>
                    <tr>
                      <th>Métrica (Pandas)</th>
                      {resultado.columnas?.map(col => <th key={col}>{col}</th>)}
                    </tr>
                  </thead>
                  <tbody>
                    {resultado.estadisticas && Object.keys(resultado.estadisticas).map(metric => (
                      <tr key={metric}>
                        <td className="metric-name">{metric}</td>
                        {resultado.columnas?.map(col => {
                          const val = resultado.estadisticas[metric]?.[col];
                          return <td key={col}>{typeof val === 'number' ? val.toFixed(2) : val ?? '-'}</td>;
                        })}
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        )}

        {resultado?.error && (
          <div className="error-box">❌ Error: {resultado.error}</div>
        )}
      </main>
    </div>
  );
}

export default App;