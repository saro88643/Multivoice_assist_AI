# MultiVoice Assist — Local RAG Setup Guide

## Overview
Retrieval-Augmented Generation (RAG) ensures responses are strictly grounded in factual college and project data.

---

## Retrieval Engine Details
- **Algorithm**: BM25 / TF-IDF term frequency with title & keyword boosting + Levenshtein fuzzy string distance.
- **Threshold Policy**: `MIN_RELEVANCE_SCORE = 0.18`. If top chunk < 0.18, returns localized fallback message preventing hallucination.
- **Top-K**: Retrieves top 3 context chunks per query.
- **Languages**: Evaluates queries across 7 supported languages (`en`, `ta`, `hi`, `ml`, `te`, `kn`, `ar`).
