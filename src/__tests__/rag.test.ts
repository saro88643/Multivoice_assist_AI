import { languageDetectionService } from '../services/languageDetectionService';
import { ragService } from '../services/ragService';
import { answerGeneratorService } from '../services/answerGeneratorService';

describe('Local RAG & Multilingual Engine Tests', () => {
  beforeAll(async () => {
    await ragService.initialize();
  });

  test('Language Detection - English', () => {
    const lang = languageDetectionService.detectLanguage('What is MultiVoice Assist?');
    expect(lang).toBe('en');
  });

  test('Language Detection - Tamil', () => {
    const lang = languageDetectionService.detectLanguage('MultiVoice Assist என்றால் என்ன?');
    expect(lang).toBe('ta');
  });

  test('Language Detection - Hindi', () => {
    const lang = languageDetectionService.detectLanguage('मल्टीवॉइस असिस्ट क्या है?');
    expect(lang).toBe('hi');
  });

  test('Language Detection - Malayalam', () => {
    const lang = languageDetectionService.detectLanguage('MultiVoice Assist എന്താണ്?');
    expect(lang).toBe('ml');
  });

  test('Language Detection - Telugu', () => {
    const lang = languageDetectionService.detectLanguage('MultiVoice Assist అంటే ఏమిటి?');
    expect(lang).toBe('te');
  });

  test('Language Detection - Kannada', () => {
    const lang = languageDetectionService.detectLanguage('MultiVoice Assist ಎಂದರೇನು?');
    expect(lang).toBe('kn');
  });

  test('Language Detection - Arabic', () => {
    const lang = languageDetectionService.detectLanguage('ما هو MultiVoice Assist؟');
    expect(lang).toBe('ar');
  });

  test('RAG Query Search - English Overview', async () => {
    const results = await ragService.search('What is MultiVoice Assist?', 'en');
    expect(results.length).toBeGreaterThan(0);
    expect(results[0].score).toBeGreaterThanOrEqual(0.18);

    const answer = answerGeneratorService.generateAnswer({
      query: 'What is MultiVoice Assist?',
      searchResults: results,
      detectedLanguage: 'en',
    });
    expect(answer).toContain('MultiVoice Assist is a lightweight');
  });

  test('RAG Query Search - Tamil Overview', async () => {
    const results = await ragService.search('MultiVoice Assist என்றால் என்ன?', 'ta');
    expect(results.length).toBeGreaterThan(0);

    const answer = answerGeneratorService.generateAnswer({
      query: 'MultiVoice Assist என்றால் என்ன?',
      searchResults: results,
      detectedLanguage: 'ta',
    });
    expect(answer).toContain('உள்ளூர் RAG');
  });

  test('Unknown Question Handling (No Hallucination)', async () => {
    const results = await ragService.search('What is the distance from the Earth to Mars in miles?', 'en');
    const answer = answerGeneratorService.generateAnswer({
      query: 'What is the distance from the Earth to Mars in miles?',
      searchResults: results,
      detectedLanguage: 'en',
    });
    expect(answer).toContain("couldn't find this information");
  });
});
