import { KnowledgeDocument, RAGResult } from '../models/KnowledgeDocument';
import { RagConfig } from '../utils/ragConfig';

const knowledgeData: KnowledgeDocument[] = require('../assets/knowledge/knowledge_base.json');

export class RagService {
  private documents: KnowledgeDocument[] = [];
  private isLoaded: boolean = false;

  constructor() {
    this.initialize();
  }

  /**
   * Loads knowledge base from JSON asset into memory.
   */
  public async initialize(): Promise<void> {
    if (this.isLoaded) return;

    try {
      this.documents = knowledgeData.map((json: any) => ({
        id: String(json.id || ''),
        title: String(json.title || ''),
        category: String(json.category || ''),
        language: String(json.language || 'en'),
        keywords: Array.isArray(json.keywords)
          ? json.keywords.map((k: any) => String(k).toLowerCase())
          : [],
        question: String(json.question || ''),
        content: String(json.content || ''),
      }));
      this.isLoaded = true;
      console.log(`Local RAG: Loaded ${this.documents.length} knowledge entries.`);
    } catch (e) {
      console.error('Local RAG Initialization Error:', e);
    }
  }

  /**
   * Searches local knowledge base and returns ranked results, prioritizing the user's language.
   */
  public async search(query: string, detectedLanguage: string): Promise<RAGResult[]> {
    if (!this.isLoaded) {
      await this.initialize();
    }

    const cleanQuery = this.normalize(query);
    const queryTokens = this.tokenize(cleanQuery);

    if (queryTokens.length === 0) {
      return [];
    }

    const scoredResults: RAGResult[] = [];

    for (const doc of this.documents) {
      const score = this.calculateRelevanceScore(
        doc,
        queryTokens,
        cleanQuery,
        detectedLanguage
      );
      if (score > 0) {
        scoredResults.push({ document: doc, score });
      }
    }

    // Sort by score descending
    scoredResults.sort((a, b) => b.score - a.score);

    // Filter results matching user's requested language if available above threshold
    const sameLanguageResults = scoredResults.filter(
      (res) =>
        res.document.language.toLowerCase() === detectedLanguage.toLowerCase() &&
        res.score >= RagConfig.minRelevanceScore
    );

    if (sameLanguageResults.length > 0) {
      return sameLanguageResults.slice(0, RagConfig.topK);
    }

    // Return top K overall results as cross-language fallback
    return scoredResults.slice(0, RagConfig.topK);
  }

  private calculateRelevanceScore(
    doc: KnowledgeDocument,
    queryTokens: string[],
    fullQuery: string,
    lang: string
  ): number {
    let score = 0.0;

    // Language match boost
    const isLangMatch = doc.language.toLowerCase() === lang.toLowerCase();
    const langMultiplier = isLangMatch ? 1.8 : 0.6;

    const normTitle = this.normalize(doc.title);
    const normQuestion = this.normalize(doc.question);
    const normContent = this.normalize(doc.content);

    // Exact full query match
    if (normQuestion.includes(fullQuery) || normTitle.includes(fullQuery)) {
      score += 0.6;
    }

    const matchWord = (text: string, word: string) => {
      if (word.length <= 2) {
        return new RegExp(`\\b${word}\\b`, 'i').test(text);
      }
      return text.includes(word);
    };

    let matchedTokens = 0;

    for (const token of queryTokens) {
      if (!token) continue;

      // Token in title
      if (matchWord(normTitle, token)) {
        matchedTokens++;
        score += 0.35;
      }

      // Token in question
      if (matchWord(normQuestion, token)) {
        matchedTokens++;
        score += 0.35;
      }

      // Token in keywords
      if (doc.keywords.some((kw) => matchWord(kw, token) || matchWord(token, kw))) {
        matchedTokens++;
        score += 0.3;
      }

      // Token in content
      if (matchWord(normContent, token)) {
        matchedTokens++;
        score += 0.2;
      }

      // Fuzzy string match for typos (words longer than 3 chars)
      if (token.length > 3) {
        for (const kw of doc.keywords) {
          if (this.fuzzySimilarity(token, kw) > 0.8) {
            score += 0.15;
          }
        }
      }
    }

    // Normalize score between 0.0 and 1.0
    const normalizedScore = Math.min(
      Math.max(score / (queryTokens.length * 0.8 + 0.1), 0.0),
      1.0
    );

    return Math.min(Math.max(normalizedScore * langMultiplier, 0.0), 1.0);
  }

  private normalize(text: string): string {
    return text
      .toLowerCase()
      .replace(
        /[^\w\s\u0900-\u097F\u0B80-\u0BFF\u0D00-\u0D7F\u0C00-\u0C7F\u0C80-\u0CFF\u0600-\u06FF]/g,
        ' '
      )
      .replace(/\s+/g, ' ')
      .trim();
  }

  private tokenize(text: string): string[] {
    const stopWords = new Set([
      'is',
      'a',
      'an',
      'the',
      'what',
      'how',
      'does',
      'in',
      'of',
      'and',
      'to',
      'for',
      'it',
      'my',
      'do',
    ]);
    const rawTokens = text.split(' ');
    return rawTokens.filter((t) => t.length > 1 && !stopWords.has(t));
  }

  private fuzzySimilarity(s1: string, s2: string): number {
    if (s1 === s2) return 1.0;
    if (!s1 || !s2) return 0.0;

    const distance = this.levenshteinDistance(s1, s2);
    const maxLength = Math.max(s1.length, s2.length);
    return 1.0 - distance / maxLength;
  }

  private levenshteinDistance(a: string, b: string): number {
    const v0: number[] = Array.from({ length: b.length + 1 }, (_, i) => i);
    const v1: number[] = new Array(b.length + 1).fill(0);

    for (let i = 0; i < a.length; i++) {
      v1[0] = i + 1;
      for (let j = 0; j < b.length; j++) {
        const cost = a.charCodeAt(i) === b.charCodeAt(j) ? 0 : 1;
        v1[j + 1] = Math.min(v1[j] + 1, v0[j + 1] + 1, v0[j] + cost);
      }
      for (let j = 0; j <= b.length; j++) {
        v0[j] = v1[j];
      }
    }
    return v0[b.length];
  }
}

export const ragService = new RagService();
