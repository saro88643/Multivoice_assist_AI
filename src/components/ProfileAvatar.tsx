import React from 'react';
import { View, Image, Text, StyleSheet } from 'react-native';
import { AppColors } from '../utils/theme';

interface ProfileAvatarProps {
  imagePath?: string | null;
  radius?: number;
}

export const ProfileAvatar: React.FC<ProfileAvatarProps> = ({
  imagePath,
  radius = 25,
}) => {
  const size = radius * 2;

  if (imagePath) {
    return (
      <View style={[styles.borderWrapper, { borderRadius: radius + 2 }]}>
        <Image
          source={{ uri: imagePath }}
          style={{ width: size, height: size, borderRadius: radius }}
        />
      </View>
    );
  }

  return (
    <View style={[styles.borderWrapper, { borderRadius: radius + 2 }]}>
      <View
        style={[
          styles.fallbackContainer,
          { width: size, height: size, borderRadius: radius },
        ]}
      >
        <Text style={[styles.fallbackIcon, { fontSize: radius }]}>👤</Text>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  borderWrapper: {
    padding: 2,
    backgroundColor: AppColors.purple,
  },
  fallbackContainer: {
    backgroundColor: '#1E293B',
    justifyContent: 'center',
    alignItems: 'center',
  },
  fallbackIcon: {
    color: AppColors.white,
  },
});
