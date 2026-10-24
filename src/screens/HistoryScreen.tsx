import React, { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  ScrollView,
  Alert,
  ActivityIndicator,
} from 'react-native';
import { useHistory } from '../providers/HistoryContext';
import { useProfile } from '../providers/ProfileContext';
import { AppColors } from '../utils/theme';

export const HistoryScreen = ({ navigation }: any) => {
  const { historyList, isLoading, deleteChat, deleteAllChats, loadHistory } = useHistory();
  const { userName } = useProfile();
  const [searchQuery, setSearchQuery] = useState('');

  const filteredHistory = historyList.filter(
    (item) =>
      item.question.toLowerCase().includes(searchQuery.toLowerCase()) ||
      item.answer.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const handleDeleteOne = (id?: number) => {
    if (!id) return;
    Alert.alert('Delete Chat', 'Are you sure you want to delete this chat?', [
      { text: 'Cancel', style: 'cancel' },
      { text: 'Delete', style: 'destructive', onPress: () => deleteChat(id) },
    ]);
  };

  const handleDeleteAll = () => {
    if (historyList.length === 0) return;
    Alert.alert(
      'Delete All Chats',
      'Are you sure you want to delete all chat history?',
      [
        { text: 'Cancel', style: 'cancel' },
        { text: 'Delete All', style: 'destructive', onPress: () => deleteAllChats() },
      ]
    );
  };

  return (
    <View style={styles.container}>
      {/* HEADER */}
      <View style={styles.header}>
        <TouchableOpacity onPress={() => navigation.goBack()} style={styles.backBtn}>
          <Text style={styles.backText}>❮ Back</Text>
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Chat History</Text>
        <TouchableOpacity onPress={handleDeleteAll}>
          <Text style={styles.deleteIcon}>🗑️</Text>
        </TouchableOpacity>
      </View>

      {/* SEARCH BAR */}
      <View style={styles.searchContainer}>
        <TextInput
          style={styles.searchInput}
          value={searchQuery}
          onChangeText={setSearchQuery}
          placeholder="Search History..."
          placeholderTextColor="rgba(255,255,255,0.38)"
        />
        {searchQuery.length > 0 && (
          <TouchableOpacity onPress={() => setSearchQuery('')}>
            <Text style={styles.clearText}>❌</Text>
          </TouchableOpacity>
        )}
      </View>

      {/* CONTENT */}
      {isLoading ? (
        <ActivityIndicator size="large" color={AppColors.purple} style={{ marginTop: 40 }} />
      ) : filteredHistory.length === 0 ? (
        <View style={styles.emptyBox}>
          <Text style={styles.emptyText}>No Chat History</Text>
        </View>
      ) : (
        <ScrollView contentContainerStyle={styles.listContent}>
          {filteredHistory.map((item, idx) => (
            <View key={item.id || idx} style={styles.card}>
              {/* USER ROW */}
              <View style={styles.userHeader}>
                <Text style={styles.userAvatar}>👤</Text>
                <Text style={styles.userName}>{userName || 'User'}</Text>
              </View>
              <Text style={styles.questionText}>{item.question}</Text>

              <View style={styles.divider} />

              {/* AI ROW */}
              <View style={styles.aiHeader}>
                <Text style={styles.aiAvatar}>🤖</Text>
                <Text style={styles.aiName}>AI</Text>
              </View>
              <Text style={styles.answerText}>{item.answer}</Text>

              {/* FOOTER */}
              <View style={styles.cardFooter}>
                <Text style={styles.dateText}>
                  {new Date(item.dateTime).toLocaleString()}
                </Text>
                <TouchableOpacity onPress={() => handleDeleteOne(item.id)}>
                  <Text style={styles.trashBtn}>🗑️</Text>
                </TouchableOpacity>
              </View>
            </View>
          ))}
        </ScrollView>
      )}
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
    justifyContent: 'space-between',
    padding: 16,
    borderBottomWidth: 1,
    borderBottomColor: 'rgba(255,255,255,0.1)',
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
  deleteIcon: {
    fontSize: 22,
  },
  searchContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: AppColors.surface,
    borderRadius: 12,
    margin: 12,
    paddingHorizontal: 15,
  },
  searchInput: {
    flex: 1,
    height: 48,
    color: AppColors.white,
    fontSize: 16,
  },
  clearText: {
    fontSize: 16,
  },
  emptyBox: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  emptyText: {
    color: AppColors.grey,
    fontSize: 18,
  },
  listContent: {
    padding: 12,
  },
  card: {
    backgroundColor: AppColors.surface,
    borderRadius: 15,
    padding: 15,
    marginBottom: 12,
  },
  userHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 6,
  },
  userAvatar: {
    fontSize: 18,
    marginRight: 8,
  },
  userName: {
    color: AppColors.blue,
    fontSize: 16,
    fontWeight: 'bold',
  },
  questionText: {
    color: AppColors.white,
    fontSize: 15,
  },
  divider: {
    height: 1,
    backgroundColor: 'rgba(255,255,255,0.1)',
    marginVertical: 10,
  },
  aiHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 6,
  },
  aiAvatar: {
    fontSize: 18,
    marginRight: 8,
  },
  aiName: {
    color: AppColors.success,
    fontSize: 16,
    fontWeight: 'bold',
  },
  answerText: {
    color: AppColors.grey,
    fontSize: 15,
  },
  cardFooter: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginTop: 12,
  },
  dateText: {
    color: 'rgba(255,255,255,0.4)',
    fontSize: 12,
  },
  trashBtn: {
    fontSize: 18,
  },
});
