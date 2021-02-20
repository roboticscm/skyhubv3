class FormItem {
  String error;

  FormItem({this.error});
}

class FormItemString extends FormItem {
  String value;
  FormItemString({String error, this.value}) : super (error: error);
}

class FormItemInt extends FormItem {
  int value;

  FormItemInt({String error, this.value}) : super (error: error);
}

class FormItemDouble extends FormItem {
  double value;

  FormItemDouble({String error, this.value}) : super (error: error);
}