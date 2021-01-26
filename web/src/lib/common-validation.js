import { StringUtil } from 'src/lib/string-util';

export class CommonValidation {
  static DEADLINE_MUST_AFTER_START_TIME = 'TASK.MSG.DEADLINE_MUST_AFTER_START_TIME';
  static END_TIME_MUST_AFTER_START_TIME = 'TASK.MSG.END_TIME_MUST_AFTER_START_TIME';
  static SECOND_REMINDER_MUST_AFTER_THE_FIRST = 'TASK.MSG.SECOND_REMINDER_MUST_AFTER_THE_FIRST';
  static EVALUATE_TIME_MUST_AFTER_ASSIGNEE_START_TIME = 'TASK.MSG.EVALUATE_TIME_MUST_AFTER_ASSIGNEE_START_TIME';
  static PASSWORD_DOES_NOT_MATCH = 'SYS.MSG.PASSWORD_DOES_NOT_MATCH';
  static NEW_PASSWORD_MUST_BE_NOT_THE_SAME_THE_CURRENT = 'SYS.MSG.NEW_PASSWORD_MUST_BE_NOT_THE_SAME_THE_CURRENT';

  static REQUIRED_VALUE = 'SYS.MSG.REQUIRED_VALUE';
  static SELECT_AT_LEAST_ONE_LEAF_NODE = 'SYS.MSG.PLEASE_SELECT_AT_LEAST_ONE_LEAF_NODE';
  static SELECT_AT_LEAST_ONE_NODE = 'SYS.MSG.PLEASE_SELECT_ONE_NODE';
  static isEmptyString(source) {
    if (!source) {
      return true;
    }

    return source.trim().length === 0;
  }

  static MIN_LENGTH = 'SYS.MSG.VALUE_MUST_BE_AT_LEAST_%min%_CHARS';
  static isMinLength(source, min) {
    if (!source) {
      return false;
    }

    return source.trim().length >= min;
  }

  static LENGTH_BETWEEN = 'SYS.MSG.VALUE_MUST_BE_BETWEEN_%min_AND_%max_CHARS';
  static isLengthBetween(source, min, max) {
    if (!source && min === 0) {
      return true;
    }
    return source.trim().length >= min && source.trim().length <= max;
  }

  static INTEGER_NUMBER = 'SYS.MSG.REQUIRED_INTEGER_NUMBER';
  static isIntegerNumber(source) {
    const reg = new RegExp(/^[-+]?[0-9]\d*$/);
    return reg.test(source);
  }

  static INTEGER_NUMBER_IN_RANGE = 'SYS.MSG.INTEGER_NUMBER_IN_RANGE';
  static isIntegerInRange(source, from, to) {
    const reg = new RegExp(/^\d+$/);
    const isNumber = reg.test(source);

    if (!isNumber) {
      return false;
    }

    const number = Number(source);
    return number >= from && number <= to;
  }

  static INVALID_EMAIL = 'SYS.MSG.INVALID_EMAIL';
  static isValidEmail(email) {
    if (StringUtil.isEmpty(email)) {
      return true;
    }
    const reg = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    return reg.test(String(email).toLowerCase());
  }
}
