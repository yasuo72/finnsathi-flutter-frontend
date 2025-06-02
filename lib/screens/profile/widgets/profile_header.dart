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
  
  // Helper method to build profile image with proper handling of different URL formats
  Widget _buildProfileImage(String imageUrl, double width, double height) {
    // Default image to show if URL is empty or invalid
    if (imageUrl.isEmpty) {
      return Image.asset(
        'assets/default_avatar.png',
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.person, color: Colors.white, size: width * 0.6);
        },
      );
    }
    
    // Handle local file paths
    if (imageUrl.startsWith('file://')) {
      return Image.file(
        File(imageUrl.replaceFirst('file://', '')),
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading local image: $error');
          return Icon(Icons.person, color: Colors.white, size: width * 0.6);
        },
      );
    }
    
    // Handle backend server paths that start with /uploads/
    if (imageUrl.startsWith('/uploads/')) {
      final baseUrl = 'https://finnsathi-ai-expense-monitor-production.up.railway.app';
      final fullUrl = '$baseUrl$imageUrl';
      print('Loading profile image from: $fullUrl');
      
      return Image.network(
        fullUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading network image: $error');
          return Icon(Icons.person, color: Colors.white, size: width * 0.6);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / 
                      loadingProgress.expectedTotalBytes!
                  : null,
              color: Colors.white,
              strokeWidth: 2,
            ),
          );
        },
      );
    }
    
    // Handle full URLs
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print('Error loading network image: $error');
        return Icon(Icons.person, color: Colors.white, size: width * 0.6);
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / 
                    loadingProgress.expectedTotalBytes!
                : null,
            color: Colors.white,
            strokeWidth: 2,
          ),
        );
      },
    );
  }

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
                                  child: _buildProfileImage(profile.avatarUrl, 300, 300),
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
                        backgroundColor: Colors.grey[300],
                        child: ClipOval(
                          child: SizedBox(
                            width: 80,
                            height: 80,
                            child: _buildProfileImage(profile.avatarUrl, 80, 80),
                          ),
                        ),
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
