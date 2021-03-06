class ErrorMessage {
  static const DEADLINE_MUST_AFTER_START_TIME = 'TASK.MSG.DEADLINE_MUST_AFTER_START_TIME';
  static const  END_TIME_MUST_AFTER_START_TIME = 'TASK.MSG.END_TIME_MUST_AFTER_START_TIME';
  static const  SECOND_REMINDER_MUST_AFTER_THE_FIRST = 'TASK.MSG.SECOND_REMINDER_MUST_AFTER_THE_FIRST';
  static const  EVALUATE_TIME_MUST_AFTER_ASSIGNEE_START_TIME = 'TASK.MSG.EVALUATE_TIME_MUST_AFTER_ASSIGNEE_START_TIME';
  static const  PASSWORD_DOES_NOT_MATCH = 'SYS.MSG.PASSWORD_DOES_NOT_MATCH';
  static const  NEW_PASSWORD_MUST_BE_NOT_THE_SAME_THE_CURRENT = 'SYS.MSG.NEW_PASSWORD_MUST_BE_NOT_THE_SAME_THE_CURRENT';

  static const  REQUIRED_VALUE = 'SYS.MSG.REQUIRED_VALUE';
  static const  SELECT_AT_LEAST_ONE_LEAF_NODE = 'SYS.MSG.PLEASE_SELECT_AT_LEAST_ONE_LEAF_NODE';
  static const  SELECT_AT_LEAST_ONE_NODE = 'SYS.MSG.PLEASE_SELECT_ONE_NODE';
}

class GrpcErrorMessage {
  final String field;
  final String message;

  const GrpcErrorMessage({this.field, this.message});

  factory GrpcErrorMessage.fromJson(Map<String, dynamic> json) {
    return GrpcErrorMessage(
      field: json["field"] as String,
      message: json["message"] as String,
    );
  }
}