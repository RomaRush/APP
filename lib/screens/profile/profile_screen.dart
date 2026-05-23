import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/user_provider.dart';
import '../home/story_view_screen.dart';
import 'achievements_screen.dart';
import '../../core/models/story_entry.dart';
import '../stats/stats_screen.dart';
import '../../core/l10n/app_localizations.dart';
import 'friends_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _scanQRFromGallery(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final scanner = MobileScannerController();
    try {
      final BarcodeCapture? capture = await scanner.analyzeImage(image.path);
      if (capture != null && capture.barcodes.isNotEmpty) {
        final code = capture.barcodes.first.rawValue;
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: const Color(0xFF13131F),
              title: const Text('QR-код найден', style: TextStyle(color: Colors.white)),
              content: SelectableText(code ?? 'Пусто', style: const TextStyle(color: Colors.white70)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Закрыть', style: TextStyle(color: AppTheme.accentBlue)),
                ),
              ],
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('QR-код не обнаружен на фото')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка сканирования: $e')),
        );
      }
    } finally {
      scanner.dispose();
    }
  }

  Future<void> _pickAvatar(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null && context.mounted) {
      context.read<UserProvider>().setAvatar(image.path);
    }
  }

  void _editProfile(BuildContext context, UserProvider user) {
    final nameController = TextEditingController(text: user.name);
    final subtitleController = TextEditingController(text: user.subtitle);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: _DarkSheet(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Редактировать', style: AppTheme.headlineStyle.copyWith(fontSize: 22)),
              const SizedBox(height: 24),
              _ModalTextField(controller: nameController, label: 'Имя'),
              const SizedBox(height: 14),
              _ModalTextField(controller: subtitleController, label: 'Описание'),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<UserProvider>().updateProfile(nameController.text, subtitleController.text);
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.white,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: Text('Сохранить', style: AppTheme.buttonTextStyle),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSettingsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DarkSheet(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Настройки', style: AppTheme.titleStyle),
            const SizedBox(height: 16),
            _SettingsTile(icon: Icons.palette_outlined, title: 'Обои', onTap: () {
              Navigator.pop(ctx);
              _showWallpaperPicker(context);
            }),
            Consumer<UserProvider>(
              builder: (context, user, _) => SwitchListTile(
                secondary: const Icon(Icons.notifications_none_outlined, color: AppTheme.white70),
                title: Text(AppLocalizations.of(context).get('settings_notifications'), style: AppTheme.bodyStyle.copyWith(color: AppTheme.white)),
                value: user.notificationsEnabled,
                onChanged: (val) => user.toggleNotifications(val),
                activeTrackColor: AppTheme.accentGreen,
                contentPadding: const EdgeInsets.symmetric(horizontal: 0),
              ),
            ),
            _SettingsTile(icon: Icons.language_rounded, title: AppLocalizations.of(context).get('settings_language'), onTap: () {
              Navigator.pop(ctx);
              _showLanguagePicker(context);
            }),
            _SettingsTile(icon: Icons.star_border_rounded, title: AppLocalizations.of(context).get('settings_rate')),
            _SettingsTile(icon: Icons.support_agent_rounded, title: 'Поддержка'),
            _SettingsTile(icon: Icons.qr_code_scanner_rounded, title: 'Сканировать QR с фото', onTap: () {
              Navigator.pop(ctx);
              _scanQRFromGallery(context);
            }),
            const Divider(height: 24, color: AppTheme.white12),
            _SettingsTile(
              icon: Icons.logout_rounded, title: AppLocalizations.of(context).get('settings_logout'),
              color: AppTheme.errorRed, onTap: () {
                Navigator.pop(ctx);
                context.read<UserProvider>().logout();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DarkSheet(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Язык приложения', style: AppTheme.titleStyle),
            const SizedBox(height: 16),
            Consumer<UserProvider>(
              builder: (context, user, _) {
                final currentLang = user.appLocale.languageCode;
                return Column(
                  children: [
                    _LangTile(title: 'Русский', code: 'ru', isSelected: currentLang == 'ru',
                        onTap: () { context.read<UserProvider>().setAppLocale('ru'); Navigator.pop(ctx); }),
                    _LangTile(title: 'English', code: 'en', isSelected: currentLang == 'en',
                        onTap: () { context.read<UserProvider>().setAppLocale('en'); Navigator.pop(ctx); }),
                    _LangTile(title: '中文 (Chinese)', code: 'zh', isSelected: currentLang == 'zh',
                        onTap: () { context.read<UserProvider>().setAppLocale('zh'); Navigator.pop(ctx); }),
                  ],
                );
              }
            ),
          ],
        ),
      ),
    );
  }

  void _showWallpaperPicker(BuildContext context) {
    final wallpapers = [
      'assets/images/home_bg_dark.png',
      'assets/images/wallpapers/IMG_0062.jpeg',
      'assets/images/wallpapers/IMG_0063.jpeg',
      'assets/images/wallpapers/IMG_0064.jpeg',
      'assets/images/wallpapers/IMG_0065.jpeg',
      'assets/images/wallpapers/IMG_0066.jpeg',
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DarkSheet(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Обои', style: AppTheme.titleStyle),
            const SizedBox(height: 20),
            SizedBox(
              height: 150,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: wallpapers.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final wp = wallpapers[index];
                  return Consumer<UserProvider>(
                    builder: (context, user, _) {
                      final isSelected = user.wallpaperPath == wp;
                      return GestureDetector(
                        onTap: () {
                          context.read<UserProvider>().setWallpaper(wp);
                          Navigator.pop(ctx);
                        },
                        child: AnimatedContainer(
                          duration: 200.ms,
                          width: 96,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected ? AppTheme.accentIndigo : AppTheme.white12,
                              width: isSelected ? 2.5 : 1,
                            ),
                            image: DecorationImage(image: AssetImage(wp), fit: BoxFit.cover),
                          ),
                          child: isSelected
                              ? Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: AppTheme.accentIndigo.withValues(alpha: 0.35),
                                  ),
                                  child: const Center(child: Icon(Icons.check_rounded, color: Colors.white, size: 30)),
                                )
                              : null,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openStory(BuildContext context, List<StoryEntry> stories, int index) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, _, __) => StoryViewScreen(stories: stories, initialIndex: index),
        opaque: false,
        transitionsBuilder: (context, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Consumer<UserProvider>(
              builder: (context, user, _) => Image.asset(user.wallpaperPath, fit: BoxFit.cover),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x70000000), Color(0x20000000), Color(0xFF080810)],
                  stops: [0.0, 0.3, 0.72],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings_outlined, color: AppTheme.white),
                          onPressed: () => _showSettingsModal(context),
                        ),
                      ],
                    ),
                  ),
                  Consumer<UserProvider>(
                    builder: (context, user, _) {
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () => _pickAvatar(context),
                            child: Hero(
                              tag: 'profile_avatar',
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: 104, height: 104,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppTheme.white.withValues(alpha: 0.25), width: 2),
                                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8))],
                                      image: DecorationImage(
                                        image: user.avatarPath != null
                                            ? FileImage(File(user.avatarPath!)) as ImageProvider
                                            : const AssetImage('assets/images/user_avatar.png'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 2, right: 2,
                                    child: Container(
                                      width: 28, height: 28,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppTheme.accentIndigo,
                                        border: Border.all(color: AppTheme.primaryDark, width: 2),
                                      ),
                                      child: const Icon(Icons.edit_rounded, size: 13, color: Colors.white),
                                    ),
                                  ),
                                  Positioned(
                                    top: -6, left: -6,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.1),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.star_rounded, size: 15, color: Colors.white),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${user.userPoints}',
                                                style: const TextStyle(
                                                  color: Colors.white, 
                                                  fontSize: 13, 
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.9, 0.9)),
                          const SizedBox(height: 16),
                          Text(user.name, style: AppTheme.headlineStyle.copyWith(fontSize: 26))
                              .animate().fadeIn(duration: 400.ms, delay: 100.ms),
                          const SizedBox(height: 4),
                          Text(user.subtitle, style: AppTheme.captionStyle.copyWith(fontSize: 13))
                              .animate().fadeIn(duration: 400.ms, delay: 150.ms),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () => _editProfile(context, user),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
                                  decoration: BoxDecoration(
                                    color: AppTheme.white08,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: AppTheme.white12),
                                  ),
                                  child: Text('Редактировать', style: AppTheme.captionStyle.copyWith(color: AppTheme.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatsScreen())),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
                                  decoration: BoxDecoration(
                                    color: AppTheme.white08,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: AppTheme.white12),
                                  ),
                                  child: Text('Статистика', style: AppTheme.captionStyle.copyWith(color: AppTheme.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ],
                          ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
                          const SizedBox(height: 36),
                        ],
                      );
                    },
                  ),
                  // Content pane
                  Container(
                    constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height * 0.55),
                    decoration: const BoxDecoration(
                      color: Color(0xFF080810),
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                    ),
                    child: Consumer<UserProvider>(
                      builder: (context, user, _) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(24, 32, 24, 120),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(child: _StatCell(value: '${user.storyImages.length}', label: 'Дней')),
                                  Container(width: 1, height: 40, color: AppTheme.white12),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FriendsScreen())),
                                      child: _StatCell(value: '${user.friendsCount}', label: 'Друзей'),
                                    ),
                                  ),
                                  Container(width: 1, height: 40, color: AppTheme.white12),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AchievementsScreen())),
                                      child: _StatCell(value: '${user.achievementsCount}', label: 'Достижений'),
                                    ),
                                  ),
                                ],
                              ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
                              const SizedBox(height: 36),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Дни', style: AppTheme.titleStyle),
                                  if (user.storyImages.isNotEmpty)
                                    Text('Все →', style: AppTheme.captionStyle.copyWith(color: AppTheme.accentIndigo, fontSize: 13)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (user.storyImages.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 40),
                                  child: Center(
                                    child: Column(children: [
                                      Icon(Icons.photo_library_outlined, size: 48, color: AppTheme.white12),
                                      const SizedBox(height: 12),
                                      Text('Здесь будут твои моменты', style: AppTheme.captionStyle),
                                    ]),
                                  ),
                                )
                              else
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3, crossAxisSpacing: 4, mainAxisSpacing: 4,
                                  ),
                                  itemCount: user.storyImages.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () => _openStory(context, user.storyImages, index),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(index == 0 ? 16 : 8),
                                        child: Image.file(user.storyImages[index].file, fit: BoxFit.cover),
                                      ),
                                    );
                                  },
                                ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Local helpers ─────────────────────────────────────────────────────────────

class _DarkSheet extends StatelessWidget {
  final Widget child;
  const _DarkSheet({required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF13131F),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(color: AppTheme.white12, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String value;
  final String label;
  const _StatCell({required this.value, required this.label});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value, style: AppTheme.headlineStyle.copyWith(fontSize: 22)),
      const SizedBox(height: 2),
      Text(label, style: AppTheme.captionStyle.copyWith(fontSize: 11)),
    ]);
  }
}

class _ModalTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  const _ModalTextField({required this.controller, required this.label});
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: AppTheme.bodyStyle.copyWith(color: AppTheme.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTheme.captionStyle.copyWith(fontSize: 13),
        filled: true,
        fillColor: AppTheme.white08,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback? onTap;
  const _SettingsTile({required this.icon, required this.title, this.color = AppTheme.white, this.onTap});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(title, style: AppTheme.bodyStyle.copyWith(color: color, fontWeight: FontWeight.w500)),
      onTap: onTap ?? () {},
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      trailing: Icon(Icons.chevron_right_rounded, color: AppTheme.white38, size: 20),
    );
  }
}

class _LangTile extends StatelessWidget {
  final String title;
  final String code;
  final bool isSelected;
  final VoidCallback onTap;

  const _LangTile({required this.title, required this.code, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: AppTheme.bodyStyle.copyWith(
        color: isSelected ? AppTheme.accentIndigo : AppTheme.white,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      )),
      trailing: isSelected ? const Icon(Icons.check_rounded, color: AppTheme.accentIndigo) : null,
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
