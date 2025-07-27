import os

# Default configuration
config = {
    "DEMO_MODE": str(os.environ.get("DEMO_MODE", "false")).lower()
    in ["true", "1", "yes", "on", "1.0", "y"],
    "VCENTER_HOST": os.environ.get("VCENTER_HOST", "localhost"),
    "VCENTER_PORT": os.environ.get("VCENTER_PORT", "443"),
    "FLASK_PORT": os.environ.get("FLASK_PORT", "5051"),
    "SECRET_KEY": os.environ.get("SECRET_KEY", "your-secret-key-here"),
    "SESSION_LIFETIME": int(
        os.environ.get("SESSION_LIFETIME", "1800")
    ),  # 30 minutes in seconds
    "LOG_FILE": os.environ.get("LOG_FILE", "vm_provisioning.log"),
}
