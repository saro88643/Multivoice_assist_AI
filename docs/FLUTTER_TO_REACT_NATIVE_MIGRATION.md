# MultiVoice Assist — Flutter to React Native Migration Map

## Overview
This document maps the architectural components, libraries, services, screens, state management, and persistence layer from the Flutter implementation (`lib/`) to the React Native + TypeScript implementation (`multivoice_assist_react_native/src/`).

---

## 1. Technology & Language Mapping

| Category | Flutter Implementation | React Native Target |
| :--- | :--- | :--- |
| **Language** | Dart (>=3.12.0) | TypeScript 5.x / JavaScript ES2023 |
| **Framework** | Flutter (Material 3) | React Native 0.73+ |
| **State Management** | `provider` (ChangeNotifier) | React Context API (`useContext`, `useReducer`) |
| **Navigation** | `Navigator.push` / `MaterialPageRoute` | React Navigation (`@react-navigation/native-stack`) |
| **Local Database** | `sqflite` | `react-native-sqlite-storage` / Local SQLite Service |
| **Local Preferences** | `shared_preferences` | `@react-native-async-storage/async-storage` |
| **Speech-to-Text** | `speech_to_text` | `@react-native-voice/voice` / Native Speech Recognition |
| **Text-to-Speech** | `flutter_tts` | `react-native-tts` / Device TTS |
| **Image Picker** | `image_picker` | `react-native-image-picker` |
| **Image Cropper** | `image_cropper` | `react-native-image-crop-picker` |

---

## 2. Directory & Architecture Mapping

```
lib/ (Flutter)                              multivoice_assist_react_native/src/ (React Native)
├── main.dart                          -->  ├── App.tsx
├── database/                          -->  ├── services/databaseService.ts
│   └── database_helper.dart
├── models/                            -->  ├── models/
│   ├── history_model.dart             -->  │   ├── History.ts
│   ├── message_model.dart             -->  │   ├── Message.ts
│   └── user_model.dart                -->  │   └── User.ts
├── providers/                         -->  ├── providers/
│   ├── auth_provider.dart             -->  │   ├── AuthContext.tsx
│   ├── chat_provider.dart             -->  │   ├── ChatContext.tsx
│   ├── history_provider.dart          -->  │   ├── HistoryContext.tsx
│   ├── profile_provider.dart          -->  │   ├── ProfileContext.tsx
│   └── speech_provider.dart           -->  │   └── SpeechContext.tsx
├── services/                          -->  ├── services/
│   ├── rag_service.dart               -->  │   ├── ragService.ts
│   ├── answer_generator_service.dart  -->  │   ├── answerGeneratorService.ts
│   ├── language_detection_service.dart-->  │   ├── languageDetectionService.ts
│   ├── speech_service.dart            -->  │   ├── speechService.ts
│   └── local_tts_service.dart         -->  │   └── ttsService.ts
├── screens/                           -->  ├── screens/
│   ├── splash/splash_screen.dart      -->  │   ├── SplashScreen.tsx
│   ├── auth/login_screen.dart         -->  │   ├── LoginScreen.tsx
│   ├── auth/register_screen.dart      -->  │   ├── RegisterScreen.tsx
│   ├── home/home_screen.dart          -->  │   ├── HomeScreen.tsx
│   ├── chat/chat_screen.dart          -->  │   ├── ChatScreen.tsx
│   ├── chat/voice_chat_screen.dart    -->  │   ├── VoiceChatScreen.tsx
│   ├── history/history_screen.dart    -->  │   ├── HistoryScreen.tsx
│   ├── profile/profile_screen.dart    -->  │   ├── ProfileScreen.tsx
│   ├── profile/edit_profile_screen.dart--> │   ├── EditProfileScreen.tsx
│   ├── profile/voice_settings_screen.d--> │   ├── VoiceSettingsScreen.tsx
│   └── rag_debug/rag_debug_screen.dart-->  │   └── RagDebugScreen.tsx
├── utils/                             -->  ├── utils/
│   ├── colors.dart                    -->  │   ├── theme.ts
│   ├── constants.dart                 -->  │   ├── constants.ts
│   └── rag_config.dart                -->  │   └── ragConfig.ts
└── assets/knowledge/                  -->  └── assets/knowledge/
    └── knowledge_base.json            -->      └── knowledge_base.json
```

---

## 3. Key Services & Logic Migration

### Local RAG Engine (`ragService.ts`)
- Preserves local JSON loading from `assets/knowledge/knowledge_base.json`.
- Implements Unicode script detection for English, Tamil, Hindi, Malayalam, Telugu, Kannada, and Arabic.
- Exact TF-IDF tokenization, stop word filtering, and Levenshtein fuzzy matching.
- Exact relevance score normalization and threshold filtering (`minRelevanceScore = 0.18`).

### Answer Generation (`answerGeneratorService.ts`)
- Returns strictly grounded answer from top context chunk when relevance >= 0.18.
- Returns localized fallback message ("I couldn't find this information in my knowledge base.") when no match satisfies threshold.

### SQLite Database (`databaseService.ts`)
- Manages `chat_history.db` with table `history (id, question, answer, dateTime)`.
- Provides async CRUD functions: `insertChat`, `getAllChats`, `deleteChat`, `deleteAllChats`, `searchChats`.

---

## 4. Zero Commercial API Key Guarantee
The React Native version contains:
- **NO** `OPENAI_API_KEY`
- **NO** `GROQ_API_KEY`
- **NO** `GEMINI_API_KEY`
- **NO** cloud AI endpoint dependencies.
