import React, { createContext, useState, useContext, ReactNode } from 'react';
import { Message } from '../models/Message';
import { ragService } from '../services/ragService';
import { languageDetectionService } from '../services/languageDetectionService';
import { answerGeneratorService } from '../services/answerGeneratorService';

interface ChatContextType {
  messages: Message[];
  isLoading: boolean;
  errorMessage: string | null;
  lastDetectedLanguage: string;
  sendMessage: (
    text: string,
    saveToHistory: (question: string, answer: string) => Promise<boolean>
  ) => Promise<void>;
  clearMessages: () => void;
  clearError: () => void;
}

const ChatContext = createContext<ChatContextType | undefined>(undefined);

export const ChatProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [messages, setMessages] = useState<Message[]>([]);
  const [isLoading, setIsLoading] = useState<boolean>(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [lastDetectedLanguage, setLastDetectedLanguage] = useState<string>('en');

  const sendMessage = async (
    text: string,
    saveToHistory: (question: string, answer: string) => Promise<boolean>
  ): Promise<void> => {
    const question = text.trim();
    if (!question || isLoading) return;

    setErrorMessage(null);

    const userMessage: Message = {
      id: String(Date.now()),
      text: question,
      isUser: true,
      time: new Date(),
    };

    setMessages((prev) => [...prev, userMessage]);
    setIsLoading(true);

    try {
      // 1. Language Detection
      const lang = languageDetectionService.detectLanguage(question);
      setLastDetectedLanguage(lang);

      // 2. Retrieval
      const searchResults = await ragService.search(question, lang);

      // 3. Grounded Answer Generation
      const groundedOutput = await answerGeneratorService.generateGroundedAnswer({
        query: question,
        searchResults,
        detectedLanguage: lang,
      });

      const aiMessage: Message = {
        id: String(Date.now() + 1),
        text: groundedOutput.answer,
        isUser: false,
        time: new Date(),
      };

      setMessages((prev) => [...prev, aiMessage]);

      // 4. Save to History
      try {
        await saveToHistory(question, groundedOutput.answer);
      } catch (e) {
        console.error('History save error:', e);
      }
    } catch (e: any) {
      console.error('Local RAG chat error:', e);
      setErrorMessage(String(e));

      const errorMsg: Message = {
        id: String(Date.now() + 2),
        text: 'Unable to retrieve answer from local knowledge base.',
        isUser: false,
        time: new Date(),
      };

      setMessages((prev) => [...prev, errorMsg]);
    } finally {
      setIsLoading(false);
    }
  };

  const clearMessages = () => {
    setMessages([]);
    setErrorMessage(null);
    setIsLoading(false);
  };

  const clearError = () => {
    setErrorMessage(null);
  };

  return (
    <ChatContext.Provider
      value={{
        messages,
        isLoading,
        errorMessage,
        lastDetectedLanguage,
        sendMessage,
        clearMessages,
        clearError,
      }}
    >
      {children}
    </ChatContext.Provider>
  );
};

export const useChat = (): ChatContextType => {
  const context = useContext(ChatContext);
  if (!context) {
    throw new Error('useChat must be used within a ChatProvider');
  }
  return context;
};
