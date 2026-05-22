import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ?? AppLocalizations(const Locale('ru'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'home_title': 'Home',
      'profile_title': 'Profile',
      'settings_theme': 'Change App Theme',
      'settings_icon': 'Change App Icon',
      'settings_notifications': 'Notifications',
      'settings_rate': 'Rate App',
      'settings_contact': 'Contact Manager',
      'settings_language': 'Language',
      'settings_logout': 'Log Out',
      'story_days': 'StoryDays',
      'friends': 'Friends',
      'achievements': 'Achievements',
      'edit_profile': 'Edit Profile',
      'save': 'Save',
      'cancel': 'Cancel',
      'name': 'Name',
      'description': 'Description',
      'expand': 'expand',
      'no_stories': 'No stories yet',
      'notification_test_title': 'Test Notification',
      'notification_test_body': 'Notifications are working correctly! 🚀',
    },
    'ru': {
      'home_title': 'Главная',
      'profile_title': 'Профиль',
      'settings_theme': 'Сменить тему приложения',
      'settings_icon': 'Смену иконки приложения',
      'settings_notifications': 'Уведомления',
      'settings_rate': 'Оценить',
      'settings_contact': 'Контакты с менеджером',
      'settings_language': 'Язык',
      'settings_logout': 'Выход из аккаунта',
      'story_days': 'Сторидей',
      'friends': 'Друзей',
      'achievements': 'Достижений',
      'edit_profile': 'Редактировать профиль',
      'save': 'Сохранить',
      'cancel': 'Отмена',
      'name': 'Имя',
      'description': 'Описание',
      'expand': 'развернуть',
      'no_stories': 'Пока нет историй',
      'notification_test_title': 'Тестовое уведомление',
      'notification_test_body': 'Уведомления работают корректно! 🚀',
    },
    'zh': {
      'home_title': '主页',
      'profile_title': '个人资料',
      'settings_theme': '更改应用主题',
      'settings_icon': '更改应用图标',
      'settings_notifications': '通知',
      'settings_rate': '评价应用',
      'settings_contact': '联系经理',
      'settings_language': '语言',
      'settings_logout': '登出',
      'story_days': '故事日',
      'friends': '朋友',
      'achievements': '成就',
      'edit_profile': '编辑个人资料',
      'save': '保存',
      'cancel': '取消',
      'name': '名字',
      'description': '描述',
      'expand': '展开',
      'no_stories': '还没有故事',
      'notification_test_title': '测试通知',
      'notification_test_body': '通知工作正常！🚀',
    },
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ru', 'zh'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
