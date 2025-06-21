# ArgoCD Implementation

Este directorio contiene todos los archivos necesarios para implementar ArgoCD en el proyecto de microservicios.

## 📁 Estructura de Archivos

- `argocd-install.yaml` - Instalación de ArgoCD en el clúster
- `argocd-repo.yaml` - Configuración del repositorio Git
- `argocd-application.yaml` - Definición de la aplicación para desarrollo
- `argocd-app-prod.yaml` - Definición de la aplicación para producción
- `install-argocd.sh` - Script automatizado de instalación
- `README.md` - Esta documentación

## 🚀 Instalación Rápida

### Opción 1: Script Automatizado
```bash
cd argocd
./install-argocd.sh
```

### Opción 2: Instalación Manual
```bash
# 1. Instalar ArgoCD
kubectl apply -f argocd-install.yaml

# 2. Configurar repositorio
kubectl apply -f argocd-repo.yaml

# 3. Desplegar aplicación
kubectl apply -f argocd-application.yaml
```

## 🔧 Configuración

### Repositorio Git
Antes de usar ArgoCD, actualiza las credenciales en `argocd-repo.yaml`:

```yaml
stringData:
  username: tu-usuario-github
  password: tu-token-github
```

### Configuración de la Aplicación
La aplicación está configurada para:
- **Repositorio**: https://github.com/JuanMaFraile/ProyectoKubernetes.git
- **Rama**: main
- **Path**: helm (directorio del chart de Helm)
- **Sincronización**: Automática con auto-healing

## 📊 Monitoreo

### Verificar Estado de ArgoCD
```bash
kubectl get pods -n argocd
kubectl get application -n argocd
```

### Verificar Estado de la Aplicación
```bash
kubectl get pods -n default -l app=proyecto-kubernetes
kubectl get svc -n default -l app=proyecto-kubernetes
```

## 🌐 Acceso a la UI

### Port Forward
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

### Credenciales
- **Usuario**: admin
- **Contraseña**: 
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

## 🔄 GitOps Workflow

1. **Desarrollo**: Los desarrolladores hacen commits al repositorio
2. **CI/CD**: Jenkins construye y publica la imagen Docker
3. **ArgoCD**: Detecta cambios en el repositorio automáticamente
4. **Despliegue**: ArgoCD despliega la nueva versión usando Helm
5. **Monitoreo**: ArgoCD mantiene el estado sincronizado

## 🛠️ Troubleshooting

### Problemas Comunes

1. **ArgoCD no puede acceder al repositorio**
   - Verificar credenciales en `argocd-repo.yaml`
   - Verificar permisos del token de GitHub

2. **La aplicación no se sincroniza**
   - Verificar que el chart de Helm sea válido: `helm lint helm/`
   - Verificar logs de ArgoCD: `kubectl logs -n argocd deployment/argocd-application-controller`

3. **Problemas de recursos**
   - Verificar que el clúster tenga suficientes recursos
   - Ajustar límites en `argocd-install.yaml`

### Logs Útiles
```bash
# Logs del servidor ArgoCD
kubectl logs -n argocd deployment/argocd-server

# Logs del controlador de aplicaciones
kubectl logs -n argocd deployment/argocd-application-controller

# Logs del repositorio
kubectl logs -n argocd deployment/argocd-repo-server
```

## 📈 Escalabilidad

Para entornos de producción, considera:
- Habilitar HA (High Availability) en `argocd-install.yaml`
- Configurar múltiples entornos (dev, staging, prod)
- Implementar políticas de RBAC
- Configurar notificaciones (Slack, email, etc.) 