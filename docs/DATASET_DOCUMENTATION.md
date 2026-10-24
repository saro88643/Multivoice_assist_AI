# MultiVoice Assist — Dataset Documentation

## Dataset Metadata
- **Dataset Name**: MultiVoice Assist Knowledge Base Dataset
- **Location**: `assets/knowledge/knowledge_base.json` & `datasets/knowledge_source.json`
- **Format**: JSON Array of Knowledge Records
- **Languages**: 7 Languages (English, Tamil, Hindi, Malayalam, Telugu, Kannada, Arabic)
- **License**: Public Domain / MIT Open Source
- **Purpose**: Grounding knowledge base for MultiVoice Assist local offline RAG chatbot.

---

## Schema Structure

Each entry in `knowledge_base.json` follows this JSON schema:

```json
{
  "id": "String (Unique Identifier, e.g. '001', '001_ta')",
  "title": "String (Short topic title)",
  "category": "String (e.g. 'project', 'features', 'voice', 'languages', 'auth', 'profile', 'history', 'database', 'technical', 'FAQ')",
  "language": "String ('en', 'ta', 'hi', 'ml', 'te', 'kn', 'ar')",
  "keywords": ["List of String keywords for search token matching"],
  "question": "String (Representative user query)",
  "content": "String (Grounded factual context answer)"
}
```

---

## Content Categories & Breakdown

| Category | Description | Example Topics |
|---|---|---|
| `project` | Core application overview | What is MultiVoice Assist, system purpose |
| `features` | Key features & functionalities | Offline capabilities, dark mode, voice chat |
| `voice` | Speech recognition & synthesis | STT engine, Local TTS voices |
| `languages` | Supported regional & international languages | Language list, language switching |
| `auth` | User account management | Local registration, login, data privacy |
| `profile` | User profile features | Name, email, profile picture crop & save |
| `history` | Chat persistence | SQLite database, searching past conversations |
| `database` | Local persistence details | `sqflite`, DB schema, tables |
| `technical` | RAG architecture & algorithm details | Scoring formula, thresholding, zero API keys |
| `FAQ` | Frequently Asked Questions | Troubleshooting, general usage |

---

## Extending the Knowledge Base
To add new knowledge items:
1. Open `assets/knowledge/knowledge_base.json`.
2. Add a new JSON object adhering to the schema.
3. Reload the application. The in-memory RAG retriever automatically indexes the new entry on startup without Dart code modifications.
