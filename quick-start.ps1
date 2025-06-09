# EDC NetSupervisor - Quick Start Script for Windows PowerShell
# One-command installation and startup for Windows

param(
    [Parameter(Position=0)]
    [ValidateSet("install", "start", "stop", "status", "update", "uninstall", "help", "")]
    [string]$Command = "install",
    
    [string]$InstallDir = "edc-netsupervisor",
    [string]$Domain = "localhost",
    [int]$Port = 80,
    [ValidateSet("full", "development", "production")]
    [string]$InstallType = "full"
)

# Requires PowerShell 5.1 or later
#Requires -Version 5.1

# Configuration
$Script:RepoUrl = "https://github.com/your-org/edc-netsupervisor.git"
$Script:DefaultDomain = "localhost"
$Script:DefaultPort = 80

# Colors for output (PowerShell compatible)
function Write-ColorOutput {
    param(
        [string]$Message,
        [ValidateSet("Red", "Green", "Yellow", "Blue", "Magenta", "Cyan", "White")]
        [string]$ForegroundColor = "White"
    )
    Write-Host $Message -ForegroundColor $ForegroundColor
}

function Write-Log { 
    param([string]$Message)
    $timestamp = Get-Date -Format "HH:mm:ss"
    Write-ColorOutput "[$timestamp] $Message" -ForegroundColor Green 
}

function Write-Warning { 
    param([string]$Message)
    $timestamp = Get-Date -Format "HH:mm:ss"
    Write-ColorOutput "[$timestamp] WARNING: $Message" -ForegroundColor Yellow 
}

function Write-Error { 
    param([string]$Message)
    $timestamp = Get-Date -Format "HH:mm:ss"
    Write-ColorOutput "[$timestamp] ERROR: $Message" -ForegroundColor Red 
}

function Write-Info { 
    param([string]$Message)
    $timestamp = Get-Date -Format "HH:mm:ss"
    Write-ColorOutput "[$timestamp] INFO: $Message" -ForegroundColor Blue 
}

function Write-Success { 
    param([string]$Message)
    $timestamp = Get-Date -Format "HH:mm:ss"
    Write-ColorOutput "[$timestamp] SUCCESS: $Message" -ForegroundColor Green 
}

# Show banner
function Show-Banner {
    Clear-Host
    Write-ColorOutput @"
    ███████╗██████╗  ██████╗    ███╗   ██╗███████╗████████╗
    ██╔════╝██╔══██╗██╔════╝    ████╗  ██║██╔════╝╚══██╔══╝
    █████╗  ██║  ██║██║         ██╔██╗ ██║█████╗     ██║   
    ██╔══╝  ██║  ██║██║         ██║╚██╗██║██╔══╝     ██║   
    ███████╗██████╔╝╚██████╗    ██║ ╚████║███████╗   ██║   
    ╚══════╝╚═════╝  ╚═════╝    ╚═╝  ╚═══╝╚══════╝   ╚═╝   
                                                           
    ███████╗██╗   ██╗██████╗ ███████╗██████╗ ██╗   ██╗██╗███████╗ ██████╗ ██████╗ 
    ██╔════╝██║   ██║██╔══██╗██╔════╝██╔══██╗██║   ██║██║██╔════╝██╔═══██╗██╔══██╗
    ███████╗██║   ██║██████╔╝█████╗  ██████╔╝██║   ██║██║███████╗██║   ██║██████╔╝
    ╚════██║██║   ██║██╔═══╝ ██╔══╝  ██╔══██╗╚██╗ ██╔╝██║╚════██║██║   ██║██╔══██╗
    ███████║╚██████╔╝██║     ███████╗██║  ██║ ╚████╔╝ ██║███████║╚██████╔╝██║  ██║
    ╚══════╝ ╚═════╝ ╚═╝     ╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝
"@ -ForegroundColor Magenta

    Write-ColorOutput "        Plateforme de supervision réseau avancée" -ForegroundColor Cyan
    Write-ColorOutput "              Script d'installation PowerShell" -ForegroundColor Cyan
    Write-Host ""
    Write-ColorOutput "🚀 Préparez votre plateforme de supervision réseau en quelques minutes !" -ForegroundColor Green
    Write-Host ""
}

# Check prerequisites
function Test-Prerequisites {
    Write-Log "Vérification des prérequis système..."
    
    $missingDeps = @()
    
    # Check for required commands
    $requiredCommands = @("git", "docker", "docker-compose")
    
    foreach ($cmd in $requiredCommands) {
        if (!(Get-Command $cmd -ErrorAction SilentlyContinue)) {
            $missingDeps += $cmd
        }
    }
    
    if ($missingDeps.Count -gt 0) {
        Write-Error "Dépendances manquantes : $($missingDeps -join ', ')"
        Write-Host ""
        Write-Info "Veuillez installer les dépendances manquantes :"
        Write-Host ""
        Write-Host "  Windows :"
        Write-Host "    Git : https://git-scm.com/download/win"
        Write-Host "    Docker Desktop : https://www.docker.com/products/docker-desktop"
        Write-Host ""
        throw "Dépendances manquantes"
    }
    
    # Check Docker daemon
    try {
        docker info 2>$null | Out-Null
        if ($LASTEXITCODE -ne 0) {
            throw "Docker daemon not running"
        }
    }
    catch {
        Write-Error "Docker daemon n'est pas en cours d'exécution"
        Write-Info "Veuillez démarrer Docker Desktop et réessayer"
        throw "Docker non disponible"
    }
    
    Write-Success "Tous les prérequis sont satisfaits"
}

# Get user preferences  
function Get-UserPreferences {
    Write-ColorOutput "📋 Configuration" -ForegroundColor Cyan
    Write-Host ""
    
    # Installation directory
    $userInstallDir = Read-Host "📁 Répertoire d'installation [$InstallDir]"
    if ($userInstallDir) {
        $Script:InstallDir = $userInstallDir
    }
    
    # Domain/hostname
    $userDomain = Read-Host "🌐 Domaine/hostname [$Domain]"
    if ($userDomain) {
        $Script:Domain = $userDomain
    }
    
    # Port
    $userPort = Read-Host "🔌 Port HTTP [$Port]"
    if ($userPort -and $userPort -as [int]) {
        $Script:Port = [int]$userPort
    }
    
    # Installation type
    Write-Host ""
    Write-Host "🔧 Type d'installation :"
    Write-Host "  1) Installation complète (Recommandée)"
    Write-Host "  2) Mode développement"
    Write-Host "  3) Déploiement production"
    $installChoice = Read-Host "Sélectionnez une option [1]"
    
    switch ($installChoice) {
        "2" { $Script:InstallType = "development" }
        "3" { $Script:InstallType = "production" }
        default { $Script:InstallType = "full" }
    }
    
    Write-Host ""
    Write-Success "Configuration terminée"
    Write-Host "  📁 Répertoire : $InstallDir"
    Write-Host "  🌐 Domaine : $Domain"
    Write-Host "  🔌 Port : $Port"
    Write-Host "  🔧 Type : $InstallType"
    Write-Host ""
}

# Download source code
function Get-SourceCode {
    Write-Log "Téléchargement du code source EDC NetSupervisor..."
    
    if (Test-Path $InstallDir) {
        Write-Warning "Le répertoire $InstallDir existe déjà"
        $confirm = Read-Host "Voulez-vous le supprimer et continuer ? [y/N]"
        if ($confirm -notmatch '^[Yy]$') {
            Write-Error "Installation annulée"
            exit 1
        }
        Remove-Item $InstallDir -Recurse -Force
    }
    
    try {
        git clone $RepoUrl $InstallDir
        if ($LASTEXITCODE -ne 0) {
            throw "Git clone failed"
        }
    }
    catch {
        Write-Error "Échec du clonage du repository"
        Write-Info "Vous pouvez aussi télécharger et extraire le code source manuellement"
        throw "Download failed"
    }
    
    Set-Location $InstallDir
    Write-Success "Code source téléchargé avec succès"
}

# Generate configuration
function New-Configuration {
    Write-Log "Génération des fichiers de configuration..."
    
    # Generate secure secrets
    $jwtSecret = [Convert]::ToBase64String((1..64 | ForEach-Object { Get-Random -Maximum 256 }))
    $encryptionKey = -join ((1..32) | ForEach-Object { '{0:X}' -f (Get-Random -Maximum 16) })
    $encryptionIV = -join ((1..16) | ForEach-Object { '{0:X}' -f (Get-Random -Maximum 16) })
    $dbPassword = -join ((1..16) | ForEach-Object { [char](Get-Random -Minimum 65 -Maximum 91) })
    $adminPassword = -join ((1..12) | ForEach-Object { [char](Get-Random -Minimum 65 -Maximum 91) })
    
    # Create .env file
    $envContent = @"
# EDC NetSupervisor Configuration
# Généré le $(Get-Date)

# Application
NODE_ENV=$InstallType
PORT=5000
CLIENT_URL=http://${Domain}:${Port}

# Database
MONGODB_URI=mongodb://admin:${dbPassword}@mongodb:27017/edc_netsupervisor?authSource=admin
MONGO_USERNAME=admin
MONGO_PASSWORD=$dbPassword

# Redis
REDIS_URL=redis://redis:6379
REDIS_PASSWORD=

# Security
JWT_SECRET=$jwtSecret
REFRESH_TOKEN_SECRET=${jwtSecret}refresh
ENCRYPTION_KEY=$encryptionKey
ENCRYPTION_IV=$encryptionIV

# Admin Account
ADMIN_EMAIL=admin@edc-netsupervisor.local
ADMIN_PASSWORD=$adminPassword

# Features
ENABLE_METRICS=true
ENABLE_SWAGGER=true
LOG_LEVEL=info

# Monitoring
GRAFANA_USER=admin
GRAFANA_PASSWORD=admin

# Backup
BACKUP_ENABLED=true
BACKUP_INTERVAL=daily
BACKUP_RETENTION_DAYS=30
"@

    $envContent | Out-File -FilePath ".env" -Encoding UTF8
    
    # Update docker-compose ports if needed
    if ($Port -ne 80) {
        $dockerComposeContent = Get-Content "docker-compose.yml" -Raw
        $dockerComposeContent = $dockerComposeContent -replace "80:80", "${Port}:80"
        $dockerComposeContent | Out-File -FilePath "docker-compose.yml" -Encoding UTF8
    }
    
    Write-Success "Fichiers de configuration générés"
    Write-Info "Identifiants administrateur :"
    Write-Host "  📧 Email : admin@edc-netsupervisor.local"
    Write-Host "  🔐 Mot de passe : $adminPassword"
    Write-Host ""
    Write-Warning "Veuillez sauvegarder ces identifiants - ils ne seront plus affichés !"
    Write-Host ""
    
    # Save credentials to file for user
    @"
EDC NetSupervisor - Identifiants de connexion
============================================
Email: admin@edc-netsupervisor.local
Mot de passe: $adminPassword
Généré le: $(Get-Date)

IMPORTANT: Changez ce mot de passe après la première connexion !
"@ | Out-File -FilePath "IDENTIFIANTS.txt" -Encoding UTF8
}

# Setup SSL certificates
function New-SSLCertificates {
    Write-Log "Configuration des certificats SSL..."
    
    New-Item -ItemType Directory -Path "ssl" -Force | Out-Null
    
    # Check if OpenSSL is available
    if (Get-Command openssl -ErrorAction SilentlyContinue) {
        # Generate self-signed certificate with OpenSSL
        & openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ssl/key.pem -out ssl/cert.pem -subj "/C=FR/ST=State/L=City/O=EDC NetSupervisor/CN=$Domain" 2>$null
        Write-Success "Certificats SSL créés (auto-signés pour développement)"
    }
    else {
        Write-Warning "OpenSSL non trouvé - création de certificats factices"
        "# Certificate placeholder" | Out-File -FilePath "ssl/cert.pem" -Encoding UTF8
        "# Key placeholder" | Out-File -FilePath "ssl/key.pem" -Encoding UTF8
    }
}

# Create necessary directories
function New-Directories {
    Write-Log "Création des répertoires nécessaires..."
    
    $directories = @("logs", "uploads", "backups", "ssl", "nginx/conf.d")
    
    foreach ($dir in $directories) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        # Create .gitkeep files
        "" | Out-File -FilePath "$dir/.gitkeep" -Encoding UTF8
    }
    
    Write-Success "Répertoires créés"
}

# Install and start services
function Start-Services {
    Write-Log "Démarrage des services EDC NetSupervisor..."
    
    # Pull images and build
    Write-Info "Téléchargement des images Docker (peut prendre quelques minutes)..."
    & docker-compose pull --ignore-pull-failures
    
    Write-Info "Construction des conteneurs d'application..."
    & docker-compose build
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Échec de la construction Docker"
        throw "Docker build failed"
    }
    
    # Start services
    Write-Info "Démarrage de tous les services..."
    & docker-compose up -d
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Échec du démarrage des services"
        throw "Service startup failed"
    }
    
    # Wait for services to be ready
    Write-Log "Attente du démarrage des services..."
    $timeout = 120
    $elapsed = 0
    
    do {
        Start-Sleep -Seconds 5
        $elapsed += 5
        Write-Host "." -NoNewline
        
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:5000/api/health" -TimeoutSec 2 -ErrorAction SilentlyContinue
            if ($response.StatusCode -eq 200) {
                break
            }
        }
        catch {
            # Continue waiting
        }
    } while ($elapsed -lt $timeout)
    
    Write-Host ""
    
    if ($elapsed -ge $timeout) {
        Write-Error "Les services n'ont pas démarré dans les $timeout secondes"
        Write-Info "Vérifiez les logs avec : docker-compose logs"
        throw "Service startup timeout"
    }
    
    Write-Success "Tous les services sont en cours d'exécution !"
}

# Run initial setup
function Initialize-Setup {
    Write-Log "Exécution de la configuration initiale..."
    
    # Initialize database
    Write-Info "Initialisation de la base de données..."
    try {
        if (Test-Path "scripts/mongo-init.js") {
            & docker-compose exec -T mongodb mongosh edc_netsupervisor --file /scripts/mongo-init.js
        }
    }
    catch {
        Write-Warning "L'initialisation de la base de données peut avoir échoué - ce n'est généralement pas critique"
    }
    
    # Wait a bit for everything to settle
    Start-Sleep -Seconds 10
    
    Write-Success "Configuration initiale terminée"
}

# Verify installation
function Test-Installation {
    Write-Log "Vérification de l'installation..."
    
    $services = @("app", "mongodb", "redis", "nginx")
    $allHealthy = $true
    
    foreach ($service in $services) {
        try {
            $status = & docker-compose ps $service
            if ($status -match "Up") {
                Write-Success "✅ $service est en cours d'exécution"
            }
            else {
                Write-Error "❌ $service n'est pas en cours d'exécution"
                $allHealthy = $false
            }
        }
        catch {
            Write-Error "❌ Impossible de vérifier le statut de $service"
            $allHealthy = $false
        }
    }
    
    # Test API endpoint
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:5000/api/health" -TimeoutSec 5
        if ($response.StatusCode -eq 200) {
            Write-Success "✅ L'API répond"
        }
        else {
            Write-Error "❌ L'API ne répond pas correctement"
            $allHealthy = $false
        }
    }
    catch {
        Write-Error "❌ L'API ne répond pas"
        $allHealthy = $false
    }
    
    # Test web interface
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:$Port" -TimeoutSec 5
        if ($response.StatusCode -eq 200) {
            Write-Success "✅ L'interface web est accessible"
        }
        else {
            Write-Error "❌ L'interface web n'est pas accessible"
            $allHealthy = $false
        }
    }
    catch {
        Write-Error "❌ L'interface web n'est pas accessible"
        $allHealthy = $false
    }
    
    if ($allHealthy) {
        Write-Success "🎉 Vérification de l'installation réussie !"
    }
    else {
        Write-Error "⚠️ Certains services peuvent ne pas fonctionner correctement"
        Write-Info "Vérifiez les logs avec : docker-compose logs"
    }
}

# Show completion message
function Show-Completion {
    Write-Host ""
    Write-ColorOutput "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-ColorOutput "║                    🎉 INSTALLATION TERMINÉE ! 🎉            ║" -ForegroundColor Green  
    Write-ColorOutput "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    Write-ColorOutput "🌐 Votre EDC NetSupervisor est maintenant accessible à :" -ForegroundColor Cyan
    Write-ColorOutput "   👉 http://${Domain}:${Port}" -ForegroundColor White
    Write-Host ""
    Write-ColorOutput "📊 Tableaux de bord de monitoring :" -ForegroundColor Cyan
    Write-ColorOutput "   📈 Grafana : http://${Domain}:3001 (admin/admin)" -ForegroundColor White
    Write-ColorOutput "   🔍 Prometheus : http://${Domain}:9090" -ForegroundColor White
    Write-Host ""
    Write-ColorOutput "🔧 Commandes de gestion :" -ForegroundColor Cyan
    Write-ColorOutput "   🐳 Voir les logs : " -ForegroundColor White -NoNewline
    Write-ColorOutput "docker-compose logs -f" -ForegroundColor Yellow
    Write-ColorOutput "   ⏹️  Arrêter services : " -ForegroundColor White -NoNewline
    Write-ColorOutput "docker-compose down" -ForegroundColor Yellow
    Write-ColorOutput "   🔄 Redémarrer : " -ForegroundColor White -NoNewline
    Write-ColorOutput "docker-compose restart" -ForegroundColor Yellow
    Write-Host ""
    Write-ColorOutput "📚 Prochaines étapes :" -ForegroundColor Cyan
    Write-ColorOutput "   1️⃣  Connectez-vous avec vos identifiants admin" -ForegroundColor White
    Write-ColorOutput "   2️⃣  Configurez vos sous-réseaux" -ForegroundColor White
    Write-ColorOutput "   3️⃣  Lancez votre première découverte réseau" -ForegroundColor White
    Write-ColorOutput "   4️⃣  Explorez la visualisation de topologie" -ForegroundColor White
    Write-Host ""
    Write-ColorOutput "⚠️  Notes de sécurité importantes :" -ForegroundColor Yellow
    Write-ColorOutput "   🔐 Changez le mot de passe admin après la première connexion" -ForegroundColor White
    Write-ColorOutput "   🔒 Remplacez les certificats SSL auto-signés en production" -ForegroundColor White
    Write-ColorOutput "   🛡️  Révisez les paramètres de sécurité dans le panneau admin" -ForegroundColor White
    Write-Host ""
    Write-ColorOutput "📄 Les identifiants sont sauvegardés dans : IDENTIFIANTS.txt" -ForegroundColor Green
    Write-Host ""
    Write-ColorOutput "Merci d'utiliser EDC NetSupervisor ! 🚀" -ForegroundColor Magenta
    Write-Host ""
}

# Main installation function
function Install-EDCNetSupervisor {
    try {
        Show-Banner
        
        # Interactive installation
        Write-ColorOutput "🔥 Bienvenue dans l'installation rapide d'EDC NetSupervisor !" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Ce script va installer et configurer EDC NetSupervisor sur votre système."
        Write-Host "Le processus complet devrait prendre 5-10 minutes selon votre connexion internet."
        Write-Host ""
        $proceed = Read-Host "Prêt à continuer ? [Y/n]"
        
        if ($proceed -match '^[Nn]$') {
            Write-Info "Installation annulée par l'utilisateur"
            exit 0
        }
        
        Write-Host ""
        
        # Run installation steps
        Test-Prerequisites
        Get-UserPreferences
        Get-SourceCode
        New-Directories
        New-Configuration
        New-SSLCertificates
        Start-Services
        Initialize-Setup
        Test-Installation
        Show-Completion
    }
    catch {
        Write-Error "Installation échouée : $($_.Exception.Message)"
        Write-Info "Consultez les logs pour plus de détails"
        exit 1
    }
}

# Command handlers
function Start-Application {
    if (!(Test-Path $InstallDir)) {
        Write-Error "Installation EDC NetSupervisor non trouvée"
        exit 1
    }
    Set-Location $InstallDir
    Write-Log "Démarrage d'EDC NetSupervisor..."
    & docker-compose up -d
    Write-Success "Services démarrés"
}

function Stop-Application {
    if (!(Test-Path $InstallDir)) {
        Write-Error "Installation EDC NetSupervisor non trouvée"
        exit 1
    }
    Set-Location $InstallDir
    Write-Log "Arrêt d'EDC NetSupervisor..."
    & docker-compose down
    Write-Success "Services arrêtés"
}

function Get-ApplicationStatus {
    if (!(Test-Path $InstallDir)) {
        Write-Error "Installation EDC NetSupervisor non trouvée"
        exit 1
    }
    Set-Location $InstallDir
    & docker-compose ps
}

function Update-Application {
    if (!(Test-Path $InstallDir)) {
        Write-Error "Installation EDC NetSupervisor non trouvée"
        exit 1
    }
    Set-Location $InstallDir
    Write-Log "Mise à jour d'EDC NetSupervisor..."
    & git pull origin main
    & docker-compose build
    & docker-compose up -d
    Write-Success "Mise à jour terminée"
}

function Uninstall-Application {
    if (!(Test-Path $InstallDir)) {
        Write-Error "Installation EDC NetSupervisor non trouvée"
        exit 1
    }
    $confirm = Read-Host "Êtes-vous sûr de vouloir désinstaller EDC NetSupervisor ? [y/N]"
    if ($confirm -match '^[Yy]$') {
        Set-Location $InstallDir
        & docker-compose down -v
        Set-Location ..
        Remove-Item $InstallDir -Recurse -Force
        Write-Success "EDC NetSupervisor désinstallé"
    }
}

function Show-Help {
    Write-Host "EDC NetSupervisor - Script d'installation rapide PowerShell"
    Write-Host ""
    Write-Host "Usage: .\quick-start.ps1 [commande]"
    Write-Host ""
    Write-Host "Commandes:"
    Write-Host "  install    - Installer EDC NetSupervisor (par défaut)"
    Write-Host "  start      - Démarrer les services"
    Write-Host "  stop       - Arrêter les services"
    Write-Host "  status     - Afficher le statut des services"
    Write-Host "  update     - Mettre à jour vers la dernière version"
    Write-Host "  uninstall  - Supprimer EDC NetSupervisor"
    Write-Host "  help       - Afficher cette aide"
    Write-Host ""
    Write-Host "Exemples:"
    Write-Host "  .\quick-start.ps1"
    Write-Host "  .\quick-start.ps1 install"
    Write-Host "  .\quick-start.ps1 start"
}

# Main script execution
switch ($Command.ToLower()) {
    "" { Install-EDCNetSupervisor }
    "install" { Install-EDCNetSupervisor }
    "start" { Start-Application }
    "stop" { Stop-Application }
    "status" { Get-ApplicationStatus }
    "update" { Update-Application }
    "uninstall" { Uninstall-Application }
    "help" { Show-Help }
    default {
        Write-Error "Commande inconnue : $Command"
        Write-Host "Utilisez '.\quick-start.ps1 help' pour l'aide"
        exit 1
    }
}