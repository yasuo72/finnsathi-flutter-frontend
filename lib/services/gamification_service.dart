import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile_model.dart';
import 'profile_service.dart';
import 'finance_service.dart';
import 'api_service.dart';
import '../config/api_config.dart';
import 'notification_api_service.dart';

// Challenge model
class Challenge {
  final String id;
  final String title;
  final String description;
  final String type;
  final int rewardCoins;
  final int rewardPoints;
  final int targetValue;
  int currentValue;
  bool isCompleted;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.rewardCoins,
    required this.rewardPoints,
    required this.targetValue,
    required this.currentValue,
    required this.isCompleted,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'type': type,
      'category': type, // Map type to category for backend compatibility
      'points': rewardPoints, // Map rewardPoints to points for backend
      'isCompleted': isCompleted,
      'icon': 'star', // Default icon
      // Include frontend-specific fields for local use
      'id': id,
      'rewardCoins': rewardCoins,
      'rewardPoints': rewardPoints,
      'targetValue': targetValue,
      'currentValue': currentValue,
    };
  }

  factory Challenge.fromJson(Map<String, dynamic> json) {
    // Create a Challenge object with proper null handling for all fields
    return Challenge(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Challenge',
      description:
          json['description']?.toString() ??
          'Complete this challenge to earn rewards',
      type: json['type']?.toString() ?? 'general',
      rewardCoins: _parseIntValue(json['rewardCoins'], 0),
      rewardPoints: _parseIntValue(json['rewardPoints'], 0),
      targetValue: _parseIntValue(json['targetValue'], 1),
      currentValue: _parseIntValue(json['currentValue'], 0),
      isCompleted: json['isCompleted'] == null
          ? false
          : json['isCompleted'] is bool
              ? json['isCompleted']
              : json['isCompleted'].toString().toLowerCase() == 'true',
    );
  }
  
  // Helper method to safely parse integer values
  static int _parseIntValue(dynamic value, int defaultValue) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  double get progress =>
      targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;
}

// Quest model (a series of related challenges)
class Quest {
  final String id;
  final String title;
  final String description;
  final List<Challenge> challenges;
  final int rewardCoins;
  final int rewardPoints;

  Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.challenges,
    required this.rewardCoins,
    required this.rewardPoints,
  });

  bool get isCompleted =>
      challenges.every((challenge) => challenge.isCompleted);

  double get progress {
    if (challenges.isEmpty) return 0.0;

    final totalCompleted = challenges.where((c) => c.isCompleted).length;
    return totalCompleted / challenges.length;
  }
}

class GamificationService extends ChangeNotifier {
  // Keys for SharedPreferences storage
  static const String _dailyChallengesKey = 'daily_challenges';
  static const String _streakKey = 'activity_streak';
  static const String _lastActivityKey = 'last_activity_date';
  static const String _xpKey = 'user_xp';
  static const String _levelKey = 'user_level';
  static const String _badgesKey = 'user_badges';

  final ProfileService _profileService;
  final FinanceService _financeService;

  // Challenges
  List<Challenge> _dailyChallenges = [];
  List<Challenge> _weeklyChallenges = [];
  List<Quest> _activeQuests = [];

  // Streaks
  int _currentStreak = 0;
  int _longestStreak = 0;
  DateTime? _lastActivityDate;

  // Rewards
  int _financeCoins = 0;

  // XP and Level System
  int _currentXP = 0;
  int _currentLevel = 1;
  List<Trophy> _availableTrophies = [];
  List<String> _userBadges = [];

  // AI Insights
  Map<String, dynamic> _financialInsights = {};
  List<String> _personalizedTips = [];

  // Flag to indicate if initial data has been loaded
  bool _isInitialized = false;

  // Constructor
  GamificationService(this._profileService, this._financeService) {
    _initialize();
  }

  // Getters
  List<Challenge> get dailyChallenges => _dailyChallenges;
  List<Challenge> get weeklyChallenges => _weeklyChallenges;
  List<Quest> get activeQuests => _activeQuests;
  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;
  int get financeCoins => _financeCoins;
  int get currentXP => _currentXP;
  int get currentLevel => _currentLevel;
  List<Trophy> get availableTrophies => _availableTrophies;
  List<String> getBadges() {
    return _userBadges;
  }

  // Add a badge
  Future<void> addBadge(String badgeId) async {
    if (!_userBadges.contains(badgeId)) {
      _userBadges.add(badgeId);

      // Try to update badge on backend
      await _updateBadgeOnBackend(badgeId);

      await _saveGamificationData();
      notifyListeners();

      // Show notification
      _showNotification(
        'New Badge Unlocked!',
        'You earned the $badgeId badge!',
      );
    }
  }

  // Update badge on backend
  Future<bool> _updateBadgeOnBackend(String badgeId) async {
    try {
      debugPrint('Updating badge on backend: ${ApiConfig.gamification}/badges');
      final data = await ApiService.post('${ApiConfig.gamification}/badges', {
        'badgeId': badgeId,
      });

      return data != null && data['success'] == true;
    } catch (e) {
      debugPrint('Error updating badge on backend: $e');
      return false;
    }
  }

  // Get all available badges (including locked ones)
  Future<List<Map<String, dynamic>>> getAllBadges() async {
    try {
      // Try to get from backend first
      final data = await ApiService.get('${ApiConfig.gamification}/badges');

      if (data != null &&
          data['success'] == true &&
          data['data'] != null &&
          data['data']['badges'] != null) {
        return List<Map<String, dynamic>>.from(data['data']['badges']);
      }

      // Fallback to local badges
      return _getLocalBadges();
    } catch (e) {
      debugPrint('Error getting all badges: $e');
      return _getLocalBadges();
    }
  }

  // Get leaderboard data
  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    try {
      // Try to get from backend first
      final data = await ApiService.get(
        '${ApiConfig.gamification}/leaderboard',
      );

      if (data != null &&
          data['success'] == true &&
          data['data'] != null &&
          data['data']['leaderboard'] != null) {
        return List<Map<String, dynamic>>.from(data['data']['leaderboard']);
      }

      // Fallback to local leaderboard data
      return _getLocalLeaderboard();
    } catch (e) {
      debugPrint('Error getting leaderboard: $e');
      return _getLocalLeaderboard();
    }
  }

  // Get local leaderboard data
  List<Map<String, dynamic>> _getLocalLeaderboard() {
    // Generate some mock leaderboard data
    // Get username from shared preferences if available
    String username = 'You';
    try {
      SharedPreferences.getInstance().then((prefs) {
        final userData = prefs.getString('user_data');
        if (userData != null) {
          final userMap = json.decode(userData);
          username = userMap['username'] ?? 'You';
        }
      });
    } catch (e) {
      debugPrint('Error getting username: $e');
    }

    return [
      {
        'rank': 1,
        'username': 'FinancePro',
        'points': _currentXP + Random().nextInt(500) + 500,
        'level': _currentLevel + Random().nextInt(3) + 1,
        'badges': 12,
      },
      {
        'rank': 2,
        'username': 'SavingsMaster',
        'points': _currentXP + Random().nextInt(300) + 200,
        'level': _currentLevel + Random().nextInt(2) + 1,
        'badges': 10,
      },
      {
        'rank': 3,
        'username': username,
        'points': _currentXP,
        'level': _currentLevel,
        'badges': _userBadges.length,
        'isCurrentUser': true,
      },
      {
        'rank': 4,
        'username': 'BudgetBuddy',
        'points': _currentXP - Random().nextInt(200) - 100,
        'level': _currentLevel,
        'badges': 7,
      },
      {
        'rank': 5,
        'username': 'InvestorPro',
        'points': _currentXP - Random().nextInt(300) - 200,
        'level': _currentLevel - 1,
        'badges': 5,
      },
    ];
  }

  // Get local badges
  List<Map<String, dynamic>> _getLocalBadges() {
    return [
      {
        'id': 'first_login',
        'title': 'First Steps',
        'description': 'Logged into the app for the first time',
        'isUnlocked': _userBadges.contains('first_login'),
        'category': 'general',
        'icon': 'assets/icons/badges/first_login.png',
      },
      {
        'id': 'budget_master',
        'title': 'Budget Master',
        'description': 'Created and maintained a budget for 30 days',
        'isUnlocked': _userBadges.contains('budget_master'),
        'category': 'budgeting',
        'icon': 'assets/icons/badges/budget_master.png',
      },
      {
        'id': 'savings_hero',
        'title': 'Savings Hero',
        'description': 'Reached a savings goal',
        'isUnlocked': _userBadges.contains('savings_hero'),
        'category': 'savings',
        'icon': 'assets/icons/badges/savings_hero.png',
      },
      {
        'id': 'expense_tracker',
        'title': 'Expense Tracker',
        'description': 'Tracked expenses for 7 consecutive days',
        'isUnlocked': _userBadges.contains('expense_tracker'),
        'category': 'tracking',
        'icon': 'assets/icons/badges/expense_tracker.png',
      },
      {
        'id': 'streak_master',
        'title': 'Streak Master',
        'description': 'Maintained a 7-day streak',
        'isUnlocked': _userBadges.contains('streak_master'),
        'category': 'engagement',
        'icon': 'assets/icons/badges/streak_master.png',
      },
    ];
  }

  // Get financial insights
  Map<String, dynamic> getFinancialInsights() {
    return _financialInsights;
  }

  // Get personalized tips
  List<String> getPersonalizedTips() {
    // If we don't have any tips yet, generate some default ones
    if (_personalizedTips.isEmpty) {
      _personalizedTips.addAll([
        'Track your expenses regularly to stay on top of your finances.',
        'Set up automatic transfers to your savings account on payday.',
        'Review your budget monthly and adjust as needed.',
      ]);
    }
    return _personalizedTips;
  }

  // Refresh financial insights from backend
  Future<Map<String, dynamic>> refreshFinancialInsights() async {
    try {
      // Try to get from backend
      final data = await ApiService.get(
        '${ApiConfig.gamification}/financial-health',
      );

      if (data != null && data['success'] == true && data['data'] != null) {
        final score = data['data']['score'] ?? 50;
        final breakdown =
            data['data']['breakdown'] ??
            {
              'savingsRate': score * 0.3, // 30% of score
              'budgetAdherence': score * 0.25, // 25% of score
              'expenseManagement': score * 0.25, // 25% of score
              'goalProgress': score * 0.2, // 20% of score
            };

        // Store in insights
        _financialInsights['score'] = score;
        _financialInsights['breakdown'] = breakdown;
        _financialInsights['lastUpdated'] = DateTime.now().toIso8601String();

        notifyListeners();
        return {'score': score, 'breakdown': breakdown};
      }

      // Fallback to local calculation
      return _calculateFinancialHealthScore();
    } catch (e) {
      debugPrint('Error getting financial health score: $e');
      return _calculateFinancialHealthScore();
    }
  }

  // Calculate financial health score locally
  Map<String, dynamic> _calculateFinancialHealthScore() {
    try {
      // Simple calculation based on available data
      final savingsGoals = _financeService.savingsGoals;
      final budgets = _financeService.budgets;

      // Calculate savings rate (30% of score)
      double savingsRate = 0;
      if (savingsGoals.isNotEmpty) {
        final totalProgress = savingsGoals.fold<double>(
          0,
          (sum, goal) => sum + (goal.currentAmount / goal.targetAmount),
        );
        savingsRate = (totalProgress / savingsGoals.length) * 30;
      }

      // Calculate budget adherence (25% of score)
      double budgetAdherence = 0;
      if (budgets.isNotEmpty) {
        final adherenceRates =
            budgets.map((budget) {
              if (budget.limit <= 0) return 1.0;
              final adherence =
                  1 - (budget.spent / budget.limit).clamp(0.0, 1.0);
              return adherence;
            }).toList();

        final avgAdherence =
            adherenceRates.fold<double>(0, (sum, rate) => sum + rate) /
            adherenceRates.length;
        budgetAdherence = avgAdherence * 25;
      }

      // Expense management (25% of score) - simplified
      final expenseManagement = 15.0; // Default middle value

      // Goal progress (20% of score)
      double goalProgress = 0;
      if (savingsGoals.isNotEmpty) {
        final totalProgress = savingsGoals.fold<double>(
          0,
          (sum, goal) => sum + (goal.currentAmount / goal.targetAmount),
        );
        goalProgress = (totalProgress / savingsGoals.length) * 20;
      }

      // Calculate total score
      final score =
          (savingsRate + budgetAdherence + expenseManagement + goalProgress)
              .round();

      // Store in insights
      _financialInsights['score'] = score;
      _financialInsights['breakdown'] = {
        'savingsRate': savingsRate,
        'budgetAdherence': budgetAdherence,
        'expenseManagement': expenseManagement,
        'goalProgress': goalProgress,
      };
      _financialInsights['lastUpdated'] = DateTime.now().toIso8601String();

      notifyListeners();
      return {
        'score': score,
        'breakdown': {
          'savingsRate': savingsRate,
          'budgetAdherence': budgetAdherence,
          'expenseManagement': expenseManagement,
          'goalProgress': goalProgress,
        },
      };
    } catch (e) {
      debugPrint('Error calculating financial health score: $e');
      return {
        'score': 50,
        'breakdown': {
          'savingsRate': 15,
          'budgetAdherence': 12.5,
          'expenseManagement': 12.5,
          'goalProgress': 10,
        },
      };
    }
  }

  // XP required for each level
  int getXPForNextLevel(int level) {
    // Progressive XP requirements: each level requires more XP than the previous
    return 100 * level * (level + 1) ~/ 2;
  }

  // Calculate level progress percentage
  double getLevelProgress() {
    final currentLevelXP = getXPForNextLevel(_currentLevel - 1);
    final nextLevelXP = getXPForNextLevel(_currentLevel);
    final xpForCurrentLevel = _currentXP - currentLevelXP;
    final xpRequiredForNextLevel = nextLevelXP - currentLevelXP;

    return (xpForCurrentLevel / xpRequiredForNextLevel).clamp(0.0, 1.0);
  }

  // Get XP needed for next level
  int getXPNeededForNextLevel() {
    final nextLevelXP = getXPForNextLevel(_currentLevel);
    return nextLevelXP - _currentXP;
  }

  // Initialize the service
  Future<void> _initialize() async {
    try {
      // Reset all data to 0 first
      _resetAllData();

      // First try to load data from backend
      final backendData = await _fetchGamificationDataFromBackend();
      if (backendData != null) {
        await _processBackendGamificationData(backendData);
      } else {
        // If backend data not available, load from local storage
        await _loadGamificationData();
      }

      // Generate initial challenges if none exist
      if (_dailyChallenges.isEmpty) {
        await _fetchChallengesFromBackend();
        if (_dailyChallenges.isEmpty) {
          _generateDailyChallenges();
        }
      }

      // Mark as initialized
      _isInitialized = true;
      notifyListeners();

      // Set up a timer to check for updates every hour
      Timer.periodic(const Duration(hours: 1), (_) async {
        try {
          await _checkAndUpdateStreak();
          await _checkAndGenerateDailyChallenges();
          await _checkAchievements();
          notifyListeners();
        } catch (e) {
          debugPrint('Error in gamification periodic update: $e');
        }
      });
    } catch (e) {
      debugPrint('Error initializing gamification service: $e');
      // Still mark as initialized to prevent repeated initialization attempts
      _isInitialized = true;
    }
  }

  // Fetch gamification data from backend
  Future<Map<String, dynamic>?> _fetchGamificationDataFromBackend() async {
    try {
      debugPrint(
        'Fetching gamification data from backend: ${ApiConfig.gamification}',
      );
      final data = await ApiService.get(ApiConfig.gamification);

      if (data != null && data['success'] == true && data['data'] != null) {
        debugPrint('Successfully fetched gamification data from backend');
        return data['data'];
      }

      debugPrint('No gamification data found in backend response');
      return null;
    } catch (e) {
      debugPrint('Error fetching gamification data from backend: $e');
      return null;
    }
  }

  // Process backend gamification data
  Future<void> _processBackendGamificationData(
    Map<String, dynamic> data,
  ) async {
    try {
      // Update streak data
      if (data['streak'] != null) {
        _currentStreak = data['streak'];
      }
      if (data['longestStreak'] != null) {
        _longestStreak = data['longestStreak'];
      }

      // Update XP and level
      if (data['points'] != null) {
        _currentXP = data['points'];
      }
      if (data['level'] != null) {
        _currentLevel = data['level'];
      }

      // Update financial health score
      if (data['financialHealthScore'] != null) {
        _financialInsights['score'] = data['financialHealthScore'];
      }

      // Process challenges if available
      if (data['challenges'] != null && data['challenges'] is List) {
        _dailyChallenges =
            (data['challenges'] as List)
                .map((c) => Challenge.fromJson(c))
                .toList();
      }

      // Process achievements if available
      if (data['achievements'] != null && data['achievements'] is List) {
        // Update profile achievements if available
        final achievementsList =
            (data['achievements'] as List)
                .map(
                  (a) => {
                    'id': a['id'],
                    'title': a['title'],
                    'description': a['description'],
                    'isUnlocked': a['isUnlocked'] ?? false,
                    'dateUnlocked':
                        a['unlockedDate'] != null
                            ? DateTime.parse(a['unlockedDate'])
                            : null,
                  },
                )
                .toList();

        // Update the user's achievements locally
        if (achievementsList.isNotEmpty) {
          try {
            // Store achievements locally since ProfileService might not have updateAchievements method
            for (final achievement in achievementsList) {
              if (achievement['isUnlocked'] == true &&
                  !_userBadges.contains(achievement['id'])) {
                _userBadges.add(achievement['id']);
              }
            }
            debugPrint(
              'Updated ${achievementsList.length} achievements locally',
            );
          } catch (e) {
            debugPrint('Error updating achievements locally: $e');
          }
        }
      }

      await _saveGamificationData();
    } catch (e) {
      debugPrint('Error processing backend gamification data: $e');
    }
  }

  // Fetch challenges from backend
  Future<void> _fetchChallengesFromBackend() async {
    // TEMPORARILY DISABLED BACKEND SYNC FOR CHALLENGES DUE TO 500 ERROR
    debugPrint(
      '⚠️ Backend challenges fetch is temporarily disabled due to API 500 error',
    );
    debugPrint(
      '💾 Using local challenges generation instead',
    );
    
    // Ensure we generate local challenges instead
    await _generateDailyChallenges();
    return;
    
    /* Original implementation - kept for future re-enabling
    try {
      debugPrint(
        'Fetching challenges from backend: ${ApiConfig.gamification}/challenges',
      );
      final data = await ApiService.get('${ApiConfig.gamification}/challenges');

      if (data != null &&
          data['success'] == true &&
          data['data'] != null &&
          data['data']['challenges'] != null) {
        final List<dynamic> challengesJson = data['data']['challenges'];
        _dailyChallenges =
            challengesJson.map((json) => Challenge.fromJson(json)).toList();
        await _saveChallenges();
        debugPrint(
          'Successfully fetched ${_dailyChallenges.length} challenges from backend',
        );
      } else {
        debugPrint('No challenges found in backend response');
      }
    } catch (e) {
      debugPrint('Error fetching challenges from backend: $e');
    }
    */
  }

  // Reset all data to initial values
  void _resetAllData() {
    // Reset streaks
    _currentStreak = 0;
    _longestStreak = 0;
    _lastActivityDate = null;

    // Reset rewards
    _financeCoins = 0;

    // Reset XP and level
    _currentXP = 0;
    _currentLevel = 1;

    // Reset badges
    _userBadges = [];

    // Initialize default trophies
    _initializeDefaultTrophies();

    // Reset challenges
    _dailyChallenges = [];
    _weeklyChallenges = [];
    _activeQuests = [];
  }

  // Load gamification data from shared preferences
  Future<void> _loadGamificationData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if user is authenticated
      final token = prefs.getString('auth_token');
      bool isAuthenticated = token != null && token.isNotEmpty;

      // First try to load from backend if user is authenticated
      if (isAuthenticated) {
        debugPrint(
          'User is authenticated. Attempting to fetch gamification data from backend',
        );
        final backendData = await _fetchGamificationDataFromBackend();

        if (backendData != null) {
          debugPrint('Successfully loaded gamification data from backend');
          await _processBackendGamificationData(backendData);
          return; // Successfully loaded from backend, no need to load from local storage
        } else {
          debugPrint(
            'Failed to load from backend, falling back to local storage',
          );
        }
      } else {
        debugPrint('User not authenticated. Loading from local storage only');
      }

      // Check if data has been initialized before
      final isInitialized = prefs.getBool('${_xpKey}_initialized') ?? false;
      if (!isInitialized) {
        // First time use, don't load anything
        return;
      }

      // Load streak data
      _currentStreak = prefs.getInt(_streakKey) ?? 0;
      _longestStreak = prefs.getInt('longest_$_streakKey') ?? 0;
      final lastActivityStr = prefs.getString(_lastActivityKey);
      _lastActivityDate =
          lastActivityStr != null ? DateTime.parse(lastActivityStr) : null;

      // Load XP and level
      _currentXP = prefs.getInt(_xpKey) ?? 0;
      _currentLevel = prefs.getInt(_levelKey) ?? 1;

      // Load badges
      final badgesJson = prefs.getString(_badgesKey);
      if (badgesJson != null) {
        final List<dynamic> badgesList = jsonDecode(badgesJson);
        _userBadges = badgesList.cast<String>();
      }

      // Load challenges
      await _loadChallenges();
    } catch (e) {
      debugPrint('Error loading gamification data: $e');
      // Reset to defaults on error
      _resetAllData();
    }
  }

  // Initialize default trophies
  void _initializeDefaultTrophies() {
    _availableTrophies = [
      Trophy(
        id: 'trophy_001',
        title: 'Savings Champion',
        description: 'Saved ₹50,000 in total',
        rarity: TrophyRarity.rare,
        iconPath: 'assets/icons/trophies/savings_champion.png',
        isUnlocked: false,
        dateAwarded: null,
      ),
      Trophy(
        id: 'trophy_002',
        title: 'Budget Master',
        description: 'Stayed within budget for 5 consecutive months',
        rarity: TrophyRarity.epic,
        iconPath: 'assets/icons/trophies/budget_master.png',
        isUnlocked: false,
        dateAwarded: null,
      ),
      Trophy(
        id: 'trophy_003',
        title: 'First Investment',
        description: 'Made your first investment',
        rarity: TrophyRarity.common,
        iconPath: 'assets/icons/trophies/first_investment.png',
        isUnlocked: false,
        dateAwarded: null,
      ),
    ];
  }

  // Save gamification data to shared preferences
  Future<void> _saveGamificationData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if user is authenticated
      final token = prefs.getString('auth_token');
      bool isAuthenticated = token != null && token.isNotEmpty;

      // First save to backend if user is authenticated
      if (isAuthenticated) {
        await _saveGamificationDataToBackend();
      }

      // Always save locally as a backup

      // Save streak data
      await prefs.setInt(_streakKey, _currentStreak);
      await prefs.setInt('longest_$_streakKey', _longestStreak);

      if (_lastActivityDate != null) {
        await prefs.setString(
          _lastActivityKey,
          _lastActivityDate!.toIso8601String(),
        );
      }

      // Save XP and level
      await prefs.setInt(_xpKey, _currentXP);
      await prefs.setInt(_levelKey, _currentLevel);
      await prefs.setBool('${_xpKey}_initialized', true);

      // Save badges
      await prefs.setString(_badgesKey, jsonEncode(_userBadges));

      // Save finance coins
      await prefs.setInt('finance_coins', _financeCoins);

      // Save financial insights
      if (_financialInsights.isNotEmpty) {
        await prefs.setString(
          'financial_insights',
          jsonEncode(_financialInsights),
        );
      }

      // Save personalized tips
      if (_personalizedTips.isNotEmpty) {
        await prefs.setString(
          'personalized_tips',
          jsonEncode(_personalizedTips),
        );
      }

      // Save challenges
      await _saveChallenges();
    } catch (e) {
      debugPrint('Error saving gamification data: $e');
    }
  }

  // Save gamification data to backend
  Future<bool> _saveGamificationDataToBackend() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null || token.isEmpty) {
        debugPrint(
          '⚠️ No auth token found. Cannot save gamification data to backend.',
        );
        return false;
      }

      debugPrint('💾 Saving gamification data to backend');

      // Instead of sending all data in one request, we'll send different data to different endpoints
      bool success = true;

      // 1. Update user profile with gamification stats
      final userProfileData = {
        'gamification': {
          'streak': _currentStreak,
          'longestStreak': _longestStreak,
          'lastActivityDate': _lastActivityDate?.toIso8601String(),
          'points': _currentXP,
          'level': _currentLevel,
          'coins': _financeCoins,
          'financialHealthScore': _financialInsights['score'] ?? 0,
        },
      };

      debugPrint('📝 Updating user profile with gamification stats');
      final profileResult = await ApiService.put(
        '${ApiConfig.users}/profile',
        userProfileData,
      );

      if (profileResult == null || profileResult['success'] != true) {
        debugPrint('❌ Failed to update user profile with gamification data');
        success = false;
      } else {
        debugPrint(
          '✅ Successfully updated user profile with gamification stats',
        );
      }

      // 2. Update user badges
      if (_userBadges.isNotEmpty) {
        final badgesData = {'badges': _userBadges};

        debugPrint('🏆 Updating user badges');
        final badgesResult = await ApiService.put(
          '${ApiConfig.gamification}/badges',
          badgesData,
        );

        if (badgesResult == null || badgesResult['success'] != true) {
          debugPrint('❌ Failed to update user badges');
          success = false;
        } else {
          debugPrint('✅ Successfully updated user badges');
        }
      }

      // 3. Update user challenges - TEMPORARILY DISABLED DUE TO MISSING ENDPOINT
      if (_dailyChallenges.isNotEmpty) {
        debugPrint('🎯 Challenge sync temporarily disabled - endpoint not available');
        // Uncomment and fix when backend endpoint is available
        /*
        final challengesData = {
          'challenges': _dailyChallenges.map((c) => c.toJson()).toList(),
        };

        debugPrint('🎯 Updating user challenges');
        final challengesResult = await ApiService.put(
          '${ApiConfig.gamification}/challenges/sync',
          challengesData,
        );

        if (challengesResult == null || challengesResult['success'] != true) {
          debugPrint(
            '❌ Failed to update user challenges: ${challengesResult?['message'] ?? 'Unknown error'}',
          );
          success = false;
        } else {
          debugPrint('✅ Successfully updated user challenges');
        }
        */
      }

      return success;
    } catch (e) {
      debugPrint('❌ Error saving gamification data to backend: $e');
      return false;
    }
  }

  // Check and update streak
  Future<void> _checkAndUpdateStreak() async {
    try {
      // Try to get gamification data from backend first
      final backendData = await _getGamificationDataFromBackend();

      if (backendData != null && backendData['streak'] != null) {
        // Use backend streak data if available
        _currentStreak = backendData['streak'];
        if (backendData['longestStreak'] != null) {
          _longestStreak = backendData['longestStreak'];
        }
        return;
      }

      // Fallback to local streak calculation
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      if (_lastActivityDate == null) {
        // First time using the app
        _currentStreak = 1;
        _lastActivityDate = today;
        return;
      }

      final lastDate = DateTime(
        _lastActivityDate!.year,
        _lastActivityDate!.month,
        _lastActivityDate!.day,
      );

      final difference = today.difference(lastDate).inDays;

      if (difference == 0) {
        // Already recorded activity today
        return;
      } else if (difference == 1) {
        // Consecutive day
        _currentStreak++;
        _lastActivityDate = today;

        // Update longest streak if current is longer
        if (_currentStreak > _longestStreak) {
          _longestStreak = _currentStreak;
        }

        // Award streak bonus
        _awardStreakBonus();
      } else {
        // Streak broken
        _currentStreak = 1;
        _lastActivityDate = today;
      }

      await _saveGamificationData();
    } catch (e) {
      debugPrint('Error checking streak: $e');
    }
  }

  // Get gamification data from backend
  Future<Map<String, dynamic>?> _getGamificationDataFromBackend() async {
    try {
      final data = await ApiService.get(ApiConfig.gamification);

      if (data != null && data['success'] == true && data['data'] != null) {
        return data['data'];
      }

      return null;
    } catch (e) {
      debugPrint('Error fetching gamification data from backend: $e');
      return null;
    }
  }

  // Award streak bonus
  void _awardStreakBonus() {
    // Award coins based on streak milestones
    if (_currentStreak % 7 == 0) {
      // Weekly streak bonus
      _financeCoins += 50;
      _showNotification(
        'Weekly Streak Bonus!',
        'You earned 50 Finance Coins for a 7-day streak!',
      );
    } else if (_currentStreak % 30 == 0) {
      // Monthly streak bonus
      _financeCoins += 200;
      _showNotification(
        'Monthly Streak Bonus!',
        'You earned 200 Finance Coins for a 30-day streak!',
      );
    } else {
      // Regular daily bonus - start small
      _financeCoins += 5;
    }

    // Check for streak achievements
    _checkStreakAchievements();
  }

  // Record user activity to maintain streak
  Future<void> recordActivity() async {
    try {
      // Initialize if not already done
      if (!_isInitialized) {
        await _initialize();
      } else {
        // Try to record activity on the backend first
        final backendSuccess = await _recordActivityOnBackend();

        if (!backendSuccess) {
          // If backend update fails, update locally
          await _checkAndUpdateStreak();
          await _checkAndGenerateDailyChallenges();
          await _checkAchievements();
          await _saveGamificationData();
        } else {
          // If backend update succeeds, refresh data from backend
          final backendData = await _fetchGamificationDataFromBackend();
          if (backendData != null) {
            await _processBackendGamificationData(backendData);
          }
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error recording gamification activity: $e');
      // Rethrow to allow UI to handle the error
      rethrow;
    }
  }

  // Record activity on backend
  Future<bool> _recordActivityOnBackend() async {
    // TEMPORARILY DISABLED BACKEND SYNC FOR ACTIVITY RECORDING DUE TO 404 ERROR
    debugPrint(
      '⚠️ Backend activity recording is temporarily disabled due to API 404 error',
    );
    debugPrint(
      '💾 Using local activity tracking instead',
    );
    
    // Return false to trigger fallback to local updates
    // This is handled in the calling methods which will update local data
    return false;
    
    /* Original implementation - kept for future re-enabling
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null || token.isEmpty) {
        debugPrint(
          '⚠️ No auth token found. Cannot record activity on backend.',
        );
        return false;
      }

      // Use the correct path: /api/gamification/activities instead of /record-activity
      debugPrint(
        '📝 Recording activity on backend: ${ApiConfig.gamification}/activities',
      );
      final data = await ApiService.post(
        '${ApiConfig.gamification}/activities',
        {
          'type': 'app_usage',
          'timestamp': DateTime.now().toIso8601String(),
          'details': {'action': 'app_opened', 'platform': 'mobile'},
        },
      );

      if (data != null && data['success'] == true) {
        debugPrint('✅ Successfully recorded activity on backend');
        return true;
      } else {
        debugPrint(
          '❌ Failed to record activity: ${data != null ? data['message'] : 'No response data'}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error recording activity on backend: $e');
      return false;
    }
    */
  }

  // Complete a challenge
  Future<bool> completeChallenge(String challengeId) async {
    try {
      // Find the challenge
      final challenge = _dailyChallenges.firstWhere(
        (c) => c.id == challengeId,
        orElse:
            () => _weeklyChallenges.firstWhere(
              (c) => c.id == challengeId,
              orElse:
                  () => Challenge(
                    id: challengeId,
                    title: 'Unknown Challenge',
                    description: 'This challenge does not exist',
                    type: 'unknown',
                    rewardCoins: 0,
                    rewardPoints: 0,
                    targetValue: 1,
                    currentValue: 0,
                    isCompleted: false,
                  ),
            ),
      );

      if (challenge.isCompleted) {
        debugPrint('Challenge $challengeId is already completed');
        return false;
      }

      // Try to complete the challenge on the backend first
      final backendSuccess = await _updateChallengeCompletionOnBackend(
        challengeId,
      );

      if (backendSuccess) {
        // If backend update succeeds, refresh data from backend
        final backendData = await _fetchGamificationDataFromBackend();
        if (backendData != null) {
          await _processBackendGamificationData(backendData);
          return true;
        }
      }

      // If backend update fails, update locally
      challenge.isCompleted = true;
      challenge.currentValue = challenge.targetValue;

      // Award XP and coins
      await addXP(challenge.rewardPoints);
      await _addCoins(challenge.rewardCoins);

      // Show notification
      _showNotification(
        'Challenge Completed!',
        'You completed "${challenge.title}" and earned ${challenge.rewardPoints} XP and ${challenge.rewardCoins} coins!',
      );

      await _saveGamificationData();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error completing challenge: $e');
      return false;
    }
  }

  // Add coins to user's balance
  Future<void> _addCoins(int amount) async {
    if (amount <= 0) return;

    _financeCoins += amount;
    await _saveGamificationData();
    notifyListeners();

    // Show notification for coins earned
    if (amount > 0) {
      _showNotification('Coins Earned', 'You earned $amount finance coins!');
    }
  }

  // Check and generate daily challenges if needed
  Future<void> _checkAndGenerateDailyChallenges() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final prefs = await SharedPreferences.getInstance();
      final lastChallengeGenDateStr = prefs.getString(
        'last_challenge_generation_date',
      );
      final lastChallengeGenDate =
          lastChallengeGenDateStr != null
              ? DateTime.parse(lastChallengeGenDateStr)
              : null;

      // If challenges have never been generated or were generated on a different day
      if (lastChallengeGenDate == null ||
          lastChallengeGenDate.day != today.day ||
          _dailyChallenges.isEmpty) {
        // Clear old challenges
        _dailyChallenges.clear();

        // Generate new ones
        _generateDailyChallenges();

        // Save the generation date
        await prefs.setString(
          'last_challenge_generation_date',
          today.toIso8601String(),
        );
        await _saveChallenges();
      }
    } catch (e) {
      debugPrint('Error generating daily challenges: $e');
      // If challenge generation fails, create a simple default challenge
      if (_dailyChallenges.isEmpty) {
        _createDefaultChallenge();
      }
    }
  }

  // Generate daily challenges
  Future<void> _generateDailyChallenges() async {
    // Generate 3 random challenges
    final challengeTypes = [
      'transaction',
      'budget',
      'saving',
      'streak',
      'education',
    ];
    final random = Random();

    // Shuffle the types to get random ones
    challengeTypes.shuffle(random);

    // Take the first 3 types (or fewer if there are less than 3 types)
    final selectedTypes = challengeTypes.take(3).toList();

    // Create challenges for each selected type
    for (final type in selectedTypes) {
      final challenge = _createChallengeByType(type);
      _dailyChallenges.add(challenge);
    }
  }

  // Create a default challenge if generation fails
  void _createDefaultChallenge() {
    final challenge = Challenge(
      id: 'default_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Daily Login',
      description: 'Log in to the app today',
      type: 'streak',
      rewardCoins: 5,
      rewardPoints: 10,
      targetValue: 1,
      currentValue: 1, // Already completed since they're logged in
      isCompleted: true,
    );

    _dailyChallenges.add(challenge);
  }

  // Create a challenge based on type
  Challenge _createChallengeByType(String type) {
    final random = Random();
    final now = DateTime.now();
    final id = '${type}_${now.millisecondsSinceEpoch}_${random.nextInt(1000)}';

    switch (type) {
      case 'transaction':
        return Challenge(
          id: id,
          title: 'Record a Transaction',
          description: 'Add a new income or expense transaction today',
          type: type,
          rewardCoins: 10,
          rewardPoints: 15,
          targetValue: 1,
          currentValue: 0,
          isCompleted: false,
        );

      case 'budget':
        return Challenge(
          id: id,
          title: 'Check Your Budget',
          description: 'Review your budget categories',
          type: type,
          rewardCoins: 5,
          rewardPoints: 10,
          targetValue: 1,
          currentValue: 0,
          isCompleted: false,
        );

      case 'saving':
        return Challenge(
          id: id,
          title: 'Savings Goal Progress',
          description: 'Add money to one of your savings goals',
          type: type,
          rewardCoins: 15,
          rewardPoints: 20,
          targetValue: 1,
          currentValue: 0,
          isCompleted: false,
        );

      case 'streak':
        return Challenge(
          id: id,
          title: 'Maintain Your Streak',
          description: 'Log in tomorrow to maintain your activity streak',
          type: type,
          rewardCoins: 5,
          rewardPoints: 5,
          targetValue: 1,
          currentValue: 0,
          isCompleted: false,
        );

      case 'education':
        return Challenge(
          id: id,
          title: 'Financial Tip',
          description: 'Learn a new financial tip today',
          type: type,
          rewardCoins: 5,
          rewardPoints: 10,
          targetValue: 1,
          currentValue: 0,
          isCompleted: false,
        );

      default:
        return Challenge(
          id: id,
          title: 'App Activity',
          description: 'Complete an activity in the app',
          type: 'general',
          rewardCoins: 5,
          rewardPoints: 5,
          targetValue: 1,
          currentValue: 0,
          isCompleted: false,
        );
    }
  }

  // Load challenges from storage
  Future<void> _loadChallenges() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if user is authenticated
      final token = prefs.getString('auth_token');
      bool isAuthenticated = token != null && token.isNotEmpty;

      // First try to load from backend if user is authenticated
      if (isAuthenticated) {
        debugPrint(
          'User is authenticated. Attempting to fetch challenges from backend',
        );
        final backendChallenges = await _getChallengesFromBackend();

        if (backendChallenges != null && backendChallenges.isNotEmpty) {
          debugPrint(
            'Successfully loaded ${backendChallenges.length} challenges from backend',
          );
          _dailyChallenges = backendChallenges;
          return; // Successfully loaded from backend, no need to load from local storage
        } else {
          debugPrint(
            'Failed to load challenges from backend or no challenges found, falling back to local storage',
          );
        }
      } else {
        debugPrint(
          'User not authenticated. Loading challenges from local storage only',
        );
      }

      // Fall back to local storage
      final challengesJson = prefs.getString(_dailyChallengesKey);

      if (challengesJson != null) {
        final List<dynamic> decoded = jsonDecode(challengesJson);
        _dailyChallenges =
            decoded
                .map((item) => Challenge.fromJson(item as Map<String, dynamic>))
                .toList();
        debugPrint(
          'Loaded ${_dailyChallenges.length} challenges from local storage',
        );
      } else {
        debugPrint('No challenges found in local storage');
        _dailyChallenges = [];
      }
    } catch (e) {
      debugPrint('Error loading challenges: $e');
      // If loading fails, just use an empty list
      _dailyChallenges = [];
    }
  }

  // Save challenges to storage
  Future<void> _saveChallenges() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if user is authenticated
      final token = prefs.getString('auth_token');
      bool isAuthenticated = token != null && token.isNotEmpty;

      // First save to backend if user is authenticated
      if (isAuthenticated) {
        await _saveChallengesOnBackend();
      }

      // Always save locally as a backup
      final challengesJson = jsonEncode(
        _dailyChallenges.map((c) => c.toJson()).toList(),
      );
      await prefs.setString(_dailyChallengesKey, challengesJson);
    } catch (e) {
      debugPrint('Error saving challenges: $e');
    }
  }

  // Save challenges to backend
  Future<bool> _saveChallengesOnBackend() async {
    try {
      debugPrint(
        'Saving challenges to backend: ${ApiConfig.gamification}/challenges',
      );

      // Prepare data to send to backend
      final Map<String, dynamic> challengesData = {
        'challenges': _dailyChallenges.map((c) => c.toJson()).toList(),
      };

      final data = await ApiService.put(
        '${ApiConfig.gamification}/challenges',
        challengesData,
      );

      if (data != null && data['success'] == true) {
        debugPrint('Successfully saved challenges to backend');
        return true;
      }

      debugPrint(
        'Failed to save challenges to backend: ${data?['message'] ?? 'Unknown error'}',
      );
      return false;
    } catch (e) {
      debugPrint('Error saving challenges to backend: $e');
      return false;
    }
  }

  // Update challenge progress
  Future<void> updateChallengeProgress(String challengeId, int progress) async {
    try {
      // Try to complete challenge on backend first
      final backendSuccess = await _updateChallengeCompletionOnBackend(
        challengeId,
      );

      if (backendSuccess) {
        // If backend update was successful, refresh challenges from backend
        final backendChallenges = await _getChallengesFromBackend();
        if (backendChallenges != null) {
          _dailyChallenges = backendChallenges;
          await _saveChallenges();
          notifyListeners();
          return;
        }
      }

      // Fallback to local challenge update
      // Find the challenge
      Challenge? challenge = _findChallengeById(challengeId);
      if (challenge == null) return;

      // Update progress
      challenge.currentValue += progress;

      // Check if challenge is completed
      if (!challenge.isCompleted &&
          challenge.currentValue >= challenge.targetValue) {
        challenge.isCompleted = true;

        // Award rewards
        _financeCoins += challenge.rewardCoins;
        _currentXP += challenge.rewardPoints;

        // Check for level up
        _checkForLevelUp();

        // Show notification
        _showNotification(
          'Challenge Completed!',
          'You completed: ${challenge.title} and earned ${challenge.rewardCoins} coins and ${challenge.rewardPoints} XP!',
        );
      }

      // Save changes
      await _saveChallenges();
      await _saveGamificationData();

      notifyListeners();
    } catch (e) {
      debugPrint('Error updating challenge progress: $e');
    }
  }

  // Update challenge completion on backend
  Future<bool> _updateChallengeCompletionOnBackend(String challengeId) async {
    // TEMPORARILY DISABLED BACKEND SYNC FOR CHALLENGE COMPLETION DUE TO API ERRORS
    debugPrint(
      '⚠️ Backend challenge completion is temporarily disabled due to API errors',
    );
    debugPrint(
      '💾 Using local challenge completion instead for challenge ID: $challengeId',
    );
    
    // Return false to trigger fallback to local updates
    // This is handled in the calling methods which will update local data
    return false;
    
    /* Original implementation - kept for future re-enabling
    try {
      final data = await ApiService.post(
        '${ApiConfig.gamification}/challenges/$challengeId/complete',
        {},
      );

      return data != null && data['success'] == true;
    } catch (e) {
      debugPrint('Error completing challenge on backend: $e');
      return false;
    }
    */
  }

  // Find a challenge by ID
  Challenge? _findChallengeById(String challengeId) {
    try {
      return _dailyChallenges.firstWhere((c) => c.id == challengeId);
    } catch (e) {
      return null;
    }
  }

  // Add XP
  Future<void> addXP(int amount) async {
    if (amount <= 0) return;

    // Try to update XP on backend first
    final backendSuccess = await _updateXPOnBackend(amount);

    if (!backendSuccess) {
      // If backend update fails, update locally
      _currentXP += amount;

      // Check if level up
      final nextLevelXP = getXPForNextLevel(_currentLevel);
      if (_currentXP >= nextLevelXP) {
        await _levelUp();
      }

      await _saveGamificationData();
    } else {
      // If backend update succeeds, refresh data from backend
      final backendData = await _fetchGamificationDataFromBackend();
      if (backendData != null) {
        await _processBackendGamificationData(backendData);
      }
    }

    notifyListeners();
  }

  // Update XP on backend
  Future<bool> _updateXPOnBackend(int amount) async {
    try {
      debugPrint('Updating XP on backend: ${ApiConfig.gamification}/xp');
      final data = await ApiService.post('${ApiConfig.gamification}/xp', {
        'amount': amount,
      });

      return data != null && data['success'] == true;
    } catch (e) {
      debugPrint('Error updating XP on backend: $e');
      return false;
    }
  }

  // Check if user leveled up
  void _checkForLevelUp() {
    final nextLevelXP = getXPForNextLevel(_currentLevel);
    if (_currentXP >= nextLevelXP) {
      _currentLevel++;

      // Show notification
      _showNotification(
        'Level Up!',
        'Congratulations! You reached level $_currentLevel!',
      );
    }
  }

  // Level up the user
  Future<void> _levelUp() async {
    _currentLevel++;

    // Show notification
    _showNotification(
      'Level Up!',
      'Congratulations! You reached level $_currentLevel!',
    );

    // Award bonus coins for leveling up
    await _addCoins(_currentLevel * 50); // 50 coins per level

    await _saveGamificationData();
    notifyListeners();
  }

  // Check achievements
  Future<void> _checkAchievements() async {
    try {
      // First try to get achievements from backend
      final backendAchievements = await _getAchievementsFromBackend();

      if (backendAchievements != null) {
        // Use backend achievements if available
        // Process the backend achievements
        debugPrint('Using backend achievements: ${backendAchievements.length}');
        // TODO: Process backend achievements
        return;
      }

      // Fallback to local achievement checking
      final profile = _profileService.currentProfile;
      final achievements = List<Achievement>.from(profile.achievements);
      bool achievementsUpdated = false;

      // Check for transaction-related achievements
      if (profile.completedTransactions >= 10) {
        achievementsUpdated =
            _checkAndUnlockAchievement(achievements, 'ach_001', true) ||
            achievementsUpdated;
      }

      // Check for budget-related achievements
      // This would be based on actual budget data

      // Check for savings-related achievements
      final savingsGoals = _financeService.savingsGoals;
      if (savingsGoals.isNotEmpty) {
        achievementsUpdated =
            _checkAndUnlockAchievement(achievements, 'ach_002', true) ||
            achievementsUpdated;
      }

      // Check streak achievements
      achievementsUpdated = _checkStreakAchievements() || achievementsUpdated;

      // Update profile if achievements changed
      if (achievementsUpdated) {
        final updatedProfile = profile.copyWith(achievements: achievements);
        await _profileService.updateUserProfile(updatedProfile);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error checking achievements: $e');
    }
  }

  // Get achievements from backend
  Future<List<dynamic>?> _getAchievementsFromBackend() async {
    try {
      final data = await ApiService.get(
        '${ApiConfig.gamification}/achievements',
      );

      if (data != null && data['success'] == true && data['data'] != null) {
        return data['data']['achievements'];
      }

      return null;
    } catch (e) {
      debugPrint('Error fetching achievements from backend: $e');
      return null;
    }
  }

  // Get challenges from backend
  Future<List<Challenge>?> _getChallengesFromBackend() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null || token.isEmpty) {
        debugPrint(
          '⚠️ No auth token found. Cannot fetch challenges from backend.',
        );
        return null;
      }

      debugPrint(
        '🔍 Fetching challenges from backend: ${ApiConfig.gamification}/challenges',
      );
      final data = await ApiService.get('${ApiConfig.gamification}/challenges');

      if (data != null) {
        // Handle different response formats
        List<dynamic>? challengesJson;

        if (data['success'] == true && data['data'] != null) {
          // Format: {success: true, data: {challenges: [...]}}
          if (data['data']['challenges'] != null) {
            challengesJson = data['data']['challenges'];
          }
          // Format: {success: true, data: [...]}
          else if (data['data'] is List) {
            challengesJson = data['data'];
          }
        }
        // Format: {challenges: [...]} or direct array
        else if (data['challenges'] != null) {
          challengesJson = data['challenges'];
        } else if (data is List) {
          challengesJson = data;
        }

        if (challengesJson != null && challengesJson.isNotEmpty) {
          final challenges =
              challengesJson.map((json) => Challenge.fromJson(json)).toList();
          debugPrint(
            '✅ Successfully fetched ${challenges.length} challenges from backend',
          );
          return challenges;
        }
      }

      debugPrint('⚠️ No challenges found in backend response');
      return null;
    } catch (e) {
      debugPrint('❌ Error fetching challenges from backend: $e');
      return null;
    }
  }

  // Check streak achievements
  bool _checkStreakAchievements() {
    try {
      final profile = _profileService.currentProfile;
      final achievements = List<Achievement>.from(profile.achievements);
      bool achievementsUpdated = false;

      achievementsUpdated =
          _checkAndUnlockAchievement(
            achievements,
            'week_streak',
            _currentStreak >= 7,
          ) ||
          achievementsUpdated;

      achievementsUpdated =
          _checkAndUnlockAchievement(
            achievements,
            'month_streak',
            _currentStreak >= 30,
          ) ||
          achievementsUpdated;

      return achievementsUpdated;
    } catch (e) {
      debugPrint('Error checking streak achievements: $e');
      return false;
    }
  }

  // Check and unlock an achievement
  bool _checkAndUnlockAchievement(
    List<Achievement> achievements,
    String achievementId,
    bool condition,
  ) {
    if (!condition) return false;

    final achievementIndex = achievements.indexWhere(
      (a) => a.id == achievementId,
    );
    if (achievementIndex == -1) return false;

    final achievement = achievements[achievementIndex];
    if (achievement.isUnlocked) return false;

    // Unlock the achievement
    achievements[achievementIndex] = Achievement(
      id: achievement.id,
      title: achievement.title,
      description: achievement.description,
      icon: achievement.icon,
      isUnlocked: true,
      dateUnlocked: DateTime.now(),
      xpReward: achievement.xpReward,
    );

    // Show notification
    _showNotification(
      'Achievement Unlocked!',
      'You unlocked: ${achievement.title}',
    );

    // Award bonus coins
    _financeCoins += 50;

    return true;
  }

  // Show notification
  void _showNotification(String title, String message) {
    // This will be implemented to show in-app notifications
    debugPrint('NOTIFICATION: $title - $message');

    // Create a notification in the backend
    _createNotificationInBackend(title, message);
  }

  // Create a notification in the backend
  Future<void> _createNotificationInBackend(
    String title,
    String message,
  ) async {
    try {
      // Try to use the notification service if available
      try {
        // This is a local notification since we can't create backend notifications directly
        // (they're admin-only)
        final notificationService = NotificationApiService();
        await notificationService.createLocalNotification(
          title,
          message,
          type: 'gamification',
        );
        debugPrint('Created local notification via service: $title - $message');
      } catch (e) {
        // If notification service isn't available, just log it
        debugPrint('Would create notification in backend: $title - $message');
      }
    } catch (e) {
      debugPrint('Error creating notification: $e');
    }
  }
}
