import React, { createContext, useState, useContext, ReactNode } from 'react';
import { speechService } from '../services/speechService';

interface SpeechContextType {
  isListening: boolean;
  recognizedText: string;
  error: string | null;
  startListening: () => Promise<void>;
  stopListening: () => Promise<void>;
  cancelListening: () => Promise<void>;
  clearText: () => void;
  setRecognizedText: (text: string) => void;
}

const SpeechContext = createContext<SpeechContextType | undefined>(undefined);

export const SpeechProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [isListening, setIsListening] = useState<boolean>(false);
  const [recognizedText, setRecognizedText] = useState<string>('');
  const [error, setError] = useState<string | null>(null);

  const startListening = async (): Promise<void> => {
    setError(null);
    setRecognizedText('');
    setIsListening(true);
    await speechService.startListening((text) => {
      setRecognizedText(text);
    });
  };

  const stopListening = async (): Promise<void> => {
    await speechService.stopListening();
    setIsListening(false);
  };

  const cancelListening = async (): Promise<void> => {
    await speechService.cancelListening();
    setIsListening(false);
  };

  const clearText = () => {
    setRecognizedText('');
    setError(null);
  };

  return (
    <SpeechContext.Provider
      value={{
        isListening,
        recognizedText,
        error,
        startListening,
        stopListening,
        cancelListening,
        clearText,
        setRecognizedText,
      }}
    >
      {children}
    </SpeechContext.Provider>
  );
};

export const useSpeech = (): SpeechContextType => {
  const context = useContext(SpeechContext);
  if (!context) {
    throw new Error('useSpeech must be used within a SpeechProvider');
  }
  return context;
};
