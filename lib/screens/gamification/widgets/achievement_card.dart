import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/user_profile_model.dart';

class AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final AnimationController animationController;
  final double delay;

  const AchievementCard({
    Key? key,
    required this.achievement,
    required this.animationController,
    required this.delay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate safe interval values that won't exceed 1.0
    final double startValue = (0.1 + delay).clamp(0.0, 0.8);
    final double endValue = math.min(startValue + 0.2, 1.0);
    
    final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Interval(startValue, endValue, curve: Curves.easeOut),
      ),
    );

    final scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Interval(startValue, endValue, curve: Curves.easeOutCubic),
      ),
    );

    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: fadeAnimation,
          child: Transform.scale(
            scale: scaleAnimation.value,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              width: 150,
              decoration: BoxDecoration(
                color:
                    achievement.isUnlocked
                        ? (isDark ? Colors.grey[850] : Colors.white)
                        : (isDark ? Colors.grey[900]?.withOpacity(0.7) : Colors.grey[200]),
                borderRadius: BorderRadius.circular(20),
                boxShadow:
                    achievement.isUnlocked
                        ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ]
                        : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color:
                              achievement.isUnlocked
                                  ? _getAchievementColor(
                                    achievement.id,
                                  ).withOpacity(0.2)
                                  : Colors.grey.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (achievement.isUnlocked)
                        Icon(
                          _getAchievementIcon(achievement.id),
                          color: _getAchievementColor(achievement.id),
                          size: 36,
                        )
                      else
                        Icon(
                          Icons.lock_outline,
                          color: isDark ? Colors.grey[600] : Colors.grey[400],
                          size: 36,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      achievement.title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color:
                            achievement.isUnlocked
                                ? (isDark ? Colors.white : Colors.black87)
                                : (isDark
                                    ? Colors.grey[500]
                                    : Colors.grey[600]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (achievement.isUnlocked)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getAchievementColor(
                          achievement.id,
                        ).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Unlocked',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _getAchievementColor(achievement.id),
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Locked',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.grey[500] : Colors.grey[600],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getAchievementIcon(String id) {
    // Map achievement IDs to appropriate icons
    switch (id) {
      case 'first_transaction':
        return Icons.payments_outlined;
      case 'savings_goal':
        return Icons.savings_outlined;
      case 'budget_master':
        return Icons.account_balance_wallet_outlined;
      case 'expense_tracker':
        return Icons.receipt_long_outlined;
      case 'investment_guru':
        return Icons.trending_up_outlined;
      default:
        return Icons.emoji_events_outlined;
    }
  }

  Color _getAchievementColor(String id) {
    // Map achievement IDs to appropriate colors
    switch (id) {
      case 'first_transaction':
        return Colors.green;
      case 'savings_goal':
        return Colors.blue;
      case 'budget_master':
        return Colors.purple;
      case 'expense_tracker':
        return Colors.orange;
      case 'investment_guru':
        return Colors.teal;
      default:
        return Colors.amber;
    }
  }
}
