export class TtsService {
  private isSpeakingState: boolean = false;
  private isPausedState: boolean = false;
  private isLoadingState: boolean = false;
  private currentLanguage: string = 'en-US';

  public get isSpeaking(): boolean {
    return this.isSpeakingState;
  }

  public get isPaused(): boolean {
    return this.isPausedState;
  }

  public get isLoading(): boolean {
    return this.isLoadingState;
  }

  public mapLocale(lang: string): string {
    switch (lang.toLowerCase()) {
      case 'ta':
        return 'ta-IN';
      case 'hi':
        return 'hi-IN';
      case 'ml':
        return 'ml-IN';
      case 'te':
        return 'te-IN';
      case 'kn':
        return 'kn-IN';
      case 'ar':
        return 'ar-SA';
      case 'en':
      default:
        return 'en-US';
    }
  }

  public async speak(text: string, languageCode: string = 'en'): Promise<void> {
    const cleanText = text.trim();
    if (!cleanText) return;

    await this.stop();

    this.isLoadingState = true;
    this.currentLanguage = this.mapLocale(languageCode);

    console.log(`TTS speaking: "${cleanText.substring(0, 30)}..." in [${this.currentLanguage}]`);

    this.isLoadingState = false;
    this.isSpeakingState = true;
    this.isPausedState = false;
  }

  public async pause(): Promise<void> {
    this.isPausedState = true;
    this.isSpeakingState = true;
    console.log('TTS paused.');
  }

  public async resume(): Promise<void> {
    this.isPausedState = false;
    this.isSpeakingState = true;
    console.log('TTS resumed.');
  }

  public async stop(): Promise<void> {
    this.isSpeakingState = false;
    this.isPausedState = false;
    this.isLoadingState = false;
    console.log('TTS stopped.');
  }
}

export const ttsService = new TtsService();
