# ArgoCD Implementation

Este directorio contiene todos los archivos necesarios para implementar ArgoCD en el proyecto de microservicios con **reconocimiento automático de acciones de CD**.

## 📁 Estructura de Archivos

- `argocd-install.yaml` - Instalación de ArgoCD en el clúster
- `argocd-repo.yaml` - Configuración del repositorio Git
- `argocd-application.yaml` - Definición de la aplicación para desarrollo
- `argocd-app-prod.yaml` - Definición de la aplicación para producción
- `argocd-webhook-config.yaml` - **NUEVO**: Configuración de webhooks para CD
- `argocd-notifications.yaml` - **NUEVO**: Configuración de notificaciones
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

# 2. Configurar webhooks y notificaciones
kubectl apply -f argocd-webhook-config.yaml
kubectl apply -f argocd-notifications.yaml

# 3. Configurar repositorio
kubectl apply -f argocd-repo.yaml

# 4. Desplegar aplicación
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
- **CD Actions**: **Reconocimiento automático de despliegues**

## 🚀 CD Actions - Reconocimiento Automático

### **1. Webhooks Configurados**
- **GitHub Webhook**: Detecta push y pull requests
- **Jenkins Webhook**: Detecta builds exitosos/fallidos
- **URL del Webhook**: `https://argocd-server.argocd.svc.cluster.local/api/webhook`

### **2. Triggers Automáticos**
```yaml
# En argocd-application.yaml
annotations:
  # Webhook triggers para CD
  argocd.argoproj.io/sync-options: Prune=true
  argocd.argoproj.io/sync-wave: "0"
```

### **3. Jenkins Pipeline Integration**
El pipeline Jenkins ahora incluye:
- **Stage "Trigger ArgoCD Sync"**: Activa sincronización tras deploy
- **Stage "Verify ArgoCD Sync"**: Verifica estado de sincronización
- **Notificaciones**: Confirma reconocimiento de CD actions

### **4. Notificaciones Automáticas**
- **Slack**: Canal `#deployments` para desarrollo, `#deployments-prod` para producción
- **Email**: Notificaciones por correo electrónico
- **Eventos**: Sync succeeded/failed, health degraded, deployment detected

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

### Verificar CD Actions
```bash
# Ver logs de webhooks
kubectl logs -n argocd deployment/argocd-server | grep webhook

# Ver estado de sincronización
kubectl get application proyecto-kubernetes-app -n argocd -o yaml

# Ver notificaciones
kubectl get events -n argocd --sort-by='.lastTimestamp'
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

## 🔄 GitOps Workflow con CD Actions

1. **Desarrollo**: Los desarrolladores hacen commits al repositorio
2. **CI/CD**: Jenkins construye y publica la imagen Docker
3. **CD Action Detection**: ArgoCD detecta la acción de CD automáticamente
4. **Webhook Trigger**: Jenkins envía webhook a ArgoCD
5. **Auto-Sync**: ArgoCD sincroniza la aplicación
6. **Notification**: Se envía notificación de éxito/fallo
7. **Monitoreo**: ArgoCD mantiene el estado sincronizado

## 🚀 Configuración de Webhooks

### GitHub Webhook
1. Ve a tu repositorio: https://github.com/JuanMaFraile/ProyectoKubernetes/settings/hooks
2. Agrega nuevo webhook:
   - **URL**: `https://argocd-server.argocd.svc.cluster.local/api/webhook`
   - **Content type**: `application/json`
   - **Events**: `push`, `pull_request`

### Jenkins Webhook
El pipeline Jenkins ya está configurado para enviar webhooks automáticamente tras el despliegue exitoso.

## 🛠️ Troubleshooting

### Problemas Comunes

1. **ArgoCD no puede acceder al repositorio**
   - Verificar credenciales en `argocd-repo.yaml`
   - Verificar permisos del token de GitHub

2. **La aplicación no se sincroniza**
   - Verificar que el chart de Helm sea válido: `helm lint helm/`
   - Verificar logs de ArgoCD: `kubectl logs -n argocd deployment/argocd-application-controller`

3. **Webhooks no funcionan**
   - Verificar que el servicio webhook esté expuesto: `kubectl get svc -n argocd`
   - Verificar logs del servidor: `kubectl logs -n argocd deployment/argocd-server`

4. **Notificaciones no llegan**
   - Verificar configuración en `argocd-notifications.yaml`
   - Verificar credenciales de Slack/Email en el secret

### Logs Útiles
```bash
# Logs del servidor ArgoCD
kubectl logs -n argocd deployment/argocd-server

# Logs del controlador de aplicaciones
kubectl logs -n argocd deployment/argocd-application-controller

# Logs del repositorio
kubectl logs -n argocd deployment/argocd-repo-server

# Logs de webhooks
kubectl logs -n argocd deployment/argocd-server | grep -i webhook
```

## 📈 Escalabilidad

Para entornos de producción, considera:
- Habilitar HA (High Availability) en `argocd-install.yaml`
- Configurar múltiples entornos (dev, staging, prod)
- Implementar políticas de RBAC
- Configurar notificaciones (Slack, email, etc.)
- **Configurar webhooks para cada entorno**
- **Implementar rollback automático en caso de fallos**

## ✅ CD Actions Implementadas

- ✅ **Detección automática** de commits y builds
- ✅ **Webhooks** para GitHub y Jenkins
- ✅ **Notificaciones** Slack/Email
- ✅ **Trigger automático** desde Jenkins pipeline
- ✅ **Auto-sync** con reconocimiento de cambios
- ✅ **Verificación** de estado de sincronización
- ✅ **Multi-entorno** (dev/prod) con diferentes configuraciones 