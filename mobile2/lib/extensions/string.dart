import 'package:flutter/foundation.dart';
import 'package:recase/recase.dart';
import 'package:skyone/global/variable.dart';

extension Trans on String {
  String get t  {
    String alternativeKey;

    final split = this.split(".");
    if (kReleaseMode) {
      alternativeKey = split[split.length - 1].titleCase;
    } else {
      alternativeKey = '#${split[split.length - 1].titleCase}';
    }
    if (localeResources == null) {
      return alternativeKey;
    }

    return localeResources[this] ?? alternativeKey;
  }
}