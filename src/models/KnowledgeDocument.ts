export interface KnowledgeDocument {
  id: string;
  title: string;
  category: string;
  language: string;
  keywords: string[];
  question: string;
  content: string;
}

export interface RAGResult {
  document: KnowledgeDocument;
  score: number;
}
