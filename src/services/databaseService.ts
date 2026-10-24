import AsyncStorage from '@react-native-async-storage/async-storage';
import { HistoryItem } from '../models/History';

const CHAT_HISTORY_STORAGE_KEY = '@multivoice_assist_chat_history';

export class DatabaseService {
  private inMemoryHistory: HistoryItem[] = [];
  private isInitialized: boolean = false;

  public async initializeDatabase(): Promise<void> {
    if (this.isInitialized) return;

    try {
      const stored = await AsyncStorage.getItem(CHAT_HISTORY_STORAGE_KEY);
      if (stored) {
        this.inMemoryHistory = JSON.parse(stored);
      } else {
        this.inMemoryHistory = [];
      }
      this.isInitialized = true;
      console.log(`Database initialized. Found ${this.inMemoryHistory.length} history records.`);
    } catch (e) {
      console.error('Database initialization error:', e);
      this.inMemoryHistory = [];
      this.isInitialized = true;
    }
  }

  private async persist(): Promise<void> {
    try {
      await AsyncStorage.setItem(
        CHAT_HISTORY_STORAGE_KEY,
        JSON.stringify(this.inMemoryHistory)
      );
    } catch (e) {
      console.error('Error persisting history:', e);
    }
  }

  public async insertChat(item: Omit<HistoryItem, 'id'>): Promise<number> {
    await this.initializeDatabase();

    const id = Date.now();
    const newChat: HistoryItem = {
      id,
      question: item.question.trim(),
      answer: item.answer.trim(),
      dateTime: item.dateTime || new Date().toISOString(),
    };

    // Prepend to list (order by id DESC)
    this.inMemoryHistory.unshift(newChat);
    await this.persist();
    return id;
  }

  public async getAllChats(): Promise<HistoryItem[]> {
    await this.initializeDatabase();
    return [...this.inMemoryHistory];
  }

  public async deleteChat(id: number): Promise<boolean> {
    await this.initializeDatabase();
    this.inMemoryHistory = this.inMemoryHistory.filter((c) => c.id !== id);
    await this.persist();
    return true;
  }

  public async deleteAllChats(): Promise<boolean> {
    await this.initializeDatabase();
    this.inMemoryHistory = [];
    await this.persist();
    return true;
  }

  public async searchChats(query: string): Promise<HistoryItem[]> {
    await this.initializeDatabase();
    const clean = query.toLowerCase().trim();
    if (!clean) return [...this.inMemoryHistory];

    return this.inMemoryHistory.filter(
      (c) =>
        c.question.toLowerCase().includes(clean) ||
        c.answer.toLowerCase().includes(clean)
    );
  }
}

export const databaseService = new DatabaseService();
