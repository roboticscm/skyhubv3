import 'package:flutter/foundation.dart';
import 'package:skyone_mobile/util/locale_resource.dart';
import 'package:skyone_mobile/util/string_util.dart';

extension Trans on String {
  String t() {
    String alternativeKey;

    final split = this.split(".");
    if (kReleaseMode) {
      alternativeKey = StringUtil.toWordCase(split[split.length - 1]);
    } else {
      alternativeKey = '#${StringUtil.toWordCase(split[split.length - 1])}';
    }
    if (LR.localeResources == null) {
      return alternativeKey;
    }

    return LR.localeResources[this] ?? alternativeKey;
  }

  String toWordCase() {
    final buffer = StringBuffer();

    final chars = split("");

    for(var i = 0; i < chars.length; i++) {
      if(chars[i] == chars[i].toUpperCase()) {
        buffer.write(' ${chars[i].toLowerCase()}');
      } else if ( i == 0) {
        buffer.write(chars[i].toUpperCase());
      } else {
        buffer.write(chars[i]);
      }
    }

    return buffer.toString();
  }
}
