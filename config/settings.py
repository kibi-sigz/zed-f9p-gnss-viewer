



"""
Configuration settings for GNSS Professional Viewer
Production-ready with environment variable support
"""

import os
from pathlib import Path
from dataclasses import dataclass
from typing import Dict, List, Optional
import logging

@dataclass
class GNSSConfig:
    """GNSS Receiver Configuration"""
    port: str = os.getenv('GNSS_PORT', '/dev/ttyACM0')
    baudrate: int = int(os.getenv('GNSS_BAUDRATE', '9600'))
    timeout: float = float(os.getenv('GNSS_TIMEOUT', '1.0'))
    protocol: str = os.getenv('GNSS_PROTOCOL', 'UBX')  # UBX or NMEA
    enable_rtcm: bool = os.getenv('GNSS_ENABLE_RTCM', 'True').lower() == 'true'
    enable_nmea: bool = os.getenv('GNSS_ENABLE_NMEA', 'True').lower() == 'true'
    
    # UBX-specific settings
    ubx_rate: int = int(os.getenv('GNSS_UBX_RATE', '1'))  # Measurement rate in Hz
    nav_rate: int = int(os.getenv('GNSS_NAV_RATE', '1'))  # Navigation rate

@dataclass
class WebConfig:
    """Web Server Configuration"""
    host: str = os.getenv('WEB_HOST', '0.0.0.0')
    port: int = int(os.getenv('WEB_PORT', '5000'))
    debug: bool = os.getenv('WEB_DEBUG', 'False').lower() == 'true'
    secret_key: str = os.getenv('WEB_SECRET_KEY', 'dev-secret-key-change-in-production')
    cors_origins: List[str] = os.getenv('WEB_CORS_ORIGINS', '*').split(',')
    
    # Security
    session_timeout: int = int(os.getenv('WEB_SESSION_TIMEOUT', '3600'))  # seconds
    rate_limit: str = os.getenv('WEB_RATE_LIMIT', '100 per minute')

@dataclass
class MapConfig:
    """Map Configuration"""
    default_center: List[float] = [0.0, 0.0]
    default_zoom: int = 2
    max_zoom: int = 18
    tile_provider: str = os.getenv('MAP_TILE_PROVIDER', 
        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png')
    tile_attribution: str = os.getenv('MAP_TILE_ATTRIBUTION',
        '© <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors')
    
    # Optional satellite imagery
    satellite_layer: bool = os.getenv('MAP_SATELLITE_LAYER', 'True').lower() == 'true'
    satellite_url: str = os.getenv('MAP_SATELLITE_URL',
        'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}')

@dataclass
class LoggingConfig:
    """Logging Configuration"""
    level: str = os.getenv('LOG_LEVEL', 'INFO').upper()
    format: str = '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    date_format: str = '%Y-%m-%d %H:%M:%S'
    
    # File logging
    file_enabled: bool = os.getenv('LOG_FILE_ENABLED', 'True').lower() == 'true'
    file_path: str = os.getenv('LOG_FILE_PATH', 'data/logs/gnss_viewer.log')
    max_file_size: int = int(os.getenv('LOG_MAX_FILE_SIZE', '10485760'))  # 10MB
    backup_count: int = int(os.getenv('LOG_BACKUP_COUNT', '5'))

@dataclass
class DataConfig:
    """Data Configuration"""
    # Logging
    enable_logging: bool = os.getenv('DATA_ENABLE_LOGGING', 'True').lower() == 'true'
    log_directory: str = os.getenv('DATA_LOG_DIRECTORY', 'data/logs')
    export_directory: str = os.getenv('DATA_EXPORT_DIRECTORY', 'data/exports')
    
    # Retention
    max_history_points: int = int(os.getenv('DATA_MAX_HISTORY', '10000'))
    export_formats: List[str] = os.getenv('DATA_EXPORT_FORMATS', 'csv,json,kml').split(',')
    
    # Performance
    cache_enabled: bool = os.getenv('DATA_CACHE_ENABLED', 'True').lower() == 'true'
    cache_ttl: int = int(os.getenv('DATA_CACHE_TTL', '300'))  # seconds

@dataclass
class SatelliteConfig:
    """Satellite Systems Configuration"""
    systems: Dict[str, Dict] = None
    
    def __post_init__(self):
        if self.systems is None:
            self.systems = {
                'GPS': {
                    'enabled': True,
                    'color': '#00ff88',
                    'priority': 1,
                    'description': 'Global Positioning System (USA)'
                },
                'GLONASS': {
                    'enabled': True,
                    'color': '#ff4444',
                    'priority': 2,
                    'description': 'Global Navigation Satellite System (Russia)'
                },
                'Galileo': {
                    'enabled': True,
                    'color': '#4488ff',
                    'priority': 3,
                    'description': 'European Global Navigation Satellite System'
                },
                'BeiDou': {
                    'enabled': True,
                    'color': '#ffaa00',
                    'priority': 4,
                    'description': 'BeiDou Navigation Satellite System (China)'
                },
                'QZSS': {
                    'enabled': False,
                    'color': '#aa00ff',
                    'priority': 5,
                    'description': 'Quasi-Zenith Satellite System (Japan)'
                },
                'SBAS': {
                    'enabled': False,
                    'color': '#ff00aa',
                    'priority': 6,
                    'description': 'Satellite-Based Augmentation Systems'
                }
            }

# Create configuration instances
gnss_config = GNSSConfig()
web_config = WebConfig()
map_config = MapConfig()
logging_config = LoggingConfig()
data_config = DataConfig()
satellite_config = SatelliteConfig()

# Base directory
BASE_DIR = Path(__file__).resolve().parent.parent

# Logging setup function
def setup_logging():
    """Configure logging based on settings"""
    logger = logging.getLogger()
    logger.setLevel(getattr(logging, logging_config.level))
    
    # Console handler
    console_handler = logging.StreamHandler()
    console_formatter = logging.Formatter(
        logging_config.format,
        datefmt=logging_config.date_format
    )
    console_handler.setFormatter(console_formatter)
    logger.addHandler(console_handler)
    
    # File handler
    if logging_config.file_enabled:
        os.makedirs(os.path.dirname(logging_config.file_path), exist_ok=True)
        file_handler = logging.handlers.RotatingFileHandler(
            logging_config.file_path,
            maxBytes=logging_config.max_file_size,
            backupCount=logging_config.backup_count
        )
        file_formatter = logging.Formatter(
            logging_config.format,
            datefmt=logging_config.date_format
        )
        file_handler.setFormatter(file_formatter)
        logger.addHandler(file_handler)
    
    return logger

# Export configuration
__all__ = [
    'gnss_config',
    'web_config',
    'map_config',
    'logging_config',
    'data_config',
    'satellite_config',
    'BASE_DIR',
    'setup_logging'
]

