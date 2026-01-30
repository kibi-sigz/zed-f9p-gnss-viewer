
"""
Application constants
"""

# Version
VERSION = '1.0.0'
API_VERSION = 'v1'

# GNSS Constants
GNSS_FIX_QUALITY = {
    0: 'No Fix',
    1: 'GPS Fix',
    2: 'DGPS Fix',
    3: 'PPS Fix',
    4: 'RTK Fixed',
    5: 'RTK Float',
    6: 'DR',
    7: 'Manual',
    8: 'Simulation'
}

GNSS_SIGNAL_QUALITY = {
    0: 'No Signal',
    1: 'Searching',
    2: 'Acquired',
    3: 'Unusable',
    4: 'Code Lock',
    5: 'Code & Carrier Lock',
    6: 'Code & Carrier Lock (Time)'
}

# UBX Message Classes
UBX_CLASSES = {
    0x01: 'NAV',   # Navigation
    0x02: 'RXM',   # Receiver Manager
    0x04: 'INF',   # Information
    0x05: 'ACK',   # Acknowledge
    0x06: 'CFG',   # Configuration
    0x0A: 'MON',   # Monitoring
    0x0D: 'TIM',   # Timing
    0x10: 'ESF',   # External Sensor Fusion
    0x13: 'MGA',   # AssistNow
    0x21: 'LOG',   # Logging
    0x27: 'SEC',   # Security
    0x28: 'HNR'    # High Rate Navigation
}

# NMEA Sentence Types
NMEA_SENTENCES = {
    'GGA': 'Global Positioning System Fix Data',
    'GLL': 'Geographic Position - Latitude/Longitude',
    'GSA': 'GNSS DOP and Active Satellites',
    'GSV': 'GNSS Satellites in View',
    'RMC': 'Recommended Minimum Specific GNSS Data',
    'VTG': 'Course Over Ground and Ground Speed',
    'ZDA': 'Time & Date',
    'PUBX': 'u-blox Proprietary'
}

# Error Codes
ERROR_CODES = {
    'GNSS001': 'GNSS receiver not connected',
    'GNSS002': 'Invalid NMEA sentence',
    'GNSS003': 'Serial port error',
    'WEB001': 'Invalid API request',
    'WEB002': 'Resource not found',
    'WEB003': 'Rate limit exceeded',
    'SYS001': 'System configuration error',
    'SYS002': 'Database connection failed'
}

# Status Messages
STATUS_MESSAGES = {
    'CONNECTING': 'Connecting to GNSS receiver...',
    'CONNECTED': 'GNSS receiver connected',
    'DISCONNECTED': 'GNSS receiver disconnected',
    'NO_FIX': 'No satellite fix',
    '2D_FIX': '2D fix acquired',
    '3D_FIX': '3D fix acquired',
    'RTK_FLOAT': 'RTK float solution',
    'RTK_FIXED': 'RTK fixed solution'
}

# Colors for UI
COLORS = {
    'primary': '#0066cc',
    'secondary': '#00cc66',
    'accent': '#ff9900',
    'danger': '#ff4444',
    'warning': '#ffaa00',
    'info': '#00aaff',
    'success': '#00cc88',
    'dark': '#1a1a2e',
    'light': '#f8f9fa'
}

# API Response Templates
API_RESPONSE = {
    'success': {
        'status': 'success',
        'code': 200
    },
    'error': {
        'status': 'error',
        'code': 400
    }
}

