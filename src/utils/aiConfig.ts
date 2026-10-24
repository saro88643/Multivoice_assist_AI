export const aiConfig = {
  // Configurable Hugging Face Model Identifier
  // User Model Repository: hvjhvyuvyuj/multivoice-assist
  hfModelId: 'hvjhvyuvyuj/multivoice-assist',

  // Backend Proxy URL (10.0.2.2 connects from Android Emulator to host machine)
  backendUrl: 'http://10.0.2.2:5000',

  // Hugging Face Inference Router Endpoint
  hfInferenceEndpoint: 'https://router.huggingface.co/hf-inference/v1/chat/completions',

  // Request timeout in milliseconds
  requestTimeoutMs: 30000,

  // Fallback to local RAG when cloud inference is offline or rate-limited
  enableLocalFallback: true,

  // System prompt guiding multilingual conversational behavior
  systemPrompt: `You are MultiVoice Assist, an intelligent multilingual AI assistant.
Rules:
1. Detect the user's input language (English, Tamil, Tanglish, Hindi, Malayalam, Telugu, Kannada, Arabic).
2. Reply in the SAME language or code-switched dialect (e.g. Tanglish) as the user.
3. Use plain text response format. Keep answers concise, factual, and helpful.
4. If relevant local context is provided, ground your response primarily in that context.`,
};
