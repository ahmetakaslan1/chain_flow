import 'package:flutter/widgets.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const _localizedStrings = {
    'en': {
      'app_title': 'ChainFlow Local',
      'greeting': 'Hello!',
      'home_title': "Don't Break the Chain",
      'search_hint': 'Search projects...',
      'no_projects_title': 'No projects yet',
      'no_projects_message': 'Add a project now and keep the chain strong.',
      'new_project': 'New Project',
      'home_tab': 'Home',
      'stats_tab': 'Statistics',
      'settings_tab': 'Settings',
      'completed_tab': 'Completed',
      'projects_title': 'Projects',
      'projects_count': 'Projects ({count})',
      'project_status_completed': 'Completed',
      'project_status_active': 'In Progress',
      'total_days': 'Total Days Tracked',
      'days_completed': 'Days Completed',
      'progress_overview': 'Progress Overview',
      'empty_completed': 'No completed projects yet.',
      'undo_completion': 'Undo Completion',
      'completion_date': 'Completion Date',
      'statistics': 'Statistics',
      'start_date': 'Start Date',
      'days_worked': 'Days Worked',
      'days_missed': 'Days Missed',
      'success_rate': 'Success Rate',
      'settings': 'Settings',
      'dark_mode': 'Dark Mode',
      'notification_time': 'Notification Time',
      'chain_analysis_threshold': 'Chain Analysis Threshold',
      'warn_after': 'Warn after {days} consecutive missed days',
      'export_data': 'Export Data (JSON)',
      'import_data': 'Import Data (JSON)',
      'language': 'Language',
      'turkish': 'Turkish',
      'english': 'English',
      'add_project': 'Add New Project',
      'project_name': 'Project Name',
      'start_date_label': 'Start Date',
      'select_date': 'Select Date',
      'save': 'Save',
      'cancel': 'Cancel',
      'project_saved': 'Project saved.',
      'project_deleted': 'Project deleted.',
      'project_updated': 'Project name updated.',
      'complete_project': 'Complete Project',
      'revert_project': 'Revert Project',
      'complete_project_message': 'Are you sure you want to complete this project?',
      'revert_project_message': 'Are you sure you want to revert this project?',
      'project_completed': 'Project marked as completed!',
      'project_reverted': 'Project reverted to active!',
      'edit_project': 'Edit Project',
      'delete_project': 'Delete Project',
      'delete_project_message': 'Are you sure you want to delete "{name}"?',
      'chain_broken_title': 'Chain broken alert for {name}!',
      'chain_broken_body': 'You have missed {days} consecutive days. Do you want to add a note?',
      'notification_time_saved': 'Notification time updated.',
      'export_success': 'Data exported to:\n{path}',
      'import_success': 'Data imported successfully.',
      'import_cancelled': 'Import cancelled.',
      'error_export': 'Error exporting data: {error}',
      'error_import': 'Error importing data: {error}',
    },
    'tr': {
      'app_title': 'ChainFlow Local',
      'greeting': 'Merhaba!',
      'home_title': 'Zinciri Kırma',
      'search_hint': 'Projelerde ara...',
      'no_projects_title': 'Henüz proje yok',
      'no_projects_message': 'Hemen bir proje ekle ve zinciri güçlü tut.',
      'new_project': 'Yeni Proje',
      'home_tab': 'Ana Sayfa',
      'stats_tab': 'İstatistikler',
      'settings_tab': 'Ayarlar',
      'completed_tab': 'Biten Projeler',
      'projects_title': 'Projeler',
      'projects_count': 'Projeler ({count})',
      'project_status_completed': 'Tamamlandı',
      'project_status_active': 'Devam Ediyor',
      'total_days': 'Takip Edilen Gün Sayısı',
      'days_completed': 'Yapılan Gün Sayısı',
      'progress_overview': 'İlerleme Görünümü',
      'empty_completed': 'Henüz tamamlanmış proje yok.',
      'undo_completion': 'Geri Al',
      'completion_date': 'Tamamlanma Tarihi',
      'statistics': 'İstatistikler',
      'start_date': 'Başlangıç Tarihi',
      'days_worked': 'Çalışılan Gün',
      'days_missed': 'Boş Gün',
      'success_rate': 'Başarı Oranı',
      'settings': 'Ayarlar',
      'dark_mode': 'Karanlık Mod',
      'notification_time': 'Bildirim Saati',
      'chain_analysis_threshold': 'Zincir Analizi Eşiği',
      'warn_after': '{days} gün üst üste boş geçildiğinde uyar',
      'export_data': 'Verileri Dışa Aktar (JSON)',
      'import_data': 'Verileri İçe Aktar (JSON)',
      'language': 'Dil',
      'turkish': 'Türkçe',
      'english': 'İngilizce',
      'add_project': 'Yeni Proje Ekle',
      'project_name': 'Proje Adı',
      'start_date_label': 'Başlangıç Tarihi',
      'select_date': 'Tarih Seç',
      'save': 'Kaydet',
      'cancel': 'Vazgeç',
      'project_saved': 'Proje kaydedildi.',
      'project_deleted': 'Proje silindi.',
      'project_updated': 'Proje adı güncellendi.',
      'complete_project': 'Projeyi Tamamla',
      'revert_project': 'Projeyi Geri Al',
      'complete_project_message': 'Bu projeyi tamamlamak istediğinizden emin misiniz?',
      'revert_project_message': 'Bu projeyi geri almak istediğinizden emin misiniz?',
      'project_completed': 'Proje tamamlandı!',
      'project_reverted': 'Proje tekrar aktifleştirildi!',
      'edit_project': 'Projeyi Düzenle',
      'delete_project': 'Projeyi Sil',
      'delete_project_message': '"{name}" adlı projeyi silmek istediğinizden emin misiniz?',
      'chain_broken_title': '{name} için zincir bozuldu!',
      'chain_broken_body': '{days} gündür ara verdin. Not eklemek ister misin?',
      'notification_time_saved': 'Bildirim saati güncellendi.',
      'export_success': 'Veriler buraya aktarıldı:\n{path}',
      'import_success': 'Veriler içe aktarıldı.',
      'import_cancelled': 'İçe aktarma iptal edildi.',
      'error_export': 'Veriler aktarılırken hata: {error}',
      'error_import': 'Veriler içe aktarılırken hata: {error}',
    },
  };

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  String translate(String key, {Map<String, String>? params}) {
    final languageCode = locale.languageCode;
    final values = _localizedStrings[languageCode] ?? _localizedStrings['en']!;
    String value = values[key] ?? key;
    if (params != null) {
      params.forEach((paramKey, paramValue) {
        value = value.replaceAll('{$paramKey}', paramValue);
      });
    }
    return value;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'tr'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this);
}
