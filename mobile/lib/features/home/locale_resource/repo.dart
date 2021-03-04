import 'dart:async';

import 'package:skyone_mobile/util/global_functions.dart';

import 'package:skyone_mobile/util/locale_resource.dart';
import 'package:skyone_mobile/pt/proto/locale_resource/locale_resource_service.pbgrpc.dart';
import 'package:skyone_mobile/grpc//helper.dart';
import 'package:skyone_mobile/grpc//service_url.dart';
import 'package:fixnum/fixnum.dart' as $fixnum;


class LocaleResourceRepo {
  static Future<bool>
      findLocaleResource(int companyId, String locale) async {
    final channel = createChannel(ServiceURL.core);
    final client = LocaleResourceServiceClient(channel);
    final request = FindLocaleResourceRequest()
      ..companyId = companyId != null? $fixnum.Int64(companyId) : $fixnum.Int64()
      ..locale = locale;
    try {
      final data = (await unAuthCall(client.findHandler, request)).data;
        final map = <String, String>{};
        data.forEach((LocaleResourceResponseItem e) {
          map['${e.category}.${e.typeGroup}.${e.key}'] = e.value;
        });
        if (LR.localeResources == null) {
          LR.localeResources = map;
        } else {
          LR.localeResources.addAll(map);
        }

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
