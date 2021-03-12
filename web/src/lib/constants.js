const SCHEME = 'http';
const PORT = 8888;
const HOST = 'localhost';

const GRPC_DEFAULT_PORT = 8080;
const GRPC_DEFAULT_HOST = '172.16.30.63';

export class BaseUrl {
  static SYSTEM = `${SCHEME}://${HOST}:${PORT}`;
  static GRPC_CORE = `${SCHEME}://${GRPC_DEFAULT_HOST}:${GRPC_DEFAULT_PORT}`;
  static CONTROL = `http://172.16.50.253`;
}

export class App {
  static NAME = 'SKYHUB';
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
  static REFRESH_QR_CODE_TIMEOUT = 1000*60*5;
  static POWERED_BY = 'Suntech';
}


export class Session {
  static SCREEN_LOCK_MINUTE = 10;
  static EXP_MINUTE = 600000;
  static CHECK_TIME = 1000; // ms
  static DELAY_TIME = 10; // ms
}
