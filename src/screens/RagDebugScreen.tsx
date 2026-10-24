import React, { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  ScrollView,
  ActivityIndicator,
} from 'react-native';
import { ragService } from '../services/ragService';
import { languageDetectionService } from '../services/languageDetectionService';
import { answerGeneratorService } from '../services/answerGeneratorService';
import { localLLMService } from '../services/localLLMService';
import { RAGResult } from '../models/KnowledgeDocument';
import { AppColors } from '../utils/theme';

export const RagDebugScreen = ({ navigation }: any) => {
  const [query, setQuery] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [detectedLanguage, setDetectedLanguage] = useState('');
  const [results, setResults] = useState<RAGResult[]>([]);
  const [generatedAnswer, setGeneratedAnswer] = useState('');
  const [sources, setSources] = useState<string[]>([]);
  const [retrievalTimeMs, setRetrievalTimeMs] = useState<number>(0);
  const [inferenceTimeMs, setInferenceTimeMs] = useState<number>(0);

  const handleRunTest = async () => {
    const text = query.trim();
    if (!text) return;

    setIsLoading(true);
    setDetectedLanguage('');
    setResults([]);
    setGeneratedAnswer('');
    setSources([]);

    try {
      const startTime = Date.now();
      const lang = languageDetectionService.detectLanguage(text);
      const searchRes = await ragService.search(text, lang);
      const retTime = Date.now() - startTime;
      setRetrievalTimeMs(retTime);

      const groundedOutput = await answerGeneratorService.generateGroundedAnswer({
        query: text,
        searchResults: searchRes,
        detectedLanguage: lang,
      });

      setDetectedLanguage(lang);
      setResults(searchRes);
      setGeneratedAnswer(groundedOutput.answer);
      setSources(groundedOutput.sources);
      setInferenceTimeMs(groundedOutput.inferenceResult?.inferenceTimeMs || 0);
    } catch (e: any) {
      console.error(e);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <ScrollView contentContainerStyle={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => navigation.goBack()} style={styles.backBtn}>
          <Text style={styles.backText}>❮ Back</Text>
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Local RAG & LLM Debug</Text>
        <View style={{ width: 40 }} />
      </View>

      {/* STATUS BANNER */}
      <View style={styles.statusBanner}>
        <Text style={styles.statusIcon}>🧠</Text>
        <View style={{ flex: 1 }}>
          <Text style={styles.statusText}>
            Local LLM: {localLLMService.getModelName()}
          </Text>
          <Text style={styles.statusSubtext}>
            Status: {localLLMService.getStatus().toUpperCase()} • 100% Offline
          </Text>
        </View>
      </View>

      {/* INPUT FIELD */}
      <View style={styles.inputWrapper}>
        <TextInput
          style={styles.input}
          value={query}
          onChangeText={setQuery}
          placeholder="Enter test query (e.g., What is MultiVoice Assist?)"
          placeholderTextColor="rgba(255,255,255,0.38)"
        />
        <TouchableOpacity style={styles.searchBtn} onPress={handleRunTest}>
          <Text style={{ fontSize: 20 }}>🔍</Text>
        </TouchableOpacity>
      </View>

      <TouchableOpacity
        style={styles.executeBtn}
        onPress={handleRunTest}
        disabled={isLoading}
      >
        <Text style={styles.executeBtnText}>📊 Execute Local RAG + LLM Test</Text>
      </TouchableOpacity>

      {isLoading ? (
        <ActivityIndicator size="large" color={AppColors.purple} style={{ marginTop: 25 }} />
      ) : (
        detectedLanguage !== '' && (
          <View style={styles.resultsBox}>
            {/* METRICS ROW */}
            <View style={styles.metricsRow}>
              <Text style={styles.metricBadge}>
                Lang: <Text style={{ color: '#FFD700' }}>{detectedLanguage}</Text>
              </Text>
              <Text style={styles.metricBadge}>
                Retrieval: <Text style={{ color: '#4ADE80' }}>{retrievalTimeMs} ms</Text>
              </Text>
              <Text style={styles.metricBadge}>
                Inference: <Text style={{ color: '#60A5FA' }}>{inferenceTimeMs} ms</Text>
              </Text>
            </View>

            <Text style={styles.sectionTitle}>
              Retrieved Context Chunks (Ranked):
            </Text>

            {results.length === 0 ? (
              <Text style={styles.noResults}>
                No relevant documents found above threshold (0.18).
              </Text>
            ) : (
              results.map((res, idx) => (
                <View key={res.document.id || idx} style={styles.resultCard}>
                  <View style={styles.resultHeader}>
                    <Text style={styles.docTitle}>
                      #{idx + 1} {res.document.title}
                    </Text>
                    <View style={styles.scoreBadge}>
                      <Text style={styles.scoreText}>
                        Score: {(res.score * 100).toFixed(1)}%
                      </Text>
                    </View>
                  </View>
                  <Text style={styles.docContent}>{res.document.content}</Text>
                </View>
              ))
            )}

            <Text style={styles.sectionTitle}>Final Grounded Answer:</Text>
            <View style={styles.answerBox}>
              <Text style={styles.answerText}>{generatedAnswer}</Text>
            </View>

            {sources.length > 0 && (
              <View style={styles.sourcesBox}>
                <Text style={styles.sourcesTitle}>Sources Used:</Text>
                {sources.map((src, i) => (
                  <Text key={i} style={styles.sourceItem}>
                    • {src}
                  </Text>
                ))}
              </View>
            )}
          </View>
        )
      )}
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flexGrow: 1,
    backgroundColor: AppColors.chatBackground,
    padding: 16,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 20,
  },
  backBtn: {
    padding: 4,
  },
  backText: {
    color: AppColors.white,
    fontSize: 16,
  },
  headerTitle: {
    color: AppColors.white,
    fontSize: 18,
    fontWeight: 'bold',
  },
  statusBanner: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: AppColors.cardBackground,
    borderRadius: 12,
    padding: 12,
    borderWidth: 1,
    borderColor: 'rgba(59, 130, 246, 0.5)',
    marginBottom: 16,
  },
  statusIcon: {
    fontSize: 24,
    marginRight: 10,
  },
  statusText: {
    color: AppColors.white,
    fontWeight: 'bold',
    fontSize: 14,
  },
  statusSubtext: {
    color: 'rgba(255,255,255,0.6)',
    fontSize: 12,
    marginTop: 2,
  },
  inputWrapper: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: AppColors.inputBackground,
    borderRadius: 12,
    paddingHorizontal: 15,
    marginBottom: 16,
  },
  input: {
    flex: 1,
    height: 48,
    color: AppColors.white,
    fontSize: 15,
  },
  searchBtn: {
    padding: 8,
  },
  executeBtn: {
    height: 48,
    backgroundColor: AppColors.primaryPurple,
    borderRadius: 12,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 20,
  },
  executeBtnText: {
    color: AppColors.white,
    fontSize: 16,
    fontWeight: 'bold',
  },
  resultsBox: {
    marginTop: 5,
  },
  metricsRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 16,
    backgroundColor: AppColors.inputBackground,
    padding: 10,
    borderRadius: 10,
  },
  metricBadge: {
    color: AppColors.white,
    fontSize: 13,
    fontWeight: 'bold',
  },
  sectionTitle: {
    color: AppColors.white,
    fontSize: 16,
    fontWeight: 'bold',
    marginTop: 10,
    marginBottom: 8,
  },
  noResults: {
    color: 'rgba(255,255,255,0.54)',
    marginVertical: 8,
  },
  resultCard: {
    backgroundColor: AppColors.inputBackground,
    borderRadius: 12,
    padding: 12,
    marginBottom: 10,
  },
  resultHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 6,
  },
  docTitle: {
    color: AppColors.white,
    fontWeight: 'bold',
    fontSize: 14,
    flex: 1,
  },
  scoreBadge: {
    backgroundColor: 'rgba(139, 92, 246, 0.3)',
    paddingHorizontal: 8,
    paddingVertical: 2,
    borderRadius: 6,
  },
  scoreText: {
    color: AppColors.lightPurple,
    fontSize: 12,
  },
  docContent: {
    color: 'rgba(255,255,255,0.7)',
    fontSize: 13,
  },
  answerBox: {
    backgroundColor: AppColors.cardBackground,
    borderRadius: 12,
    padding: 14,
    borderWidth: 1,
    borderColor: AppColors.primaryPurple,
    marginTop: 8,
  },
  answerText: {
    color: AppColors.white,
    fontSize: 15,
    lineHeight: 22,
  },
  sourcesBox: {
    marginTop: 12,
    padding: 10,
    backgroundColor: 'rgba(255,255,255,0.05)',
    borderRadius: 8,
  },
  sourcesTitle: {
    color: AppColors.grey,
    fontSize: 12,
    fontWeight: 'bold',
    marginBottom: 4,
  },
  sourceItem: {
    color: AppColors.lightPurple,
    fontSize: 12,
  },
});
