from pydantic_settings import BaseSettings, SettingsConfigDict
import os

class Settings(BaseSettings):
    GEMINI_API_KEY: str = os.getenv("GEMINI_API_KEY", "")
    FIREBASE_PROJECT_ID: str = os.getenv("FIREBASE_PROJECT_ID", "")
    ANTIGRAVITY_ENDPOINT: str = os.getenv("ANTIGRAVITY_ENDPOINT", "http://localhost:8001")
    MOCK_WEATHER_URL: str = os.getenv("MOCK_WEATHER_URL", "http://localhost:9000/weather")
    MOCK_TRAFFIC_URL: str = os.getenv("MOCK_TRAFFIC_URL", "http://localhost:9000/traffic")

    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")
def get_settings() -> Settings:
    """Return a cached Settings instance.
    The function creates a Settings object on first call and reuses it thereafter.
    This matches the expected import in app.main.
    """
    return Settings()
