import { aiConfig } from '../utils/aiConfig';

export interface HuggingFaceChatResponse {
  response: string;
  model: string;
  sources?: string[];
  success: boolean;
  error?: string;
}

export class HuggingFaceService {
  private isProcessing: boolean = false;

  public getIsProcessing(): boolean {
    return this.isProcessing;
  }

  public async sendMessage(params: {
    message: string;
    language: string;
    context?: string;
    history?: { role: 'user' | 'assistant'; content: string }[];
  }): Promise<HuggingFaceChatResponse> {
    if (this.isProcessing) {
      return {
        response: 'A request is already processing. Please wait.',
        model: aiConfig.hfModelId,
        success: false,
        error: 'Duplicate request blocked',
      };
    }

    this.isProcessing = true;

    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), aiConfig.requestTimeoutMs);

      const response = await fetch(`${aiConfig.backendUrl}/api/chat`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          message: params.message,
          language: params.language,
          context: params.context || '',
          history: params.history || [],
          model_id: aiConfig.hfModelId,
        }),
        signal: controller.signal,
      });

      clearTimeout(timeoutId);

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(
          errorData.message || `Backend returned status HTTP ${response.status}`
        );
      }

      const data = await response.json();

      return {
        response: data.response || 'No response generated.',
        model: data.model || aiConfig.hfModelId,
        sources: data.sources || [],
        success: true,
      };
    } catch (error: any) {
      console.warn('[HuggingFaceService] Backend proxy request notice:', error?.message);

      return {
        response: '',
        model: aiConfig.hfModelId,
        success: false,
        error: error?.message || 'Network error connecting to AI backend service.',
      };
    } finally {
      this.isProcessing = false;
    }
  }
}

export const huggingFaceService = new HuggingFaceService();
