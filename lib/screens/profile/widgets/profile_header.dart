import 'package:flutter/material.dart';
import '../../../models/user_profile_model.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:io';

class ProfileHeader extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback? onProfileUpdated;

  const ProfileHeader({
    Key? key,
    required this.profile,
    this.onProfileUpdated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1E1E1E),
                  const Color(0xFF2D2D2D),
                ]
              : [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.7),
                ],
        ),
      ),
      child: Stack(
        children: [
          // Animated background particles
          ...List.generate(10, (index) {
            final double size = 5.0 + (index * 2.0);
            final double opacity = 0.05 + (index * 0.01);
            
            return Positioned(
              top: 20 + (index * 15),
              right: 20 + (index * 12),
              child: FadeInDown(
                delay: Duration(milliseconds: 100 * index),
                duration: const Duration(milliseconds: 500),
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(opacity),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
          
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 16),
            child: Row(
              children: [
                // Profile Picture with Glow Effect
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Hero(
                    tag: 'profile-picture',
                    child: GestureDetector(
                      onTap: () {
                        // Show full profile picture
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            backgroundColor: Colors.transparent,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: profile.avatarUrl.startsWith('file://')
                                    ? Image.file(
                                        File(profile.avatarUrl.replaceFirst('file://', '')),
                                        width: 300,
                                        height: 300,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.network(
                                        profile.avatarUrl,
                                        width: 300,
                                        height: 300,
                                        fit: BoxFit.cover,
                                      ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(Icons.close),
                                  label: const Text('Close'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: profile.avatarUrl.startsWith('file://') 
                          ? FileImage(File(profile.avatarUrl.replaceFirst('file://', ''))) as ImageProvider
                          : NetworkImage(profile.avatarUrl),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FadeInRight(
                        duration: const Duration(milliseconds: 500),
                        child: Text(
                          profile.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      FadeInRight(
                        duration: const Duration(milliseconds: 500),
                        delay: const Duration(milliseconds: 100),
                        child: Text(
                          profile.email,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      FadeInRight(
                        duration: const Duration(milliseconds: 500),
                        delay: const Duration(milliseconds: 200),
                        child: Text(
                          profile.phone,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Edit Profile Button
                FadeInRight(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 300),
                  child: IconButton(
                    onPressed: () async {
                      // Navigate to edit profile and wait for result
                      final result = await Navigator.pushNamed(context, '/edit');
                      
                      // If profile was updated, refresh the profile data
                      if (result == true && context.mounted) {
                        // Notify parent to refresh data
                        if (onProfileUpdated != null) {
                          onProfileUpdated!();
                        }
                      }
                    },
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: Colors.white,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
