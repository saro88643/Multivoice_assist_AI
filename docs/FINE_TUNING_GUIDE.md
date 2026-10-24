# MultiVoice Assist — Future Fine-Tuning & Model Swap Guide

## Overview
This guide explains how to fine-tune a custom multilingual model using Google Colab (LoRA / QLoRA) on your Hugging Face dataset and deploy it to MultiVoice Assist.

---

## Step 1: Fine-Tuning on Google Colab
1. Use `unsloth` or `peft` with `TRL` (SFTTrainer) to train on your Hugging Face dataset.
2. Base Model: `Qwen/Qwen2.5-7B-Instruct` or `meta-llama/Llama-3.2-3B-Instruct`.
3. Save and push the fine-tuned adapter / merged model to Hugging Face Hub:
   ```python
   model.push_to_hub_merged("your_hf_username/multivoice-assist-finetuned", tokenizer, save_method="merged_16bit")
   ```

---

## Step 2: Switching Model in MultiVoice Assist
To replace the default model with your fine-tuned model:

1. Update `backend/.env`:
   ```env
   HF_MODEL_ID=your_hf_username/multivoice-assist-finetuned
   ```

2. Update `src/utils/aiConfig.ts`:
   ```typescript
   export const aiConfig = {
     hfModelId: 'your_hf_username/multivoice-assist-finetuned',
     ...
   };
   ```

3. Restart the Python backend (`python app.py`). No mobile code changes required!
