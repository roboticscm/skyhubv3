export class NotifyType {
  static chat = 'CHAT';
  static functional = 'FUNCTIONAL';
  static alarm = 'ALARM';
}

export class MessageType {
  static submit = 'SUBMIT';
  static assign = 'ASSIGN';
  static hold = 'HOLD';
  static update = 'UPDATE';
  static complete = 'COMPLETE';
}

export class NotificationStore {
  static findNotifications(type, value) {}
}
