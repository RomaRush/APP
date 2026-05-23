import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/user_provider.dart';
import '../../core/models/friend.dart';
import '../../core/services/online_friends_service.dart';
import 'friend_profile_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoadingGlobalProfile = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Код скопирован в буфер обмена!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showAddFriendDialog(BuildContext context) {
    final codeController = TextEditingController();
    final nameController = TextEditingController();
    final nicknameController = TextEditingController();
    final bioController = TextEditingController();

    bool isOnlineMode = true;
    bool isLoading = false;
    String? errorMessage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF13131F),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Добавить друга', style: AppTheme.headlineStyle.copyWith(fontSize: 22)),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => setState(() => isOnlineMode = true),
                          child: Text(
                            'По коду',
                            style: TextStyle(
                              color: isOnlineMode ? AppTheme.accentGreen : AppTheme.white38,
                              fontWeight: isOnlineMode ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => setState(() => isOnlineMode = false),
                          child: Text(
                            'Вручную',
                            style: TextStyle(
                              color: !isOnlineMode ? AppTheme.accentGreen : AppTheme.white38,
                              fontWeight: !isOnlineMode ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (isOnlineMode) ...[
                  TextField(
                    controller: codeController,
                    style: const TextStyle(color: Colors.white),
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: 'Введите код друга (например, DL-XXXXXX)',
                      labelStyle: const TextStyle(color: AppTheme.white38),
                      filled: true,
                      fillColor: AppTheme.white05,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(errorMessage!, style: const TextStyle(color: AppTheme.errorRed, fontSize: 13)),
                  ],
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                              final code = codeController.text.trim().toUpperCase();
                              if (code.isEmpty) return;

                              setState(() {
                                isLoading = true;
                                errorMessage = null;
                              });

                              try {
                                final friend = await context.read<UserProvider>().searchAndAddFriendOnline(code);
                                if (friend != null) {
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Друг ${friend.name} успешно добавлен!'),
                                      backgroundColor: AppTheme.accentGreen,
                                    ),
                                  );
                                } else {
                                  setState(() {
                                    errorMessage = 'Пользователь с таким кодом не найден';
                                    isLoading = false;
                                  });
                                }
                              } catch (e) {
                                setState(() {
                                  errorMessage = e.toString().replaceAll('Exception: ', '');
                                  isLoading = false;
                                });
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.black)
                          : const Text('Найти и добавить', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                    ),
                  ),
                ] else ...[
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Имя',
                      labelStyle: const TextStyle(color: AppTheme.white38),
                      filled: true,
                      fillColor: AppTheme.white05,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nicknameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Никнейм (без @)',
                      labelStyle: const TextStyle(color: AppTheme.white38),
                      filled: true,
                      fillColor: AppTheme.white05,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: bioController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'О себе / Статус',
                      labelStyle: const TextStyle(color: AppTheme.white38),
                      filled: true,
                      fillColor: AppTheme.white05,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        final name = nameController.text.trim();
                        final nickname = nicknameController.text.trim();
                        final bio = bioController.text.trim();

                        if (name.isNotEmpty && nickname.isNotEmpty) {
                          final newFriend = Friend(
                            id: 'MANUAL_${DateTime.now().millisecondsSinceEpoch}',
                            name: name,
                            nickname: '@${nickname.toLowerCase()}',
                            bio: bio.isNotEmpty ? bio : 'Пользователь DAYLO',
                            points: 100 + (DateTime.now().millisecond % 200),
                            level: 1 + (DateTime.now().millisecond % 3),
                            mockStories: const [],
                            mockAchievements: const ['first_task'],
                          );
                          context.read<UserProvider>().addFriend(newFriend);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Друг $name успешно добавлен!'),
                              backgroundColor: AppTheme.accentGreen,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Сохранить', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMyQRCodeDialog(BuildContext context, UserProvider user) {
    final qrPayload = user.myFriendCode;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF13131F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Center(
          child: Text(
            'Мой QR-код',
            style: AppTheme.titleStyle.copyWith(fontSize: 20),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Дайте другу отсканировать этот код, чтобы добавиться в DAYLO',
              textAlign: TextAlign.center,
              style: AppTheme.bodyStyle.copyWith(color: AppTheme.white70, fontSize: 13),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: QrImageView(
                data: qrPayload,
                version: QrVersions.auto,
                size: 200.0,
                gapless: false,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              user.name,
              style: AppTheme.titleStyle.copyWith(fontSize: 18),
            ),
            Text(
              'Код: ${user.myFriendCode}',
              style: AppTheme.captionStyle.copyWith(color: AppTheme.accentGreen, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Закрыть', style: TextStyle(color: AppTheme.accentGreen, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _scanQRCode(BuildContext context) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QRScannerScreen()),
    );

    if (result != null && context.mounted) {
      try {
        final friend = await context.read<UserProvider>().searchAndAddFriendOnline(result);
        if (friend != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Друг ${friend.name} успешно добавлен!'),
              backgroundColor: AppTheme.accentGreen,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Не удалось найти пользователя'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  Widget _buildMyFriendsTab(UserProvider userProvider, List<Friend> friends) {
    return Column(
      children: [
        // Display personal Friend Code
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: GestureDetector(
            onTap: () => _copyToClipboard(userProvider.myFriendCode),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.white05,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.white12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.copy_rounded, size: 18, color: AppTheme.accentGreen),
                      const SizedBox(width: 12),
                      Text(
                        'Мой код друга:',
                        style: AppTheme.bodyStyle.copyWith(color: AppTheme.white70, fontSize: 14),
                      ),
                    ],
                  ),
                  Text(
                    userProvider.myFriendCode,
                    style: AppTheme.titleStyle.copyWith(
                      color: AppTheme.accentGreen,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Поиск друзей...',
              hintStyle: const TextStyle(color: AppTheme.white38),
              prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.white38),
              filled: true,
              fillColor: AppTheme.white05,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
          ),
        ),
        Expanded(
          child: friends.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _searchQuery.isEmpty
                            ? Icons.people_outline_rounded
                            : Icons.search_off_rounded,
                        size: 64,
                        color: AppTheme.white38,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty
                            ? 'У вас пока нет друзей'
                            : 'Ничего не найдено',
                        style: AppTheme.headlineStyle.copyWith(
                          color: AppTheme.white38,
                          fontSize: 16,
                        ),
                      ),
                      if (_searchQuery.isEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Добавьте друга вручную или по QR-коду!',
                          style: AppTheme.bodyStyle.copyWith(
                            color: AppTheme.white38,
                            fontSize: 12,
                          ),
                        ),
                      ]
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: friends.length,
                  itemBuilder: (context, index) {
                    final friend = friends[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF13131F),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.white05),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: AppTheme.accentGreen.withOpacity(0.1),
                          child: Text(
                            friend.name.isNotEmpty ? friend.name[0].toUpperCase() : '?',
                            style: const TextStyle(
                              color: AppTheme.accentGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        title: Text(
                          friend.name,
                          style: AppTheme.titleStyle.copyWith(fontSize: 16),
                        ),
                        subtitle: Text(
                          friend.nickname,
                          style: AppTheme.captionStyle.copyWith(color: AppTheme.white38),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.accentGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Lvl ${friend.level}',
                                style: const TextStyle(
                                  color: AppTheme.accentGreen,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.errorRed, size: 20),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    backgroundColor: const Color(0xFF13131F),
                                    title: const Text('Удалить друга?', style: TextStyle(color: Colors.white)),
                                    content: Text('Вы действительно хотите удалить ${friend.name} из друзей?', style: const TextStyle(color: AppTheme.white70)),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text('Отмена', style: TextStyle(color: Colors.white38)),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          userProvider.removeFriend(friend.id);
                                          Navigator.pop(ctx);
                                        },
                                        child: const Text('Удалить', style: TextStyle(color: AppTheme.errorRed)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FriendProfileScreen(friend: friend),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildGlobalTab(UserProvider userProvider) {
    return FutureBuilder<List<Friend>>(
      future: OnlineFriendsService.fetchGlobalDirectory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.accentGreen));
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Ошибка загрузки: ${snapshot.error}',
              style: const TextStyle(color: AppTheme.errorRed),
            ),
          );
        }
        final globalUsers = snapshot.data ?? [];
        final filteredUsers = globalUsers.where((u) => u.id != userProvider.myFriendCode).toList();

        if (filteredUsers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.public_off_rounded, size: 64, color: AppTheme.white38),
                const SizedBox(height: 16),
                Text(
                  'Глобальный список пуст',
                  style: AppTheme.headlineStyle.copyWith(color: AppTheme.white38, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: AppTheme.accentGreen,
          onRefresh: () async {
            setState(() {});
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              final globalUser = filteredUsers[index];
              final isFriend = userProvider.friends.any((f) => f.id == globalUser.id);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF13131F),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.white05),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: AppTheme.accentGreen.withOpacity(0.1),
                    child: Text(
                      globalUser.name.isNotEmpty ? globalUser.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: AppTheme.accentGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  title: Text(globalUser.name, style: AppTheme.titleStyle.copyWith(fontSize: 16)),
                  subtitle: Text(globalUser.nickname, style: AppTheme.captionStyle.copyWith(color: AppTheme.white38)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Lvl ${globalUser.level}',
                          style: const TextStyle(color: AppTheme.accentGreen, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isFriend)
                        const Icon(Icons.check_circle_rounded, color: AppTheme.accentGreen, size: 24)
                      else
                        IconButton(
                          icon: const Icon(Icons.person_add_rounded, color: AppTheme.accentGreen),
                          onPressed: () async {
                            try {
                              final added = await userProvider.searchAndAddFriendOnline(globalUser.id);
                              if (added != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Друг ${globalUser.name} добавлен!'),
                                    backgroundColor: AppTheme.accentGreen,
                                  ),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(e.toString().replaceAll('Exception: ', '')),
                                  backgroundColor: AppTheme.errorRed,
                                ),
                              );
                            }
                          },
                        ),
                    ],
                  ),
                  onTap: () async {
                    setState(() {
                      _isLoadingGlobalProfile = true;
                    });
                    try {
                      final fullFriend = await OnlineFriendsService.lookupProfile(globalUser.id);
                      if (mounted) {
                        setState(() {
                          _isLoadingGlobalProfile = false;
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FriendProfileScreen(friend: fullFriend ?? globalUser),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        setState(() {
                          _isLoadingGlobalProfile = false;
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FriendProfileScreen(friend: globalUser),
                          ),
                        );
                      }
                    }
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final friends = userProvider.friends.where((f) {
      final query = _searchQuery.toLowerCase();
      return f.name.toLowerCase().contains(query) ||
          f.nickname.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF080810),
      appBar: AppBar(
        title: const Text('Друзья', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accentGreen,
          labelColor: AppTheme.accentGreen,
          unselectedLabelColor: AppTheme.white38,
          tabs: const [
            Tab(text: 'Мои друзья'),
            Tab(text: 'Глобальные'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_2_rounded, color: AppTheme.white70),
            onPressed: () => _showMyQRCodeDialog(context, userProvider),
            tooltip: 'Мой QR-код',
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded, color: AppTheme.white70),
            onPressed: () => _scanQRCode(context),
            tooltip: 'Сканировать QR',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddFriendDialog(context),
        backgroundColor: AppTheme.accentGreen,
        child: const Icon(Icons.person_add_alt_1_rounded, color: Colors.black),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              _buildMyFriendsTab(userProvider, friends),
              _buildGlobalTab(userProvider),
            ],
          ),
          if (_isLoadingGlobalProfile)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(color: AppTheme.accentGreen),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController controller = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Сканировать QR-код'),
        backgroundColor: const Color(0xFF080810),
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final code = barcodes.first.rawValue;
                if (code != null && code.startsWith('DL-')) {
                  controller.dispose();
                  Navigator.pop(context, code);
                }
              }
            },
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.accentGreen, width: 3),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Text(
              'Наведите камеру на QR-код друга DAYLO',
              textAlign: TextAlign.center,
              style: AppTheme.bodyStyle.copyWith(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
