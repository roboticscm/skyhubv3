import 'package:flutter/material.dart';
import 'package:skyone/global/function.dart';
import 'package:skyone/global/variable.dart';
import 'package:skyone/pt/proto/locale_resource/locale_resource_service.pbgrpc.dart';
import 'package:skyone/system/grpc/helper.dart';
import 'package:skyone/system/grpc/service_url.dart';
import 'package:fixnum/fixnum.dart';

class TheAppService {
  Future<void> findLocaleResource ({@required String locale, int companyId}) async {
    final channel = createChannel(ServiceURL.core);
    final client = LocaleResourceServiceClient(channel);
    final request = FindLocaleResourceRequest()
      ..companyId = companyId != null? Int64(companyId) : Int64()
      ..locale = locale;
    try {
      final data = (await unAuthCall(client.findHandler, request)).data;
      final map = <String, String>{};
      data.forEach((LocaleResourceResponseItem e) {
        map['${e.category}.${e.typeGroup}.${e.key}'] = e.value;
      });
      if (localeResources == null) {
        localeResources = map;
      } else {
        localeResources.addAll(map);
      }
    } catch (e) {
      log(e);
      localeResources = null;
      rethrow;
    } finally {
      channel.shutdown();
    }
  }
}