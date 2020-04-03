import distutils.util
import os

DB_URL = os.getenv("OS_REFAPP_DB_URL", "sqlite:///os_refapp.sqlite")
DEBUG = bool(
    distutils.util.strtobool(os.getenv("OS_REFAPP_DEBUG", "false").lower())
)
