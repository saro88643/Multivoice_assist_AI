import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { Message } from '../models/Message';
import { AppColors } from '../utils/theme';

interface ChatBubbleProps {
  message: Message;
  isPlaying?: boolean;
  isPaused?: boolean;
  isLoadingTts?: boolean;
  onPlayTts?: (text: string) => void;
  onPauseTts?: () => void;
  onResumeTts?: () => void;
  onStopTts?: () => void;
}

export const ChatBubble: React.FC<ChatBubbleProps> = ({
  message,
  isPlaying,
  isPaused,
  isLoadingTts,
  onPlayTts,
  onPauseTts,
  onResumeTts,
  onStopTts,
}) => {
  const cleanText = (text: string) => {
    return text
      .replace(/^\s*#{1,6}\s*/gm, '')
      .replace(/\*\*/g, '')
      .replace(/```/g, '')
      .replace(/`/g, '')
      .trim();
  };

  const textContent = cleanText(message.text);

  if (!textContent) return null;

  if (message.isUser) {
    return (
      <View style={styles.userContainer}>
        <View style={styles.userBubble}>
          <Text style={styles.userText}>{textContent}</Text>
        </View>
      </View>
    );
  }

  return (
    <View style={styles.aiRow}>
      <View style={styles.robotAvatar}>
        <Text style={styles.robotIcon}>🤖</Text>
      </View>

      <View style={styles.aiBubble}>
        <Text style={styles.aiText}>{textContent}</Text>

        <View style={styles.controlsRow}>
          {isLoadingTts ? (
            <Text style={styles.loadingText}>⏳ Loading voice...</Text>
          ) : isPaused ? (
            <View style={styles.playPauseGroup}>
              <TouchableOpacity onPress={onResumeTts} style={styles.iconBtn}>
                <Text style={styles.speakerIcon}>▶️</Text>
              </TouchableOpacity>
              <TouchableOpacity onPress={onStopTts} style={styles.iconBtn}>
                <Text style={styles.speakerIcon}>⏹️</Text>
              </TouchableOpacity>
            </View>
          ) : isPlaying ? (
            <View style={styles.playPauseGroup}>
              <TouchableOpacity onPress={onPauseTts} style={styles.iconBtn}>
                <Text style={styles.speakerIcon}>⏸️</Text>
              </TouchableOpacity>
              <TouchableOpacity onPress={onStopTts} style={styles.iconBtn}>
                <Text style={styles.speakerIcon}>⏹️</Text>
              </TouchableOpacity>
            </View>
          ) : (
            <TouchableOpacity
              onPress={() => onPlayTts && onPlayTts(textContent)}
              style={styles.iconBtn}
            >
              <Text style={styles.speakerIcon}>🔊</Text>
            </TouchableOpacity>
          )}
        </View>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  userContainer: {
    alignSelf: 'flex-end',
    maxWidth: '80%',
    marginBottom: 14,
    marginLeft: 50,
  },
  userBubble: {
    backgroundColor: AppColors.userBubble,
    paddingHorizontal: 18,
    paddingVertical: 14,
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
    borderBottomLeftRadius: 20,
    borderBottomRightRadius: 5,
  },
  userText: {
    color: AppColors.white,
    fontSize: 16,
    lineHeight: 22,
  },
  aiRow: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    marginBottom: 18,
  },
  robotAvatar: {
    width: 42,
    height: 42,
    borderRadius: 21,
    backgroundColor: AppColors.robotGreen,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 10,
  },
  robotIcon: {
    fontSize: 22,
  },
  aiBubble: {
    flex: 1,
    backgroundColor: AppColors.aiBubble,
    paddingHorizontal: 16,
    paddingTop: 15,
    paddingBottom: 8,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: '#2B3950',
  },
  aiText: {
    color: AppColors.white,
    fontSize: 16,
    lineHeight: 24,
  },
  controlsRow: {
    marginTop: 8,
    flexDirection: 'row',
    alignItems: 'center',
  },
  playPauseGroup: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  iconBtn: {
    padding: 4,
    marginRight: 8,
  },
  speakerIcon: {
    fontSize: 22,
  },
  loadingText: {
    color: AppColors.primaryPurple,
    fontSize: 12,
  },
});
