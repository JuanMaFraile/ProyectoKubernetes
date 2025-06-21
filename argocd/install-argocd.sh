#!/bin/bash

echo "🚀 Instalando ArgoCD en el clúster de Kubernetes..."

# Verificar que kubectl esté disponible
if ! command -v kubectl &> /dev/null; then
    echo "❌ Error: kubectl no está instalado o no está en el PATH"
    exit 1
fi

# Verificar conexión al clúster
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Error: No se puede conectar al clúster de Kubernetes"
    exit 1
fi

echo "✅ Conexión al clúster verificada"

# Instalar ArgoCD Operator (si no está instalado)
echo "📦 Instalando ArgoCD Operator..."
kubectl apply -f https://raw.githubusercontent.com/argoproj-labs/argocd-operator/main/deploy/crds/argoproj.io_argocds_crd.yaml
kubectl apply -f https://raw.githubusercontent.com/argoproj-labs/argocd-operator/main/deploy/crds/argoproj.io_applications_crd.yaml
kubectl apply -f https://raw.githubusercontent.com/argoproj-labs/argocd-operator/main/deploy/crds/argoproj.io_applicationsets_crd.yaml
kubectl apply -f https://raw.githubusercontent.com/argoproj-labs/argocd-operator/main/deploy/crds/argoproj.io_appprojects_crd.yaml

# Instalar ArgoCD Operator
kubectl apply -f https://raw.githubusercontent.com/argoproj-labs/argocd-operator/main/deploy/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/argoproj-labs/argocd-operator/main/deploy/service_account.yaml
kubectl apply -f https://raw.githubusercontent.com/argoproj-labs/argocd-operator/main/deploy/role.yaml
kubectl apply -f https://raw.githubusercontent.com/argoproj-labs/argocd-operator/main/deploy/role_binding.yaml
kubectl apply -f https://raw.githubusercontent.com/argoproj-labs/argocd-operator/main/deploy/cluster_role.yaml
kubectl apply -f https://raw.githubusercontent.com/argoproj-labs/argocd-operator/main/deploy/cluster_role_binding.yaml
kubectl apply -f https://raw.githubusercontent.com/argoproj-labs/argocd-operator/main/deploy/operator.yaml

echo "⏳ Esperando que el ArgoCD Operator esté listo..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-operator-controller-manager -n argocd-operator-system

# Instalar ArgoCD
echo "🔧 Instalando ArgoCD..."
kubectl apply -f argocd-install.yaml

echo "⏳ Esperando que ArgoCD esté listo..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Configurar repositorio
echo "📚 Configurando repositorio Git..."
kubectl apply -f argocd-repo.yaml

# Desplegar aplicación
echo "🚀 Desplegando aplicación..."
kubectl apply -f argocd-application.yaml

echo "✅ Instalación completada!"
echo ""
echo "📋 Información de acceso:"
echo "   - Namespace: argocd"
echo "   - Aplicación: proyecto-kubernetes-app"
echo ""
echo "🌐 Para acceder a la UI de ArgoCD:"
echo "   kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo ""
echo "🔑 Contraseña por defecto del admin:"
echo "   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 -d"
echo ""
echo "📊 Para ver el estado de la aplicación:"
echo "   kubectl get application -n argocd"
echo "   kubectl get pods -n default -l app=proyecto-kubernetes" 