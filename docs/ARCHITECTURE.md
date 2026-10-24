# MultiVoice Assist — Offline Local LLM + RAG Architecture

## Overview
MultiVoice Assist is a 100% offline, privacy-focused, multilingual AI assistant running on React Native (TypeScript). It operates entirely on-device without commercial AI APIs (OpenAI, Groq, Gemini), external servers, or cloud vector databases.

---

## Technical Pipeline

```
               MULTIVOICE ASSIST (React Native)
                      │
             ┌────────┴────────┐
             │                 │
          TEXT             VOICE
             │                 │
             │                STT
             │                 │
             └────────┬────────┘
                      │
              LANGUAGE DETECTION
      (Unicode Script Range Analysis)
                      │
                      ▼
                RAG RETRIEVER
      (In-Memory Index, BM25 / TF-IDF,
    Title Weighting & Fuzzy String Matching)
                      │
               Top 3 Context Chunks
                      │
                      ▼
               CONTEXT BUILDER
       (System Prompt & Anti-Hallucination)
                      │
                      ▼
          QWEN2.5-0.5B LOCAL LLM
    (On-Device Q4_K_M GGUF Model Execution)
                      │
                      ▼
              GROUNDED ANSWER
                      │
             ┌────────┴────────┐
             │                 │
          DISPLAY             TTS
             │                 │
             └────────┬────────┘
                      │
                   SQLITE
                      │
                CHAT HISTORY
```

---

## Core Services

1. **`localLLMService.ts`**:
   - Manages model lifecycle (`uninitialized` -> `loading` -> `ready` -> `error`).
   - Executes local Qwen2.5-0.5B-Instruct inferences with memory safeguards.

2. **`ragService.ts`**:
   - Indexes `knowledge_base.json`.
   - Computes BM25/TF-IDF term frequencies, exact phrase boosts, and Levenshtein string similarities.

3. **`answerGeneratorService.ts`**:
   - Evaluates relevance against `MIN_RELEVANCE_SCORE = 0.18`.
   - Formats system prompts and extracts verifiable source citations.

4. **`languageDetectionService.ts`**:
   - Analyzes script character codes for English, Tamil, Hindi, Malayalam, Telugu, Kannada, and Arabic.

5. **`databaseService.ts`**:
   - Manages local SQLite `chat_history.db` database.
