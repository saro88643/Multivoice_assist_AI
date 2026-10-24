# MultiVoice Assist Dataset Documentation

## Dataset Overview
- **Name**: MultiVoice Assist Local Knowledge Base
- **Source**: Custom curated dataset & open domain project knowledge
- **Location**: `assets/knowledge/knowledge_base.json` and `datasets/knowledge_source.json`
- **Format**: JSON array containing structured knowledge entries
- **License**: Public Domain / MIT License
- **Purpose**: Lightweight local RAG retrieval for offline multilingual assistant
- **Total Records**: 30+ structured records across 7 supported languages

## Schema Definition
Each entry in the knowledge base contains:
- `id` (String): Unique identifier (e.g. "001")
- `title` (String): Descriptive document title
- `category` (String): Knowledge domain (`project`, `features`, `voice`, `languages`, `authentication`, `profile`, `history`, `database`, `technical`, `FAQ`)
- `language` (String): ISO 639-1 language code (`en`, `ta`, `hi`, `ml`, `te`, `kn`, `ar`)
- `keywords` (Array of Strings): Tokens and synonyms for TF-IDF keyword matching
- `question` (String): Example question matched by the chunk
- `content` (String): Text factual content retrieved by the RAG engine

## Supported Languages
- English (`en`)
- Tamil (`ta`)
- Hindi (`hi`)
- Malayalam (`ml`)
- Telugu (`te`)
- Kannada (`kn`)
- Arabic (`ar`)
