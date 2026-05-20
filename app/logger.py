import sys
from loguru import logger as _loguru_logger

# Configure logger to output JSON lines, suitable for CI/CD and observability
_loguru_logger.remove()
_loguru_logger.add(
    sys.stdout,
    format="{\"time\": \"{time}\", \"level\": \"{level}\", \"message\": \"{message}\"}",
    level="INFO",
    serialize=False,
)

logger = _loguru_logger
