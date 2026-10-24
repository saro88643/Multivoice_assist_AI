# MultiVoice Assist — Dataset Setup Guide

## Dataset File
- **Path**: `src/assets/knowledge/knowledge_base.json` & `datasets/knowledge_source.json`
- **Format**: JSON Array of Documents
- **Categories**: `project`, `features`, `voice`, `languages`, `auth`, `profile`, `history`, `database`, `technical`, `FAQ`, `Campus`, `Academic`, `Facilities`

---

## Schema Reference

```json
{
  "id": "001",
  "title": "Document Title",
  "category": "project",
  "language": "en",
  "keywords": ["keyword1", "keyword2"],
  "question": "Representative question",
  "content": "Factual grounded answer text"
}
```
