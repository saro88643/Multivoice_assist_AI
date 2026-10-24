export class LanguageDetectionService {
  /**
   * Detects language code ('en', 'ta', 'hi', 'ml', 'te', 'kn', 'ar') from text script using Unicode range analysis.
   */
  detectLanguage(text: string): string {
    if (!text || text.trim().length === 0) {
      return 'en';
    }

    let taCount = 0;
    let hiCount = 0;
    let mlCount = 0;
    let teCount = 0;
    let knCount = 0;
    let arCount = 0;
    let totalLetters = 0;

    for (let i = 0; i < text.length; i++) {
      const code = text.charCodeAt(i);

      // Tamil: U+0B80 - U+0BFF
      if (code >= 0x0b80 && code <= 0x0bff) {
        taCount++;
        totalLetters++;
      }
      // Hindi / Devanagari: U+0900 - U+097F
      else if (code >= 0x0900 && code <= 0x097f) {
        hiCount++;
        totalLetters++;
      }
      // Malayalam: U+0D00 - U+0D7F
      else if (code >= 0x0d00 && code <= 0x0d7f) {
        mlCount++;
        totalLetters++;
      }
      // Telugu: U+0C00 - U+0C7F
      else if (code >= 0x0c00 && code <= 0x0c7f) {
        teCount++;
        totalLetters++;
      }
      // Kannada: U+0C80 - U+0CFF
      else if (code >= 0x0c80 && code <= 0x0cff) {
        knCount++;
        totalLetters++;
      }
      // Arabic: U+0600 - U+06FF
      else if (code >= 0x0600 && code <= 0x06ff) {
        arCount++;
        totalLetters++;
      }
    }

    if (totalLetters === 0) {
      return 'en';
    }

    if (
      taCount > hiCount &&
      taCount > mlCount &&
      taCount > teCount &&
      taCount > knCount &&
      taCount > arCount
    ) {
      return 'ta';
    }
    if (
      hiCount > taCount &&
      hiCount > mlCount &&
      hiCount > teCount &&
      hiCount > knCount &&
      hiCount > arCount
    ) {
      return 'hi';
    }
    if (
      mlCount > taCount &&
      mlCount > hiCount &&
      mlCount > teCount &&
      mlCount > knCount &&
      mlCount > arCount
    ) {
      return 'ml';
    }
    if (
      teCount > taCount &&
      teCount > hiCount &&
      teCount > mlCount &&
      teCount > knCount &&
      teCount > arCount
    ) {
      return 'te';
    }
    if (
      knCount > taCount &&
      knCount > hiCount &&
      knCount > mlCount &&
      knCount > teCount &&
      knCount > arCount
    ) {
      return 'kn';
    }
    if (
      arCount > taCount &&
      arCount > hiCount &&
      arCount > mlCount &&
      arCount > teCount &&
      arCount > knCount
    ) {
      return 'ar';
    }

    return 'en';
  }
}

export const languageDetectionService = new LanguageDetectionService();
