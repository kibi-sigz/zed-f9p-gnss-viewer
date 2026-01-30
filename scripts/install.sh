
#!/bin/bash
# GNSS Professional Viewer Installation Script
# Production-ready installation for Raspberry Pi

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Print banner
print_banner() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║               GNSS Professional Viewer                   ║"
    echo "║                 Installation Script                      ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking system prerequisites..."
    
    # Check Python version
    if ! command -v python3 &> /dev/null; then
        log_error "Python3 not found. Installing..."
        sudo apt update && sudo apt install -y python3 python3-pip python3-venv
    fi
    
    PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
    log_info "Python version: $PYTHON_VERSION"
    
    # Check if running on Raspberry Pi
    if [ -f /proc/device-tree/model ]; then
        MODEL=$(tr -d '\0' < /proc/device-tree/model)
        log_info "Device: $MODEL"
    else
        log_warning "Not running on Raspberry Pi - some features may be limited"
    fi
    
    # Check disk space
    DISK_SPACE=$(df -h . | awk 'NR==2 {print $4}')
    log_info "Available disk space: $DISK_SPACE"
    
    # Check RAM
    RAM=$(free -h | awk 'NR==2 {print $2}')
    log_info "Total RAM: $RAM"
}

# Install system dependencies
install_system_deps() {
    log_info "Installing system dependencies..."
    
    sudo apt update
    sudo apt upgrade -y
    
    # Required system packages
    sudo apt install -y \
        git \
        build-essential \
        python3-dev \
        python3-venv \
        python3-pip \
        libffi-dev \
        libssl-dev \
        usbutils \
        network-manager
    
    log_success "System dependencies installed"
}

# Setup Python environment
setup_python_env() {
    log_info "Setting up Python virtual environment..."
    
    # Create virtual environment
    if [ ! -d "venv" ]; then
        python3 -m venv venv
        log_success "Virtual environment created"
    else
        log_warning "Virtual environment already exists - skipping"
    fi
    
    # Activate virtual environment
    source venv/bin/activate
    
    # Upgrade pip
    pip install --upgrade pip setuptools wheel
    
    # Install Python dependencies
    log_info "Installing Python dependencies..."
    pip install -r requirements.txt
    
    log_success "Python environment setup complete"
}

# Setup GNSS receiver permissions
setup_gnss_permissions() {
    log_info "Setting up GNSS receiver permissions..."
    
    # Add user to dialout group for serial access
    sudo usermod -a -G dialout $USER
    sudo usermod -a -G tty $USER
    
    # Create udev rule for persistent device naming
    sudo tee /etc/udev/rules.d/99-zed-f9p.rules > /dev/null << 'UDEVRULE'
# u-blox ZED-F9P GNSS Receiver
SUBSYSTEM=="tty", ATTRS{idVendor}=="1546", ATTRS{idProduct}=="01a8", SYMLINK+="zed_f9p", MODE="0666"
SUBSYSTEM=="tty", ATTRS{idVendor}=="1546", ATTRS{idProduct}=="01a7", SYMLINK+="zed_f9p", MODE="0666"
UDEVRULE
    
    sudo udevadm control --reload-rules
    sudo udevadm trigger
    
    log_success "GNSS receiver permissions configured"
}

# Setup data directories
setup_data_dirs() {
    log_info "Setting up data directories..."
    
    mkdir -p data/{logs,exports,cache}
    mkdir -p static/{css,js,images,fonts}
    
    # Set permissions
    chmod 755 data data/logs data/exports data/cache
    chmod 644 data/logs/.gitkeep data/exports/.gitkeep data/cache/.gitkeep
    
    log_success "Data directories created"
}

# Create environment file
create_env_file() {
    log_info "Creating environment configuration..."
    
    if [ ! -f ".env" ]; then
        cp .env.example .env
        log_warning "Edit .env file with your configuration:"
        echo "  nano .env"
    else
        log_info ".env file already exists"
    fi
}

# Setup systemd service
setup_systemd_service() {
    log_info "Setting up systemd service..."
    
    # Get absolute path
    PROJECT_DIR=$(pwd)
    USER_NAME=$(whoami)
    
    # Create systemd service file
    sudo tee /etc/systemd/system/gnss-viewer.service > /dev/null << SERVICE
[Unit]
Description=GNSS Professional Viewer
After=network.target
Wants=network.target
StartLimitIntervalSec=0

[Service]
Type=simple
User=$USER_NAME
WorkingDirectory=$PROJECT_DIR
Environment="PATH=$PROJECT_DIR/venv/bin"
Environment="PYTHONPATH=$PROJECT_DIR"
ExecStart=$PROJECT_DIR/venv/bin/python $PROJECT_DIR/src/core/application.py
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

# Security
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ReadWritePaths=$PROJECT_DIR/data

[Install]
WantedBy=multi-user.target
SERVICE
    
    sudo systemctl daemon-reload
    log_success "Systemd service created"
}

# Setup logging
setup_logging() {
    log_info "Setting up logging..."
    
    # Create logrotate configuration
    sudo tee /etc/logrotate.d/gnss-viewer > /dev/null << LOGROTATE
$PROJECT_DIR/data/logs/*.log {
    daily
    missingok
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 $USER dialout
    sharedscripts
    postrotate
        systemctl kill -s USR1 gnss-viewer.service
    endscript
}
LOGROTATE
    
    log_success "Logging configuration complete"
}

# Display installation summary
display_summary() {
    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║           INSTALLATION COMPLETE!                        ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Get IP address
    IP_ADDRESS=$(hostname -I | awk '{print $1}')
    
    echo -e "${YELLOW}📦 Installation Summary:${NC}"
    echo "  ✓ Python virtual environment created"
    echo "  ✓ Dependencies installed"
    echo "  ✓ GNSS receiver permissions configured"
    echo "  ✓ Data directories created"
    echo "  ✓ Systemd service installed"
    echo "  ✓ Logging configured"
    echo ""
    
    echo -e "${YELLOW}🚀 Next Steps:${NC}"
    echo "  1. Edit configuration:"
    echo "     nano .env"
    echo ""
    echo "  2. Connect your ZED-F9P receiver via USB"
    echo ""
    echo "  3. Start the application:"
    echo "     ./scripts/start.sh"
    echo "     OR for production:"
    echo "     sudo systemctl start gnss-viewer"
    echo ""
    echo "  4. Enable auto-start:"
    echo "     sudo systemctl enable gnss-viewer"
    echo ""
    echo -e "${YELLOW}🌐 Access URLs:${NC}"
    echo -e "  Local:    ${GREEN}http://localhost:5000${NC}"
    if [ -n "$IP_ADDRESS" ]; then
        echo -e "  Network:  ${GREEN}http://${IP_ADDRESS}:5000${NC}"
    fi
    echo ""
    echo -e "${YELLOW}🔧 Useful Commands:${NC}"
    echo "  Check status:   sudo systemctl status gnss-viewer"
    echo "  View logs:      journalctl -u gnss-viewer -f"
    echo "  Stop service:   sudo systemctl stop gnss-viewer"
    echo "  Restart:        sudo systemctl restart gnss-viewer"
    echo ""
    echo -e "${YELLOW}⚠️  Important:${NC}"
    echo "  Logout and login again for group permission changes to take effect"
    echo ""
    echo -e "${BLUE}For support, check documentation in docs/ directory${NC}"
}

# Main installation process
main() {
    print_banner
    
    # Check if running as root
    if [ "$EUID" -eq 0 ]; then
        log_error "Please do not run as root. Run as normal user."
        exit 1
    fi
    
    # Run installation steps
    check_prerequisites
    install_system_deps
    setup_python_env
    setup_gnss_permissions
    setup_data_dirs
    create_env_file
    setup_systemd_service
    setup_logging
    
    display_summary
}

# Run main function
main "$@"
EOF

# Make it executable
chmod +x scripts/install.sh

# Create start script
cat > scripts/start.sh << 'EOF'
#!/bin/bash
# GNSS Professional Viewer - Start Script

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_header() {
    clear
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║               GNSS Professional Viewer                   ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

check_environment() {
    echo -e "${YELLOW}Checking environment...${NC}"
    
    # Check if virtual environment exists
    if [ ! -d "venv" ]; then
        echo -e "${RED}Virtual environment not found. Run ./scripts/install.sh first${NC}"
        exit 1
    fi
    
    # Activate virtual environment
    source venv/bin/activate
    
    # Check Python dependencies
    if ! python -c "import flask" &> /dev/null; then
        echo -e "${YELLOW}Installing missing dependencies...${NC}"
        pip install -r requirements.txt
    fi
    
    # Check .env file
    if [ ! -f ".env" ]; then
        echo -e "${YELLOW}Warning: .env file not found. Using default settings${NC}"
        echo "Copy .env.example to .env and edit for custom configuration"
    fi
}

check_gnss_receiver() {
    echo -e "${YELLOW}Checking GNSS receiver...${NC}"
    
    # Check for connected GNSS receivers
    RECEIVER_PORTS=()
    
    if [ -e "/dev/ttyACM0" ]; then
        RECEIVER_PORTS+=("/dev/ttyACM0")
    fi
    
    if [ -e "/dev/ttyUSB0" ]; then
        RECEIVER_PORTS+=("/dev/ttyUSB0")
    fi
    
    if [ -e "/dev/zed_f9p" ]; then
        RECEIVER_PORTS+=("/dev/zed_f9p")
    fi
    
    if [ ${#RECEIVER_PORTS[@]} -eq 0 ]; then
        echo -e "${YELLOW}⚠ No GNSS receiver detected${NC}"
        echo "   Connect your ZED-F9P via USB for real data"
        echo "   Running in DEMO mode with simulated data"
    else
        echo -e "${GREEN}✓ GNSS receiver detected on:${NC}"
        for port in "${RECEIVER_PORTS[@]}"; do
            echo "   $port"
        done
    fi
}

display_network_info() {
    echo -e "${YELLOW}Network information...${NC}"
    
    # Get IP addresses
    IPV4=$(hostname -I | awk '{print $1}')
    IPV6=$(hostname -I | awk '{print $2}')
    
    if [ -n "$IPV4" ]; then
        echo -e "  IPv4: ${GREEN}$IPV4${NC}"
    fi
    
    if [ -n "$IPV6" ]; then
        echo -e "  IPv6: ${GREEN}$IPV6${NC}"
    fi
}

display_access_info() {
    echo ""
    echo -e "${BLUE}══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}               ACCESS INFORMATION${NC}"
    echo -e "${BLUE}══════════════════════════════════════════════════════════${NC}"
    echo ""
    
    IPV4=$(hostname -I | awk '{print $1}')
    
    echo -e "${YELLOW}🌐 Web Interface:${NC}"
    echo -e "  Local:    ${GREEN}http://localhost:5000${NC}"
    
    if [ -n "$IPV4" ]; then
        echo -e "  Network:  ${GREEN}http://${IPV4}:5000${NC}"
    fi
    
    echo ""
    echo -e "${YELLOW}📡 API Endpoints:${NC}"
    echo -e "  Status:   ${GREEN}http://localhost:5000/api/v1/status${NC}"
    echo -e "  Position: ${GREEN}http://localhost:5000/api/v1/position${NC}"
    echo -e "  Docs:     ${GREEN}http://localhost:5000/docs${NC}"
    
    echo ""
    echo -e "${YELLOW}⚙️  Mode:${NC}"
    if [ -e "/dev/ttyACM0" ] || [ -e "/dev/ttyUSB0" ]; then
        echo -e "  ${GREEN}Production Mode${NC} - Real GNSS data"
    else
        echo -e "  ${YELLOW}Demo Mode${NC} - Simulated data"
    fi
    
    echo ""
    echo -e "${YELLOW}📋 Commands:${NC}"
    echo "  Ctrl+C     - Stop application"
    echo "  R          - Restart"
    echo "  S          - Status check"
    echo "  L          - View logs"
    
    echo -e "${BLUE}══════════════════════════════════════════════════════════${NC}"
    echo ""
}

start_application() {
    echo -e "${YELLOW}Starting GNSS Professional Viewer...${NC}"
    echo ""
    
    # Export environment variables from .env if exists
    if [ -f ".env" ]; then
        set -a
        source .env
        set +a
    fi
    
    # Start the application
    exec python src/core/application.py
}

# Main execution
main() {
    print_header
    check_environment
    check_gnss_receiver
    display_network_info
    display_access_info
    start_application
}

# Handle signals
trap 'echo -e "\n${YELLOW}Shutting down...${NC}"; exit 0' INT TERM

# Run main function
main "$@"
EOF

chmod +x scripts/start.sh

# Create stop script
cat > scripts/stop.sh << 'EOF'
#!/bin/bash
# Stop GNSS Professional Viewer

echo "Stopping GNSS Professional Viewer..."

# Try systemd service first
if systemctl is-active --quiet gnss-viewer; then
    sudo systemctl stop gnss-viewer
    echo "Stopped systemd service"
fi

# Kill any running Python processes
pkill -f "python.*application.py" && echo "Stopped application process"

# Kill any related processes
pkill -f "socketio" && echo "Stopped WebSocket processes"

echo "GNSS Professional Viewer stopped"
EOF

chmod +x scripts/stop.sh
