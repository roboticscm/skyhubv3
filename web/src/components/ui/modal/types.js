import { App } from 'src/lib/constants';

export class ModalType {
  static alert = 'alert';
  static confirm = 'confirm';
  static confirmPassword = 'confirmPassword';
  static inputText = 'inputText';
  static inputNumber = 'inputNumber';
  static custom = 'custom';
}

export class ModalId {
  static alert = 'mdalert';
  static confirm = 'mdConfirm';
  static confirmPassword = 'mdConfirmPasword';
  static inputText = 'mdInputText';
  static inputNumber = 'mdInputNumber';
}

export class SkyLogFilter {
  constructor() {
    this.startDate = Date.now() - App.DEFAULT_END_TIME_FILTER_OFFSET;
    this.endDate = Date.now();
    this.filter = '';
  }
}
