import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ScrollView,
  Alert,
} from 'react-native';
import { AppColors } from '../utils/theme';

export const VoiceSettingsScreen = ({ navigation }: any) => {
  const [speechRate, setSpeechRate] = useState('Normal (1.0x)');
  const [pitch, setPitch] = useState('Normal (1.0)');

  const handleRateChange = () => {
    Alert.alert('Speech Rate', 'Select preferred TTS speech rate', [
      { text: 'Slow (0.75x)', onPress: () => setSpeechRate('Slow (0.75x)') },
      { text: 'Normal (1.0x)', onPress: () => setSpeechRate('Normal (1.0x)') },
      { text: 'Fast (1.25x)', onPress: () => setSpeechRate('Fast (1.25x)') },
    ]);
  };

  const handlePitchChange = () => {
    Alert.alert('Speech Pitch', 'Select preferred TTS voice pitch', [
      { text: 'Low (0.8)', onPress: () => setPitch('Low (0.8)') },
      { text: 'Normal (1.0)', onPress: () => setPitch('Normal (1.0)') },
      { text: 'High (1.2)', onPress: () => setPitch('High (1.2)') },
    ]);
  };

  return (
    <ScrollView contentContainerStyle={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => navigation.goBack()} style={styles.backBtn}>
          <Text style={styles.backText}>❮ Back</Text>
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Voice Settings</Text>
        <View style={{ width: 40 }} />
      </View>

      <View style={styles.card}>
        <TouchableOpacity style={styles.settingRow} onPress={handleRateChange}>
          <View>
            <Text style={styles.settingTitle}>Speech Rate</Text>
            <Text style={styles.settingVal}>{speechRate}</Text>
          </View>
          <Text style={styles.arrow}>❯</Text>
        </TouchableOpacity>

        <View style={styles.divider} />

        <TouchableOpacity style={styles.settingRow} onPress={handlePitchChange}>
          <View>
            <Text style={styles.settingTitle}>Voice Pitch</Text>
            <Text style={styles.settingVal}>{pitch}</Text>
          </View>
          <Text style={styles.arrow}>❯</Text>
        </TouchableOpacity>
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flexGrow: 1,
    backgroundColor: AppColors.background,
    padding: 20,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 30,
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
    fontSize: 20,
    fontWeight: 'bold',
  },
  card: {
    backgroundColor: AppColors.surface,
    borderRadius: 15,
    padding: 16,
  },
  settingRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingVertical: 10,
  },
  settingTitle: {
    color: AppColors.white,
    fontSize: 16,
    fontWeight: 'bold',
  },
  settingVal: {
    color: 'rgba(255,255,255,0.6)',
    fontSize: 14,
    marginTop: 4,
  },
  divider: {
    height: 1,
    backgroundColor: 'rgba(255,255,255,0.1)',
    marginVertical: 10,
  },
  arrow: {
    color: 'rgba(255,255,255,0.5)',
    fontSize: 16,
  },
});
