# EDC NetSupervisor 🚀

**Une plateforme complète de supervision et cartographie réseau multi-marque centralisée**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Node.js Version](https://img.shields.io/badge/node.js-18+-green.svg)](https://nodejs.org/)
[![MongoDB](https://img.shields.io/badge/MongoDB-7.0+-green.svg)](https://www.mongodb.com/)
[![Docker](https://img.shields.io/badge/Docker-Ready-blue.svg)](https://www.docker.com/)

## 🌟 Fonctionnalités principales

### 🔍 Découverte réseau automatisée
- Scan automatique des sous-réseaux configurés
- Détection intelligente des équipements réseau
- Identification automatique des types d'équipements
- Topologie dynamique en temps réel

### 🗺️ Cartographie avancée
- Visualisation interactive de la topologie réseau
- Schémas d'architecture avec icônes correspondantes
- Mise à jour automatique et dynamique
- Interface moderne et intuitive

### 🛡️ Supervision sécurité
- Surveillance en temps réel des équipements
- Détection d'anomalies et menaces
- Alertes configurables par seuils
- Score de sécurité global
- Monitoring des vulnérabilités

### 📋 Exécution de commandes
- Support SSH, SNMP, Telnet, API
- Commandes prédéfinies par type d'équipement
- Historique complet des exécutions
- Interface terminal intégrée

### 📄 Génération automatique de documents
- Documents d'architecture technique
- Rapports d'inventaire détaillés
- Rapports de sécurité
- Export PDF, Word, Excel
- Templates personnalisables

### 🌐 Interface moderne
- Design responsive et fluide
- Support multilingue (Français/Anglais)
- Thème clair/sombre
- Notifications temps réel
- Dashboard personnalisable

## 🏗️ Architecture technique

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   React Client  │────│  Express API    │────│    MongoDB      │
│                 │    │                 │    │                 │
│ • Redux Toolkit │    │ • REST API      │    │ • Documents     │
│ • React Router  │    │ • WebSocket     │    │ • Indexes       │
│ • TailwindCSS   │    │ • Middleware    │    │ • Validation    │
│ • i18n          │    │ • Services      │    │ • Aggregation   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │     Redis       │
                    │                 │
                    │ • Sessions      │
                    │ • Cache         │
                    │ • Real-time     │
                    └─────────────────┘
```

## 🚀 Installation rapide

### Prérequis
- Node.js 18+ 
- MongoDB 7.0+
- Redis (optionnel, pour le cache)
- Docker & Docker Compose (recommandé)

### Option 1: Installation avec Docker (Recommandée)

```bash
# Cloner le repository
git clone https://github.com/votre-org/edc_netsupervisor-pro.git
cd edc_netsupervisor-pro

# Copier et configurer les variables d'environnement
cp .env.example .env
# Éditer .env avec vos paramètres

# Lancer avec Docker Compose
docker-compose up -d

# Vérifier le statut
docker-compose ps
```

L'application sera disponible sur:
- **Interface principale**: http://localhost
- **API**: http://localhost:5000
- **Monitoring**: http://localhost:3001 (Grafana)

### Option 2: Installation manuelle

```bash
# 1. Cloner le repository
git clone https://github.com/votre-org/edc_netsupervisor-pro.git
cd edc_netsupervisor-pro

# 2. Installer les dépendances
npm install
cd client && npm install && cd ..
cd server && npm install && cd ..

# 3. Configurer l'environnement
cp .env.example .env
# Éditer .env avec vos paramètres

# 4. Démarrer MongoDB et Redis
# (selon votre système)

# 5. Initialiser la base de données
node scripts/init-database.js

# 6. Démarrer l'application
npm run dev
```

## 🔧 Configuration

### Variables d'environnement principales

```bash
# Application
NODE_ENV=production
PORT=5000
CLIENT_URL=http://localhost:3000

# Base de données
MONGODB_URI=mongodb://localhost:27017/edc_netsupervisor
REDIS_URL=redis://localhost:6379

# Sécurité
JWT_SECRET=votre-clé-secrète-très-longue
ENCRYPTION_KEY=votre-clé-32-caractères
```

### Configuration réseau

```javascript
// Dans l'interface admin
{
  "network": {
    "autoDiscoveryInterval": 30,        // minutes
    "discoverySubnets": [
      "192.168.1.0/24",
      "10.0.0.0/24"
    ],
    "snmpCommunity": "public",
    "sshTimeout": 30,                   // secondes
    "maxConcurrentConnections": 10
  }
}
```

## 📱 Utilisation

### 1. Première connexion

Connectez-vous avec le compte admin par défaut:
- **Email**: admin@edc-netsupervisor.com
- **Mot de passe**: admin123

⚠️ **Changez immédiatement le mot de passe par défaut !**

### 2. Configuration initiale

1. **Paramètres réseau**: Configurez les sous-réseaux à scanner
2. **Découverte**: Lancez un scan initial de votre réseau
3. **Topologie**: Visualisez et organisez votre cartographie
4. **Monitoring**: Activez la surveillance temps réel

### 3. Fonctionnalités avancées

#### Découverte automatique
```bash
# Via l'interface web ou API
POST /api/discovery/scan
{
  "subnet": "192.168.1.0/24",
  "protocols": ["icmp", "snmp", "ssh"],
  "timeout": 30
}
```

#### Exécution de commandes
```bash
# SSH vers un équipement
POST /api/commands/execute
{
  "deviceId": "device_id",
  "command": "show interface status",
  "protocol": "ssh"
}
```

#### Génération de documents
```bash
# Générer un rapport d'architecture
POST /api/documents/generate
{
  "type": "architecture",
  "format": "pdf",
  "includeTopology": true,
  "includeDeviceDetails": true
}
```

## 🐳 Déploiement Docker

### Architecture conteneurs

```yaml
services:
  app:           # Application principale
  mongodb:       # Base de données
  redis:         # Cache et sessions
  nginx:         # Reverse proxy
  prometheus:    # Métriques
  grafana:       # Dashboards
  elasticsearch: # Logs
  backup:        # Sauvegardes automatiques
```

### Commandes Docker utiles

```bash
# Démarrer tous les services
docker-compose up -d

# Voir les logs en temps réel
docker-compose logs -f app

# Redémarrer un service
docker-compose restart app

# Sauvegarder la base de données
docker-compose exec mongodb mongodump --out /backup

# Accéder au conteneur
docker-compose exec app sh

# Nettoyer les volumes
docker-compose down -v
```

## 🔒 Sécurité

### Bonnes pratiques implémentées

- ✅ Authentification JWT avec refresh tokens
- ✅ Chiffrement des mots de passe (bcrypt)
- ✅ Validation et sanitisation des entrées
- ✅ Protection CSRF
- ✅ Rate limiting
- ✅ Audit trail complet
- ✅ Chiffrement des données sensibles
- ✅ Isolation des conteneurs Docker

### Configuration sécurisée

```javascript
// Exemple de politique de mot de passe
{
  "passwordPolicy": {
    "minLength": 12,
    "requireUppercase": true,
    "requireNumbers": true,
    "requireSpecialChars": true,
    "preventReuse": 5
  }
}
```

## 📊 Monitoring et observabilité

### Métriques disponibles

- **Performance**: Temps de réponse, throughput
- **Santé système**: CPU, mémoire, disque
- **Réseau**: Latence, perte de paquets, bande passante
- **Sécurité**: Tentatives de connexion, alertes
- **Utilisation**: Utilisateurs actifs, commandes exécutées

### Dashboards Grafana

Accédez à Grafana sur http://localhost:3001
- **Dashboard système**: Métriques serveur
- **Dashboard réseau**: État des équipements
- **Dashboard sécurité**: Alertes et incidents
- **Dashboard utilisateurs**: Activité et performance

## 🔧 API Reference

### Authentification

```bash
# Login
POST /api/auth/login
{
  "email": "user@example.com",
  "password": "password"
}

# Réponse
{
  "token": "jwt_token",
  "refreshToken": "refresh_token",
  "user": { ... }
}
```

### Gestion des équipements

```bash
# Lister les équipements
GET /api/devices?type=router&status=online

# Ajouter un équipement
POST /api/devices
{
  "name": "Router-01",
  "ipAddress": "192.168.1.1",
  "type": "router",
  "credentials": { ... }
}

# Mettre à jour un équipement
PUT /api/devices/:id
{
  "location": "Datacenter A"
}
```

### Topologie réseau

```bash
# Obtenir la topologie
GET /api/network/topology

# Mettre à jour la topologie
PUT /api/network/topology
{
  "devices": [...],
  "connections": [...]
}
```

## 🛠️ Développement

### Structure du projet

```
edc_netsupervisor-pro/
├── client/                 # Application React
│   ├── src/
│   │   ├── components/     # Composants réutilisables
│   │   ├── pages/         # Pages de l'application
│   │   ├── store/         # État global (Redux)
│   │   ├── services/      # Services API
│   │   └── utils/         # Utilitaires
├── server/                # API Express.js
│   ├── routes/            # Routes API
│   ├── models/            # Modèles MongoDB
│   ├── services/          # Services métier
│   ├── middleware/        # Middlewares
│   └── utils/             # Utilitaires serveur
├── scripts/               # Scripts utilitaires
├── monitoring/            # Configuration monitoring
└── docs/                  # Documentation
```

### Commandes de développement

```bash
# Démarrer en mode développement
npm run dev

# Tests
npm test
npm run test:coverage

# Build de production
npm run build

# Linting
npm run lint
npm run lint:fix

# Base de données
npm run db:seed        # Données de test
npm run db:migrate     # Migrations
npm run db:backup      # Sauvegarde
```

### Contribution

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📋 Tests

### Tests automatisés

```bash
# Tests unitaires
npm run test:unit

# Tests d'intégration
npm run test:integration

# Tests E2E
npm run test:e2e

# Coverage
npm run test:coverage
```

### Tests manuels

1. **Découverte réseau**: Tester sur différents sous-réseaux
2. **Commandes**: Vérifier SSH, SNMP, Telnet
3. **Documents**: Générer tous les types de rapports
4. **Monitoring**: Vérifier les alertes temps réel

## 🔄 Sauvegarde et restauration

### Sauvegarde automatique

```bash
# Exécuter une sauvegarde manuelle
docker-compose exec backup /backup.sh

# Programmer des sauvegardes automatiques
# (configuré dans docker-compose.yml)
```

### Restauration

```bash
# Restaurer depuis une sauvegarde
docker-compose exec backup /backup.sh restore backup_file.tar.gz

# Lister les sauvegardes disponibles
docker-compose exec backup /backup.sh list
```

## 🆘 Dépannage

### Problèmes courants

#### L'application ne démarre pas
```bash
# Vérifier les logs
docker-compose logs app

# Vérifier la connectivité MongoDB
docker-compose exec app ping mongodb
```

#### Problèmes de découverte réseau
```bash
# Vérifier les permissions réseau
docker-compose exec app ping 192.168.1.1

# Tester SNMP manuellement
docker-compose exec app snmpget -v2c -c public 192.168.1.1 1.3.6.1.2.1.1.1.0
```

#### Erreurs de base de données
```bash
# Vérifier l'état MongoDB
docker-compose exec mongodb mongosh --eval "db.adminCommand('ping')"

# Recréer les index
docker-compose exec mongodb mongosh edc_netsupervisor --eval "db.dropDatabase()"
```

### Performance

#### Optimisation des requêtes
- Vérifiez les index MongoDB avec `db.collection.getIndexes()`
- Surveillez les requêtes lentes dans les logs
- Utilisez l'aggregation pipeline pour les requêtes complexes

#### Mise à l'échelle
- Augmentez les workers Node.js (`CLUSTER_MODE=true`)
- Configurez un cluster MongoDB pour la haute disponibilité
- Utilisez un load balancer pour répartir la charge

## 📚 Documentation avancée

- [Guide d'architecture](docs/architecture.md)
- [API Reference complète](docs/api.md)
- [Guide de déploiement](docs/deployment.md)
- [Sécurité et bonnes pratiques](docs/security.md)
- [Monitoring et alertes](docs/monitoring.md)
- [Personnalisation et plugins](docs/customization.md)

## 🤝 Support

### Communauté
- **GitHub Issues**: Rapports de bugs et demandes de fonctionnalités
- **Discussions**: Questions et entraide communautaire
- **Wiki**: Documentation collaborative

### Support commercial
Pour un support prioritaire, formations ou développements sur mesure:
- Email: support@edc-netsupervisor.com
- Documentation: https://docs.edc-netsupervisor.com

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

## 🎯 Roadmap

### Version 2.0 (Q2 2025)
- [ ] Support IPv6 complet
- [ ] Intégration NetBox et Zabbix
- [ ] Module de gestion des changements
- [ ] API GraphQL
- [ ] Support multi-tenant

### Version 2.1 (Q3 2025)
- [ ] Intelligence artificielle pour la détection d'anomalies
- [ ] Intégration avec les outils ITSM
- [ ] Support des protocoles IoT
- [ ] Module de conformité automatisée

### Version 3.0 (Q4 2025)
- [ ] Interface mobile native
- [ ] Support cloud hybride
- [ ] Orchestration réseau automatisée
- [ ] Analytics avancées avec ML

---

**EDC NetSupervisor** - *Une solution complète pour la gestion moderne des infrastructures réseau*

Développé avec ❤️ pour les administrateurs réseau du monde entier.