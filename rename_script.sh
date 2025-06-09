#!/bin/bash

# Script de renommage: NetworkManager Pro -> EDC NetSupervisor
# Exécutez ce script à la racine de votre projet

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔄 Renommage de NetworkManager Pro vers EDC NetSupervisor...${NC}"

# Sauvegarde avant modification
echo -e "${YELLOW}📋 Création d'une sauvegarde...${NC}"
cp -r . ../backup-before-rename-$(date +%Y%m%d-%H%M%S) 2>/dev/null || echo "Backup failed, continuing..."

# Liste des remplacements à effectuer
declare -A replacements=(
    # Noms d'application
    ["NetworkManager Pro"]="EDC NetSupervisor"
    ["networkmanager-pro"]="edc-netsupervisor"
    ["NetworkManager"]="NetSupervisor"
    ["networkmanager"]="netsupervisor"
    ["NETWORKMANAGER"]="NETSUPERVISOR"
    
    # URLs et chemins
    ["github.com/your-org/networkmanager-pro"]="github.com/your-org/edc-netsupervisor"
    ["networkmanager.com"]="edc-netsupervisor.com"
    ["admin@networkmanager.com"]="admin@edc-netsupervisor.com"
    
    # Descriptions
    ["Professional network management and topology visualization platform"]="EDC NetSupervisor - Plateforme de supervision réseau avancée"
    ["network management and security"]="supervision réseau EDC"
    ["Network Management & Topology Visualization"]="EDC NetSupervisor - Supervision Réseau"
    
    # Base de données
    ["networkmanager"]="edc_netsupervisor"
    ["networkmanager_test"]="edc_netsupervisor_test"
)

# Fichiers à modifier
files_to_modify=(
    "package.json"
    "client/package.json"
    "server/package.json"
    "README.md"
    "CHANGELOG.md"
    "LICENSE"
    "docker-compose.yml"
    "Dockerfile"
    ".env.example"
    "quick-start.sh"
    "scripts/install.sh"
    "scripts/backup.sh"
    "scripts/maintenance.sh"
    "scripts/mongo-init.js"
    "server/server.js"
    "client/src/App.js"
    "client/src/pages/Auth/LoginPage.js"
    "client/src/pages/Dashboard.js"
    "client/src/i18n/locales/fr/translation.json"
    "client/src/i18n/locales/en/translation.json"
    "monitoring/grafana/dashboards/networkmanager-overview.json"
    "monitoring/prometheus.yml"
    "monitoring/rules/alerts.yml"
    "nginx/nginx.conf"
    "cypress/e2e/networkmanager.cy.js"
    "cypress.config.js"
    ".github/workflows/ci-cd.yml"
    "jest.config.js"
    "babel.config.js"
    ".eslintrc.js"
)

# Fonction de remplacement dans un fichier
replace_in_file() {
    local file="$1"
    if [ -f "$file" ]; then
        echo "  📝 Modification de $file"
        
        # Créer une copie temporaire
        cp "$file" "$file.tmp"
        
        # Appliquer tous les remplacements
        for search in "${!replacements[@]}"; do
            replace="${replacements[$search]}"
            sed -i.bak "s|$search|$replace|g" "$file.tmp" 2>/dev/null || true
        done
        
        # Remplacer le fichier original
        mv "$file.tmp" "$file"
        rm -f "$file.bak"
    else
        echo "  ⚠️  Fichier non trouvé: $file"
    fi
}

# Modifier les fichiers
echo -e "${BLUE}📝 Modification des fichiers...${NC}"
for file in "${files_to_modify[@]}"; do
    replace_in_file "$file"
done

# Renommer les fichiers spécifiques
echo -e "${BLUE}📁 Renommage des fichiers spécifiques...${NC}"

# Renommer le fichier de test Cypress
if [ -f "cypress/e2e/networkmanager.cy.js" ]; then
    mv "cypress/e2e/networkmanager.cy.js" "cypress/e2e/edc-netsupervisor.cy.js"
    echo "  📝 Renommé: networkmanager.cy.js -> edc-netsupervisor.cy.js"
fi

# Renommer le dashboard Grafana
if [ -f "monitoring/grafana/dashboards/networkmanager-overview.json" ]; then
    mv "monitoring/grafana/dashboards/networkmanager-overview.json" "monitoring/grafana/dashboards/edc-netsupervisor-overview.json"
    echo "  📝 Renommé: networkmanager-overview.json -> edc-netsupervisor-overview.json"
fi

# Modifications spéciales pour les traductions
echo -e "${BLUE}🌐 Mise à jour des traductions...${NC}"

# Français
if [ -f "client/src/i18n/locales/fr/translation.json" ]; then
    sed -i.bak 's/"title": "NetworkManager Pro"/"title": "EDC NetSupervisor"/g' "client/src/i18n/locales/fr/translation.json"
    sed -i.bak 's/"welcomeMessage": "Bienvenue dans votre centre de supervision réseau"/"welcomeMessage": "Bienvenue dans EDC NetSupervisor"/g' "client/src/i18n/locales/fr/translation.json"
    rm -f "client/src/i18n/locales/fr/translation.json.bak"
fi

# Anglais
if [ -f "client/src/i18n/locales/en/translation.json" ]; then
    sed -i.bak 's/"title": "Dashboard"/"title": "EDC NetSupervisor Dashboard"/g' "client/src/i18n/locales/en/translation.json"
    sed -i.bak 's/"welcomeMessage": "Welcome to your network supervision center"/"welcomeMessage": "Welcome to EDC NetSupervisor"/g' "client/src/i18n/locales/en/translation.json"
    rm -f "client/src/i18n/locales/en/translation.json.bak"
fi

# Modifications dans les métadonnées Docker
echo -e "${BLUE}🐳 Mise à jour des métadonnées Docker...${NC}"
if [ -f "docker-compose.yml" ]; then
    sed -i.bak 's/networkmanager-/edc-netsupervisor-/g' "docker-compose.yml"
    sed -i.bak 's/container_name: networkmanager-/container_name: edc-netsupervisor-/g' "docker-compose.yml"
    rm -f "docker-compose.yml.bak"
fi

# Mise à jour du titre dans index.html
if [ -f "client/public/index.html" ]; then
    sed -i.bak 's/<title>.*<\/title>/<title>EDC NetSupervisor<\/title>/g' "client/public/index.html"
    sed -i.bak 's/"name": "NetworkManager Pro"/"name": "EDC NetSupervisor"/g' "client/public/manifest.json" 2>/dev/null || true
    rm -f "client/public/index.html.bak"
fi

# Mise à jour des constantes dans le code
echo -e "${BLUE}⚙️  Mise à jour des constantes...${NC}"

# App.js
if [ -f "client/src/App.js" ]; then
    sed -i.bak 's/NetworkManager Pro/EDC NetSupervisor/g' "client/src/App.js"
    rm -f "client/src/App.js.bak"
fi

# Variables d'environnement
if [ -f ".env.example" ]; then
    sed -i.bak 's/NetworkManager Pro Configuration/EDC NetSupervisor Configuration/g' ".env.example"
    sed -i.bak 's/networkmanager/edc_netsupervisor/g' ".env.example"
    rm -f ".env.example.bak"
fi

# Mise à jour du fichier de base de données MongoDB
if [ -f "scripts/mongo-init.js" ]; then
    sed -i.bak "s/db = db.getSiblingDB('networkmanager');/db = db.getSiblingDB('edc_netsupervisor');/g" "scripts/mongo-init.js"
    sed -i.bak 's/Initializing NetworkManager Pro database/Initializing EDC NetSupervisor database/g' "scripts/mongo-init.js"
    rm -f "scripts/mongo-init.js.bak"
fi

# Nettoyage des fichiers de sauvegarde
echo -e "${BLUE}🧹 Nettoyage...${NC}"
find . -name "*.bak" -delete 2>/dev/null || true

echo ""
echo -e "${GREEN}✅ Renommage terminé avec succès !${NC}"
echo ""
echo -e "${BLUE}📋 Résumé des modifications :${NC}"
echo "  🏷️  Nom de l'application : NetworkManager Pro → EDC NetSupervisor"
echo "  📦 Nom du package : networkmanager-pro → edc-netsupervisor"
echo "  🗄️  Base de données : networkmanager → edc_netsupervisor"
echo "  🌐 Traductions mises à jour"
echo "  🐳 Conteneurs Docker renommés"
echo "  📊 Dashboards Grafana mis à jour"
echo ""
echo -e "${YELLOW}⚠️  Actions manuelles nécessaires :${NC}"
echo "  1. Vérifiez votre fichier .env si il existe"
echo "  2. Mettez à jour vos variables d'environnement de production"
echo "  3. Reconstruisez les images Docker : docker-compose build"
echo "  4. Si vous avez une base de données existante, sauvegardez-la avant de redémarrer"
echo ""
echo -e "${GREEN}🚀 Votre application s'appelle maintenant EDC NetSupervisor !${NC}"