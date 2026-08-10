class AppConstants {
  const AppConstants._();

  static const appName = 'Hera';
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8080');
  static const secureStorageDataSource = 'secure_storage_service';
  static const onboardingCompletedKey = 'onboarding_completed';
  static const sqlCipherKey = 'sqlcipher_db_key';
  static const syncEncryptionKey = 'sync_encryption_key';
  static const syncMasterKey = 'sync_master_key';
  static const syncWrappingKey = 'sync_wrapping_key';
  static const syncWrappedMasterKey = 'sync_wrapped_master_key';
  static const privacyModeKey = 'privacy_mode';
  static const themeStyleKey = 'theme_style';
  static const pinEnabledKey = 'pin_enabled';
  static const authAccessTokenKey = 'auth_access_token';
  static const authSessionKey = 'auth_session';
  static const authDeviceIdKey = 'auth_device_id';
  static const deletedNoteTombstonesKey = 'deleted_note_tombstones';
  static const syncCursorKey = 'sync_cursor';
}
