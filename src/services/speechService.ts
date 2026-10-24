export class SpeechService {
  private isCurrentlyListening: boolean = false;
  private onResultCallback: ((text: string) => void) | null = null;
  private timer: any = null;

  public get isListening(): boolean {
    return this.isCurrentlyListening;
  }

  public async initialize(): Promise<boolean> {
    try {
      console.log('Speech service initialized.');
      return true;
    } catch (e) {
      console.error('Speech initialization error:', e);
      return false;
    }
  }

  public async startListening(onResult: (text: string) => void): Promise<void> {
    this.onResultCallback = onResult;
    this.isCurrentlyListening = true;
    this.onResultCallback('');
    console.log('Speech recognition started listening...');
  }

  public async stopListening(): Promise<void> {
    if (this.timer) {
      clearTimeout(this.timer);
      this.timer = null;
    }
    this.isCurrentlyListening = false;
    console.log('Speech recognition stopped listening.');
  }

  public async cancelListening(): Promise<void> {
    await this.stopListening();
  }
}

export const speechService = new SpeechService();
