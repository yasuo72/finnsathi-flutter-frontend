import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile_model.dart';

class ProfileService extends ChangeNotifier {
  // Helper method to parse trophy rarity from string
  TrophyRarity _parseTrophyRarity(String rarityStr) {
    switch (rarityStr) {
      case 'common':
        return TrophyRarity.common;
      case 'uncommon':
        return TrophyRarity.uncommon;
      case 'rare':
        return TrophyRarity.rare;
      case 'epic':
        return TrophyRarity.epic;
      case 'legendary':
        return TrophyRarity.legendary;
      default:
        return TrophyRarity.common;
    }
  }
  
  static const String _profileKey = 'user_profile';
  
  UserProfile? _currentProfile;
  
  UserProfile get currentProfile => _currentProfile ?? UserProfile.mock();
  
  ProfileService() {
    // Load profile when service is initialized
    _loadUserProfile();
  }
  
  // Refresh the profile data (call this when user data might have changed)
  void refreshProfile() {
    _loadUserProfile();
  }
  
  // Load the user profile from SharedPreferences
  Future<void> _loadUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString(_profileKey);
      
      if (profileJson != null) {
        // Parse the stored profile JSON
        final Map<String, dynamic> profileMap = jsonDecode(profileJson);
        _currentProfile = _createProfileFromJson(profileMap);
      } else {
        // Create and save a default profile if none exists
        _currentProfile = UserProfile.mock();
        await _saveUserProfile(_currentProfile!);
      }
      
      // Notify listeners that profile has been loaded
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      _currentProfile = UserProfile.mock();
      notifyListeners();
    }
  }
  
  // Create a UserProfile from JSON data
  UserProfile _createProfileFromJson(Map<String, dynamic> json) {
    // Create achievements list from JSON if available
    List<Achievement> achievements = [];
    if (json.containsKey('achievements') && json['achievements'] is List) {
      achievements = (json['achievements'] as List).map((item) {
        return Achievement(
          id: item['id'] ?? '',
          title: item['title'] ?? '',
          description: item['description'] ?? '',
          icon: item['icon'] ?? '',
          isUnlocked: item['isUnlocked'] ?? false,
          dateUnlocked: item['dateUnlocked'] != null ? DateTime.parse(item['dateUnlocked']) : null,
          xpReward: item['xpReward'] ?? 50,
        );
      }).toList();
    } else {
      // Use default achievements if none in JSON
      achievements = UserProfile.mock().achievements;
    }
    
    // Create trophies list from JSON if available
    List<Trophy> trophies = [];
    if (json.containsKey('trophies') && json['trophies'] is List) {
      trophies = (json['trophies'] as List).map((item) {
        return Trophy(
          id: item['id'] ?? '',
          title: item['title'] ?? '',
          description: item['description'] ?? '',
          rarity: _parseTrophyRarity(item['rarity'] ?? 'common'),
          iconPath: item['iconPath'] ?? '',
          isUnlocked: item['isUnlocked'] ?? false,
          dateAwarded: item['dateAwarded'] != null ? DateTime.parse(item['dateAwarded']) : null,
          xpReward: item['xpReward'] ?? 100,
        );
      }).toList();
    } else {
      // Use default trophies if none in JSON
      trophies = UserProfile.mock().trophies;
    }
    
    // Create badges list from JSON if available
    List<String> badges = [];
    if (json.containsKey('badges') && json['badges'] is List) {
      badges = List<String>.from(json['badges']);
    } else {
      // Use default badges if none in JSON
      badges = UserProfile.mock().badges;
    }
    
    // Create preferences map from JSON if available
    Map<String, dynamic> preferences = {};
    if (json.containsKey('preferences') && json['preferences'] is Map) {
      preferences = Map<String, dynamic>.from(json['preferences']);
    } else {
      // Use default preferences if none in JSON
      preferences = UserProfile.mock().preferences;
    }
    
    // Create and return the UserProfile
    return UserProfile(
      id: json['id'] ?? UserProfile.mock().id,
      name: json['name'] ?? UserProfile.mock().name,
      email: json['email'] ?? UserProfile.mock().email,
      phone: json['phone'] ?? UserProfile.mock().phone,
      avatarUrl: json['avatarUrl'] ?? UserProfile.mock().avatarUrl,
      membershipLevel: json['membershipLevel'] ?? UserProfile.mock().membershipLevel,
      levelProgress: json['levelProgress']?.toDouble() ?? UserProfile.mock().levelProgress,
      nextLevel: json['nextLevel'] ?? UserProfile.mock().nextLevel,
      xp: json['xp'] ?? UserProfile.mock().xp,
      level: json['level'] ?? UserProfile.mock().level,
      points: json['points'] ?? UserProfile.mock().points,
      rank: json['rank'] ?? UserProfile.mock().rank,
      completedTransactions: json['completedTransactions'] ?? UserProfile.mock().completedTransactions,
      achievements: achievements,
      trophies: trophies,
      badges: badges,
      preferences: preferences,
    );
  }
  
  // Get the current user profile
  Future<UserProfile> getUserProfile() async {
    if (_currentProfile != null) {
      return _currentProfile!;
    }
    
    await _loadUserProfile();
    return currentProfile;
  }
  
  // Save the user profile to SharedPreferences
  Future<bool> _saveUserProfile(UserProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Convert achievements to JSON
      final achievementsJson = profile.achievements.map((achievement) => {
        'id': achievement.id,
        'title': achievement.title,
        'description': achievement.description,
        'icon': achievement.icon,
        'isUnlocked': achievement.isUnlocked,
        'dateUnlocked': achievement.dateUnlocked?.toIso8601String(),
        'xpReward': achievement.xpReward,
      }).toList();
      
      // Convert trophies to JSON
      final trophiesJson = profile.trophies.map((trophy) => {
        'id': trophy.id,
        'title': trophy.title,
        'description': trophy.description,
        'rarity': trophy.rarity.toString().split('.').last,
        'iconPath': trophy.iconPath,
        'isUnlocked': trophy.isUnlocked,
        'dateAwarded': trophy.dateAwarded?.toIso8601String(),
        'xpReward': trophy.xpReward,
      }).toList();
      
      // Create a complete profile JSON
      final Map<String, dynamic> profileData = {
        'id': profile.id,
        'name': profile.name,
        'email': profile.email,
        'phone': profile.phone,
        'avatarUrl': profile.avatarUrl,
        'membershipLevel': profile.membershipLevel,
        'levelProgress': profile.levelProgress,
        'nextLevel': profile.nextLevel,
        'xp': profile.xp,
        'level': profile.level,
        'points': profile.points,
        'rank': profile.rank,
        'completedTransactions': profile.completedTransactions,
        'achievements': achievementsJson,
        'trophies': trophiesJson,
        'badges': profile.badges,
        'preferences': profile.preferences,
      };
      
      await prefs.setString(_profileKey, jsonEncode(profileData));
      return true;
    } catch (e) {
      debugPrint('Error saving user profile: $e');
      return false;
    }
  }
  
  // Update user profile
  Future<bool> updateUserProfile(UserProfile profile) async {
    try {
      // Update the current profile
      _currentProfile = profile;
      
      // Save to SharedPreferences
      final result = await _saveUserProfile(profile);
      
      // Notify listeners about the update
      notifyListeners();
      
      return result;
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      return false;
    }
  }
  
  // Update user preferences
  Future<bool> updateUserPreferences(Map<String, dynamic> preferences) async {
    try {
      // Get current profile
      final profile = currentProfile;
      
      // Create updated profile with new preferences
      final updatedProfile = profile.copyWith(
        preferences: {...profile.preferences, ...preferences},
      );
      
      // Update the profile
      return await updateUserProfile(updatedProfile);
    } catch (e) {
      debugPrint('Error updating user preferences: $e');
      return false;
    }
  }
  
  // Get user achievements
  List<Achievement> getUserAchievements() {
    return currentProfile.achievements;
  }
  
  // Upload profile picture and update profile
  Future<bool> updateProfilePicture(String newAvatarUrl) async {
    try {
      // Get current profile
      final profile = currentProfile;
      
      // Create updated profile with new avatar URL
      final updatedProfile = profile.copyWith(
        avatarUrl: newAvatarUrl,
      );
      
      // Update the profile
      return await updateUserProfile(updatedProfile);
    } catch (e) {
      debugPrint('Error updating profile picture: $e');
      return false;
    }
  }
  
  // Upload profile picture from local file path
  Future<String?> uploadProfilePicture(String filePath) async {
    try {
      // In a real app, this would upload the image to a server
      // and return the URL of the uploaded image
      
      // For this app, we'll use the file:// protocol to reference the local file
      final newAvatarUrl = 'file://$filePath';
      
      // Update the profile with the new avatar URL
      await updateProfilePicture(newAvatarUrl);
      
      return newAvatarUrl;
    } catch (e) {
      debugPrint('Error uploading profile picture: $e');
      return null;
    }
  }
}
