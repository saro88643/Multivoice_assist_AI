import React, { useState, useRef } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Alert,
} from 'react-native';
import { useChat } from '../providers/ChatContext';
import { useHistory } from '../providers/HistoryContext';
import { useSpeech } from '../providers/SpeechContext';
import { useProfile } from '../providers/ProfileContext';
import { ChatBubble } from '../components/ChatBubble';
import { MessageInput } from '../components/MessageInput';
import { ProfileAvatar } from '../components/ProfileAvatar';
import { ttsService } from '../services/ttsService';
import { AppColors } from '../utils/theme';
import { AppConstants } from '../utils/constants';

export const ChatScreen = ({ navigation }: any) => {
  const { messages, isLoading, sendMessage, lastDetectedLanguage } = useChat();
  const { saveChat } = useHistory();
  const { isListening, recognizedText, startListening, stopListening, clearText } = useSpeech();
  const { profileImagePath } = useProfile();

  const [inputText, setInputText] = useState('');
  const [playingText, setPlayingText] = useState<string | null>(null);
  const scrollViewRef = useRef<ScrollView>(null);

  const handleSend = async () => {
    const text = inputText.trim();
    if (!text || isLoading) return;

    setInputText('');
    clearText();
    await ttsService.stop();
    setPlayingText(null);

    await sendMessage(text, saveChat);

    setTimeout(() => {
      scrollViewRef.current?.scrollToEnd({ animated: true });
    }, 200);
  };

  const handleToggleMic = async () => {
    if (isListening) {
      await stopListening();
      if (recognizedText) {
        setInputText(recognizedText);
      }
    } else {
      setInputText('');
      clearText();
      await startListening();
    }
  };

  const handlePlayTts = async (text: string) => {
    setPlayingText(text);
    await ttsService.speak(text, lastDetectedLanguage);
  };

  const handlePauseTts = async () => {
    await ttsService.pause();
  };

  const handleResumeTts = async () => {
    await ttsService.resume();
  };

  const handleStopTts = async () => {
    await ttsService.stop();
    setPlayingText(null);
  };

  return (
    <View style={styles.container}>
      {/* HEADER */}
      <View style={styles.header}>
        <TouchableOpacity onPress={() => navigation.goBack()} style={styles.backBtn}>
          <Text style={styles.backIcon}>❮</Text>
        </TouchableOpacity>

        <View style={styles.headerCenter}>
          <Text style={styles.headerTitle}>{AppConstants.appName}</Text>
          <View style={styles.statusRow}>
            <View style={styles.statusDot} />
            <Text style={styles.statusText}>Local RAG Ready</Text>
          </View>
        </View>

        <View style={styles.headerRight}>
          <TouchableOpacity
            onPress={() => navigation.navigate('RagDebug')}
            style={styles.debugBtn}
          >
            <Text style={{ fontSize: 20 }}>🐛</Text>
          </TouchableOpacity>
          <ProfileAvatar imagePath={profileImagePath} radius={18} />
        </View>
      </View>

      {/* CHAT MESSAGES */}
      <ScrollView
        ref={scrollViewRef}
        contentContainerStyle={styles.scrollContent}
        onContentSizeChange={() => scrollViewRef.current?.scrollToEnd({ animated: true })}
      >
        {messages.length === 0 ? (
          <View style={styles.emptyContainer}>
            <View style={styles.emptyRobotCircle}>
              <Text style={{ fontSize: 48 }}>🤖</Text>
            </View>
            <Text style={styles.emptyTitle}>Offline Local RAG Assistant</Text>
            <Text style={styles.emptySubtitle}>
              Ask any question about MultiVoice Assist in your preferred language.
            </Text>
          </View>
        ) : (
          messages.map((msg, index) => (
            <ChatBubble
              key={msg.id || index}
              message={msg}
              isPlaying={playingText === msg.text && ttsService.isSpeaking}
              isPaused={playingText === msg.text && ttsService.isPaused}
              isLoadingTts={playingText === msg.text && ttsService.isLoading}
              onPlayTts={handlePlayTts}
              onPauseTts={handlePauseTts}
              onResumeTts={handleResumeTts}
              onStopTts={handleStopTts}
            />
          ))
        )}
      </ScrollView>

      {/* INPUT AREA */}
      <MessageInput
        value={isListening ? recognizedText || inputText : inputText}
        onChangeText={setInputText}
        onSend={handleSend}
        onToggleMic={handleToggleMic}
        isListening={isListening}
        isSending={isLoading}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: AppColors.chatBackground,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingTop: 15,
    paddingBottom: 10,
    backgroundColor: AppColors.chatBackground,
  },
  backBtn: {
    padding: 8,
  },
  backIcon: {
    color: AppColors.white,
    fontSize: 20,
  },
  headerCenter: {
    alignItems: 'center',
  },
  headerTitle: {
    color: AppColors.white,
    fontSize: 18,
    fontWeight: 'bold',
  },
  statusRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 2,
  },
  statusDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: AppColors.success,
    marginRight: 4,
  },
  statusText: {
    color: AppColors.success,
    fontSize: 11,
  },
  headerRight: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  debugBtn: {
    marginRight: 12,
  },
  scrollContent: {
    padding: 16,
    paddingBottom: 20,
  },
  emptyContainer: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    marginTop: 80,
    paddingHorizontal: 30,
  },
  emptyRobotCircle: {
    width: 90,
    height: 90,
    borderRadius: 45,
    backgroundColor: AppColors.robotGreen,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 22,
  },
  emptyTitle: {
    color: AppColors.white,
    fontSize: 22,
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 12,
  },
  emptySubtitle: {
    color: 'rgba(255,255,255,0.6)',
    fontSize: 15,
    textAlign: 'center',
    lineHeight: 22,
  },
});
