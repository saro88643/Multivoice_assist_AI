import React from 'react';
import {
  View,
  TextInput,
  TouchableOpacity,
  Text,
  StyleSheet,
  ActivityIndicator,
} from 'react-native';
import { AppColors } from '../utils/theme';

interface MessageInputProps {
  value: string;
  onChangeText: (text: string) => void;
  onSend: () => void;
  onToggleMic: () => void;
  isListening: boolean;
  isSending: boolean;
}

export const MessageInput: React.FC<MessageInputProps> = ({
  value,
  onChangeText,
  onSend,
  onToggleMic,
  isListening,
  isSending,
}) => {
  const hasText = value.trim().length > 0;

  return (
    <View style={styles.container}>
      <View
        style={[
          styles.inputWrapper,
          isListening && styles.inputWrapperListening,
        ]}
      >
        <TextInput
          style={styles.textInput}
          value={value}
          onChangeText={onChangeText}
          placeholder={isListening ? 'Listening...' : 'Type your message...'}
          placeholderTextColor="rgba(255,255,255,0.38)"
          multiline
        />
      </View>

      <TouchableOpacity
        style={styles.micBtn}
        onPress={onToggleMic}
        disabled={isSending}
      >
        <Text style={styles.iconText}>{isListening ? '🛑' : '🎙️'}</Text>
      </TouchableOpacity>

      <TouchableOpacity
        style={styles.sendBtn}
        onPress={onSend}
        disabled={!hasText || isSending}
      >
        {isSending ? (
          <ActivityIndicator size="small" color={AppColors.primaryPurple} />
        ) : (
          <Text
            style={[
              styles.iconText,
              !hasText && styles.disabledIcon,
            ]}
          >
            ➔
          </Text>
        )}
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 12,
    paddingVertical: 10,
    backgroundColor: AppColors.inputBackground,
    borderTopWidth: 1,
    borderTopColor: '#29374E',
  },
  inputWrapper: {
    flex: 1,
    backgroundColor: AppColors.chatBackground,
    borderRadius: 25,
    borderWidth: 1,
    borderColor: AppColors.primaryPurple,
    paddingHorizontal: 18,
    paddingVertical: 4,
    minHeight: 46,
    justifyContent: 'center',
  },
  inputWrapperListening: {
    borderColor: AppColors.error,
  },
  textInput: {
    color: AppColors.white,
    fontSize: 16,
  },
  micBtn: {
    padding: 8,
    marginLeft: 4,
  },
  sendBtn: {
    padding: 8,
    marginLeft: 2,
  },
  iconText: {
    fontSize: 24,
    color: AppColors.primaryPurple,
  },
  disabledIcon: {
    opacity: 0.3,
  },
});
