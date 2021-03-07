class FormItem {
  String error;

  FormItem({this.error});
}

class StrFormItem extends FormItem {
  String value;
  StrFormItem({String error, this.value}) : super (error: error);
}

class IntFormItem extends FormItem {
  int value;

  IntFormItem({String error, this.value}) : super (error: error);
}

class DoubleFormItem extends FormItem {
  double value;

  DoubleFormItem({String error, this.value}) : super (error: error);
}

class BoolFormItem extends FormItem {
  bool value;

  BoolFormItem({String error, this.value}) : super (error: error);
}