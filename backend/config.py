import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    # Hugging Face Configuration
    # User Model Repository: hvjhvyuvyuj/multivoice-assist
    HF_API_TOKEN = os.getenv("HF_API_TOKEN", "")
    HF_MODEL_ID = os.getenv("HF_MODEL_ID", "hvjhvyuvyuj/multivoice-assist")
    HF_INFERENCE_ENDPOINT = os.getenv(
        "HF_INFERENCE_ENDPOINT",
        f"https://api-inference.huggingface.co/models/{os.getenv('HF_MODEL_ID', 'hvjhvyuvyuj/multivoice-assist')}"
    )

    # Server Configuration
    PORT = int(os.getenv("PORT", 5000))
    HOST = os.getenv("HOST", "0.0.0.0")
    DEBUG = os.getenv("DEBUG", "False").lower() == "true"

    # Request & Rate Limit Configuration
    REQUEST_TIMEOUT_SECONDS = int(os.getenv("REQUEST_TIMEOUT_SECONDS", 30))
    MAX_INPUT_LENGTH = int(os.getenv("MAX_INPUT_LENGTH", 2048))
