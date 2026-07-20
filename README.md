# Plataforma de Ingesta, Análisis y Custodia Segura de Datos

Plataforma cloud-native desplegada en AWS con arquitectura multicloud, alta disponibilidad y pipeline DevSecOps automatizado. ñam ñam ñam

## Arquitectura

- **Frontend:** React (Docker, puerto 80)
- **Backend/API:** FastAPI Python (Docker, puerto 8000)
- **Infraestructura IaC:** Terraform (AWS — VPC, ECS Fargate, RDS PostgreSQL Multi-AZ, S3+KMS, ALB)
- **Automatización on-premise:** Ansible (configuración de nodo Ubuntu)

## Módulos

| Módulo | Tecnología | Dockerfile |
|--------|-----------|------------|
| Frontend | React + Nginx | `frontend/Dockerfile` |
| Backend | FastAPI + Python 3.11 | `backend/Dockerfile` |
| Infraestructura | Terraform + AWS | `terraform/aws/` |
| Automatización | Ansible | `ansible/` |

## Cómo levantar localmente

```bash
docker-compose up
```

- Frontend: http://localhost
- Backend API: http://localhost:8000

## Usuarios de prueba

| Rol | Correo | Contraseña |
|-----|--------|------------|
| Jefe | jefe@empresa.com | Jefe2026! |
| Analista | analista@empresa.com | Analista2026! |
| Seguridad | seguridad@empresa.com | Seguridad2026! |

## Pipeline DevSecOps

El pipeline corre automáticamente en GitHub Actions con cada `git push`:

- **SAST:** Bandit (Python) + ESLint (JavaScript)
- **SCA:** Safety (Python) + npm audit (JavaScript)
- **Secret Scanning:** Gitleaks
- **IaC Scanning:** Checkov (Terraform)

## Despliegue en AWS

```bash
cd terraform/aws
terraform init
terraform apply
```