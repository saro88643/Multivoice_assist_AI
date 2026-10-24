import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  ActivityIndicator,
} from 'react-native';
import { useChat } from '../providers/ChatContext';
import { useHistory } from '../providers/HistoryContext';
import { useSpeech } from '../providers/SpeechContext';
import { VoiceButton } from '../components/VoiceButton';
import { ttsService } from '../services/ttsService';
import { AppColors } from '../utils/theme';

export const VoiceChatScreen = ({ navigation }: any) => {
  const { sendMessage, lastDetectedLanguage } = useChat();
  const { saveChat } = useHistory();
  const { isListening, recognizedText, startListening, stopListening } = useSpeech();

  const [spokenText, setSpokenText] = useState('');
  const [aiResponse, setAiResponse] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  const handlePressIn = async () => {
    setSpokenText('');
    setAiResponse('');
    await startListening();
  };

  const handlePressOut = async () => {
    await stopListening();
    const query = recognizedText.trim();
    setSpokenText(query);

    if (query) {
      setIsLoading(true);
      await sendMessage(query, saveChat);
      setIsLoading(false);
    }
  };

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => navigation.goBack()} style={styles.backBtn}>
          <Text style={styles.backText}>❮ Back</Text>
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Voice Chat (Local RAG)</Text>
      </View>

      <ScrollView contentContainerStyle={styles.content}>
        {/* YOU SAID CARD */}
        <View style={styles.card}>
          <View style={styles.cardHeader}>
            <Text style={styles.cardIcon}>🎙️</Text>
            <Text style={styles.cardTitle}>You Said</Text>
          </View>
          <View style={styles.divider} />
          <Text style={styles.cardBody}>
            {spokenText || recognizedText || 'No speech detected yet.'}
          </Text>
        </View>

        {/* RAG REPLY CARD */}
        <View style={styles.card}>
          <View style={styles.cardHeader}>
            <Text style={styles.cardIcon}>🤖</Text>
            <Text style={styles.cardTitle}>RAG Reply</Text>
          </View>
          <View style={styles.divider} />
          <Text style={styles.cardBody}>
            {aiResponse || 'Awaiting voice input...'}
          </Text>
        </View>

        {isLoading && (
          <View style={styles.loadingBox}>
            <ActivityIndicator size="large" color={AppColors.purple} />
            <Text style={styles.loadingText}>Searching local knowledge base...</Text>
          </View>
        )}
      </ScrollView>

      {/* MICROPHONE BUTTON */}
      <View style={styles.voiceBtnContainer}>
        <VoiceButton
          isListening={isListening}
          onPressIn={handlePressIn}
          onPressOut={handlePressOut}
        />
        <Text style={styles.voiceHint}>
          {isListening
            ? 'Listening... Release to search local knowledge base'
            : isLoading
            ? 'Retrieving answer...'
            : 'Press and hold microphone to speak'}
        </Text>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: AppColors.background,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 16,
    borderBottomWidth: 1,
    borderBottomColor: 'rgba(255,255,255,0.1)',
  },
  backBtn: {
    marginRight: 15,
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
  content: {
    padding: 16,
  },
  card: {
    backgroundColor: AppColors.surface,
    borderRadius: 18,
    padding: 18,
    marginBottom: 15,
    elevation: 4,
  },
  cardHeader: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  cardIcon: {
    fontSize: 24,
    marginRight: 10,
  },
  cardTitle: {
    color: AppColors.white,
    fontSize: 18,
    fontWeight: 'bold',
  },
  divider: {
    height: 1,
    backgroundColor: 'rgba(255,255,255,0.12)',
    marginVertical: 12,
  },
  cardBody: {
    color: AppColors.grey,
    fontSize: 16,
    lineHeight: 22,
  },
  loadingBox: {
    alignItems: 'center',
    marginTop: 15,
  },
  loadingText: {
    color: AppColors.lightPurple,
    fontSize: 15,
    marginTop: 10,
  },
  voiceBtnContainer: {
    alignItems: 'center',
    paddingBottom: 30,
  },
  voiceHint: {
    color: AppColors.lightGrey,
    fontSize: 14,
    marginTop: 15,
    textAlign: 'center',
  },
});
