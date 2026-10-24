# MultiVoice Assist — RAG Architecture

## Overview
MultiVoice Assist features a 100% offline, lightweight Retrieval-Augmented Generation (RAG) assistant running locally on mobile devices without relying on cloud LLMs, commercial APIs (OpenAI, Groq, Gemini), or cloud vector databases.

---

## Technical Pipeline

```
[ User Input (Text / Speech-to-Text) ]
                 │
                 ▼
     [ Language Detection Service ]
 (Script & Unicode Character Analysis)
                 │
                 ▼
         [ Query Normalizer ]
(Lowercase, Punctuation & Stop Words Removal)
                 │
                 ▼
       [ Local RAG Retriever ]
(In-Memory Index, TF-IDF, Keyword & Levenshtein Fuzzy Scoring)
                 │
                 ▼
   [ Relevance Threshold Evaluator ]
       (MIN_RELEVANCE_SCORE = 0.18)
          ├── Below Threshold ──► [ Localized Fallback Response ]
          └── Above Threshold
                 │
                 ▼
    [ Grounded Answer Generator ]
 (Strict Context Construction - Zero Hallucination)
                 │
                 ▼
       [ Device Local TTS ]
  (flutter_tts mapped to locale en, ta, hi, ml, te, kn, ar)
                 │
                 ▼
     [ SQLite History Persistence ]
```

---

## Core Components

### 1. In-Memory Knowledge Cache
- **Asset Path**: `assets/knowledge/knowledge_base.json`
- **Mechanism**: Loaded once during application initialization into memory to ensure near-zero latency retrieval (< 10 ms).

### 2. Language Detection
- **Service**: `lib/services/language_detection_service.dart`
- **Method**: Evaluates Unicode script ranges for English, Tamil, Hindi, Malayalam, Telugu, Kannada, and Arabic.

### 3. Lightweight Retrieval Engine
- **Service**: `lib/services/rag_service.dart`
- **Scoring**:
  - Exact & phrase matches in title and question (0.60 weight).
  - Term matches across title, question, keywords, and content (0.15–0.25 weight).
  - Levenshtein string similarity for typo tolerance.
  - Detected language matching multiplier (1.5x boost).

### 4. Grounded Answer Generator
- **Service**: `lib/services/answer_generator_service.dart`
- **Threshold Policy**: If top match score < `MIN_RELEVANCE_SCORE` (0.18), returns localized message ("I couldn't find this information in my knowledge base.") to avoid hallucination.

### 5. Local Text-to-Speech
- **Service**: `lib/services/local_tts_service.dart`
- **Engine**: Native device TTS via `flutter_tts` using locales `en-US`, `ta-IN`, `hi-IN`, `ml-IN`, `te-IN`, `kn-IN`, `ar-SA`.

---

## Key Benefits
- **Zero API Cost**: No subscription or per-token fees.
- **Privacy & Security**: All user queries and data remain 100% on-device.
- **Offline Capability**: Operates fully without internet connectivity.
- **Low Memory & CPU Footprint**: Runs efficiently on lower-spec mobile devices without heating or heavy battery drain.
