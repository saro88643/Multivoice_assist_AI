export const ragConfig = {
  knowledgeBasePath: '../assets/knowledge/knowledge_base.json',
  modelName: 'Qwen2.5-0.5B-Instruct-Q4_K_M.gguf',
  modelDirectory: 'assets/models',

  // Relevance score threshold below which answer is "not found"
  minRelevanceScore: 0.18,

  // Maximum number of top chunks retrieved for context
  topK: 3,

  // Context & memory window controls
  maxContextTokens: 1024,
  maxOutputTokens: 256,
  maxHistoryMessages: 6,

  // Low memory mode settings
  lowMemoryMode: false,

  // System prompt template for Qwen2.5 local model
  systemPrompt: `You are MultiVoice Assist, a grounded local RAG assistant.
Your primary job is to answer the user using the supplied CONTEXT.
Always respond in the same language as the user whenever possible.
Supported languages: English, Tamil, Hindi, Malayalam, Telugu, Kannada, Arabic.
For college/project questions, use the retrieved context. Never invent facts.
If the context does not support an answer, clearly state that the information is unavailable in the local knowledge base.
Keep answers concise, friendly, and factual.`,

  // Fallback messages when information is not in knowledge base
  fallbackMessages: {
    en: "I couldn't find this information in my local knowledge base.",
    ta: 'இந்த தகவல் எனது உள்ளூர் அறிவுத் தரவுத்தளத்தில் கிடைக்கவில்லை.',
    hi: 'यह जानकारी मेरे स्थानीय ज्ञान आधार में नहीं मिली।',
    ml: 'എന്റെ പ്രാദേശിക വിജ്ഞാനശേഖരത്തിൽ ഈ വിവരം കണ്ടെത്താനായില്ല.',
    te: 'ఈ సమాచారం నా స్థానిక జ్ఞాన ఆధారంలో లభించలేదు.',
    kn: 'ಈ ಮಾಹಿತಿಯು ನನ್ನ ಸ್ಥಳೀಯ ಜ್ಞಾನ ತಳಹದಿಯಲ್ಲಿ ಕಂಡುಬಂದಿಲ್ಲ.',
    ar: 'لم أتمكن من العثور على هذه المعلومات في قاعدة المعرفة المحلية الخاصة بي.',
  } as Record<string, string>,

  getFallbackMessage(langCode: string): string {
    return this.fallbackMessages[langCode] || this.fallbackMessages.en;
  },
};

export const RagConfig = ragConfig;
