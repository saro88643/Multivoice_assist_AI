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
   * Generates answer using Hugging Face hosted model with smart context routing and offline fallback.
   */
  public async generateGroundedAnswer(params: {
    query: string;
    searchResults: RAGResult[];
    detectedLanguage: string;
  }): Promise<GroundedAnswerOutput> {
    const { query, searchResults, detectedLanguage } = params;

    // Filter results matching minimum relevance score (0.25)
    const validResults = searchResults.filter((res) => res.score >= 0.25);
    const topResult = validResults.length > 0 ? validResults[0] : null;
    const topScore = topResult ? topResult.score : 0.0;

    // Only supply context if there is a high-confidence match for project/college info
    const isProjectSpecific = topScore >= 0.35;
    const sources = isProjectSpecific ? Array.from(new Set(validResults.map((res) => res.document.title))) : [];
    const contextText = isProjectSpecific
      ? validResults.map((res) => `${res.document.title}: ${res.document.content}`).join('\n\n')
      : '';

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
      console.warn('[AnswerGeneratorService] Hugging Face backend notice:', e);
    }

    // 2. High-Confidence RAG Match Fallback
    if (topResult && isProjectSpecific) {
      return {
        answer: topResult.document.content.trim(),
        sources: [topResult.document.title],
        topScore,
        modelUsed: 'Local RAG Engine',
      };
    }

    // 3. General Knowledge On-Device Response Engine
    const localInference = await localLLMService.generateGroundedResponse({
      systemPrompt: ragConfig.systemPrompt,
      userQuery: query,
      context: contextText,
      language: detectedLanguage,
    });

    return {
      answer: localInference.text,
      sources: [],
      topScore,
      modelUsed: 'Local Intelligence Engine',
      inferenceResult: localInference,
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
