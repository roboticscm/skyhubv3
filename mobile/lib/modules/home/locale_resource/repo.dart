import 'dart:async';

import 'package:skyone_mobile/util/global_functions.dart';

import 'package:skyone_mobile/util/locale_resource.dart';
import 'package:skyone_mobile/pt/proto/locale_resource/locale_resource_service.pbgrpc.dart';
import 'package:skyone_mobile/grpc//helper.dart';
import 'package:skyone_mobile/grpc//service_url.dart';
import 'package:fixnum/fixnum.dart' as $fixnum;

class LocaleResourceRepo {
  static Future<bool>
      findLocaleResource($fixnum.Int64 companyId, String locale) async {
    final channel = createChannel(ServiceURL.core);
    final client = LocaleResourceServiceClient(channel);
    final request = FindLocaleResourceRequest()
      ..companyId = companyId
      ..locale = locale;
    try {
      final data = (await unAuthCall(client.findHandler, request)).data;
        final map = <String, String>{};
        data.forEach((LocaleResourceResponseItem e) {
          map['${e.category}.${e.typeGroup}.${e.key}'] = e.value;
          print('${e.category}.${e.typeGroup}.${e.key}');
          print(e.value);
          print('\n');
        });
        LR.localeResources = map;

        return true;

    } catch (e) {
      log(e);
      LR.localeResources = null;
    } finally {
      channel.shutdown();
    }
    return false;
  }
}
