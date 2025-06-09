#!/bin/bash

# EDC NetSupervisor - Quick Start Script
# One-command installation and startup

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
REPO_URL="https://github.com/Achka78/edc_netsupervisor-pro.git"
INSTALL_DIR="edc_netsupervisor-pro"
DEFAULT_DOMAIN="localhost"
DEFAULT_PORT="80"

# Logging functions
log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%H:%M:%S')] ERROR: $1${NC}" >&2
}

info() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')] INFO: $1${NC}"
}

success() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')] SUCCESS: $1${NC}"
}

# Show banner
show_banner() {
    clear
    echo -e "${PURPLE}"
    cat << 'EOF'
    ███╗   ██╗███████╗████████╗██╗    ██╗ ██████╗ ██████╗ ██╗  ██╗
    ████╗  ██║██╔════╝╚══██╔══╝██║    ██║██╔═══██╗██╔══██╗██║ ██╔╝
    ██╔██╗ ██║█████╗     ██║   ██║ █╗ ██║██║   ██║██████╔╝█████╔╝ 
    ██║╚██╗██║██╔══╝     ██║   ██║███╗██║██║   ██║██╔══██╗██╔═██╗ 
    ██║ ╚████║███████╗   ██║   ╚███╔███╔╝╚██████╔╝██║  ██║██║  ██╗
    ╚═╝  ╚═══╝╚══════╝   ╚═╝    ╚══╝╚══╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝
                                                                    
    ███╗   ███╗ █████╗ ███╗   ██╗ █████╗  ██████╗ ███████╗██████╗ 
    ████╗ ████║██╔══██╗████╗  ██║██╔══██╗██╔════╝ ██╔════╝██╔══██╗
    ██╔████╔██║███████║██╔██╗ ██║███████║██║  ███╗█████╗  ██████╔╝
    ██║╚██╔╝██║██╔══██║██║╚██╗██║██╔══██║██║   ██║██╔══╝  ██╔══██╗
    ██║ ╚═╝ ██║██║  ██║██║ ╚████║██║  ██║╚██████╔╝███████╗██║  ██║
    ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝
                                                                    
                            ██████╗ ██████╗  ██████╗               
                            ██╔══██╗██╔══██╗██╔═══██╗              
                            ██████╔╝██████╔╝██║   ██║              
                            ██╔═══╝ ██╔══██╗██║   ██║              
                            ██║     ██║  ██║╚██████╔╝              
                            ╚═╝     ╚═╝  ╚═╝ ╚═════╝               
EOF
    echo -e "${NC}"
    echo -e "${CYAN}        Professional EDC NetSupervisor - Supervision Réseau${NC}"
    echo -e "${CYAN}                    Quick Start Installation Script${NC}"
    echo ""
    echo -e "${GREEN}🚀 Getting your network management platform ready in minutes!${NC}"
    echo ""
}

# Check prerequisites
check_prerequisites() {
    log "Checking system prerequisites..."
    
    local missing_deps=()
    
    # Check for required commands
    local required_commands=("git" "curl" "docker" "docker-compose")
    
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_deps+=("$cmd")
        fi
    done
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        error "Missing required dependencies: ${missing_deps[*]}"
        echo ""
        info "Please install the missing dependencies:"
        echo ""
        
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            echo "  Ubuntu/Debian:"
            echo "    sudo apt-get update"
            echo "    sudo apt-get install -y git curl"
            echo "    # Install Docker: https://docs.docker.com/engine/install/"
            echo ""
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            echo "  macOS:"
            echo "    brew install git curl"
            echo "    # Install Docker Desktop: https://www.docker.com/products/docker-desktop"
            echo ""
        fi
        
        exit 1
    fi
    
    # Check Docker daemon
    if ! docker info &> /dev/null; then
        error "Docker daemon is not running"
        info "Please start Docker and try again"
        exit 1
    fi
    
    success "All prerequisites are satisfied"
}

# Get user preferences
get_user_preferences() {
    echo -e "${CYAN}📋 Configuration Setup${NC}"
    echo ""
    
    # Installation directory
    echo -n "📁 Installation directory [${INSTALL_DIR}]: "
    read -r user_install_dir
    if [ -n "$user_install_dir" ]; then
        INSTALL_DIR="$user_install_dir"
    fi
    
    # Domain/hostname
    echo -n "🌐 Domain/hostname [${DEFAULT_DOMAIN}]: "
    read -r user_domain
    if [ -n "$user_domain" ]; then
        DOMAIN="$user_domain"
    else
        DOMAIN="$DEFAULT_DOMAIN"
    fi
    
    # Port
    echo -n "🔌 HTTP port [${DEFAULT_PORT}]: "
    read -r user_port
    if [ -n "$user_port" ]; then
        PORT="$user_port"
    else
        PORT="$DEFAULT_PORT"
    fi
    
    # Installation type
    echo ""
    echo "🔧 Installation type:"
    echo "  1) Full installation (Recommended)"
    echo "  2) Development mode"
    echo "  3) Production deployment"
    echo -n "Select option [1]: "
    read -r install_type
    
    case "$install_type" in
        2)
            INSTALL_TYPE="development"
            ;;
        3)
            INSTALL_TYPE="production"
            ;;
        *)
            INSTALL_TYPE="full"
            ;;
    esac
    
    echo ""
    success "Configuration completed"
    echo "  📁 Directory: $INSTALL_DIR"
    echo "  🌐 Domain: $DOMAIN"
    echo "  🔌 Port: $PORT"
    echo "  🔧 Type: $INSTALL_TYPE"
    echo ""
}

# Download source code
download_source() {
    log "Downloading EDC NetSupervisor source code..."
    
    if [ -d "$INSTALL_DIR" ]; then
        warn "Directory $INSTALL_DIR already exists"
        echo -n "Do you want to remove it and continue? [y/N]: "
        read -r confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            error "Installation cancelled"
            exit 1
        fi
        rm -rf "$INSTALL_DIR"
    fi
    
    git clone "$REPO_URL" "$INSTALL_DIR" || {
        error "Failed to clone repository"
        info "You can also download and extract the source code manually"
        exit 1
    }
    
    cd "$INSTALL_DIR"
    success "Source code downloaded successfully"
}

# Generate configuration
generate_config() {
    log "Generating configuration files..."
    
    # Generate secure secrets
    local jwt_secret=$(openssl rand -base64 64 | tr -d '\n')
    local encryption_key=$(openssl rand -hex 16)
    local encryption_iv=$(openssl rand -hex 8)
    local db_password=$(openssl rand -base64 32 | tr -d '=+/' | cut -c1-16)
    local admin_password=$(openssl rand -base64 16 | tr -d '=+/' | cut -c1-12)
    
    # Create .env file
    cat > .env << EOF
# EDC NetSupervisor Configuration
# Generated on $(date)

# Application
NODE_ENV=${INSTALL_TYPE}
PORT=5000
CLIENT_URL=http://${DOMAIN}:${PORT}

# Database
MONGODB_URI=mongodb://admin:${db_password}@mongodb:27017/edc_netsupervisor?authSource=admin
MONGO_USERNAME=admin
MONGO_PASSWORD=${db_password}

# Redis
REDIS_URL=redis://redis:6379
REDIS_PASSWORD=

# Security
JWT_SECRET=${jwt_secret}
REFRESH_TOKEN_SECRET=${jwt_secret}refresh
ENCRYPTION_KEY=${encryption_key}
ENCRYPTION_IV=${encryption_iv}

# Admin Account
ADMIN_EMAIL=admin@edc_netsupervisor.local
ADMIN_PASSWORD=${admin_password}

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
EOF

    # Update docker-compose ports if needed
    if [ "$PORT" != "80" ]; then
        sed -i.bak "s/80:80/${PORT}:80/g" docker-compose.yml 2>/dev/null || true
    fi
    
    success "Configuration files generated"
    info "Admin credentials:"
    echo "  📧 Email: admin@edc_netsupervisor.local"
    echo "  🔐 Password: $admin_password"
    echo ""
    warn "Please save these credentials - they won't be shown again!"
    echo ""
}

# Setup SSL certificates
setup_ssl() {
    log "Setting up SSL certificates..."
    
    mkdir -p ssl
    
    # Generate self-signed certificate
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout ssl/key.pem \
        -out ssl/cert.pem \
        -subj "/C=US/ST=State/L=City/O=EDC NetSupervisor/CN=${DOMAIN}" \
        2>/dev/null
    
    success "SSL certificates created (self-signed for development)"
}

# Install and start services
start_services() {
    log "Starting EDC NetSupervisor services..."
    
    # Pull images and build
    info "Pulling Docker images (this may take a few minutes)..."
    docker-compose pull --ignore-pull-failures
    
    info "Building application containers..."
    docker-compose build
    
    # Start services
    info "Starting all services..."
    docker-compose up -d
    
    # Wait for services to be ready
    log "Waiting for services to start..."
    local timeout=120
    local elapsed=0
    
    while [ $elapsed -lt $timeout ]; do
        if curl -sf "http://localhost:5000/api/health" &>/dev/null; then
            break
        fi
        sleep 5
        elapsed=$((elapsed + 5))
        echo -n "."
    done
    echo ""
    
    if [ $elapsed -ge $timeout ]; then
        error "Services failed to start within ${timeout} seconds"
        info "Check logs with: docker-compose logs"
        exit 1
    fi
    
    success "All services are running!"
}

# Run initial setup
initial_setup() {
    log "Running initial setup..."
    
    # Initialize database
    info "Initializing database..."
    docker-compose exec -T mongodb mongosh edc_netsupervisor < scripts/mongo-init.js || {
        warn "Database initialization may have failed - this is usually not critical"
    }
    
    # Wait a bit for everything to settle
    sleep 10
    
    success "Initial setup completed"
}

# Verify installation
verify_installation() {
    log "Verifying installation..."
    
    local services=("app" "mongodb" "redis" "nginx")
    local all_healthy=true
    
    for service in "${services[@]}"; do
        if docker-compose ps "$service" | grep -q "Up"; then
            success "✅ $service is running"
        else
            error "❌ $service is not running"
            all_healthy=false
        fi
    done
    
    # Test API endpoint
    if curl -sf "http://localhost:5000/api/health" &>/dev/null; then
        success "✅ API is responding"
    else
        error "❌ API is not responding"
        all_healthy=false
    fi
    
    # Test web interface
    if curl -sf "http://localhost:${PORT}" &>/dev/null; then
        success "✅ Web interface is accessible"
    else
        error "❌ Web interface is not accessible"
        all_healthy=false
    fi
    
    if [ "$all_healthy" = true ]; then
        success "🎉 Installation verification passed!"
    else
        error "⚠️  Some services may not be working correctly"
        info "Check logs with: docker-compose logs"
    fi
}

# Show completion message
show_completion() {
    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                    🎉 INSTALLATION COMPLETE! 🎉              ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}🌐 Your EDC NetSupervisor is now running at:${NC}"
    echo -e "${WHITE}   👉 http://${DOMAIN}:${PORT}${NC}"
    echo ""
    echo -e "${CYAN}📊 Monitoring dashboards:${NC}"
    echo -e "${WHITE}   📈 Grafana: http://${DOMAIN}:3001 (admin/admin)${NC}"
    echo -e "${WHITE}   🔍 Prometheus: http://${DOMAIN}:9090${NC}"
    echo ""
    echo -e "${CYAN}🔧 Management commands:${NC}"
    echo -e "${WHITE}   🐳 View logs: ${YELLOW}docker-compose logs -f${NC}"
    echo -e "${WHITE}   ⏹️  Stop services: ${YELLOW}docker-compose down${NC}"
    echo -e "${WHITE}   🔄 Restart services: ${YELLOW}docker-compose restart${NC}"
    echo -e "${WHITE}   💾 Backup database: ${YELLOW}./scripts/backup.sh${NC}"
    echo ""
    echo -e "${CYAN}📚 Next steps:${NC}"
    echo -e "${WHITE}   1️⃣  Login with your admin credentials${NC}"
    echo -e "${WHITE}   2️⃣  Configure your network subnets${NC}"
    echo -e "${WHITE}   3️⃣  Start your first network discovery${NC}"
    echo -e "${WHITE}   4️⃣  Explore the topology visualization${NC}"
    echo ""
    echo -e "${YELLOW}⚠️  Important security notes:${NC}"
    echo -e "${WHITE}   🔐 Change the default admin password after first login${NC}"
    echo -e "${WHITE}   🔒 Replace self-signed SSL certificates in production${NC}"
    echo -e "${WHITE}   🛡️  Review security settings in the admin panel${NC}"
    echo ""
    echo -e "${GREEN}📖 Documentation: https://docs.edc_netsupervisor-pro.com${NC}"
    echo -e "${GREEN}🆘 Support: https://github.com/your-org/edc_netsupervisor-pro/issues${NC}"
    echo ""
    echo -e "${PURPLE}Thank you for using EDC NetSupervisor! 🚀${NC}"
    echo ""
}

# Handle script interruption
cleanup() {
    echo ""
    warn "Installation interrupted by user"
    if [ -d "$INSTALL_DIR" ]; then
        echo -n "Do you want to remove the installation directory? [y/N]: "
        read -r cleanup_confirm
        if [[ "$cleanup_confirm" =~ ^[Yy]$ ]]; then
            rm -rf "$INSTALL_DIR"
            info "Installation directory removed"
        fi
    fi
    exit 1
}

# Set up signal handlers
trap cleanup SIGINT SIGTERM

# Main installation flow
main() {
    show_banner
    
    # Interactive installation
    echo -e "${YELLOW}🔥 Welcome to EDC NetSupervisor Quick Start!${NC}"
    echo ""
    echo "This script will install and configure EDC NetSupervisor on your system."
    echo "The entire process should take 5-10 minutes depending on your internet connection."
    echo ""
    echo -n "Ready to proceed? [Y/n]: "
    read -r proceed
    
    if [[ "$proceed" =~ ^[Nn]$ ]]; then
        info "Installation cancelled by user"
        exit 0
    fi
    
    echo ""
    
    # Run installation steps
    check_prerequisites
    get_user_preferences
    download_source
    generate_config
    setup_ssl
    start_services
    initial_setup
    verify_installation
    show_completion
}

# Command line argument handling
case "${1:-install}" in
    "install"|"")
        main
        ;;
    "update")
        if [ ! -d "$INSTALL_DIR" ]; then
            error "EDC NetSupervisor installation not found"
            exit 1
        fi
        cd "$INSTALL_DIR"
        log "Updating EDC NetSupervisor..."
        git pull origin main
        docker-compose build
        docker-compose up -d
        success "Update completed"
        ;;
    "start")
        if [ ! -d "$INSTALL_DIR" ]; then
            error "EDC NetSupervisor installation not found"
            exit 1
        fi
        cd "$INSTALL_DIR"
        log "Starting EDC NetSupervisor..."
        docker-compose up -d
        success "Services started"
        ;;
    "stop")
        if [ ! -d "$INSTALL_DIR" ]; then
            error "EDC NetSupervisor installation not found"
            exit 1
        fi
        cd "$INSTALL_DIR"
        log "Stopping EDC NetSupervisor..."
        docker-compose down
        success "Services stopped"
        ;;
    "status")
        if [ ! -d "$INSTALL_DIR" ]; then
            error "EDC NetSupervisor installation not found"
            exit 1
        fi
        cd "$INSTALL_DIR"
        docker-compose ps
        ;;
    "uninstall")
        if [ ! -d "$INSTALL_DIR" ]; then
            error "EDC NetSupervisor installation not found"
            exit 1
        fi
        echo -n "Are you sure you want to uninstall EDC NetSupervisor? [y/N]: "
        read -r confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            cd "$INSTALL_DIR"
            docker-compose down -v
            cd ..
            rm -rf "$INSTALL_DIR"
            success "EDC NetSupervisor uninstalled"
        fi
        ;;
    "help")
        echo "EDC NetSupervisor Quick Start Script"
        echo ""
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  install    - Install EDC NetSupervisor (default)"
        echo "  update     - Update to latest version"
        echo "  start      - Start services"
        echo "  stop       - Stop services"
        echo "  status     - Show service status"
        echo "  uninstall  - Remove EDC NetSupervisor"
        echo "  help       - Show this help message"
        echo ""
        echo "Examples:"
        echo "  curl -fsSL https://get.edc_netsupervisor-pro.com | bash"
        echo "  $0 install"
        echo "  $0 update"
        ;;
    *)
        error "Unknown command: $1"
        echo "Use '$0 help' for usage information"
        exit 1
        ;;
esac