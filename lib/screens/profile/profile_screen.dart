import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/l10n/app_localizations.dart';
import '../home/story_view_screen.dart';
import 'achievements_screen.dart';
import '../../core/models/story_entry.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _pickAvatar(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      context.read<UserProvider>().setAvatar(image.path);
    }
  }

  void _editProfile(BuildContext context, UserProvider user) {
    // Only localized briefly for the dialog, ideally passed in
    final l10n = AppLocalizations.of(context);
    final nameController = TextEditingController(text: user.name);
    final subtitleController = TextEditingController(text: user.subtitle);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text(l10n.get('edit_profile'), style: const TextStyle(color: Colors.black)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: l10n.get('name'),
                labelStyle: const TextStyle(color: Colors.grey),
                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: subtitleController,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: l10n.get('description'),
                labelStyle: const TextStyle(color: Colors.grey),
                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.get('cancel'), style: const TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              context.read<UserProvider>().updateProfile(
                nameController.text,
                subtitleController.text,
              );
              Navigator.pop(context);
            },
            child: Text(l10n.get('save'), style: const TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  void _openStory(BuildContext context, List<StoryEntry> stories, int index) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, _, __) => StoryViewScreen(stories: stories, initialIndex: index),
        opaque: false,
        transitionsBuilder: (context, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _showSettingsModal(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final userProvider = context.read<UserProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSettingsTile(icon: Icons.palette_outlined, title: l10n.get('settings_theme')),
                  _buildSettingsTile(icon: Icons.app_settings_alt_outlined, title: l10n.get('settings_icon')),
                  
                  // Notifications Switch
                  Consumer<UserProvider>(
                    builder: (context, user, _) {
                      return SwitchListTile(
                        secondary: const Icon(Icons.notifications_none_outlined, color: Colors.black),
                        title: Text(
                          l10n.get('settings_notifications'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
                        ),
                        value: user.notificationsEnabled,
                        onChanged: (val) {
                          user.toggleNotifications(val);
                        },
                        activeColor: Colors.black,
                      );
                    },
                  ),

                  _buildSettingsTile(icon: Icons.star_border, title: l10n.get('settings_rate')),
                  _buildSettingsTile(icon: Icons.support_agent, title: l10n.get('settings_contact')),
                  
                  // Language Selector
                  ListTile(
                    leading: const Icon(Icons.language, color: Colors.black),
                    title: Text(
                      l10n.get('settings_language'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
                    ),
                    trailing: DropdownButtonHideUnderline(
                      child: DropdownButton<Locale>(
                        value: userProvider.appLocale,
                        dropdownColor: Colors.white,
                        items: const [
                          DropdownMenuItem(value: Locale('en'), child: Text('English')),
                          DropdownMenuItem(value: Locale('ru'), child: Text('Русский')),
                        ],
                        onChanged: (Locale? newLocale) {
                          if (newLocale != null) {
                            userProvider.changeLanguage(newLocale);
                            Navigator.pop(context); // Close to refresh modal or just let Provider rebuild
                          }
                        },
                      ),
                    ),
                  ),

                  const Divider(height: 24),
                  _buildSettingsTile(
                    icon: Icons.logout,
                    title: l10n.get('settings_logout'),
                    color: Colors.red,
                    onTap: () {
                      Navigator.pop(context); 
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSettingsTile({required IconData icon, required String title, Color color = Colors.black, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
      onTap: onTap ?? () {},
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color kProfileBrown = const Color(0xffA68069); 
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: kProfileBrown,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Top Section
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings, color: Colors.white),
                          onPressed: () => _showSettingsModal(context),
                        ),
                      ],
                    ),
                    
                    Consumer<UserProvider>(
                      builder: (context, user, _) {
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () => _pickAvatar(context),
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 3),
                                  image: DecorationImage(
                                    image: user.avatarPath != null
                                        ? FileImage(File(user.avatarPath!))
                                        : const AssetImage('assets/images/user_avatar.png') as ImageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              user.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.subtitle,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Unified Edit Button
                            GestureDetector(
                              onTap: () => _editProfile(context, user),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                                ),
                                child: Text(
                                  l10n.get('edit_profile'), // Localized
                                  style: const TextStyle(color: Colors.white, fontSize: 13),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            Container(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 300,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Consumer<UserProvider>(
                builder: (context, user, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('${user.storyImages.length}', l10n.get('story_days')),
                          _buildDivider(),
                          _buildStatItem('${user.friendsCount}', l10n.get('friends')),
                          _buildDivider(),
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AchievementsScreen())),
                            child: _buildStatItem('${user.achievementsCount}', l10n.get('achievements')),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      const Divider(color: Color(0xFFEEEEEE)),
                      const SizedBox(height: 24),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.get('story_days'),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          if (user.storyImages.isNotEmpty)
                            Text(
                              l10n.get('expand'),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black.withValues(alpha: 0.5),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      if (user.storyImages.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              l10n.get('no_stories'), // Localized
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                          ),
                        )
                      else
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 4,
                            mainAxisSpacing: 4,
                          ),
                          itemCount: user.storyImages.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () => _openStory(context, user.storyImages, index),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: FileImage(user.storyImages[index].file),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      
                      const SizedBox(height: 40),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.black.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.black.withValues(alpha: 0.1),
    );
  }
}
