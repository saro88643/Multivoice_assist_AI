# MultiVoice Assist — Hugging Face Integration Guide

## 1. Architecture Summary
The application connects to Hugging Face hosted open-source instruction-tuned models (`Qwen/Qwen2.5-7B-Instruct` or user fine-tuned LoRA models) via a secure Python Flask backend proxy.

```
React Native App (Android)
       │
       ▼  HTTP POST /api/chat (http://10.0.2.2:5000)
Python Flask Backend Proxy
       │
       ▼  Bearer Token Auth (HF_API_TOKEN in .env)
Hugging Face Hosted Inference API
       │
       ▼
Cloud LLM Model Computation (e.g., Qwen2.5-7B-Instruct / LoRA Fine-Tuned Model)
```

---

## 2. Files Created & Modified

| File Path | Purpose |
|---|---|
| `backend/app.py` | Flask server entry point & CORS configuration |
| `backend/config.py` | Environment variable loader (`HF_API_TOKEN`, `HF_MODEL_ID`) |
| `backend/services/ai_service.py` | Hugging Face Hosted Inference API wrapper with error handling |
| `backend/routes/chatbot.py` | REST API `/api/chat` route |
| `backend/requirements.txt` | Python backend dependencies |
| `backend/.env.example` | Environment configuration template |
| `src/utils/aiConfig.ts` | Configurable model ID and backend endpoint URL settings |
| `src/services/huggingFaceService.ts` | React Native HTTP client for Hugging Face proxy |
| `src/services/answerGeneratorService.ts` | RAG grounding & Hugging Face service bridge |
| `docs/HUGGINGFACE_INTEGRATION.md` | Integration and deployment guide |
| `docs/FINE_TUNING_GUIDE.md` | LoRA / QLoRA fine-tuning and model swap guide |

---

## 3. Dependency Installation Commands

### Backend Dependencies:
```bash
cd backend
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
```

### Mobile Dependencies:
```bash
npm install
```

---

## 4. Environment Variables Configuration

Copy `backend/.env.example` to `backend/.env`:

```env
HF_API_TOKEN=hf_your_private_token_here
HF_MODEL_ID=Qwen/Qwen2.5-7B-Instruct
PORT=5000
HOST=0.0.0.0
```

> **SECURITY NOTE**: `backend/.env` is listed in `.gitignore`. The Hugging Face API Token is **NEVER** embedded in the Android app or committed to Git.

---

## 5. Running the Backend & Application

1. **Start Backend Server**:
   ```bash
   cd backend
   python app.py
   ```
2. **Launch Android Emulator**:
   ```bash
   adb devices
   ```
3. **Run React Native App**:
   ```bash
   npx react-native run-android
   ```

---

## 6. Verification Checklist

- [x] Hugging Face Model ID is configurable in `config.py` and `aiConfig.ts`.
- [x] `HF_API_TOKEN` is secured on the backend proxy server.
- [x] MultiVoice Assist Android app connects via `10.0.2.2:5000`.
- [x] User input in English, Tamil, Tanglish, Hindi, Malayalam, Telugu, Kannada, Arabic is supported.
- [x] Local RAG knowledge base grounds model prompts.
- [x] Voice STT, device TTS audio playback, and SQLite history persistence preserved.
