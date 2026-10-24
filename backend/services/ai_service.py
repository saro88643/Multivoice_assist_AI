import requests
import logging
from config import Config

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("HFService")

class HuggingFaceAIService:
    def __init__(self):
        self.token = Config.HF_API_TOKEN

    def generate_response(self, user_message, language="en", context="", history=None, custom_model_id=None):
        model_id = custom_model_id or Config.HF_MODEL_ID

        # Check if HF token is missing
        if not Config.HF_API_TOKEN or Config.HF_API_TOKEN == "hf_your_private_token_here":
            logger.warning("HF_API_TOKEN is not set in backend/.env")
            return {
                "success": False,
                "response": "Please set your HF_API_TOKEN in backend/.env to use Hugging Face inference.",
                "error": "Missing HF_API_TOKEN",
                "model": model_id
            }

        headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {Config.HF_API_TOKEN}"
        }

        # Try Hugging Face OpenAI-compatible Chat Completions Router first
        router_url = "https://router.huggingface.co/hf-inference/v1/chat/completions"
        system_content = (
            "You are MultiVoice Assist, an intelligent multilingual AI assistant.\n"
            f"Respond in the user's language ({language}).\n"
            "Keep answers clear, concise, plain-text, and conversational."
        )
        if context:
            system_content += f"\n\nCONTEXT:\n{context}"

        messages = [{"role": "system", "content": system_content}]
        if history:
            for item in history:
                if isinstance(item, dict) and "role" in item and "content" in item:
                    messages.append({"role": item["role"], "content": item["content"]})
        messages.append({"role": "user", "content": user_message})

        router_payload = {
            "model": model_id,
            "messages": messages,
            "max_tokens": 256,
            "temperature": 0.4
        }

        try:
            logger.info(f"Sending request to Hugging Face Router for model: {model_id}")
            res = requests.post(router_url, headers=headers, json=router_payload, timeout=Config.REQUEST_TIMEOUT_SECONDS)
            if res.status_code == 200:
                data = res.json()
                if "choices" in data and len(data["choices"]) > 0:
                    answer = data["choices"][0].get("message", {}).get("content", "")
                    return {
                        "success": True,
                        "response": answer.strip(),
                        "model": model_id
                    }
        except Exception as e:
            logger.warn(f"HF Router exception: {e}")

        # Fallback to direct Inference API Endpoint
        endpoint = f"https://api-inference.huggingface.co/models/{model_id}"
        prompt = f"<|im_start|>system\n{system_content}\n<|im_end|>\n<|im_start|>user\n{user_message}\n<|im_end|>\n<|im_start|>assistant\n"

        payload = {
            "inputs": prompt,
            "parameters": {
                "max_new_tokens": 256,
                "temperature": 0.4
            },
            "options": {
                "wait_for_model": True
            }
        }

        try:
            res = requests.post(endpoint, headers=headers, json=payload, timeout=Config.REQUEST_TIMEOUT_SECONDS)
            if res.status_code == 200:
                data = res.json()
                answer = ""
                if isinstance(data, list) and len(data) > 0:
                    answer = data[0].get("generated_text", "")
                elif isinstance(data, dict):
                    answer = data.get("generated_text", "")
                return {
                    "success": True,
                    "response": answer.strip() or "No response generated.",
                    "model": model_id
                }
            else:
                return {
                    "success": False,
                    "response": f"Hugging Face API status HTTP {res.status_code}.",
                    "error": res.text,
                    "model": model_id
                }
        except Exception as e:
            logger.error(f"Inference Exception: {e}")
            return {
                "success": False,
                "response": "Backend connection error.",
                "error": str(e),
                "model": model_id
            }

ai_service = HuggingFaceAIService()
