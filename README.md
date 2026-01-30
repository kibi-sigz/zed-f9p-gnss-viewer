
# 🛰️ GNSS Professional Viewer

<div align="center">

![Python](https://img.shields.io/badge/Python-3.8+-blue.svg)
![Flask](https://img.shields.io/badge/Flask-2.3.3-green.svg)
![Raspberry Pi](https://img.shields.io/badge/Raspberry_Pi-Compatible-red.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)
![Version](https://img.shields.io/badge/Version-1.0.0-blue.svg)

**Professional GNSS data visualization platform for ZED-F9P receivers**

[Features](#-features) • [Installation](#-installation) • [Documentation](#-documentation) • [Contributing](#-contributing)

</div>

## 📋 Table of Contents
- [Overview](#-overview)
- [Features](#-features)
- [Screenshots](#-screenshots)
- [Installation](#-installation)
- [Quick Start](#-quick-start)
- [API Documentation](#-api-documentation)
- [Architecture](#-architecture)
- [Contributing](#-contributing)
- [License](#-license)
- [Support](#-support)

## 🎯 Overview

**GNSS Professional Viewer** is a production-ready web application for real-time visualization of GNSS data from u-blox ZED-F9P receivers. Designed specifically for Raspberry Pi, it provides a professional interface for surveying, mapping, and precision agriculture applications.

### Key Capabilities
- Real-time multi-constellation tracking (GPS, GLONASS, Galileo, BeiDou)
- High-precision RTK positioning visualization
- Web-based interface accessible from any device
- Comprehensive data logging and export
- Professional dashboard with analytics

## ✨ Features

### 🌍 **Mapping & Visualization**
- Real-time position tracking with Leaflet.js
- Multiple map layers (Street, Satellite, Topographic)
- Track recording and playback
- Geofencing and area measurement
- Export to KML, GPX, CSV formats

### 🛰️ **GNSS Processing**
- Support for u-blox ZED-F9P multi-band receiver
- UBX and NMEA protocol parsing
- RTK status monitoring (Float/Fixed)
- Satellite constellation visualization
- DOP (Dilution of Precision) monitoring

### 📊 **Dashboard & Analytics**
- Professional data visualization with Chart.js
- Real-time WebSocket updates
- Historical data analysis
- Performance metrics
- Customizable widgets

### 🔧 **System Features**
- Raspberry Pi optimized
- Hotspot mode for offline operation
- Auto-start on boot
- Systemd service management
- Comprehensive logging

### 🔒 **Security & Reliability**
- Rate limiting on API endpoints
- CORS configuration
- Session management
- Error handling and recovery
- Data validation

## 📸 Screenshots

*Coming soon: Application screenshots*

## 🚀 Installation

### Prerequisites
- Raspberry Pi (3B+/4/Zero 2W recommended)
- u-blox ZED-F9P GNSS receiver
- Python 3.8 or higher
- 2GB+ RAM, 8GB+ storage

### Step-by-Step Installation

```bash
# 1. Clone the repository
git clone https://github.com/yourusername/gnss-professional.git
cd gnss-professional

# 2. Run the installation script
chmod +x scripts/install.sh
./scripts/install.sh

# 3. Configure environment variables
cp .env.example .env
nano .env  # Edit with your settings

# 4. Start the application
./scripts/start.sh# zed-f9p-gnss-viewer
Professional GNSS viewer for ZED-F9P receiver on Raspberry Pi
