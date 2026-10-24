import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  RefreshControl,
} from 'react-native';
import { useHistory } from '../providers/HistoryContext';
import { useProfile } from '../providers/ProfileContext';
import { ProfileAvatar } from '../components/ProfileAvatar';
import { AppColors } from '../utils/theme';
import { AppConstants } from '../utils/constants';

export const HomeScreen = ({ navigation }: any) => {
  const [selectedIndex, setSelectedIndex] = useState(0);
  const { historyList, isLoading, loadHistory } = useHistory();
  const { userName, profileImagePath } = useProfile();

  const [refreshing, setRefreshing] = useState(false);

  const onRefresh = async () => {
    setRefreshing(true);
    await loadHistory();
    setRefreshing(false);
  };

  const recentChats = historyList.slice(0, 3);

  return (
    <View style={styles.container}>
      <ScrollView
        contentContainerStyle={styles.scrollContent}
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={onRefresh}
            tintColor={AppColors.purple}
          />
        }
      >
        {/* HEADER */}
        <View style={styles.header}>
          <TouchableOpacity style={styles.headerBtn}>
            <Text style={styles.headerIcon}>☰</Text>
          </TouchableOpacity>

          <Text style={styles.headerTitle}>{AppConstants.appName}</Text>

          <TouchableOpacity style={styles.headerBtn}>
            <Text style={styles.headerIcon}>🔔</Text>
          </TouchableOpacity>
        </View>

        {/* WELCOME ROW */}
        <View style={styles.welcomeRow}>
          <ProfileAvatar imagePath={profileImagePath} radius={28} />
          <View style={styles.welcomeTextCol}>
            <Text style={styles.welcomeGreeting}>👋 Welcome back,</Text>
            <View style={styles.nameRow}>
              <Text style={styles.userNameText}>{userName || 'User'}</Text>
              <View style={styles.badge}>
                <Text style={styles.badgeText}>👑 Premium</Text>
              </View>
            </View>
          </View>
          <View style={styles.aiGlowBtn}>
            <Text style={{ fontSize: 23 }}>✨</Text>
          </View>
        </View>

        {/* HERO CARD */}
        <View style={styles.heroCard}>
          <View style={styles.heroTextCol}>
            <Text style={styles.heroTitle}>
              {AppConstants.appName} <Text style={{ color: '#A855F7' }}>AI</Text>
            </Text>
            <Text style={styles.heroSubtitle}>
              Speak, Type and Connect in Any Language.
            </Text>
          </View>
          <View style={styles.robotGraphic}>
            <Text style={{ fontSize: 50 }}>🤖</Text>
          </View>
        </View>

        {/* START CHAT CARD */}
        <View style={styles.startChatCard}>
          <View style={styles.startChatIconCircle}>
            <Text style={{ fontSize: 28, color: '#FFF' }}>💬</Text>
          </View>
          <Text style={styles.startChatTitle}>Start a New AI Conversation</Text>
          <Text style={styles.startChatSubtitle}>
            Chat with AI in any language. Voice, text, image and translation are all
            supported automatically.
          </Text>

          <TouchableOpacity
            style={styles.startChatBtn}
            onPress={() => navigation.navigate('Chat')}
          >
            <Text style={styles.startChatBtnText}>✨ Start Chat ➔</Text>
          </TouchableOpacity>
        </View>

        {/* RECENT CHATS TITLE */}
        <View style={styles.recentHeader}>
          <Text style={styles.recentTitle}>Recent Chats</Text>
          <TouchableOpacity onPress={() => navigation.navigate('History')}>
            <Text style={styles.seeAllText}>See all ➔</Text>
          </TouchableOpacity>
        </View>

        {/* RECENT CHATS LIST */}
        <View style={styles.recentCard}>
          {recentChats.length === 0 ? (
            <View style={styles.emptyRecent}>
              <Text style={{ fontSize: 30 }}>💬</Text>
              <Text style={styles.emptyRecentText}>No conversations yet</Text>
            </View>
          ) : (
            recentChats.map((chat, idx) => (
              <TouchableOpacity
                key={chat.id || idx}
                style={styles.recentItem}
                onPress={() => navigation.navigate('History')}
              >
                <View style={styles.recentIconCircle}>
                  <Text style={{ fontSize: 16 }}>💬</Text>
                </View>
                <View style={{ flex: 1, marginHorizontal: 10 }}>
                  <Text style={styles.recentQuestion} numberOfLines={1}>
                    {chat.question}
                  </Text>
                  <Text style={styles.recentAnswer} numberOfLines={1}>
                    {chat.answer}
                  </Text>
                </View>
                <Text style={styles.recentTime}>
                  {new Date(chat.dateTime).toLocaleTimeString([], {
                    hour: '2-digit',
                    minute: '2-digit',
                  })}
                </Text>
              </TouchableOpacity>
            ))
          )}
        </View>
      </ScrollView>

      {/* BOTTOM TAB BAR */}
      <View style={styles.bottomBar}>
        <TouchableOpacity
          style={styles.tabItem}
          onPress={() => setSelectedIndex(0)}
        >
          <Text style={styles.tabIcon}>🏠</Text>
          <Text style={[styles.tabLabel, { color: AppColors.purple }]}>Home</Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={styles.tabItem}
          onPress={() => navigation.navigate('Chat')}
        >
          <Text style={styles.tabIcon}>💬</Text>
          <Text style={styles.tabLabel}>Chat</Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={styles.tabItem}
          onPress={() => navigation.navigate('History')}
        >
          <Text style={styles.tabIcon}>📜</Text>
          <Text style={styles.tabLabel}>History</Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={styles.tabItem}
          onPress={() => navigation.navigate('Profile')}
        >
          <Text style={styles.tabIcon}>👤</Text>
          <Text style={styles.tabLabel}>Profile</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: AppColors.homeBackground,
  },
  scrollContent: {
    padding: 18,
    paddingBottom: 100,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 20,
  },
  headerBtn: {
    width: 42,
    height: 42,
    borderRadius: 13,
    backgroundColor: AppColors.cardBackground,
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.08)',
  },
  headerIcon: {
    color: AppColors.white,
    fontSize: 20,
  },
  headerTitle: {
    color: AppColors.white,
    fontSize: 20,
    fontWeight: 'bold',
  },
  welcomeRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 22,
  },
  welcomeTextCol: {
    flex: 1,
    marginLeft: 13,
  },
  welcomeGreeting: {
    color: 'rgba(255,255,255,0.65)',
    fontSize: 13,
  },
  nameRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 4,
  },
  userNameText: {
    color: AppColors.white,
    fontSize: 18,
    fontWeight: 'bold',
  },
  badge: {
    marginLeft: 8,
    paddingHorizontal: 7,
    paddingVertical: 3,
    backgroundColor: 'rgba(76, 29, 149, 0.35)',
    borderRadius: 6,
    borderWidth: 1,
    borderColor: 'rgba(139, 92, 246, 0.4)',
  },
  badgeText: {
    color: '#C4B5FD',
    fontSize: 10,
    fontWeight: 'bold',
  },
  aiGlowBtn: {
    width: 48,
    height: 48,
    borderRadius: 15,
    backgroundColor: AppColors.purple,
    justifyContent: 'center',
    alignItems: 'center',
  },
  heroCard: {
    width: '100%',
    height: 155,
    borderRadius: 17,
    backgroundColor: '#17145A',
    padding: 17,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 16,
    borderWidth: 1,
    borderColor: 'rgba(109, 40, 217, 0.55)',
  },
  heroTextCol: {
    flex: 1,
  },
  heroTitle: {
    color: AppColors.white,
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 8,
  },
  heroSubtitle: {
    color: 'rgba(255,255,255,0.68)',
    fontSize: 12,
    lineHeight: 18,
  },
  robotGraphic: {
    width: 80,
    height: 80,
    justifyContent: 'center',
    alignItems: 'center',
  },
  startChatCard: {
    width: '100%',
    padding: 18,
    borderRadius: 17,
    backgroundColor: AppColors.darkCardBackground,
    borderWidth: 1,
    borderColor: 'rgba(51, 65, 85, 0.65)',
    alignItems: 'center',
    marginBottom: 25,
  },
  startChatIconCircle: {
    width: 58,
    height: 58,
    borderRadius: 29,
    backgroundColor: AppColors.purple,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 14,
  },
  startChatTitle: {
    color: AppColors.white,
    fontSize: 17,
    fontWeight: 'bold',
    marginBottom: 8,
    textAlign: 'center',
  },
  startChatSubtitle: {
    color: 'rgba(255,255,255,0.58)',
    fontSize: 12,
    textAlign: 'center',
    lineHeight: 18,
    marginBottom: 17,
  },
  startChatBtn: {
    width: '100%',
    height: 46,
    borderRadius: 15,
    backgroundColor: AppColors.blue,
    justifyContent: 'center',
    alignItems: 'center',
  },
  startChatBtnText: {
    color: AppColors.white,
    fontSize: 15,
    fontWeight: 'bold',
  },
  recentHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 11,
  },
  recentTitle: {
    color: AppColors.white,
    fontSize: 18,
    fontWeight: 'bold',
  },
  seeAllText: {
    color: AppColors.lightPurple,
    fontSize: 12,
    fontWeight: 'bold',
  },
  recentCard: {
    backgroundColor: '#0D1628',
    borderRadius: 15,
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.06)',
    overflow: 'hidden',
  },
  emptyRecent: {
    padding: 20,
    alignItems: 'center',
  },
  emptyRecentText: {
    color: 'rgba(255,255,255,0.5)',
    fontSize: 13,
    marginTop: 8,
  },
  recentItem: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 12,
    borderBottomWidth: 1,
    borderBottomColor: 'rgba(255,255,255,0.05)',
  },
  recentIconCircle: {
    width: 34,
    height: 34,
    borderRadius: 17,
    backgroundColor: 'rgba(37, 99, 235, 0.2)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  recentQuestion: {
    color: AppColors.white,
    fontSize: 13,
    fontWeight: '500',
  },
  recentAnswer: {
    color: 'rgba(255,255,255,0.45)',
    fontSize: 11,
    marginTop: 2,
  },
  recentTime: {
    color: 'rgba(255,255,255,0.45)',
    fontSize: 10,
  },
  bottomBar: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    height: 65,
    backgroundColor: AppColors.cardBackground,
    flexDirection: 'row',
    justifyContent: 'space-around',
    alignItems: 'center',
    borderTopWidth: 1,
    borderTopColor: 'rgba(255,255,255,0.05)',
  },
  tabItem: {
    alignItems: 'center',
  },
  tabIcon: {
    fontSize: 20,
  },
  tabLabel: {
    color: 'rgba(255,255,255,0.54)',
    fontSize: 11,
    marginTop: 2,
  },
});
