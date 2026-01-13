type SecureFeature = 'announcements' | 'sync';

export type SecurePathEnvNames = {
  enabledEnv: string;
  usersEnv: string;
  devicesEnv: string;
  minVersionEnv?: string;
  feature: SecureFeature;
};

export const getSecurePathEnv = (feature: SecureFeature): SecurePathEnvNames => {
  return {
    enabledEnv: 'SECURE_PATH_ENABLED',
    usersEnv: 'SECURE_PATH_TEST_USERS',
    devicesEnv: 'SECURE_PATH_TEST_DEVICES',
    minVersionEnv: 'SECURE_PATH_MIN_APP_VERSION',
    feature,
  };
};
