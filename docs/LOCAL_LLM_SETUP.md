# MultiVoice Assist — Local LLM Setup Guide

## Model Overview
- **Model Architecture**: Qwen2.5-0.5B-Instruct
- **Format**: GGUF
- **Quantization**: Q4_K_M (4-bit)
- **Approximate Size**: ~350 MB - 390 MB
- **Target Location**: `assets/models/Qwen2.5-0.5B-Instruct-Q4_K_M.gguf`

---

## Memory & Execution Policy
1. **Single Model Instance**: Only one quantized model is active in memory.
2. **Context Window Control**:
   - `MAX_CONTEXT_TOKENS = 1024`
   - `MAX_OUTPUT_TOKENS = 256`
   - `MAX_HISTORY_MESSAGES = 6`
3. **On-Demand Loading**: Model is initialized when user enters Chat/Voice screens and stays resident until app release.
