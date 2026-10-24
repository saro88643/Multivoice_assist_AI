import React, { createContext, useState, useContext, ReactNode, useEffect } from 'react';
import { HistoryItem } from '../models/History';
import { databaseService } from '../services/databaseService';

interface HistoryContextType {
  historyList: HistoryItem[];
  isLoading: boolean;
  loadHistory: () => Promise<void>;
  saveChat: (question: string, answer: string) => Promise<boolean>;
  deleteChat: (id: number) => Promise<boolean>;
  deleteAllChats: () => Promise<boolean>;
}

const HistoryContext = createContext<HistoryContextType | undefined>(undefined);

export const HistoryProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [historyList, setHistoryList] = useState<HistoryItem[]>([]);
  const [isLoading, setIsLoading] = useState<boolean>(false);

  const loadHistory = async (): Promise<void> => {
    setIsLoading(true);
    try {
      const chats = await databaseService.getAllChats();
      setHistoryList(chats);
    } catch (e) {
      console.error('History load error:', e);
    } finally {
      setIsLoading(false);
    }
  };

  const saveChat = async (question: string, answer: string): Promise<boolean> => {
    try {
      await databaseService.insertChat({
        question,
        answer,
        dateTime: new Date().toISOString(),
      });
      await loadHistory();
      return true;
    } catch (e) {
      console.error('History save error:', e);
      return false;
    }
  };

  const deleteChat = async (id: number): Promise<boolean> => {
    try {
      await databaseService.deleteChat(id);
      await loadHistory();
      return true;
    } catch (e) {
      console.error('Delete chat error:', e);
      return false;
    }
  };

  const deleteAllChats = async (): Promise<boolean> => {
    try {
      await databaseService.deleteAllChats();
      setHistoryList([]);
      return true;
    } catch (e) {
      console.error('Delete all error:', e);
      return false;
    }
  };

  useEffect(() => {
    loadHistory();
  }, []);

  return (
    <HistoryContext.Provider
      value={{
        historyList,
        isLoading,
        loadHistory,
        saveChat,
        deleteChat,
        deleteAllChats,
      }}
    >
      {children}
    </HistoryContext.Provider>
  );
};

export const useHistory = (): HistoryContextType => {
  const context = useContext(HistoryContext);
  if (!context) {
    throw new Error('useHistory must be used within a HistoryProvider');
  }
  return context;
};
