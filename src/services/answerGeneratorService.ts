import { RAGResult } from '../models/KnowledgeDocument';
import { ragConfig } from '../utils/ragConfig';
import { huggingFaceService } from './huggingFaceService';
import { localLLMService, LLMInferenceResult } from './localLLMService';

export interface GroundedAnswerOutput {
  answer: string;
  sources: string[];
  topScore: number;
  modelUsed: string;
  inferenceResult?: LLMInferenceResult;
}

export class AnswerGeneratorService {
  /**
   * Generates answer using Hugging Face hosted model (or local grounded engine fallback if offline/unauthorized).
   */
  public async generateGroundedAnswer(params: {
    query: string;
    searchResults: RAGResult[];
    detectedLanguage: string;
  }): Promise<GroundedAnswerOutput> {
    const { query, searchResults, detectedLanguage } = params;

    const validResults = searchResults.filter((res) => res.score >= ragConfig.minRelevanceScore);
    const topResult = validResults.length > 0 ? validResults[0] : null;
    const topScore = topResult ? topResult.score : 0.0;

    const sources = Array.from(new Set(validResults.map((res) => res.document.title)));
    const contextText = validResults
      .map((res) => `${res.document.title}: ${res.document.content}`)
      .join('\n\n');

    // 1. Try Hugging Face Hosted Inference via Backend Proxy
    try {
      const hfResponse = await huggingFaceService.sendMessage({
        message: query,
        language: detectedLanguage,
        context: contextText,
      });

      if (
        hfResponse.success &&
        hfResponse.response &&
        hfResponse.response.trim().length > 0 &&
        !hfResponse.response.includes('Backend connection error') &&
        !hfResponse.response.includes('Missing HF_API_TOKEN')
      ) {
        return {
          answer: hfResponse.response.trim(),
          sources: hfResponse.sources && hfResponse.sources.length > 0 ? hfResponse.sources : sources,
          topScore,
          modelUsed: hfResponse.model,
        };
      }
    } catch (e) {
      console.warn('[AnswerGeneratorService] Hugging Face backend unreachable, utilizing local engine.');
    }

    // 2. Seamless Local Grounded Fallback: Return top best match content in requested language
    if (topResult && topScore >= ragConfig.minRelevanceScore) {
      return {
        answer: topResult.document.content.trim(),
        sources: [topResult.document.title],
        topScore,
        modelUsed: 'Local RAG Engine',
      };
    }

    return {
      answer: ragConfig.getFallbackMessage(detectedLanguage),
      sources: [],
      topScore,
      modelUsed: 'Offline Fallback',
    };
  }

  /**
   * Legacy helper method for unit test suites.
   */
  public generateAnswer(params: {
    query: string;
    searchResults: RAGResult[];
    detectedLanguage: string;
  }): string {
    const { searchResults, detectedLanguage } = params;
    if (!searchResults || searchResults.length === 0) {
      return ragConfig.getFallbackMessage(detectedLanguage);
    }
    const topResult = searchResults[0];
    if (topResult.score < ragConfig.minRelevanceScore) {
      return ragConfig.getFallbackMessage(detectedLanguage);
    }
    return topResult.document.content.trim();
  }
}

export const answerGeneratorService = new AnswerGeneratorService();
