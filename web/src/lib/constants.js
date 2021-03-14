export class App {
  static DEFAULT_ICON = `<i class="fa fa-bars"></i>`;
  static SNACKBAR_TIMEOUT = 2000;
  static MAX_HEADER_HEIGHT = 100;
  static MIN_HEADER_HEIGHT = 30;
  static MIN_PASSWORD_LENGTH = 4;
  static GUTTER_WIDTH = 5;
  static AUTO_COMPLETE = 'off';
  static DEFAULT_PAGE_SIZE = 20;
  static PROGRESS_BAR = '<i class="fa fa-spinner fa-spin" />';
  static DEFAULT_END_TIME_FILTER_OFFSET = 30 * 24 * 60 * 60 * 1000;
  static SAVE_USER_SETTINGS = true;
  static REFRESH_QR_CODE_TIMEOUT = 1000 * 60 * 5;
  static MAX_AVATAR_SIZE = 1024 * 1024;
  static SIZE_DETAIL = App.MAX_AVATAR_SIZE / (1024 * 1024) >= 1 ? `${App.MAX_AVATAR_SIZE / (1024 * 1024)}MB` : `${App.MAX_AVATAR_SIZE / (1024)}KB`
}

export class Session {
  static SCREEN_LOCK_MINUTE = 10;
  static EXP_MINUTE = 60;
  static CHECK_TIME = 1000 * 60; // ms
  static DELAY_TIME = 50; // ms
}
